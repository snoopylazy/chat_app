import 'package:chat_app/components/user_tile.dart';
import 'package:chat_app/pages/chat_screen.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/components/my_drawer.dart';
import 'package:chat_app/services/chats/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Messages",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              // Add search functionality later
            },
          ),
        ],
      ),
      drawer: const MyDrawer(),
      backgroundColor: Theme.of(context).colorScheme.surface,
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
    return StreamBuilder(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
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
                  "Something went wrong",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Error: ${snapshot.error}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
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

        if (!snapshot.hasData) {
          return Center(
            child: Text(
              "No data available",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          );
        }

        final users = snapshot.data as List<Map<String, dynamic>>;
        final filteredUsers = users.where((userData) {
          final userEmail = userData['email'] ?? '';
          return _currentUser != null && userEmail != _currentUser!.email && userEmail.isNotEmpty;
        }).toList();

        if (filteredUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  "No users found",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Ask your friends to register!",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
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
    final userName = userEmail.split('@')[0]; // Get username part of email

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          radius: 28,
          child: Text(
            userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          userName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          userEmail,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
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
                receivedId: userData['uid'],
              ),
            ),
          );
        },
      ),
    );
  }
}