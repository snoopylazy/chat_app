import 'package:chat_app/themes/theme_provider.dart';
import 'package:chat_app/providers/language_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
            // Profile Section
            _buildProfileSection(context),
            const SizedBox(height: 24),

            // Appearance Section
            _buildAppearanceSection(context),
            const SizedBox(height: 24),

            // Language Section
            _buildLanguageSection(context),
            const SizedBox(height: 24),

            // Notifications Section
            _buildNotificationsSection(context),
            const SizedBox(height: 24),

            // Privacy Section
            _buildPrivacySection(context),
            const SizedBox(height: 24),

            // Support Section
            _buildSupportSection(context),
            const SizedBox(height: 24),

            // About Section
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
          subtitle: AppLocalizations.of(context)!.help,
          onTap: () {
            // TODO: Implement edit profile
          },
        ),
        _buildSettingTile(
          context,
          icon: Icons.photo_camera,
          title: AppLocalizations.of(context)!.changeAvatar,
          subtitle: AppLocalizations.of(context)!.help,
          onTap: () {
            // TODO: Implement change avatar
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
          subtitle: AppLocalizations.of(context)!.appearance,
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
          subtitle: AppLocalizations.of(context)!.notifications,
          value: true,
          onChanged: (value) {
            // TODO: Implement push notifications toggle
          },
        ),
        _buildSwitchTile(
          context,
          icon: Icons.volume_up,
          title: AppLocalizations.of(context)!.sound,
          subtitle: AppLocalizations.of(context)!.notifications,
          value: true,
          onChanged: (value) {
            // TODO: Implement sound toggle
          },
        ),
        _buildSwitchTile(
          context,
          icon: Icons.vibration,
          title: AppLocalizations.of(context)!.vibration,
          subtitle: AppLocalizations.of(context)!.notifications,
          value: true,
          onChanged: (value) {
            // TODO: Implement vibration toggle
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
        _buildSettingTile(
          context,
          icon: Icons.visibility,
          title: AppLocalizations.of(context)!.onlineStatus,
          subtitle: AppLocalizations.of(context)!.privacy,
          onTap: () {
            // TODO: Implement online status toggle
          },
        ),
        _buildSettingTile(
          context,
          icon: Icons.block,
          title: AppLocalizations.of(context)!.blockedUsers,
          subtitle: AppLocalizations.of(context)!.privacy,
          onTap: () {
            // TODO: Implement blocked users
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
          subtitle: AppLocalizations.of(context)!.help,
          onTap: () {
            // TODO: Implement help center
          },
        ),
        _buildSettingTile(
          context,
          icon: Icons.feedback,
          title: AppLocalizations.of(context)!.sendFeedback,
          subtitle: AppLocalizations.of(context)!.feedback,
          onTap: () {
            // TODO: Implement feedback
          },
        ),
        _buildSettingTile(
          context,
          icon: Icons.bug_report,
          title: AppLocalizations.of(context)!.reportBug,
          subtitle: AppLocalizations.of(context)!.help,
          onTap: () {
            // TODO: Implement bug report
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
              applicationName: "Chat App",
              applicationVersion: "1.0.0",
              applicationIcon: Icon(
                Icons.chat_bubble_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 48,
              ),
              children: [
                const Text(
                  "A modern chat application built with Flutter and Firebase.",
                ),
              ],
            );
          },
        ),
        _buildSettingTile(
          context,
          icon: Icons.description,
          title: AppLocalizations.of(context)!.termsOfService,
          subtitle: AppLocalizations.of(context)!.termsOfService,
          onTap: () {
            // TODO: Implement terms of service
          },
        ),
        _buildSettingTile(
          context,
          icon: Icons.privacy_tip,
          title: AppLocalizations.of(context)!.privacyPolicy,
          subtitle: AppLocalizations.of(context)!.privacyPolicy,
          onTap: () {
            // TODO: Implement privacy policy
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
          title: const Text("Select Language"),
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
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}
