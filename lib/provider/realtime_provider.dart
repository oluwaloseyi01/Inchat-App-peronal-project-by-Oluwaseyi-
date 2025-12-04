import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:inchat/databases/config/appwrite.dart';
import 'package:inchat/model/chatmodel.dart';

class RealtimeProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  String? _myUserId;
  String? _myFullName;

  RealtimeSubscription? _subscription;

  void init({required String myUserId, required String myFullName}) {
    if (_subscription != null) return;

    _myUserId = myUserId;
    _myFullName = myFullName;

    fetchOldMessages();
    _listenToRealtime();
  }

  void _listenToRealtime() {
    final channel =
        "databases.${AppwriteConfig.databaseId}.collections.${AppwriteConfig.chat}.documents";

    final realtime = Realtime(AppwriteConfig.client);

    _subscription = realtime.subscribe([channel]);

    _subscription!.stream.listen((event) {
      _handleRealtimeEvent(event);
    });
  }

  Future<void> fetchOldMessages() async {
    if (_myUserId == null) return;

    try {
      final response = await AppwriteConfig.tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.chat,
        queries: [
          Query.or([
            Query.equal('senderId', _myUserId!),
            Query.equal('receiverId', _myUserId!),
          ]),
          Query.orderAsc("\$createdAt"),
        ],
      );

      final fetched = response.rows.map(_fromRow).toList();
      addFetchedMessages(fetched);
    } catch (e) {
      debugPrint("Fetch old messages error: $e");
    }
  }

  void _handleRealtimeEvent(RealtimeMessage event) {
    if (_myUserId == null || event.payload == null) return;

    final data = event.payload;

    if (data['senderId'] != _myUserId && data['receiverId'] != _myUserId) {
      return;
    }

    final msgType = data['type'] ?? "text";

    if (msgType != "text" && msgType != "image") return;

    final msg = _fromPayload(data);

    final existingIndex = _messages.indexWhere((m) => m.rowId == msg.rowId);

    if (existingIndex != -1) {
      _messages[existingIndex] = msg;
    } else {
      _messages.add(msg);
    }

    _sortMessages();
    notifyListeners();
  }

  ChatMessage _fromRow(models.Row row) {
    final d = row.data;

    return ChatMessage(
      rowId: row.$id,
      senderId: d['senderId'] ?? "",
      senderFullName: d['senderFullName'] ?? "",
      receiverId: d['receiverId'] ?? "",
      receiverFullName: d['receiverFullName'] ?? "",
      message: d['message'] ?? "",
      type: d['type'] ?? "text",
      fileId: d['fileId'],
      status: d['status'] ?? "sent",
      timestamp: _parseTimestamp(row.$createdAt),
    );
  }

  ChatMessage _fromPayload(Map<String, dynamic> d) {
    return ChatMessage(
      rowId: d['\$id'],
      senderId: d['senderId'] ?? "",
      senderFullName: d['senderFullName'] ?? "",
      receiverId: d['receiverId'] ?? "",
      receiverFullName: d['receiverFullName'] ?? "",
      message: d['message'] ?? "",
      type: d['type'] ?? "text",
      fileId: d['fileId'],
      status: d['status'] ?? "sent",
      timestamp: _parseTimestamp(d['\$createdAt']),
    );
  }

  int _parseTimestamp(dynamic t) {
    try {
      return DateTime.parse(t.toString()).millisecondsSinceEpoch;
    } catch (_) {
      return DateTime.now().millisecondsSinceEpoch;
    }
  }

  void addFetchedMessages(List<ChatMessage> list) {
    for (var m in list) {
      if (!_messages.any((x) => x.rowId == m.rowId)) {
        _messages.add(m);
      }
    }
    _sortMessages();
    notifyListeners();
  }

  void _sortMessages() {
    _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  List<ChatMessage> getMessagesForFriend(String friendId) {
    if (_myUserId == null) return [];

    return _messages.where((msg) {
      return (msg.senderId == _myUserId && msg.receiverId == friendId) ||
          (msg.receiverId == _myUserId && msg.senderId == friendId);
    }).toList();
  }

  List<ChatMessage> get allMessages => List.unmodifiable(_messages);

  @override
  void dispose() {
    _subscription?.close();
    super.dispose();
  }
}
