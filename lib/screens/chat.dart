import 'package:flutter/material.dart';
import 'package:inchat/databases/config/appwrite.dart';
import 'package:inchat/provider/chatlistprovider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:inchat/provider/securestorage.dart';
import 'package:inchat/core/costants/text_theme.dart';
import 'messages.dart';
import 'package:inchat/model/chatmodel.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  String myUserId = "";
  bool isSearching = false;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserAndChats();
  }

  Future<void> _loadUserAndChats() async {
    myUserId = await SecureStorage.getUserId() ?? "";
    final provider = context.read<ActiveChatProvider>();
    provider.setMyUserId(myUserId);
    await provider.fetchActiveChats();
  }

  String formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('hh:mm a').format(date);
  }

  Widget _buildStatusIcon(String status) {
    switch (status) {
      case "sent":
        return const Icon(Icons.check, size: 14, color: Colors.white54);
      case "delivered":
        return const Icon(Icons.done_all, size: 14, color: Colors.white54);
      case "read":
        return const Icon(Icons.done_all, size: 14, color: Colors.blue);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAvatar(
    String? profilePictureIdOrUrl,
    String name,
    bool isOnline,
  ) {
    String? imageUrl;

    if (profilePictureIdOrUrl != null && profilePictureIdOrUrl.isNotEmpty) {
      if (profilePictureIdOrUrl.startsWith("http")) {
        imageUrl = profilePictureIdOrUrl;
      } else {
        imageUrl = AppwriteConfig.getFileUrl(fileId: profilePictureIdOrUrl);
      }
    }

    return Stack(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.blueGrey.withOpacity(0.3),
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
          child: imageUrl == null
              ? Text(
                  name.isNotEmpty ? name[0].toUpperCase() : "?",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        if (isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blueGrey, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveChatProvider>(
      builder: (context, provider, _) {
        final activeList = isSearching
            ? provider.filteredChats
            : provider.latestChats;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blueGrey,
            title: !isSearching
                ? Text(
                    "Chats",
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 23,
                    ),
                  )
                : TextField(
                    controller: _searchCtrl,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Search friends/messages...",
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) => provider.searchChats(value),
                  ),
            actions: [
              IconButton(
                icon: Icon(
                  isSearching ? Icons.close : Icons.search,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (isSearching) {
                    _searchCtrl.clear();
                    provider.searchChats('');
                  }
                  setState(() => isSearching = !isSearching);
                },
              ),
            ],
          ),
          backgroundColor: const Color.fromARGB(255, 57, 63, 66),
          body: provider.loading
              ? const Center(child: CircularProgressIndicator())
              : activeList.isEmpty
              ? const Center(
                  child: Text(
                    "No active chats",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : ListView.separated(
                  separatorBuilder: (_, __) =>
                      const Divider(color: Colors.white12, height: 1),
                  itemCount: activeList.length,
                  itemBuilder: (context, index) {
                    final ChatMessage chat = activeList[index];

                    final isMe = chat.senderId == myUserId;
                    final friendId = isMe ? chat.receiverId : chat.senderId;
                    final friendName = isMe
                        ? chat.receiverFullName
                        : chat.senderFullName;

                    final friendProfilePicture = chat.receiverProfilePicture;

                    final lastMessage = chat.message.isNotEmpty
                        ? chat.message
                        : (chat.type == "image" ? "Image" : "");
                    final lastMessageStatus = chat.status;
                    final isOnline = false;

                    final unreadCount = provider.getUnreadCount(friendId);

                    return ListTile(
                      onTap: () {
                        if (friendId.isEmpty) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Messages(
                              friendId: friendId,
                              friendName: friendName,
                              friendProfilePicture: friendProfilePicture,
                            ),
                          ),
                        ).then((_) {
                          provider.markAsRead(friendId);
                        });
                      },
                      leading: _buildAvatar(
                        friendProfilePicture,
                        friendName,
                        isOnline,
                      ),
                      title: Text(
                        friendName,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Row(
                        children: [
                          if (isMe) _buildStatusIcon(lastMessageStatus),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              lastMessage,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatTime(chat.timestamp),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                          if (unreadCount > 0)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
