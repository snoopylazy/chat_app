// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '聊天应用';

  @override
  String get welcomeBack => '欢迎回来，我们想你了！';

  @override
  String get createAccount => '让我们为您创建一个账户！';

  @override
  String get email => '邮箱';

  @override
  String get password => '密码';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get login => '登录';

  @override
  String get register => '注册';

  @override
  String get notAMember => '还不是会员？';

  @override
  String get registerNow => '立即注册';

  @override
  String get alreadyHaveAccount => '已有账户？';

  @override
  String get loginNow => '立即登录';

  @override
  String get settings => '设置';

  @override
  String get darkMode => '深色模式';

  @override
  String get language => '语言';

  @override
  String get about => '关于';

  @override
  String get version => '版本';

  @override
  String get logout => '退出登录';

  @override
  String get logoutConfirm => '您确定要退出登录吗？';

  @override
  String get cancel => '取消';

  @override
  String get add => '添加';

  @override
  String get home => '首页';

  @override
  String get chats => '聊天';

  @override
  String get groups => '群组';

  @override
  String get search => '搜索';

  @override
  String get searchUsers => '搜索用户...';

  @override
  String get noUsersFound => '未找到用户。';

  @override
  String get noChatUsersYet => '还没有聊天用户。\n点击 + 按钮添加联系人！';

  @override
  String get noGroupChatsYet => '还没有群聊。\n点击 + 按钮创建一个！';

  @override
  String get noDataAvailable => '暂无数据';

  @override
  String get loading => '加载中...';

  @override
  String get somethingWentWrong => '出现了一些问题';

  @override
  String get addUserToChat => '添加聊天用户';

  @override
  String get enterEmailAddress => '输入您想要聊天的用户邮箱地址：';

  @override
  String get createGroupChat => '创建群聊';

  @override
  String get groupName => '群组名称';

  @override
  String get enterGroupName => '输入群组名称...';

  @override
  String get addParticipantEmail => '添加参与者邮箱';

  @override
  String get enterEmailAndPressEnter => '输入邮箱并按回车';

  @override
  String get participants => '参与者';

  @override
  String get addAtLeast2Participants => '至少添加2个参与者来创建群聊';

  @override
  String get youCannotAddYourself => '您不能将自己添加到群组中';

  @override
  String get userAlreadyAdded => '用户已添加到群组中';

  @override
  String get groupChatMustHave3Participants => '群聊必须至少有3个参与者（包括您）';

  @override
  String get userAddedSuccessfully => '用户添加成功！';

  @override
  String get groupChatCreatedSuccessfully => '群聊创建成功！';

  @override
  String errorAddingUser(String error) {
    return '添加用户时出错：$error';
  }

  @override
  String errorCreatingGroupChat(String error) {
    return '创建群聊时出错：$error';
  }

  @override
  String get pleaseEnterEmail => '请输入邮箱地址';

  @override
  String get pleaseEnterPassword => '請輸入密碼';

  @override
  String get pleaseEnterGroupName => '请输入群组名称';

  @override
  String get passwordsDoNotMatch => '密码不匹配';

  @override
  String get pleaseFillOutAllFields => '请填写所有字段';

  @override
  String get registrationSuccessful => '註冊成功';

  @override
  String get loginSuccessful => '登录成功';

  @override
  String get pleaseEnterBothEmailAndPassword => '请输入邮箱和密码。';

  @override
  String get passwordMustBeAtLeast6Characters => '密碼必須至少 6 個字元';

  @override
  String get pleaseEnterValidEmail => '請輸入驗證電子郵件';

  @override
  String get online => '在线';

  @override
  String get active => '活跃';

  @override
  String get lastSeen => '最后在线';

  @override
  String get justNow => '刚刚';

  @override
  String minutesAgo(int minutes) {
    return '$minutes分钟前';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours小时前';
  }

  @override
  String isTyping(String user) {
    return '正在输入...';
  }

  @override
  String get messageRemoved => '消息已被删除';

  @override
  String messageRemovedBy(String user) {
    return '消息已被$user删除';
  }

  @override
  String get edited => '已编辑';

  @override
  String get clearChat => '清空聊天';

  @override
  String get blockUser => '屏蔽用户';

  @override
  String get edit => '编辑';

  @override
  String get delete => '删除';

  @override
  String get reply => '回复';

  @override
  String get noMessages => '暂无消息';

  @override
  String get useThePlusButtonToAddUsers => '使用 + 按钮添加聊天用户';

  @override
  String get useThePlusButtonToCreateGroupChat => '使用 + 按钮创建群聊';

  @override
  String get english => 'English';

  @override
  String get chinese => '中文';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get profile => '个人资料';

  @override
  String get notifications => '通知';

  @override
  String get privacy => '隐私';

  @override
  String get help => '帮助';

  @override
  String get feedback => '反馈';

  @override
  String get termsOfService => '服务条款';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get contactUs => '联系我们';

  @override
  String get rateApp => '评价应用';

  @override
  String get shareApp => '分享应用';

  @override
  String get reportBug => '报告错误';

  @override
  String get suggestFeature => '建议功能';

  @override
  String get create => '创建';

  @override
  String get searchMessages => '搜索消息';

  @override
  String get searchMessagesHint => '搜索消息...';

  @override
  String get deleteMessageTitle => '删除消息';

  @override
  String get deleteMessageConfirm => '您确定要删除此消息吗？';

  @override
  String get save => '保存';

  @override
  String get editMessageTitle => '编辑消息';

  @override
  String get typeAMessage => '输入消息...';

  @override
  String get noMessagesYet => '暂无消息';

  @override
  String get startTheConversation => '开始聊天吧！';

  @override
  String get error => '错误';

  @override
  String get main => '主菜单';

  @override
  String get account => '账户';

  @override
  String get support => '支持';

  @override
  String get helpSupport => '帮助与支持';

  @override
  String get sendFeedback => '发送反馈';

  @override
  String get appName => '聊天应用';

  @override
  String get appDescription => '一款使用 Flutter 和 Firebase 构建的现代聊天应用。';

  @override
  String get editProfile => '编辑资料';

  @override
  String get changeAvatar => '更换头像';

  @override
  String get appearance => '外观';

  @override
  String get pushNotifications => '推送通知';

  @override
  String get sound => '声音';

  @override
  String get vibration => '震动';

  @override
  String get onlineStatus => '在线状态';

  @override
  String get blockedUsers => '已屏蔽用户';

  @override
  String get helpCenter => '帮助中心';

  @override
  String get appVersion => '应用版本';

  @override
  String get selectLanguageTitle => '选择语言';

  @override
  String get signInToContinue => '登入以繼續您的對話';

  @override
  String get signIn => '登入';

  @override
  String get signUp => '註冊';

  @override
  String get or => '或者';

  @override
  String get dontHaveAnAccount => '沒有帳戶?';

  @override
  String get bySigningInYouAgreeToOurTermsOfServiceAndPrivacyPolicy =>
      '透過登入同意我們的服務和隱私權政策條款';

  @override
  String get joinUsAndStartChattingWithFriends => '加入我們並開始與朋友聊天';

  @override
  String get pleaseconfirmPassword => '請確認密碼';

  @override
  String get byCreatingAnAccountYouAgreeToOurTermsOfServiceAndPrivacyPolicy =>
      '透過建立帳戶您同意我們的服務條款和隱私權政策';

  @override
  String get areYouSureYouWantToDeleteThisMessage => '您確定要刪除此訊息嗎?';

  @override
  String get image => '圖像';

  @override
  String get file => '文件';

  @override
  String errorLoggingOut(Object error) {
    return '錯誤記錄輸出: $error';
  }

  @override
  String get newMessages => '新消息';

  @override
  String get stayUpdated => '保持更新';

  @override
  String get directMessages => '私訊';

  @override
  String get groupMessages => '群組留言';

  @override
  String get updateYourProfileDetails => '更新您的個人資料詳情';

  @override
  String get updateYourAvatar => '更新你的頭像';

  @override
  String get toggleDarkLightMode => '切換暗光模式';

  @override
  String get receivePushNotifications => '接收推播通知';

  @override
  String get enableNotificationSound => '啟用通知聲音';

  @override
  String get enableNotificationVibration => '啟用通知振動';

  @override
  String get showOnlineStatus => '顯示線上狀態';

  @override
  String get manageBlockedUsers => '管理已封鎖用戶';

  @override
  String get getHelpAndSupport => '獲取協助和支持';

  @override
  String get shareYourFeedback => '分享您的回饋';

  @override
  String get reportIssues => '報告問題';

  @override
  String get viewTermsOfService => '查看服務條款';

  @override
  String get viewPrivacyPolicy => '查看隱私權政策';

  @override
  String get describeTheIssue => '描述問題';

  @override
  String get bugReported => '已報告錯誤';

  @override
  String get submit => '提交';

  @override
  String get noBlockedUsers => '無封鎖用戶';

  @override
  String get userUnblocked => '用戶解鎖';

  @override
  String get errorUnblockingUser => '錯誤解除封鎖用戶';

  @override
  String get select => '選擇';

  @override
  String get avatarUpdated => '頭像已更新';

  @override
  String get avatarUploadNotImplemented => '頭像上傳未實現';

  @override
  String get bugReportInfo => '錯誤報告訊息';

  @override
  String get errorSendingBugReport => '錯誤發送錯誤報告';

  @override
  String get bugReportEmpty => '錯誤報告空';
}
