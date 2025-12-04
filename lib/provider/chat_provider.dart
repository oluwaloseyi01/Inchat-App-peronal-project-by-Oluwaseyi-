import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:inchat/databases/config/appwrite.dart';
import 'package:inchat/model/chatmodel.dart';
import 'package:inchat/provider/securestorage.dart';
import 'package:inchat/provider/upload_provider.dart';

class ChatProvider extends ChangeNotifier {
  String? myUserId;
  String? _myName;

  bool loading = false;

  List<ChatMessage> messages = [];
  StreamSubscription<RealtimeMessage>? _sub;

  String? get myName => _myName;

  Future<void> initUser() async {
    myUserId = await SecureStorage.getUserId();
    _myName = await SecureStorage.getFullName() ?? "Unknown";

    debugPrint("ChatProvider INIT → myUserId: $myUserId, myName: $_myName");
    notifyListeners();
  }

  Future<void> fetchMessages(String friendId) async {
    if (myUserId == null) return;

    loading = true;
    notifyListeners();

    try {
      final result = await AppwriteConfig.tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.chat,
        queries: [
          Query.or([
            Query.and([
              Query.equal('senderId', myUserId),
              Query.equal('receiverId', friendId),
            ]),
            Query.and([
              Query.equal('senderId', friendId),
              Query.equal('receiverId', myUserId),
            ]),
          ]),
          Query.orderAsc('\$createdAt'),
        ],
      );

      messages = result.rows.map((row) {
        final d = row.data;
        final timestamp =
            DateTime.tryParse(row.$createdAt)?.millisecondsSinceEpoch ??
            DateTime.now().millisecondsSinceEpoch;

        return ChatMessage(
          rowId: row.$id,
          senderId: d['senderId'] ?? '',
          receiverId: d['receiverId'] ?? '',
          senderFullName: d['senderFullName'] ?? '',
          receiverFullName: d['receiverFullName'] ?? '',
          message: d['message'] ?? '',
          type: d['type'] ?? 'text',
          fileId: d['fileId'],
          timestamp: timestamp,
          status: d['status'] ?? 'sent',
        );
      }).toList();

      _listenToRealtime(friendId);
    } catch (e) {
      debugPrint("FETCH ERROR: $e");
    }

    loading = false;
    notifyListeners();
  }

  void _listenToRealtime(String friendId) {
    _sub?.cancel();

    final realtime = Realtime(AppwriteConfig.client);
    final channel =
        "databases.${AppwriteConfig.databaseId}.collections.${AppwriteConfig.chat}.documents";

    _sub = realtime.subscribe([channel]).stream.listen((event) {
      final data = event.payload;
      if (data == null) return;

      final isBetweenUsers =
          (data['senderId'] == myUserId && data['receiverId'] == friendId) ||
          (data['senderId'] == friendId && data['receiverId'] == myUserId);

      if (!isBetweenUsers) return;

      final type = event.events.first;

      if (type.contains('.create')) {
        final messageType = data['type'] ?? 'text';

        if (messageType != 'text' && messageType != 'image') return;

        final timestamp =
            DateTime.tryParse(data['\$createdAt'])?.millisecondsSinceEpoch ??
            DateTime.now().millisecondsSinceEpoch;

        final chat = ChatMessage(
          rowId: data['\$id'],
          senderId: data['senderId'],
          receiverId: data['receiverId'],
          senderFullName: data['senderFullName'] ?? '',
          receiverFullName: data['receiverFullName'] ?? '',
          message: data['message'] ?? '',
          type: messageType,
          fileId: data['fileId'],
          timestamp: timestamp,
          status: data['status'] ?? 'sent',
        );

        if (!messages.any((m) => m.rowId == chat.rowId)) {
          messages.add(chat);
          notifyListeners();
        }
      }

      if (type.contains('.update')) {
        final index = messages.indexWhere((m) => m.rowId == data['\$id']);
        if (index != -1) {
          messages[index] = messages[index].copyWith(
            message: data['message'] ?? messages[index].message,
            type: data['type'] ?? messages[index].type,
            fileId: data['fileId'] ?? messages[index].fileId,
            status: data['status'] ?? messages[index].status,
          );
          notifyListeners();
        }
      }

      if (type.contains('.delete')) {
        messages.removeWhere((m) => m.rowId == data['\$id']);
        notifyListeners();
      }
    });
  }

  List<ChatMessage> getMessagesForFriend(String friendId) {
    return messages
        .where(
          (m) =>
              (m.senderId == myUserId && m.receiverId == friendId) ||
              (m.senderId == friendId && m.receiverId == myUserId),
        )
        .toList();
  }

  Future<void> sendMessage({
    required String friendId,
    required String receiverName,
    required String message,
  }) async {
    if (message.trim().isEmpty) return;

    try {
      await AppwriteConfig.tablesDB.createRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.chat,
        rowId: ID.unique(),
        data: {
          "senderId": myUserId,
          "senderFullName": _myName,
          "receiverId": friendId,
          "receiverFullName": receiverName,
          "message": message.trim(),
          "type": "text",
          "status": "sent",
        },
      );
    } catch (e) {
      debugPrint("SEND ERROR: $e");
    }
  }

  Future<void> sendImageMessage({
    required String friendId,
    required String receiverName,
    required File imageFile,
    required UploadProvider uploadProv,
  }) async {
    try {
      final fileId = await uploadProv.uploadImage(imageFile);

      await AppwriteConfig.tablesDB.createRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.chat,
        rowId: ID.unique(),
        data: {
          "senderId": myUserId,
          "senderFullName": _myName,
          "receiverId": friendId,
          "receiverFullName": receiverName,
          "type": "image",
          "fileId": fileId,
          "status": "sent",
        },
      );
    } catch (e) {
      debugPrint("IMAGE SEND ERROR: $e");
    }
  }

  Future<void> markMessagesAsRead(String friendId) async {
    for (var msg in getMessagesForFriend(friendId)) {
      if (msg.receiverId == myUserId && msg.status != "read") {
        updateMessageStatus(msg.rowId, "read");
      }
    }
  }

  Future<void> updateMessageStatus(String rowId, String status) async {
    try {
      await AppwriteConfig.tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.chat,
        rowId: rowId,
        data: {"status": status},
      );
    } catch (e) {
      debugPrint("STATUS UPDATE ERROR: $e");
    }
  }

  void disposeListener() {
    _sub?.cancel();
    _sub = null;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
