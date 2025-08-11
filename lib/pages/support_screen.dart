import 'package:chat_app/pages/feedback_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chat_app/gen_l10n/app_localizations.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<FAQ> _faqs = [
    FAQ(
      question: "How do I start a new chat?",
      answer:
          "To start a new chat, tap the '+' button on the main screen, then select a contact from your list or enter their email address. You can start typing your message right away!",
      category: "Getting Started",
    ),
    FAQ(
      question: "How do I know if someone is online?",
      answer:
          "You can see a user's online status by looking at the colored indicator next to their profile picture. Green means online, orange means recently active, and gray means offline.",
      category: "General",
    ),
    FAQ(
      question: "Can I delete messages after sending them?",
      answer:
          "Yes! Long press on any message you've sent to see options including edit and delete. Note that deleted messages will show as 'Message deleted' to other users.",
      category: "Messages",
    ),
    FAQ(
      question: "How do I reply to a specific message?",
      answer:
          "Long press on any message and select 'Reply' from the menu. The message you're replying to will appear above your text input field.",
      category: "Messages",
    ),
    FAQ(
      question: "Why aren't my messages being delivered?",
      answer:
          "Check your internet connection first. If the issue persists, try restarting the app. Messages are marked with status indicators: sent, delivered, and read.",
      category: "Troubleshooting",
    ),
    FAQ(
      question: "How do I change my profile information?",
      answer:
          "Go to Settings > Profile to update your name, profile picture, and status message. Changes will be visible to all your contacts.",
      category: "Profile",
    ),
    FAQ(
      question: "Is my data secure and private?",
      answer:
          "Yes, we take privacy seriously. All messages are encrypted, and we don't share your personal information with third parties. Your data is stored securely on our servers.",
      category: "Privacy",
    ),
    FAQ(
      question: "How do I report inappropriate content or users?",
      answer:
          "Long press on any message or go to a user's profile to find the report option. We review all reports promptly and take appropriate action.",
      category: "Safety",
    ),
  ];

  final List<SupportOption> _supportOptions = [
    SupportOption(
      title: "Contact Support",
      subtitle: "Get help from our support team",
      icon: Icons.support_agent,
      action: SupportAction.email,
      value: "tfortest14@gmail.com",
    ),
    SupportOption(
      title: "Live Chat",
      subtitle: "Chat with us in real-time",
      icon: Icons.chat_bubble_outline,
      action: SupportAction.liveChat,
    ),
    SupportOption(
      title: "Report a Bug",
      subtitle: "Help us improve the app",
      icon: Icons.bug_report,
      action: SupportAction.bugReport,
    ),
    SupportOption(
      title: "Feature Request",
      subtitle: "Suggest new features",
      icon: Icons.lightbulb_outline,
      action: SupportAction.featureRequest,
    ),
    SupportOption(
      title: "User Guide",
      subtitle: "Step-by-step tutorials",
      icon: Icons.menu_book,
      action: SupportAction.userGuide,
    ),
    SupportOption(
      title: "Community Forum",
      subtitle: "Connect with other users",
      icon: Icons.forum,
      action: SupportAction.forum,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.help_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Help & Support'),
          ],
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.help_outline), text: 'FAQ'),
            Tab(icon: Icon(Icons.support), text: 'Support'),
            Tab(icon: Icon(Icons.info_outline), text: 'About'),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: TabBarView(
            controller: _tabController,
            children: [_buildFAQTab(), _buildSupportTab(), _buildAboutTab()],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQTab() {
    final categories = _faqs.map((faq) => faq.category).toSet().toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          const SizedBox(height: 24),
          Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...categories.map((category) => _buildFAQCategory(category)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for help...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                onChanged: (value) {
                  // TODO: Implement search functionality
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQCategory(String category) {
    final categoryFAQs = _faqs
        .where((faq) => faq.category == category)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            category,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...categoryFAQs.map((faq) => _buildFAQItem(faq)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFAQItem(FAQ faq) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              faq.answer,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSupportHeader(),
          const SizedBox(height: 24),
          Text(
            'How can we help you?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ..._supportOptions.map((option) => _buildSupportOption(option)),
          const SizedBox(height: 24),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildSupportHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.support_agent,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Need Help?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Our support team is here to help you 24/7',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOption(SupportOption option) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            option.icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          option.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(option.subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _handleSupportAction(option),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    'Restart Tutorial',
                    Icons.play_circle_outline,
                    () => _showFeatureDialog('Tutorial'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    'Reset Settings',
                    Icons.settings_backup_restore,
                    () => _showFeatureDialog('Reset Settings'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppInfoCard(),
          const SizedBox(height: 24),
          _buildVersionInfo(),
          const SizedBox(height: 24),
          _buildLegalSection(),
          const SizedBox(height: 24),
          _buildDeveloperInfo(),
        ],
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.chat,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Chat App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Connect with friends and family through secure, real-time messaging',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Version', '1.0.0'),
            _buildInfoRow('Build', '100'),
            _buildInfoRow('Last Updated', 'August 2025'),
            _buildInfoRow('Platform', 'Flutter'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildLegalSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showFeatureDialog('Terms of Service'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showFeatureDialog('Privacy Policy'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.gavel),
            title: const Text('Licenses'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showFeatureDialog('Licenses'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperInfo() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Developer',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Made with ❤️ by Snoopy',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '© 2025 Chat App. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSupportAction(SupportOption option) {
    switch (option.action) {
      case SupportAction.email:
        _sendEmail(option.value!);
        break;
      case SupportAction.liveChat:
        _showFeatureDialog('Live Chat');
        break;
      case SupportAction.bugReport:
      case SupportAction.featureRequest:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FeedbackScreen()),
        );
        break;
      case SupportAction.userGuide:
        _showFeatureDialog('User Guide');
        break;
      case SupportAction.forum:
        _showFeatureDialog('Community Forum');
        break;
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${Uri.encodeComponent('Support Request - Chat App')}',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showErrorDialog('Could not open email client');
    }
  }

  void _showFeatureDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: Text('$feature feature is coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Data models
class FAQ {
  final String question;
  final String answer;
  final String category;

  FAQ({required this.question, required this.answer, required this.category});
}

class SupportOption {
  final String title;
  final String subtitle;
  final IconData icon;
  final SupportAction action;
  final String? value;

  SupportOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.action,
    this.value,
  });
}

enum SupportAction {
  email,
  liveChat,
  bugReport,
  featureRequest,
  userGuide,
  forum,
}

// Add this import to your feedback screen file
// import 'package:chat_app/screens/feedback_screen.dart';
