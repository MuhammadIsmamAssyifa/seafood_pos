import '../../../shared/enums/app_enums.dart';

class UserModel {
  final int id;
  final String name;
  final String username;
  final String? email;
  final String status;
  final List<String> roles;
  final String? token;

  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    this.email,
    this.status = 'active',
    this.roles = const [],
    this.token,
  });

  UserRole get primaryRole {
    if (roles.isNotEmpty) {
      return UserRole.fromString(roles.first);
    }
    return UserRole.unknown;
  }

  UserRole get role => primaryRole;

  bool get isActive => status.toLowerCase() == 'active';
  bool get isCashier => roles.any((r) => r.toLowerCase() == 'cashier' || r.toLowerCase() == 'kasir');
  bool get isAdmin => roles.any((r) => r.toLowerCase() == 'admin');
  bool get isKitchen => roles.any((r) => r.toLowerCase() == 'kitchen' || r.toLowerCase() == 'koki');
  bool get isWaiter => roles.any((r) => r.toLowerCase() == 'waiter' || r.toLowerCase() == 'pelayan');

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // If json has nested 'data' or 'user', extract it
    final Map<String, dynamic> data = json.containsKey('data') && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : (json.containsKey('user') && json['user'] is Map<String, dynamic>
            ? json['user'] as Map<String, dynamic>
            : json);

    final rawRoles = data['roles'];
    List<String> parsedRoles = [];
    if (rawRoles is List) {
      parsedRoles = rawRoles.map((r) => r.toString()).toList();
    } else if (data['role'] != null) {
      parsedRoles = [data['role'].toString()];
    }

    return UserModel(
      id: data['id'] is int ? data['id'] as int : int.tryParse(data['id']?.toString() ?? '0') ?? 0,
      name: data['name']?.toString() ?? '',
      username: data['username']?.toString() ?? (data['email'] != null ? data['email'].toString().split('@').first : ''),
      email: data['email']?.toString(),
      status: data['status']?.toString() ?? 'active',
      roles: parsedRoles,
      token: json['token']?.toString() ?? data['token']?.toString(),
    );
  }

  factory UserModel.fromAuthResponse(Map<String, dynamic> json) {
    final token = json['token']?.toString();
    final userMap = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : (json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json);

    final user = UserModel.fromJson(userMap);
    return user.copyWith(token: token);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'status': status,
      'roles': roles,
      'token': token,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? username,
    String? email,
    String? status,
    List<String>? roles,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      status: status ?? this.status,
      roles: roles ?? this.roles,
      token: token ?? this.token,
    );
  }
}
