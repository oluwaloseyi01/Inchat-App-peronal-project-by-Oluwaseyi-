import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:inchat/databases/config/appwrite.dart';
import 'package:inchat/provider/securestorage.dart';

class FriendsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> myFriends = [];
  List<Map<String, dynamic>> filteredFriends = [];

  String buildProfilePictureUrl(String? fileId) {
    if (fileId == null || fileId.isEmpty) return "";
    if (fileId.startsWith('http')) return fileId;
    return AppwriteConfig.getFileUrl(fileId: fileId);
  }

  Future<void> fetchMyFriends() async {
    try {
      final myUserId = await SecureStorage.getUserId();
      if (myUserId == null) return;

      final friendsRows = await AppwriteConfig.tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.friends,
        queries: [Query.equal('userId', myUserId)],
      );

      List<Map<String, dynamic>> tempFriends = [];

      for (var row in friendsRows.rows) {
        final friendUserId = row.data['friendId'];

        final userRows = await AppwriteConfig.tablesDB.listRows(
          databaseId: AppwriteConfig.databaseId,
          tableId: AppwriteConfig.userCollection,
          queries: [Query.equal('userId', friendUserId)],
        );

        if (userRows.total > 0) {
          final userData = userRows.rows.first.data;

          tempFriends.add({
            ...userData,
            'profilePicture': buildProfilePictureUrl(
              userData['profilePicture'],
            ),
          });
        }
      }

      myFriends = tempFriends;
      filteredFriends = List.from(myFriends);
      notifyListeners();
    } catch (e) {
      print("FETCH FRIENDS ERROR: $e");
    }
  }

  Future<String> addFriend(Map<String, dynamic> friendData) async {
    try {
      final myUserId = await SecureStorage.getUserId();
      final friendUserId = friendData['userId'] as String?;

      if (myUserId == null || friendUserId == null) return "Invalid user";
      if (myUserId == friendUserId) return "Cannot add yourself";

      final existing = await AppwriteConfig.tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.friends,
        queries: [
          Query.equal('userId', myUserId),
          Query.equal('friendId', friendUserId),
        ],
      );

      if (existing.total > 0) return "Already friends";

      await AppwriteConfig.tablesDB.createRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.friends,
        rowId: ID.unique(),
        data: {'userId': myUserId, 'friendId': friendUserId},
      );

      myFriends.add({
        ...friendData,
        'profilePicture': buildProfilePictureUrl(friendData['profilePicture']),
      });

      filteredFriends = List.from(myFriends);
      notifyListeners();

      return "Friend added successfully";
    } catch (e) {
      print("ADD FRIEND ERROR: $e");
      return "Error adding friend";
    }
  }

  void searchFriends(String query) {
    if (query.trim().isEmpty) {
      filteredFriends = List.from(myFriends);
    } else {
      filteredFriends = myFriends
          .where(
            (friend) => (friend['fullName'] ?? "").toLowerCase().contains(
              query.trim().toLowerCase(),
            ),
          )
          .toList();
    }

    notifyListeners();
  }

  void clear() {
    myFriends = [];
    filteredFriends = [];
    notifyListeners();
  }
}
