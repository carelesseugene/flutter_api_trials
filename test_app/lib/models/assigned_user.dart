// lib/models/assigned_user.dart

class AssignedUser {
  final String userId;
  final String email;

  AssignedUser({
    required this.userId,
    required this.email,
  });

  factory AssignedUser.fromJson(Map<String, dynamic> json) {
    return AssignedUser(
      userId: json['userId'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'email': email,
  };
}
