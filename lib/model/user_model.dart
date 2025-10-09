class UserModel {
  final int? id;
  final String username;
  final String password;
  final String role; // Admin | Teacher | Accountant | Staff

  UserModel({this.id, required this.username, required this.password, required this.role});

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'username': username,
        'password': password,
        'role': role,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'] as int?,
        username: map['username'] as String,
        password: map['password'] as String,
        role: map['role'] as String,
      );
}


