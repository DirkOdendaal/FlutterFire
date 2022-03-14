class User {
  final String username;
  final String email;
  final String uid;
  final String userImage;

  const User(
      {required this.email,
      required this.uid,
      required this.username,
      this.userImage = "images/default_user.jpg"});
}
