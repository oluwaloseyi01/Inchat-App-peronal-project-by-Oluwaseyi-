import 'package:inchat/provider/auth_provider.dart';
import 'package:inchat/provider/chat_provider.dart';
import 'package:inchat/provider/chatlistprovider.dart';
import 'package:inchat/provider/friends_provider.dart';
import 'package:inchat/provider/home_provider.dart';
import 'package:inchat/provider/realtime_provider.dart';
import 'package:inchat/provider/upload_provider.dart';
import 'package:inchat/provider/voicerecord.dart';

import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class AppProvider {
  List<SingleChildWidget> providers = [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => HomeProvider()),
    ChangeNotifierProvider(create: (_) => FriendsProvider()),
    ChangeNotifierProvider(create: (_) => ChatProvider()),
    ChangeNotifierProvider(create: (_) => ActiveChatProvider()),

    ChangeNotifierProvider(create: (_) => RealtimeProvider()),
    ChangeNotifierProvider(create: (_) => UploadProvider()),
  ];
}
