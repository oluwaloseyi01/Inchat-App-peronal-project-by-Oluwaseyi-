import 'package:flutter/material.dart';
import 'package:inchat/core/costants/text_theme.dart';
import 'package:inchat/databases/config/appwrite.dart';
import 'package:inchat/provider/friends_provider.dart';
import 'package:provider/provider.dart';

class Friends extends StatefulWidget {
  const Friends({super.key});

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    final friendsProvider = Provider.of<FriendsProvider>(
      context,
      listen: false,
    );
    await friendsProvider.fetchMyFriends();
  }

  @override
  Widget build(BuildContext context) {
    final friendsProvider = context.watch<FriendsProvider>();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, "addfriend"),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: !_isSearching
            ? Text(
                "Friends",
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 23,
                ),
              )
            : TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Search friends...",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  friendsProvider.searchFriends(query);
                },
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  friendsProvider.searchFriends("");
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 57, 63, 66),
      body: friendsProvider.filteredFriends.isEmpty
          ? const Center(
              child: Text(
                "No friends found",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          : ListView.separated(
              itemCount: friendsProvider.filteredFriends.length,
              separatorBuilder: (context, index) => const Divider(
                color: Colors.white24,
                thickness: 1,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final friend = friendsProvider.filteredFriends[index];

                final friendUserId = (friend['userId'] ?? "").toString();
                final friendName = (friend['fullName'] ?? "Unknown").toString();
                final chatNumber = (friend['chatNumber'] ?? "").toString();
                final friendPictureId = friend['profilePicture'] ?? "";

                final friendProfilePictureUrl =
                    (friendPictureId.isNotEmpty &&
                        !friendPictureId.startsWith('http'))
                    ? AppwriteConfig.getFileUrl(fileId: friendPictureId)
                    : friendPictureId;

                final firstLetter = friendName.isNotEmpty
                    ? friendName[0].toUpperCase()
                    : "?";

                return ListTile(
                  onTap: () {
                    if (friendUserId.isEmpty) return;
                    Navigator.pushNamed(
                      context,
                      "messages",
                      arguments: {
                        "friendId": friendUserId,
                        "friendName": friendName,
                        "friendProfilePicture": friendProfilePictureUrl,
                      },
                    );
                  },
                  leading: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.blueGrey.withOpacity(0.5),
                    backgroundImage: friendProfilePictureUrl.isNotEmpty
                        ? NetworkImage(friendProfilePictureUrl)
                        : null,
                    child: friendProfilePictureUrl.isEmpty
                        ? Text(
                            firstLetter,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  title: Text(
                    friendName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "Inchat #: $chatNumber",
                    style: const TextStyle(color: Colors.white70),
                  ),
                );
              },
            ),
    );
  }
}
