import 'package:chat_app/pages/feedback_screen.dart';
import 'package:chat_app/pages/profile_screen.dart';
import 'package:chat_app/pages/stub_screen.dart';
import 'package:chat_app/pages/support_screen.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/themes/theme_provider.dart';
import 'package:chat_app/providers/language_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _sound = true;
  bool _vibration = true;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
    _loadOnlineStatus();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _sound = prefs.getBool('sound') ?? true;
      _vibration = prefs.getBool('vibration') ?? true;
    });
  }

  Future<void> _saveNotificationSettings(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _loadOnlineStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();
      setState(() {
        _isOnline = doc.data()?['isOnline'] ?? true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(context),
            const SizedBox(height: 24),
            _buildAppearanceSection(context),
            const SizedBox(height: 24),
            _buildLanguageSection(context),
            const SizedBox(height: 24),
            _buildNotificationsSection(context),
            const SizedBox(height: 24),
            _buildPrivacySection(context),
            const SizedBox(height: 24),
            _buildSupportSection(context),
            const SizedBox(height: 24),
            _buildAboutSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return _buildSectionCard(
      context,
      title: AppLocalizations.of(context)!.profile,
      icon: Icons.person_outline,
      children: [
        _buildSettingTile(
          context,
          icon: Icons.edit,
          title: AppLocalizations.of(context)!.editProfile,
          subtitle: AppLocalizations.of(context)!.updateYourProfileDetails,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
        ),
        _buildSettingTile(
          context,
          icon: Icons.photo_camera,
          title: AppLocalizations.of(context)!.changeAvatar,
          subtitle: AppLocalizations.of(context)!.updateYourAvatar,
          onTap: () {
            _showAvatarDialog(context);
          },
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    return _buildSectionCard(
      context,
      title: AppLocalizations.of(context)!.appearance,
      icon: Icons.palette_outlined,
      children: [
        _buildSwitchTile(
          context,
          icon: Icons.dark_mode,
          title: AppLocalizations.of(context)!.darkMode,
          subtitle: AppLocalizations.of(context)!.toggleDarkLightMode,
          value: Provider.of<ThemeProvider>(context).isDarkMode,
          onChanged: (value) {
            Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
          },
        ),
      ],
    );
  }

  Widget _buildLanguageSection(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLanguage = languageProvider.locale.languageCode;

    return _buildSectionCard(
      context,
      title: AppLocalizations.of(context)!.language,
      icon: Icons.language,
      children: [
        _buildSettingTile(
          context,
          icon: Icons.translate,
          title: AppLocalizations.of(context)!.selectLanguageTitle,
          subtitle:
              "${AppLocalizations.of(context)!.language}: ${languageProvider.getLanguageName(currentLanguage)}",
          onTap: () {
            _showLanguageDialog(context);
          },
        ),
      ],
    );
  }

  Widget _buildNotificationsSection(BuildContext context) {
    return _buildSectionCard(
      context,
      title: AppLocalizations.of(context)!.notifications,
      icon: Icons.notifications_outlined,
      children: [
        _buildSwitchTile(
          context,
          icon: Icons.notifications_active,
          title: AppLocalizations.of(context)!.pushNotifications,
          subtitle: AppLocalizations.of(context)!.receivePushNotifications,
          value: _pushNotifications,
          onChanged: (value) {
            setState(() {
              _pushNotifications = value;
            });
            _saveNotificationSettings('push_notifications', value);
          },
        ),
        _buildSwitchTile(
          context,
          icon: Icons.volume_up,
          title: AppLocalizations.of(context)!.sound,
          subtitle: AppLocalizations.of(context)!.enableNotificationSound,
          value: _sound,
          onChanged: (value) {
            setState(() {
              _sound = value;
            });
            _saveNotificationSettings('sound', value);
          },
        ),
        _buildSwitchTile(
          context,
          icon: Icons.vibration,
          title: AppLocalizations.of(context)!.vibration,
          subtitle: AppLocalizations.of(context)!.enableNotificationVibration,
          value: _vibration,
          onChanged: (value) {
            setState(() {
              _vibration = value;
            });
            _saveNotificationSettings('vibration', value);
          },
        ),
      ],
    );
  }

  Widget _buildPrivacySection(BuildContext context) {
    return _buildSectionCard(
      context,
      title: AppLocalizations.of(context)!.privacy,
      icon: Icons.security,
      children: [
        _buildSwitchTile(
          context,
          icon: Icons.visibility,
          title: AppLocalizations.of(context)!.onlineStatus,
          subtitle: AppLocalizations.of(context)!.showOnlineStatus,
          value: _isOnline,
          onChanged: (value) {
            setState(() {
              _isOnline = value;
            });
            AuthService().setUserOnlineStatus(value);
          },
        ),
        _buildSettingTile(
          context,
          icon: Icons.block,
          title: AppLocalizations.of(context)!.blockedUsers,
          subtitle: AppLocalizations.of(context)!.manageBlockedUsers,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BlockedUsersScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return _buildSectionCard(
      context,
      title: AppLocalizations.of(context)!.support,
      icon: Icons.help_outline,
      children: [
        _buildSettingTile(
          context,
          icon: Icons.help,
          title: AppLocalizations.of(context)!.helpCenter,
          subtitle: AppLocalizations.of(context)!.getHelpAndSupport,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HelpSupportScreen(),
              ),
            );
          },
        ),
        _buildSettingTile(
          context,
          icon: Icons.feedback,
          title: AppLocalizations.of(context)!.sendFeedback,
          subtitle: AppLocalizations.of(context)!.shareYourFeedback,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FeedbackScreen()),
            );
          },
        ),
        _buildSettingTile(
          context,
          icon: Icons.bug_report,
          title: AppLocalizations.of(context)!.reportBug,
          subtitle: AppLocalizations.of(context)!.reportIssues,
          onTap: () {
            _showBugReportDialog(context);
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return _buildSectionCard(
      context,
      title: AppLocalizations.of(context)!.about,
      icon: Icons.info_outline,
      children: [
        _buildSettingTile(
          context,
          icon: Icons.info,
          title: AppLocalizations.of(context)!.appVersion,
          subtitle: "${AppLocalizations.of(context)!.appName} v1.0.0",
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: AppLocalizations.of(context)!.appName,
              applicationVersion: "1.0.0",
              applicationIcon: Icon(
                Icons.chat_bubble_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 48,
              ),
              children: [Text(AppLocalizations.of(context)!.appDescription)],
            );
          },
        ),
        _buildSettingTile(
          context,
          icon: Icons.description,
          title: AppLocalizations.of(context)!.termsOfService,
          subtitle: AppLocalizations.of(context)!.viewTermsOfService,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StubScreen(
                  title: 'Terms of Service',
                  icon: Icons.supervised_user_circle_outlined,
                ),
              ),
            );
          },
        ),
        _buildSettingTile(
          context,
          icon: Icons.privacy_tip,
          title: AppLocalizations.of(context)!.privacyPolicy,
          subtitle: AppLocalizations.of(context)!.viewPrivacyPolicy,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StubScreen(
                  title: 'Privacy Policy',
                  icon: Icons.policy,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          fontSize: 12,
        ),
      ),
      trailing: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final supportedLanguages = languageProvider.getSupportedLanguages();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.selectLanguageTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: supportedLanguages.map((language) {
              return ListTile(
                leading: Icon(
                  Icons.language,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(language['name']!),
                trailing:
                    languageProvider.locale.languageCode == language['code']
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  languageProvider.setLocale(Locale(language['code']!));
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        );
      },
    );
  }

  void _showAvatarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.changeAvatar),
          content: Text(
            AppLocalizations.of(context)!.avatarUploadNotImplemented,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.avatarUpdated),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.select),
            ),
          ],
        );
      },
    );
  }

  void _showBugReportDialog(BuildContext context) {
    final TextEditingController bugController = TextEditingController();
    final currentUser = FirebaseAuth.instance.currentUser;
    final userEmail = currentUser?.email ?? 'Unknown';
    final userId = currentUser?.uid ?? 'Unknown';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.reportBug),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.bugReportInfo,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: bugController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.describeTheIssue,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (bugController.text.isNotEmpty) {
                  final subject = Uri.encodeComponent(
                    'Bug Report from Chat App',
                  );
                  final body = Uri.encodeComponent('''
                  Bug Description: ${bugController.text}

                  Reported by:
                  - Email: $userEmail
                  - User ID: $userId
                  - App Version: 1.0.0
                  - Timestamp: ${DateTime.now().toIso8601String()}
                  ''');
                  final uri = Uri.parse(
                    'mailto:tfortes14@gmail.com?subject=$subject&body=$body',
                  );

                  try {
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.bugReported,
                          ),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.errorSendingBugReport,
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.errorSendingBugReport,
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.bugReportEmpty,
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(AppLocalizations.of(context)!.submit),
            ),
          ],
        );
      },
    );
  }
}

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.blockedUsers),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: currentUser != null
            ? FirebaseFirestore.instance
                  .collection('Users')
                  .doc(currentUser.uid)
                  .snapshots()
            : null,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final blockedUsers =
              (snapshot.data?.data() as Map<String, dynamic>?)?['blockedUsers']
                  as List<dynamic>? ??
              [];

          if (blockedUsers.isEmpty) {
            return Center(
              child: Text(
                AppLocalizations.of(context)!.noBlockedUsers,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: blockedUsers.length,
            itemBuilder: (context, index) {
              final userId = blockedUsers[index];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(userId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(title: Text('Loading...'));
                  }
                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  final email = userData['email'] ?? 'Unknown';
                  final name =
                      userData['displayName'] ??
                      (email.contains('@') ? email.split('@')[0] : 'User');

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(name),
                    subtitle: Text(email),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        _unblockUser(context, userId);
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _unblockUser(BuildContext context, String userId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .update({
              'blockedUsers': FieldValue.arrayRemove([userId]),
            });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.userUnblocked),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${AppLocalizations.of(context)!.errorUnblockingUser} ${e.toString()}",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
