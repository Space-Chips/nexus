class User {
  final List<String> blockedUsersEmails;
  final String username;
  final bool isAdmin;
  final String email;

  User({
    required this.blockedUsersEmails,
    required this.username,
    required this.isAdmin,
    required this.email,
  });
}
