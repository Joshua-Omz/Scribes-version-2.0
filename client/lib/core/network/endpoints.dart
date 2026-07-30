class Endpoints {
  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String googleLogin = '/auth/google';
  static const String me = '/me';
  static const String updateEmail = '/me/email';
  static const String updatePassword = '/me/password';
  static const String notificationPreferences = '/me/notifications';
  // Feed
  static const String feed = '/feed';
  static const String explore = '/explore';

  // Posts
  static const String posts = '/posts';

  // Social
  static const String comments = '/comments';
  static const String follow = '/dm';
  static const String saved = '/saved';

  // Users
  static const String users = '/users';

  // Drafts
  static const String drafts = '/drafts';

  // Notes
  static const String notes = '/notes';
  static const String notebooks = '/notebooks';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationsReadAll = '/notifications/read-all';
  static const String notificationsClearAll = '/notifications/clear-all';
  static const String notificationsBulkDelete = '/notifications/bulk-delete';
  static const String notificationsBulkRead = '/notifications/bulk-read';
}
