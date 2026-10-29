import '../../../shared/enums/app_enums.dart';

class UserModel {
  final int id;
  final String name;
  final String? username;
  final String? email;
  final UserRole role;
  final String? token;

  UserModel({
    required this.id,
    required this.name,
    this.username,
    this.email,
    required this.role,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString(),
      email: json['email']?.toString(),
      role: UserRole.fromString(json['role']?.toString()),
      token: json['token']?.toString() ?? json['access_token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'role': role.name,
      'token': token,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? username,
    String? email,
    UserRole? role,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }
}

