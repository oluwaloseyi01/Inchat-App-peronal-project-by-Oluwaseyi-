import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:inchat/databases/config/appwrite.dart';
import 'package:inchat/provider/chat_provider.dart';
import 'package:inchat/provider/realtime_provider.dart';
import 'package:inchat/provider/upload_provider.dart';
import 'package:inchat/provider/friends_provider.dart';
import 'package:inchat/screens/widgets/chatbubble.dart';

class Messages extends StatefulWidget {
  final String friendId;
  final String friendName;
  final String? friendProfilePicture;

  const Messages({
    super.key,
    required this.friendId,
    required this.friendName,
    this.friendProfilePicture,
  });

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool isUploadingImage = false;
  bool isUserReady = false;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final chatProv = context.read<ChatProvider>();
    await chatProv.initUser();
    setState(() => isUserReady = true);

    await chatProv.fetchMessages(widget.friendId);
    await chatProv.markMessagesAsRead(widget.friendId);

    final realtimeProv = context.read<RealtimeProvider>();
    if (chatProv.myUserId != null && chatProv.myName != null) {
      realtimeProv.init(
        myUserId: chatProv.myUserId!,
        myFullName: chatProv.myName!,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final chatProv = context.read<ChatProvider>();
    if (_msgCtrl.text.trim().isEmpty) return;

    await chatProv.sendMessage(
      friendId: widget.friendId,
      message: _msgCtrl.text.trim(),
      receiverName: widget.friendName,
    );
    _msgCtrl.clear();
    _scrollToBottom();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (pickedFile == null) return;

    setState(() => isUploadingImage = true);
    final chatProv = context.read<ChatProvider>();
    final uploadProv = context.read<UploadProvider>();

    await chatProv.sendImageMessage(
      friendId: widget.friendId,
      imageFile: File(pickedFile.path),
      uploadProv: uploadProv,
      receiverName: widget.friendName,
    );

    setState(() => isUploadingImage = false);
    _scrollToBottom();
  }

  String formatTimestamp(dynamic timestamp) {
    try {
      DateTime date;
      if (timestamp is int) {
        date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else if (timestamp is String) {
        date = DateTime.parse(timestamp);
      } else {
        return "";
      }
      return DateFormat('hh:mm a').format(date);
    } catch (_) {
      return "";
    }
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

  @override
  Widget build(BuildContext context) {
    return Consumer2<ChatProvider, RealtimeProvider>(
      builder: (context, chatProv, realtimeProv, _) {
        final messages = chatProv.getMessagesForFriend(widget.friendId);

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blueGrey,
            leading: BackButton(color: Colors.white),
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.blueGrey.shade700,
                  backgroundImage:
                      (widget.friendProfilePicture != null &&
                          widget.friendProfilePicture!.isNotEmpty)
                      ? NetworkImage(widget.friendProfilePicture!)
                      : null,
                  child:
                      (widget.friendProfilePicture == null ||
                          widget.friendProfilePicture!.isEmpty)
                      ? Text(
                          widget.friendName.isNotEmpty
                              ? widget.friendName[0].toUpperCase()
                              : "?",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.friendName,
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              Consumer<FriendsProvider>(
                builder: (context, friendsProvider, _) {
                  final isFriend = friendsProvider.myFriends.any(
                    (f) => f['userId'] == widget.friendId,
                  );

                  if (!isFriend) {
                    return IconButton(
                      icon: const Icon(Icons.person_add, color: Colors.white),
                      onPressed: () async {
                        final result = await friendsProvider.addFriend({
                          "userId": widget.friendId,
                          "fullName": widget.friendName,
                          "profilePicture": widget.friendProfilePicture ?? "",
                        });

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(result)));
                      },
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
          backgroundColor: Colors.blueGrey[900],
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: messages.isEmpty
                      ? const Center(
                          child: Text(
                            "No messages yet",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollCtrl,
                          padding: EdgeInsets.only(
                            top: 12,
                            left: 12,
                            right: 12,
                            bottom:
                                MediaQuery.of(context).viewInsets.bottom + 12,
                          ),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final msg = messages[index];
                            final isMe = msg.senderId == chatProv.myUserId;

                            return Align(
                              alignment: isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? const Color.fromARGB(255, 120, 160, 180)
                                      : const Color.fromARGB(255, 112, 83, 108),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (msg.type == "image" &&
                                        msg.fileId != null)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 200,
                                            height: 200,
                                            child: Image.network(
                                              AppwriteConfig.getFileUrl(
                                                fileId: msg.fileId!,
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          if (isMe) const SizedBox(width: 4),
                                          if (isMe)
                                            _buildStatusIcon(msg.status),
                                        ],
                                      )
                                    else if (msg.type == "voice" &&
                                        msg.fileId != null)
                                      VoiceBubble(
                                        filePath: AppwriteConfig.getFileUrl(
                                          fileId: msg.fileId!,
                                        ),
                                        isMe: isMe,
                                      )
                                    else
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              msg.message.isNotEmpty
                                                  ? msg.message
                                                  : "Image",
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          if (isMe) const SizedBox(width: 4),
                                          if (isMe)
                                            _buildStatusIcon(msg.status),
                                        ],
                                      ),
                                    Text(
                                      formatTimestamp(msg.timestamp),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.blueGrey[800],
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 45,
                          child: TextField(
                            controller: _msgCtrl,
                            style: const TextStyle(color: Colors.white),
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              hintText: "Type message...",
                              hintStyle: const TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor: Colors.blueGrey[700],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.image,
                                  color: Colors.white54,
                                ),
                                onPressed: () =>
                                    _pickImage(ImageSource.gallery),
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.white54,
                        ),
                        onPressed: () => _pickImage(ImageSource.camera),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: isUserReady ? _sendMessage : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
