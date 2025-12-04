class ChatMessage {
  final String rowId;
  final String senderId;
  final String receiverId;
  final String senderFullName;
  final String receiverFullName;
  final String message;
  final String type;
  final String? fileId;
  final int timestamp;
  final String status;
  final String? receiverProfilePicture;
  int unreadCount;

  ChatMessage({
    required this.rowId,
    required this.senderId,
    required this.receiverId,
    required this.senderFullName,
    required this.receiverFullName,
    required this.message,
    required this.type,
    this.fileId,
    required this.timestamp,
    required this.status,
    this.receiverProfilePicture,
    this.unreadCount = 0,
  });

  factory ChatMessage.fromAppwrite(Map<String, dynamic> map) {
    final data = map['data'] ?? {};

    return ChatMessage(
      rowId: map['\$id'] ?? "",
      senderId: data['senderId'] ?? "",
      receiverId: data['receiverId'] ?? "",
      senderFullName: data['senderFullName'] ?? "",
      receiverFullName: data['receiverFullName'] ?? "",
      message: data['message'] ?? "",
      type: data['type'] ?? "text",
      fileId: data['fileId'],
      timestamp: data['timestamp'] ?? 0,
      status: data['status'] ?? "sent",
      receiverProfilePicture: data['receiverProfilePicture'],
      unreadCount: data['unreadCount'] ?? 0,
    );
  }

  ChatMessage copyWith({
    String? rowId,
    String? senderId,
    String? receiverId,
    String? senderFullName,
    String? receiverFullName,
    String? message,
    String? type,
    String? fileId,
    int? timestamp,
    String? status,
    String? receiverProfilePicture,
    int? unreadCount,
  }) {
    return ChatMessage(
      rowId: rowId ?? this.rowId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      senderFullName: senderFullName ?? this.senderFullName,
      receiverFullName: receiverFullName ?? this.receiverFullName,
      message: message ?? this.message,
      type: type ?? this.type,
      fileId: fileId ?? this.fileId,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      receiverProfilePicture:
          receiverProfilePicture ?? this.receiverProfilePicture,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
