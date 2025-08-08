// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ChitChat';

  @override
  String get welcomeBack => 'Welcome back, you\'ve been missed!';

  @override
  String get createAccount => 'Let\'s create an account for you!';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get notAMember => 'Not a member?';

  @override
  String get registerNow => 'Register now';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get loginNow => 'Login now';

  @override
  String get settings => 'Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get home => 'Home';

  @override
  String get chats => 'Chats';

  @override
  String get groups => 'Groups';

  @override
  String get search => 'Search';

  @override
  String get searchUsers => 'Search users...';

  @override
  String get noUsersFound => 'No users found.';

  @override
  String get noChatUsersYet =>
      'No chat users yet.\nTap the + button to add someone!';

  @override
  String get noGroupChatsYet =>
      'No group chats yet.\nTap the + button to create one!';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get loading => 'Loading...';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get addUserToChat => 'Add User to Chat';

  @override
  String get enterEmailAddress =>
      'Enter the email address of the user you want to chat with:';

  @override
  String get createGroupChat => 'Create Group Chat';

  @override
  String get groupName => 'Group Name';

  @override
  String get enterGroupName => 'Enter group name...';

  @override
  String get addParticipantEmail => 'Add Participant Email';

  @override
  String get enterEmailAndPressEnter => 'Enter email and press Enter';

  @override
  String get participants => 'Participants';

  @override
  String get addAtLeast2Participants =>
      'Add at least 2 participants to create a group chat';

  @override
  String get youCannotAddYourself => 'You cannot add yourself to the group';

  @override
  String get userAlreadyAdded => 'User already added to the group';

  @override
  String get groupChatMustHave3Participants =>
      'Group chat must have at least 3 participants (including you)';

  @override
  String get userAddedSuccessfully => 'User added successfully!';

  @override
  String get groupChatCreatedSuccessfully => 'Group chat created successfully!';

  @override
  String errorAddingUser(String error) {
    return 'Error adding user: $error';
  }

  @override
  String errorCreatingGroupChat(String error) {
    return 'Error creating group chat: $error';
  }

  @override
  String get pleaseEnterEmail => 'Please enter an email address';

  @override
  String get pleaseEnterPassword => 'Please enter an email password';

  @override
  String get pleaseEnterGroupName => 'Please enter a group name';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get pleaseFillOutAllFields => 'Please fill out all fields';

  @override
  String get registrationSuccessful => 'Registration Successful';

  @override
  String get loginSuccessful => 'Login Successful';

  @override
  String get pleaseEnterBothEmailAndPassword =>
      'Please enter both email and password.';

  @override
  String get passwordMustBeAtLeast6Characters =>
      'Password MustBe AtLeast 6 Characters';

  @override
  String get pleaseEnterValidEmail => 'Please Enter Valid Email!!';

  @override
  String get online => 'Online';

  @override
  String get active => 'Active';

  @override
  String get lastSeen => 'Last seen';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String hoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String isTyping(String user) {
    return 'is typing...';
  }

  @override
  String get messageRemoved => 'Message has been removed';

  @override
  String messageRemovedBy(String user) {
    return 'Message removed by $user';
  }

  @override
  String get edited => 'edited';

  @override
  String get clearChat => 'Clear Chat';

  @override
  String get blockUser => 'Block User';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get reply => 'Reply';

  @override
  String get noMessages => 'No messages';

  @override
  String get useThePlusButtonToAddUsers =>
      'Use the + button to add users to chat with';

  @override
  String get useThePlusButtonToCreateGroupChat =>
      'Use the + button to create a group chat';

  @override
  String get english => 'English';

  @override
  String get chinese => '中文';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get profile => 'Profile';

  @override
  String get notifications => 'Notifications';

  @override
  String get privacy => 'Privacy';

  @override
  String get help => 'Help';

  @override
  String get feedback => 'Feedback';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get rateApp => 'Rate App';

  @override
  String get shareApp => 'Share App';

  @override
  String get reportBug => 'Report Bug';

  @override
  String get suggestFeature => 'Suggest Feature';

  @override
  String get create => 'Create';

  @override
  String get searchMessages => 'Search Messages';

  @override
  String get searchMessagesHint => 'Search for messages...';

  @override
  String get deleteMessageTitle => 'Delete Message';

  @override
  String get deleteMessageConfirm =>
      'Are you sure you want to delete this message?';

  @override
  String get save => 'Save';

  @override
  String get editMessageTitle => 'Edit Message';

  @override
  String get typeAMessage => 'Type a message...';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get startTheConversation => 'Start the conversation!';

  @override
  String get error => 'Error';

  @override
  String get main => 'Main';

  @override
  String get account => 'Account';

  @override
  String get support => 'Support';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get sendFeedback => 'Send Feedback';

  @override
  String get appName => 'Chat App';

  @override
  String get appDescription =>
      'A modern chat application built with Flutter and Firebase.';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changeAvatar => 'Change Avatar';

  @override
  String get appearance => 'Appearance';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get sound => 'Sound';

  @override
  String get vibration => 'Vibration';

  @override
  String get onlineStatus => 'Online Status';

  @override
  String get blockedUsers => 'Blocked Users';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get appVersion => 'App Version';

  @override
  String get selectLanguageTitle => 'Select Language';

  @override
  String get signInToContinue => 'Sign in to continue your conversations';

  @override
  String get signIn => 'sign In';

  @override
  String get signUp => 'sign Up';

  @override
  String get or => 'Or';

  @override
  String get dontHaveAnAccount => 'Don\'t have an account? ';

  @override
  String get bySigningInYouAgreeToOurTermsOfServiceAndPrivacyPolicy =>
      'By signing in, you agree to our Terms of Service and Privacy Policy';

  @override
  String get joinUsAndStartChattingWithFriends =>
      'Join us and start chatting with friends';

  @override
  String get pleaseconfirmPassword => 'Please confirm password';

  @override
  String get byCreatingAnAccountYouAgreeToOurTermsOfServiceAndPrivacyPolicy =>
      'By creating an account, you agree to our Terms of Service and Privacy Policy';

  @override
  String get areYouSureYouWantToDeleteThisMessage =>
      'Are you sure you want to delete this message?';

  @override
  String get image => 'Image';

  @override
  String get file => 'File';

  @override
  String errorLoggingOut(Object error) {
    return 'Error logging out: $error';
  }
}
