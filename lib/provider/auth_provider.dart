import 'dart:math';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:inchat/databases/config/appwrite.dart';
import 'package:inchat/model/user.dart';
import 'package:inchat/provider/securestorage.dart';

class AuthProvider extends ChangeNotifier {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController chatNumberController = TextEditingController();

  bool isLoading = false;
  bool isLoggedIn = false;
  bool isInitialized = false;

  UserModel? currentUserData;

  final Random _random = Random();

  String _generate8DigitNumber() {
    return (10000000 + _random.nextInt(90000000)).toString();
  }

  Future<String> generateUniqueChatNumber() async {
    String number;
    bool isUnique = false;

    do {
      number = _generate8DigitNumber();

      final existing = await AppwriteConfig.tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.userCollection,
        queries: [Query.equal("chatNumber", number)],
      );

      if (existing.total == 0) {
        isUnique = true;
      }
    } while (!isUnique);

    return number;
  }

  Future<void> initAuth() async {
    final savedLogin = await SecureStorage.getStoredLogin();
    if (savedLogin == "true") {
      isLoggedIn = true;
      notifyListeners();
      return;
    }
    isLoggedIn = false;
    notifyListeners();
  }

  Future<void> register(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      String chatNumber = await generateUniqueChatNumber();

      final user = await AppwriteConfig.account.create(
        userId: ID.unique(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        name: fullNameController.text.trim(),
      );

      final row = await AppwriteConfig.tablesDB.createRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.userCollection,
        rowId: ID.unique(),
        data: {
          "userId": user.$id,
          "fullName": fullNameController.text.trim(),
          "email": emailController.text.trim(),
          "chatNumber": chatNumber,

          "profilePicture": null,
        },
      );

      await SecureStorage.storeUserId(user.$id);
      await SecureStorage.storeRowId(row.$id);
      await SecureStorage.storeFullName(fullNameController.text.trim());

      await _createSessionAfterAuth(context);
    } catch (e) {
      print("REGISTER ERROR: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      await AppwriteConfig.account.createEmailPasswordSession(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final currentUser = await AppwriteConfig.account.get();

      final rows = await AppwriteConfig.tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.userCollection,
        queries: [Query.equal("userId", currentUser.$id)],
      );

      if (rows.total > 0) {
        final row = rows.rows.first;
        await SecureStorage.storeUserId(currentUser.$id);
        await SecureStorage.storeRowId(row.$id);
        await SecureStorage.storeFullName(row.data['fullName'] ?? "Unknown");
      }

      await _createSessionAfterAuth(context);
    } catch (e) {
      print("LOGIN ERROR: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _createSessionAfterAuth(BuildContext context) async {
    DateTime now = DateTime.now();
    await SecureStorage.storeLogin("true");
    await SecureStorage.storeTime(now.toIso8601String());

    isLoggedIn = true;
    notifyListeners();

    Navigator.pushNamedAndRemoveUntil(context, "home", (route) => false);
  }

  Future<void> logOut(BuildContext context) async {
    try {
      await AppwriteConfig.account.deleteSessions();
    } catch (_) {}

    await logOutWithoutContext();
    Navigator.pushNamedAndRemoveUntil(context, "login", (route) => false);
  }

  Future<void> logOutWithoutContext() async {
    await SecureStorage.deleteStoredLogin();
    await SecureStorage.deleteStoredTime();
    await SecureStorage.deleteUserId();
    await SecureStorage.deleteRowId();

    isLoggedIn = false;
    currentUserData = null;
    notifyListeners();
  }

  Future<void> fetchUserData() async {
    try {
      String? userId = await SecureStorage.getUserId();
      if (userId == null) return;

      final rows = await AppwriteConfig.tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.userCollection,
        queries: [Query.equal("userId", userId)],
      );

      if (rows.total > 0) {
        currentUserData = UserModel.fromMap(rows.rows.first.data);
        notifyListeners();
      }
    } catch (e) {
      print("FETCH USER DATA ERROR: $e");
    }
  }

  Future<void> updateFullName(String newName) async {
    if (currentUserData == null) return;

    try {
      final rows = await AppwriteConfig.tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.userCollection,
        queries: [Query.equal("userId", currentUserData!.id)],
      );

      if (rows.total == 0) return;

      final rowId = rows.rows.first.$id;

      await AppwriteConfig.tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.userCollection,
        rowId: rowId,
        data: {"fullName": newName},
      );

      currentUserData = UserModel(
        id: currentUserData!.id,
        fullName: newName,
        email: currentUserData!.email,
        chatNumber: currentUserData!.chatNumber,
        rowId: currentUserData!.rowId,
        profilePicture: currentUserData!.profilePicture,
      );

      notifyListeners();
    } catch (e) {
      print("Error updating full name: $e");
    }
  }

  Future<Map<String, dynamic>?> fetchFriendByChatNumber(
    String chatNumber,
  ) async {
    try {
      final rows = await AppwriteConfig.tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.userCollection,
        queries: [Query.equal("chatNumber", chatNumber)],
      );

      if (rows.total > 0) {
        return rows.rows.first.data;
      } else {
        return null;
      }
    } catch (e) {
      print("FETCH FRIEND ERROR: $e");
      return null;
    }
  }

  Future<bool> addFriend(Map<String, dynamic> friendData) async {
    try {
      final myUserId = await SecureStorage.getUserId();
      final friendUserId = friendData['userId'] as String?;

      if (myUserId == null || friendUserId == null) return false;

      if (myUserId == friendUserId) return false;

      final existing = await AppwriteConfig.tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.friends,
        queries: [
          Query.equal('userId', myUserId),
          Query.equal('friendId', friendUserId),
        ],
      );

      if (existing.total > 0) return false;

      await AppwriteConfig.tablesDB.createRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.friends,
        rowId: ID.unique(),
        data: {'userId': myUserId, 'friendId': friendUserId},
      );

      return true;
    } catch (e) {
      print('ADD FRIEND ERROR: $e');
      return false;
    }
  }
}
