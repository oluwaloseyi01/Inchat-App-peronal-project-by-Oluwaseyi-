import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:inchat/databases/config/appwrite.dart';
import 'package:inchat/model/chatmodel.dart';

class ActiveChatProvider extends ChangeNotifier {
  String? myUserId;
  bool loading = false;

  List<ChatMessage> allChats = [];
  List<ChatMessage> latestChats = [];
  List<ChatMessage> filteredChats = [];
  Map<String, int> unreadCounts = {};

  StreamSubscription<RealtimeMessage>? _sub;

  void setMyUserId(String id) {
    myUserId = id;
    _initRealtime();
  }

  Future<String?> _getUserProfilePicture(String userId) async {
    try {
      final res = await AppwriteConfig.tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.userCollection,
        queries: [Query.equal("userId", userId), Query.limit(1)],
      );

      if (res.rows.isNotEmpty) {
        final fileId = res.rows.first.data["profilePicture"];
        if (fileId != null && fileId.isNotEmpty) {
          return AppwriteConfig.getFileUrl(fileId: fileId);
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile picture: $e");
    }
    return null;
  }

  Future<void> fetchActiveChats() async {
    if (myUserId == null) return;
    loading = true;
    notifyListeners();

    try {
      final result = await AppwriteConfig.tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.chat,
        queries: [
          Query.or([
            Query.equal("senderId", myUserId),
            Query.equal("receiverId", myUserId),
          ]),
          Query.orderDesc("\$createdAt"),
        ],
      );

      allChats = await Future.wait(
        result.rows.map((row) async {
          final data = row.data;
          final friendId = data["senderId"] == myUserId
              ? data["receiverId"]
              : data["senderId"];

          final profilePic = await _getUserProfilePicture(friendId);

          final timestamp =
              DateTime.tryParse(row.$createdAt)?.millisecondsSinceEpoch ??
              DateTime.now().millisecondsSinceEpoch;

          return ChatMessage(
            rowId: row.$id,
            senderId: data["senderId"] ?? "",
            receiverId: data["receiverId"] ?? "",
            senderFullName: data["senderFullName"] ?? "",
            receiverFullName: data["receiverFullName"] ?? "",
            message: data["message"] ?? "",
            type: data["type"] ?? "text",
            fileId: data["fileId"],
            timestamp: timestamp,
            status: data["status"] ?? "sent",
            receiverProfilePicture: profilePic,
          );
        }).toList(),
      );

      _computeLatestChats();
      _computeUnreadCounts();
    } catch (e) {
      debugPrint("Error fetching chats: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void _initRealtime() {
    if (myUserId == null) return;

    _sub?.cancel();

    final realtime = Realtime(AppwriteConfig.client);
    final channel =
        "databases.${AppwriteConfig.databaseId}.collections.${AppwriteConfig.chat}.documents";

    _sub = realtime.subscribe([channel]).stream.listen((event) async {
      final data = event.payload;

      if (data["senderId"] != myUserId && data["receiverId"] != myUserId) {
        return;
      }

      final type = event.events.first;

      if (type.contains(".create")) {
        await _handleMessageCreated(data);
      } else if (type.contains(".update")) {
        await _handleMessageUpdated(data);
      } else if (type.contains(".delete")) {
        _handleMessageDeleted(data["\$id"]);
      }

      notifyListeners();
    });
  }

  Future<void> _handleMessageCreated(Map<String, dynamic> data) async {
    final friendId = data["senderId"] == myUserId
        ? data["receiverId"]
        : data["senderId"];
    final profilePic = await _getUserProfilePicture(friendId);

    final timestamp =
        DateTime.tryParse(data["\$createdAt"])?.millisecondsSinceEpoch ??
        DateTime.now().millisecondsSinceEpoch;

    final chat = ChatMessage(
      rowId: data["\$id"],
      senderId: data["senderId"],
      receiverId: data["receiverId"],
      senderFullName: data["senderFullName"] ?? "",
      receiverFullName: data["receiverFullName"] ?? "",
      message: data["message"] ?? "",
      type: data["type"] ?? "text",
      fileId: data["fileId"],
      timestamp: timestamp,
      status: data["status"] ?? "sent",
      receiverProfilePicture: profilePic,
    );

    allChats.removeWhere((c) => c.rowId == chat.rowId);
    allChats.add(chat);

    _computeLatestChats();
    _computeUnreadCounts();
  }

  Future<void> _handleMessageUpdated(Map<String, dynamic> data) async {
    final index = allChats.indexWhere((c) => c.rowId == data["\$id"]);
    if (index == -1) return;

    allChats[index] = allChats[index].copyWith(
      message: data["message"],
      status: data["status"],
      fileId: data["fileId"],
    );

    _computeLatestChats();
    _computeUnreadCounts();
  }

  void _handleMessageDeleted(String rowId) {
    allChats.removeWhere((c) => c.rowId == rowId);
    _computeLatestChats();
    _computeUnreadCounts();
  }

  void _computeLatestChats() {
    final map = <String, ChatMessage>{};

    for (var chat in allChats) {
      final friendId = chat.senderId == myUserId
          ? chat.receiverId
          : chat.senderId;

      final existing = map[friendId];
      if (existing == null || chat.timestamp > existing.timestamp) {
        map[friendId] = chat;
      }
    }

    latestChats = map.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    filteredChats = List.from(latestChats);
  }

  void _computeUnreadCounts() {
    unreadCounts = {};
    for (var chat in allChats) {
      if (chat.receiverId == myUserId && chat.status != "read") {
        unreadCounts[chat.senderId] = (unreadCounts[chat.senderId] ?? 0) + 1;
      }
    }
  }

  int getUnreadCount(String friendId) => unreadCounts[friendId] ?? 0;

  void searchChats(String query) {
    if (query.trim().isEmpty) {
      filteredChats = List.from(latestChats);
    } else {
      final q = query.toLowerCase();
      filteredChats = latestChats.where((chat) {
        final name = chat.senderId == myUserId
            ? chat.receiverFullName.toLowerCase()
            : chat.senderFullName.toLowerCase();
        return name.contains(q) || chat.message.toLowerCase().contains(q);
      }).toList();
    }
    notifyListeners();
  }

  void markAsRead(String friendId) {
    for (var i = 0; i < allChats.length; i++) {
      final chat = allChats[i];
      if (chat.senderId == friendId && chat.receiverId == myUserId) {
        allChats[i] = chat.copyWith(status: "read");
      }
    }
    _computeUnreadCounts();
    _computeLatestChats();
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
