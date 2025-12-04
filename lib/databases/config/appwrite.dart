import 'package:appwrite/appwrite.dart';

class AppwriteConfig {
  static const String appwriteProjectId = '69272c4700323b7fee7c';
  static const String appwriteProjectName = 'Inchat';
  static const String endPoint = "https://fra.cloud.appwrite.io/v1";
  static const String userCollection = "usercollection";
  static const String databaseId = "69272dd20031a8ca4ff0";
  static const String chat = "chat";
  static const String chatSummary = "chatsummary";
  static const String friends = "friends";
  static const String message = "message";

  static Functions functions = Functions(client);
  static const String bucketId = "69286ed00005619c4805";

  static final Client _client = Client()
    ..setEndpoint(endPoint)
    ..setProject(appwriteProjectId);

  static Client get client => _client;

  static final Account account = Account(_client);
  static final Storage storage = Storage(_client);
  static final Realtime realtime = Realtime(_client);
  static final TablesDB tablesDB = TablesDB(_client);

  static String getFileUrl({required String fileId}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return "$endPoint/storage/buckets/$bucketId/files/$fileId/view"
        "?project=$appwriteProjectId&t=$timestamp";
  }
}
