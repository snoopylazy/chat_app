import 'package:chat_app/components/my_drawer.dart';
import 'package:chat_app/pages/chat_screen.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/services/chats/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Show dialog to add new user
  void _showAddUserDialog() {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add User to Chat'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter the email address of the user you want to chat with:'),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _addUserToChat(emailController.text.trim()),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Add user to chat list
  Future<void> _addUserToChat(String email) async {
    if (email.isEmpty) {
      _showSnackBar('Please enter an email address', isError: true);
      return;
    }

    if (email.toLowerCase() == _currentUser?.email?.toLowerCase()) {
      _showSnackBar('You cannot add yourself to chat', isError: true);
      return;
    }

    try {
      Navigator.of(context).pop(); // Close dialog

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final result = await _chatService.addUserToChat(email);

      Navigator.of(context).pop(); // Close loading

      if (result['success']) {
        _showSnackBar('User added successfully!');
      } else {
        _showSnackBar(result['message'], isError: true);
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading
      _showSnackBar('Error adding user: $e', isError: true);
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
            ? const Text(
          "ChitChat",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        )
            : TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Search users...",
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.5),
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
        onPressed: _showAddUserDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.person_add),
      ),
      body: Column(
        children: [
          Container(
            height: 1,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatService.getChatUsersStream(), // Changed to only show chat users
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }
        if (!snapshot.hasData) {
          return _buildNoDataWidget("No data available");
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
          return _buildNoDataWidget(_searchQuery.isEmpty
              ? "No chat users yet.\nTap the + button to add someone!"
              : "No users found.");
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: filteredUsers.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            indent: 72,
          ),
          itemBuilder: (context, index) {
            return _buildUserListItem(filteredUsers[index]);
          },
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
        final previewText = snapshot.data?['message'] ?? 'No messages';
        final isUnread = snapshot.data?['isUnread'] ?? false;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            // Enhanced background for unread messages
            color: isUnread
                ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            // Add subtle border for unread messages
            border: isUnread
                ? Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              width: 1,
            )
                : null,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: _buildUserAvatar(userName, isOnline, isRecentlyActive, isUnread),
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
                    // Add message icon for unread messages
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
                        previewText.isEmpty ? 'No messages' : previewText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                          color: isUnread
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.circle,
                      color: Colors.white,
                      size: 8,
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    size: 20,
                  ),
              ],
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          ),
        );
      },
    );
  }

  Widget _buildUserAvatar(String userName, bool isOnline, bool isRecentlyActive, bool isUnread) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          decoration: isUnread
              ? BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
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
        // Enhanced online status indicator
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
                  color: _getStatusColor(isOnline, isRecentlyActive).withOpacity(0.6),
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
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          )
              : null,
        ),
        // Unread message indicator on avatar
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
        isOnline ? 'Online' : 'Active',
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
          Icon(Icons.error_outline,
              size: 64, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text(
            "Something went wrong",
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
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            "Loading users...",
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
          Icon(Icons.people_outline,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
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
          if (message.contains("No chat users yet"))
            Text(
              "Use the + button to add users to chat with",
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