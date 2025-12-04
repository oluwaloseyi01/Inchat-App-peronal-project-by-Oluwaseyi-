import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:appwrite/appwrite.dart';
import 'package:inchat/model/chatmodel.dart';
import '../databases/config/appwrite.dart';

class UploadProvider extends ChangeNotifier {
  File? profileImage;
  ImageProvider? profileImageProvider;
  bool isUploading = false;
  List<ChatMessage> messages = [];

  Future<void> pickAndUploadProfilePicture(String rowId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: kIsWeb,
      );

      if (result == null) return;

      final picked = result.files.first;
      InputFile fileToUpload;

      isUploading = true;
      notifyListeners();

      if (kIsWeb) {
        if (picked.bytes == null) return;
        fileToUpload = InputFile.fromBytes(
          bytes: picked.bytes!,
          filename: picked.name,
        );
      } else {
        if (picked.path == null) return;
        profileImage = File(picked.path!);
        fileToUpload = InputFile.fromPath(
          path: picked.path!,
          filename: picked.name,
        );
      }

      final uploadedFile = await AppwriteConfig.storage.createFile(
        bucketId: AppwriteConfig.bucketId,
        fileId: ID.unique(),
        file: fileToUpload,
        permissions: [Permission.read(Role.any())],
      );

      await AppwriteConfig.tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.userCollection,
        rowId: rowId,
        data: {"profilePicture": uploadedFile.$id},
      );

      if (kIsWeb) {
        profileImageProvider = MemoryImage(picked.bytes!);
      } else {
        profileImageProvider = NetworkImage(
          AppwriteConfig.getFileUrl(fileId: uploadedFile.$id),
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Upload error: $e");
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }

  Future<File?> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: kIsWeb,
    );

    if (result == null) return null;
    if (kIsWeb) {
      return null;
    } else {
      return File(result.files.first.path!);
    }
  }

  Future<String?> uploadImage(File file) async {
    try {
      final uploadedFile = await AppwriteConfig.storage.createFile(
        bucketId: AppwriteConfig.bucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: file.path),
        permissions: [Permission.read(Role.any())],
      );
      return uploadedFile.$id;
    } catch (e) {
      debugPrint("Upload error: $e");
      return null;
    }
  }
}
