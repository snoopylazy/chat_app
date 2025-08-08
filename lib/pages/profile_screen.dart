import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/gen_l10n/app_localizations.dart';
import 'package:chat_app/services/auth/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isEditing = false;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
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
    _loadUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          _displayNameController.text =
              doc.data()?['displayName'] ??
              (user.email?.contains('@') == true
                  ? user.email!.split('@')[0]
                  : 'User');
          _bioController.text = doc.data()?['bio'] ?? '';
        });
      } else {
        setState(() {
          _displayNameController.text = user.email?.contains('@') == true
              ? user.email!.split('@')[0]
              : 'User';
          _bioController.text = '';
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
          'displayName': _displayNameController.text,
          'bio': _bioController.text,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        _showSuccessDialog();
        setState(() {
          _isEditing = false;
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to update profile: $e');
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await AuthService().signOut();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showErrorDialog('Failed to sign out: $e');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            const Text('Success!'),
          ],
        ),
        content: const Text('Your profile has been updated successfully.'),
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
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            const Text('Error'),
          ],
        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.person_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Profile'),
          ],
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () => setState(() => _isEditing = !_isEditing),
            tooltip: _isEditing ? 'Cancel' : 'Edit Profile',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseAuth.instance.currentUser != null
                  ? FirebaseFirestore.instance
                        .collection('Users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .snapshots()
                  : null,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  final userEmail =
                      FirebaseAuth.instance.currentUser?.email ?? 'No email';
                  final userName = userEmail.contains('@')
                      ? userEmail.split('@')[0]
                      : 'User';
                  final avatarLetter = userName.isNotEmpty
                      ? userName[0].toUpperCase()
                      : 'U';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderCard({}, userName, avatarLetter),
                      const SizedBox(height: 24),
                      _buildProfileInfoSection({}, userEmail),
                      const SizedBox(height: 24),
                      if (_isEditing) _buildEditProfileForm(),
                      const SizedBox(height: 24),
                      _buildSignOutButton(),
                      const SizedBox(height: 16),
                    ],
                  );
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>;
                final userEmail =
                    FirebaseAuth.instance.currentUser?.email ?? 'No email';
                final userName =
                    userData['displayName'] ??
                    (userEmail.contains('@')
                        ? userEmail.split('@')[0]
                        : 'User');
                final avatarLetter = userName.isNotEmpty
                    ? userName[0].toUpperCase()
                    : 'U';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(userData, userName, avatarLetter),
                    const SizedBox(height: 24),
                    _buildProfileInfoSection(userData, userEmail),
                    const SizedBox(height: 24),
                    if (_isEditing) _buildEditProfileForm(),
                    const SizedBox(height: 24),
                    _buildSignOutButton(),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
    Map<String, dynamic> userData,
    String userName,
    String avatarLetter,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
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
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                avatarLetter,
                style: TextStyle(
                  fontSize: 32,
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              userName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AuthService().getLastSeenText(userData),
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

  Widget _buildProfileInfoSection(
    Map<String, dynamic> userData,
    String userEmail,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Profile Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.email,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                userEmail,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (userData['bio'] != null && userData['bio'].isNotEmpty)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.description,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  userData['bio'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditProfileForm() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  hintText: 'Enter your display name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a display name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: InputDecoration(
                  labelText: 'Bio (Optional)',
                  hintText: 'Tell us about yourself',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isUpdating ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isUpdating
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text('Updating...'),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.save),
                            const SizedBox(width: 8),
                            const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _signOut,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout),
            const SizedBox(width: 8),
            const Text(
              'Sign Out',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
