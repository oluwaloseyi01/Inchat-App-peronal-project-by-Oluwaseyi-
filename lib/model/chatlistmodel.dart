class ActiveChat {
  final String userId;
  final String name;
  final String lastMessage;
  final int createdAt;
  final int unreadCount;
  final String lastMessageStatus;
  final String lastMessageType;
  final String senderId;
  final String? receiverProfilePicture; // updated

  ActiveChat({
    required this.userId,
    required this.name,
    required this.lastMessage,
    required this.createdAt,
    required this.unreadCount,
    required this.lastMessageStatus,
    required this.lastMessageType,
    required this.senderId,
    this.receiverProfilePicture, // optional
  });

  ActiveChat copyWith({
    String? lastMessage,
    int? createdAt,
    int? unreadCount,
    String? lastMessageStatus,
    String? lastMessageType,
    String? senderId,
    String? receiverProfilePicture,
  }) {
    return ActiveChat(
      userId: userId,
      name: name,
      lastMessage: lastMessage ?? this.lastMessage,
      createdAt: createdAt ?? this.createdAt,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessageStatus: lastMessageStatus ?? this.lastMessageStatus,
      lastMessageType: lastMessageType ?? this.lastMessageType,
      senderId: senderId ?? this.senderId,
      receiverProfilePicture:
          receiverProfilePicture ?? this.receiverProfilePicture,
    );
  }
}
