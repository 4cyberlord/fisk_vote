/// Centralized API endpoint paths.
///
/// All API endpoints are defined here to avoid hardcoding URLs throughout the app.
class ApiEndpoints {
  ApiEndpoints._();

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTH ENDPOINTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Student registration endpoint
  static const String register = '/students/register';

  /// Student login endpoint
  static const String login = '/students/login';

  /// Logout endpoint
  static const String logout = '/students/logout';

  /// Refresh token endpoint
  static const String refreshToken = '/auth/refresh';

  /// Forgot password endpoint
  static const String forgotPassword = '/auth/forgot-password';

  /// Reset password endpoint
  static const String resetPassword = '/auth/reset-password';

  /// Verify email endpoint
  static const String verifyEmail = '/auth/verify-email';

  /// Resend verification email endpoint
  static const String resendVerification = '/students/resend-verification';

  // ═══════════════════════════════════════════════════════════════════════════
  // PUBLIC ENDPOINTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get all departments
  static const String departments = '/departments';

  /// Get all majors
  static const String majors = '/majors';

  // ═══════════════════════════════════════════════════════════════════════════
  // USER ENDPOINTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get current authenticated user profile
  static const String me = '/students/me';

  /// Update user profile
  static const String updateProfile = '/students/me';

  /// Update user profile photo
  static const String updateProfilePhoto = '/students/me/profile-photo';

  /// Change password
  static const String changePassword = '/students/me/change-password';

  // ═══════════════════════════════════════════════════════════════════════════
  // ELECTION ENDPOINTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get all elections
  static const String elections = '/elections';

  /// Get election by ID
  static String electionById(String id) => '/elections/$id';

  /// Get election candidates
  static String electionCandidates(String id) => '/elections/$id/candidates';

  /// Get election results
  static String electionResults(String id) => '/elections/$id/results';

  /// Get all elections for authenticated student
  static const String studentElections = '/students/elections';

  /// Get ballot data for an election
  static String getBallot(String electionId) =>
      '/students/elections/$electionId/ballot';

  /// Get turnout stats for a specific election
  static String electionTurnout(String electionId) =>
      '/students/elections/$electionId/turnout';

  /// Get student statistics (Impact Score, Voting History)
  static const String studentStats = '/students/me/stats';

  /// Get campus participation statistics
  static const String campusParticipation = '/students/campus-participation';

  /// Cast a vote for an election
  static String castVote(String electionId) =>
      '/students/elections/$electionId/vote';

  /// Get all closed elections with results
  static const String allResults = '/students/elections/results';

  /// Get results for a specific election (student endpoint)
  static String studentElectionResults(String electionId) =>
      '/students/elections/$electionId/results';

  /// Get voting history for authenticated student
  static const String votingHistory = '/students/votes';

  // ═══════════════════════════════════════════════════════════════════════════
  // BLOG ENDPOINTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get all blog posts
  static const String blogPosts = '/blog/posts';

  /// Get a single blog post by ID or slug
  static String blogPost(String id) => '/blog/posts/$id';

  /// Get featured blog posts
  static const String blogFeatured = '/blog/featured';

  /// Get popular blog posts
  static const String blogPopular = '/blog/popular';

  /// Get recent blog posts
  static const String blogRecent = '/blog/recent';

  /// Get blog categories
  static const String blogCategories = '/blog/categories';

  /// Get related blog posts
  static String blogRelated(String id) => '/blog/posts/$id/related';

  /// Search blog posts
  static const String blogSearch = '/blog/search';

  // ═══════════════════════════════════════════════════════════════════════════
  // NOTIFICATION ENDPOINTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get all notifications for authenticated user
  static const String notifications = '/students/notifications';

  /// Get unread notification count
  static const String notificationUnreadCount =
      '/students/notifications/unread-count';

  /// Mark a notification as read
  static String markNotificationRead(String notificationId) =>
      '/students/notifications/$notificationId/read';

  /// Mark all notifications as read
  static const String markAllNotificationsRead =
      '/students/notifications/read-all';

  /// Delete a notification
  static String deleteNotification(String notificationId) =>
      '/students/notifications/$notificationId';

  /// Delete all read notifications
  static const String deleteAllReadNotifications =
      '/students/notifications/clear-read';
}
