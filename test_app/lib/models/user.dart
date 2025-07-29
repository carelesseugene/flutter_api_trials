class User {
  final String id;
  final String email;
  final String? phone;
  final String? fullName;
  final String? title;
  final String? position;

  User({
    required this.id,
    required this.email,
    this.phone,
    this.fullName,
    this.title,
    this.position,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: j['id'] ?? j['userId'] ?? '',
        email: j['email'],
        phone: j['phoneNumber'],
        fullName: j['fullName'],
        title: j['title'],
        position: j['position'],
      );
}
