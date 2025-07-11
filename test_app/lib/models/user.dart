class User {
  final String id;
  final String email;
  final String? phone;

  User({required this.id, required this.email, this.phone});

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: j['id'] ?? j['userId'] ?? '',
        email: j['email'],
        phone: j['phoneNumber'],
      );
}
