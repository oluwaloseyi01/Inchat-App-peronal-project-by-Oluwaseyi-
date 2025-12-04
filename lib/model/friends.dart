class FriendModel {
  final String userId;
  final String fullName;
  final String? profilePicture;

  FriendModel({
    required this.userId,
    required this.fullName,
    this.profilePicture,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fullName': fullName,
      'profilePicture': profilePicture,
    };
  }

  factory FriendModel.fromMap(Map<String, dynamic> map) {
    return FriendModel(
      userId: map['userId'] ?? "",
      fullName: map['fullName'] ?? "",
      profilePicture: map['profilePicture'],
    );
  }
}
