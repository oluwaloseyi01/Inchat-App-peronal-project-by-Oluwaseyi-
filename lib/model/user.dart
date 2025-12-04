class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String chatNumber;
  final String rowId;
  final String? profilePicture;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.chatNumber,
    required this.rowId,
    this.profilePicture,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: (map['userId'] ?? "") as String,
      fullName: (map['fullName'] ?? "") as String,
      email: (map['email'] ?? "") as String,
      chatNumber: (map['chatNumber'] ?? "") as String,
      rowId: (map['rowId'] ?? map['\$id'] ?? "") as String,
      profilePicture: map['profilePicture'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "userId": id,
      "fullName": fullName,
      "email": email,
      "chatNumber": chatNumber,
      "rowId": rowId,
      "profilePicture": profilePicture,
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? chatNumber,
    String? rowId,
    String? profilePicture,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      chatNumber: chatNumber ?? this.chatNumber,
      rowId: rowId ?? this.rowId,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }
}
