import 'package:chat_app/components/my_drawer.dart';
import 'package:chat_app/components/group_chat_tile.dart';
import 'package:chat_app/pages/chat_screen.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/services/chats/chat_service.dart';
import 'package:chat_app/modals/chat_room.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:chat_app/gen_l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  User? _currentUser;

  bool _isSearching = false;
  String _searchQuery = '';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentUser = _authService.getCurrentUser();
    _authService.setUserOnlineStatus(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _authService.setUserOnlineStatus(true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _authService.setUserOnlineStatus(false);
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
      }
    });
  }

  void _showAddUserDialog() {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.addUserToChat),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context)!.enterEmailAddress),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.email,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () => _addUserToChat(emailController.text.trim()),
              child: Text(AppLocalizations.of(context)!.add),
            ),
          ],
        );
      },
    );
  }

  void _showCreateGroupDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final List<String> participantEmails = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.createGroupChat),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.groupName,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.group),
                          hintText: AppLocalizations.of(
                            context,
                          )!.enterGroupName,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(
                            context,
                          )!.addParticipantEmail,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_add),
                          hintText: AppLocalizations.of(
                            context,
                          )!.enterEmailAndPressEnter,
                          suffixIcon: Icon(Icons.add),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onSubmitted: (email) {
                          if (email.isNotEmpty &&
                              !participantEmails.contains(
                                email.toLowerCase(),
                              ) &&
                              email.toLowerCase() !=
                                  _currentUser?.email?.toLowerCase()) {
                            setState(() {
                              participantEmails.add(email.toLowerCase());
                              emailController.clear();
                            });
                          } else if (email.toLowerCase() ==
                              _currentUser?.email?.toLowerCase()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.youCannotAddYourself,
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          } else if (participantEmails.contains(
                            email.toLowerCase(),
                          )) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.youCannotAddYourself,
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      if (participantEmails.isNotEmpty) ...[
                        Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.participants,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${participantEmails.length}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.3,
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: participantEmails.length,
                            itemBuilder: (context, index) {
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    child: Text(
                                      participantEmails[index][0].toUpperCase(),
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    participantEmails[index],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        participantEmails.removeAt(index);
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.addAtLeast2Participants,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed:
                      participantEmails.length < 2 ||
                          nameController.text.trim().isEmpty
                      ? null
                      : () => _createGroupChat(
                          nameController.text.trim(),
                          participantEmails,
                        ),
                  child: Text(AppLocalizations.of(context)!.create),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addUserToChat(String email) async {
    if (email.isEmpty) {
      _showSnackBar(
        AppLocalizations.of(context)!.pleaseEnterEmail,
        isError: true,
      );
      return;
    }

    if (email.toLowerCase() == _currentUser?.email?.toLowerCase()) {
      _showSnackBar(
        AppLocalizations.of(context)!.youCannotAddYourself,
        isError: true,
      );
      return;
    }

    try {
      Navigator.of(context).pop();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final result = await _chatService.addUserToChat(email);

      Navigator.of(context).pop();

      if (result['success']) {
        setState(() {});
        _showSnackBar(AppLocalizations.of(context)!.userAddedSuccessfully);
      } else {
        _showSnackBar(result['message'], isError: true);
      }
    } catch (e) {
      Navigator.of(context).pop();
      _showSnackBar(
        AppLocalizations.of(context)!.errorAddingUser(e.toString()),
        isError: true,
      );
    }
  }

  Future<void> _createGroupChat(
    String name,
    List<String> participantEmails,
  ) async {
    if (name.isEmpty) {
      _showSnackBar(
        AppLocalizations.of(context)!.pleaseEnterGroupName,
        isError: true,
      );
      return;
    }

    if (participantEmails.length < 2) {
      _showSnackBar(
        AppLocalizations.of(context)!.groupChatMustHave3Participants,
        isError: true,
      );
      return;
    }

    try {
      Navigator.of(context).pop();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final result = await _chatService.createGroupChat(
        name,
        participantEmails,
      );

      Navigator.of(context).pop();

      if (result['success']) {
        setState(() {});
        _showSnackBar(
          AppLocalizations.of(context)!.groupChatCreatedSuccessfully,
        );
      } else {
        _showSnackBar(result['message'], isError: true);
      }
    } catch (e) {
      Navigator.of(context).pop();
      _showSnackBar(
        AppLocalizations.of(context)!.errorCreatingGroupChat(e.toString()),
        isError: true,
      );
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !_isSearching
            ? Text(
                // "ChitChat",
                AppLocalizations.of(context)!.appTitle,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              )
            : TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchUsers,
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  });
                },
              ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      drawer: const MyDrawer(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      floatingActionButton: FloatingActionButton(
        onPressed: _currentIndex == 0
            ? _showAddUserDialog
            : _showCreateGroupDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: Icon(_currentIndex == 0 ? Icons.person_add : Icons.group_add),
      ),
      body: Column(
        children: [
          Container(
            height: 1,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
          _buildTabBar(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              AppLocalizations.of(context)!.chats,
              0,
              Icons.chat,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabButton(
              AppLocalizations.of(context)!.groups,
              1,
              Icons.group,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index, IconData icon) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_currentIndex == 0) {
      return _buildUserList();
    } else {
      return _buildGroupList();
    }
  }

  Widget _buildUserList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      key: ValueKey(
        'user_list_${_currentUser?.uid}_${_searchQuery}_${DateTime.now().millisecondsSinceEpoch ~/ 30000}',
      ),
      stream: _chatService.getChatUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }
        if (!snapshot.hasData) {
          return _buildNoDataWidget(
            AppLocalizations.of(context)!.noDataAvailable,
          );
        }

        final users = snapshot.data!;
        final filteredUsers = users.where((userData) {
          final userEmail = (userData['email'] ?? '').toString().toLowerCase();
          final userName = userEmail.split('@').first;

          if (_currentUser == null ||
              userEmail == _currentUser!.email?.toLowerCase()) {
            return false;
          }

          if (_searchQuery.isEmpty) return true;

          return userEmail.contains(_searchQuery) ||
              userName.contains(_searchQuery);
        }).toList();

        if (filteredUsers.isEmpty) {
          return _buildNoDataWidget(
            _searchQuery.isEmpty
                ? AppLocalizations.of(context)!.noChatUsersYet
                : AppLocalizations.of(context)!.noUsersFound,
          );
        }

        return AnimationLimiter(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: filteredUsers.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              indent: 72,
            ),
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _buildUserListItem(filteredUsers[index]),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildGroupList() {
    return StreamBuilder<List<ChatRoom>>(
      key: ValueKey(
        'group_list_${_currentUser?.uid}_${_searchQuery}_${DateTime.now().millisecondsSinceEpoch ~/ 30000}',
      ),
      stream: _chatService.getGroupChatRoomsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }
        if (!snapshot.hasData) {
          return _buildNoDataWidget(
            AppLocalizations.of(context)!.noDataAvailable,
          );
        }

        final groups = snapshot.data!;
        final filteredGroups = groups.where((group) {
          if (_searchQuery.isEmpty) return true;
          return group.name.toLowerCase().contains(_searchQuery);
        }).toList();

        if (filteredGroups.isEmpty) {
          return _buildNoDataWidget(
            _searchQuery.isEmpty
                ? AppLocalizations.of(context)!.noGroupChatsYet
                : AppLocalizations.of(context)!.noUsersFound,
          );
        }

        return AnimationLimiter(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: filteredGroups.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              indent: 72,
            ),
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: GroupChatTile(
                      chatRoom: filteredGroups[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              receivedEmail: filteredGroups[index].name,
                              receivedId: filteredGroups[index].id,
                              chatRoomId: filteredGroups[index].id,
                              isGroupChat: true,
                            ),
                          ),
                        );
                      },
                      onLongPress: () =>
                          _onGroupLongPress(filteredGroups[index]),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> userData) {
    final userEmail = userData['email'] ?? '';
    final userName = userEmail.split('@')[0];
    final otherUserId = userData['uid'];
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final bool isOnline = userData['isOnline'] ?? false;
    final bool isRecentlyActive = _authService.isRecentlyActive(userData);
    final String lastSeenText = _authService.getLastSeenText(userData);

    return StreamBuilder<Map<String, dynamic>>(
      stream: _chatService.getChatPreviewStream(currentUserId, otherUserId),
      builder: (context, snapshot) {
        final previewText =
            snapshot.data?['message'] ??
            AppLocalizations.of(context)!.noMessages;
        final isUnread = snapshot.data?['isUnread'] ?? false;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isUnread
                ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isUnread
                ? Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.2),
                    width: 1,
                  )
                : null,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: _buildUserAvatar(
              userName,
              isOnline,
              isRecentlyActive,
              isUnread,
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    userName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                      color: isUnread
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                _buildOnlineStatusBadge(isOnline, isRecentlyActive),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (isUnread) ...[
                      Icon(
                        Icons.fiber_manual_record,
                        color: Theme.of(context).colorScheme.primary,
                        size: 8,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: Text(
                        previewText.isEmpty
                            ? AppLocalizations.of(context)!.noMessages
                            : previewText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isUnread
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isUnread
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  lastSeenText,
                  style: TextStyle(
                    fontSize: 12,
                    color: isOnline
                        ? Colors.green[600]
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                    fontWeight: isOnline ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isUnread)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.circle,
                      color: Colors.white,
                      size: 8,
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.4),
                    size: 20,
                  ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    receivedEmail: userEmail,
                    receivedId: otherUserId,
                  ),
                ),
              );
            },
            onLongPress: () => _onDirectChatLongPress(otherUserId, userEmail),
          ),
        );
      },
    );
  }

  void _onDirectChatLongPress(String otherUserId, String userEmail) async {
    final String? choice = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  child: Icon(Icons.delete_outline, color: Colors.white),
                ),
                title: Text(
                  AppLocalizations.of(context)!.delete,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(AppLocalizations.of(context)!.clearChat),
                onTap: () => Navigator.pop(context, 'hide'),
              ),
              const SizedBox(height: 4),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: const Icon(Icons.close),
                ),
                title: Text(AppLocalizations.of(context)!.cancel),
                onTap: () => Navigator.pop(context, 'cancel'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (choice == 'hide') {
      await _chatService.hideDirectChatWithUser(otherUserId);
      _showSnackBar('${AppLocalizations.of(context)!.clearChat} - $userEmail');
      setState(() {});
    }
  }

  void _onGroupLongPress(ChatRoom room) async {
    final String currentUserId = _authService.getCurrentUser()!.uid;
    final bool isCreator = room.createdBy == currentUserId;

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (isCreator)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.15),
                    child: Icon(
                      Icons.person_add,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: const Text('Add members'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _showAddMembersDialog(room.id);
                  },
                ),
              if (isCreator)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.withOpacity(0.15),
                    child: const Icon(
                      Icons.person_remove,
                      color: Colors.orange,
                    ),
                  ),
                  title: const Text('Remove member'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _showRemoveMemberDialog(room);
                  },
                ),
              if (isCreator)
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFEBEE),
                    child: Icon(Icons.delete_forever, color: Colors.redAccent),
                  ),
                  title: const Text('Delete group'),
                  onTap: () async {
                    Navigator.pop(context);
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete group'),
                        content: const Text(
                          'Are you sure you want to delete this group? This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(AppLocalizations.of(context)!.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(AppLocalizations.of(context)!.delete),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      final res = await _chatService.deleteGroupChat(room.id);
                      _showSnackBar(res['message'] ?? '');
                    }
                  },
                ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: const Icon(Icons.close),
                ),
                title: Text(AppLocalizations.of(context)!.cancel),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAddMembersDialog(String chatRoomId) async {
    final TextEditingController emailsController = TextEditingController();
    final List<String>? result = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add members'),
          content: TextField(
            controller: emailsController,
            decoration: const InputDecoration(
              hintText: 'Enter emails separated by commas',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final emails = emailsController.text
                    .split(',')
                    .map((e) => e.trim().toLowerCase())
                    .where((e) => e.isNotEmpty)
                    .toList();
                Navigator.pop(context, emails);
              },
              child: Text(AppLocalizations.of(context)!.add),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      final res = await _chatService.addMembersToGroupByEmails(
        chatRoomId,
        result,
      );
      _showSnackBar(res['message'] ?? '');
    }
  }

  Future<void> _showRemoveMemberDialog(ChatRoom room) async {
    final String currentUserId = _authService.getCurrentUser()!.uid;
    final members = room.participants
        .where((id) => id != currentUserId)
        .toList();

    // Resolve member emails for display
    final Map<String, String> uidToEmail = {};
    if (members.isNotEmpty) {
      final usersSnap = await FirebaseFirestore.instance
          .collection('Users')
          .where('uid', whereIn: members)
          .get();
      for (final doc in usersSnap.docs) {
        final data = doc.data();
        final uid = (data['uid'] as String?) ?? doc.id;
        final email = (data['email'] as String?) ?? '';
        uidToEmail[uid] = email;
      }
    }

    final String? selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(Icons.person_remove, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Remove member',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final userId = members[index];
                    final email = uidToEmail[userId] ?? userId;
                    final name = email.split('@').first;
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                        ),
                      ),
                      title: Text(name),
                      subtitle: Text(email),
                      trailing: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.redAccent,
                      ),
                      onTap: () => Navigator.pop(context, userId),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: Text(AppLocalizations.of(context)!.cancel),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null && selected.isNotEmpty) {
      final res = await _chatService.removeMemberFromGroup(room.id, selected);
      _showSnackBar(res['message'] ?? '');
    }
  }

  Widget _buildUserAvatar(
    String userName,
    bool isOnline,
    bool isRecentlyActive,
    bool isUnread,
  ) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          decoration: isUnread
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                    width: 2,
                  ),
                )
              : null,
          child: CircleAvatar(
            backgroundColor: isUnread
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primary.withOpacity(0.8),
            radius: 28,
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 18,
                fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ),
        Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.only(bottom: 2, right: 2),
          decoration: BoxDecoration(
            color: _getStatusColor(isOnline, isRecentlyActive),
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).scaffoldBackgroundColor,
              width: 2.5,
            ),
            boxShadow: [
              if (isOnline)
                BoxShadow(
                  color: _getStatusColor(
                    isOnline,
                    isRecentlyActive,
                  ).withOpacity(0.6),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: isOnline
              ? Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
        ),
        if (isUnread)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.red[600],
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.5),
                    blurRadius: 3,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOnlineStatusBadge(bool isOnline, bool isRecentlyActive) {
    if (!isOnline && !isRecentlyActive) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getStatusColor(isOnline, isRecentlyActive).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor(isOnline, isRecentlyActive).withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        isOnline
            ? AppLocalizations.of(context)!.online
            : AppLocalizations.of(context)!.active,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(isOnline, isRecentlyActive),
        ),
      ),
    );
  }

  Color _getStatusColor(bool isOnline, bool isRecentlyActive) {
    if (isOnline) {
      return Colors.green[500]!;
    } else if (isRecentlyActive) {
      return Colors.orange[500]!;
    } else {
      return Colors.grey[400]!;
    }
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.somethingWentWrong,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.loading,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _currentIndex == 0 ? Icons.people_outline : Icons.group_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (message.contains(
                AppLocalizations.of(context)!.noChatUsersYet.split("\\n").first,
              ) ||
              message.contains(
                AppLocalizations.of(
                  context,
                )!.noGroupChatsYet.split("\\n").first,
              ))
            Text(
              _currentIndex == 0
                  ? AppLocalizations.of(context)!.useThePlusButtonToAddUsers
                  : AppLocalizations.of(
                      context,
                    )!.useThePlusButtonToCreateGroupChat,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
