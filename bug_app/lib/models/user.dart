import 'dart:convert';

class User {
  final dynamic id; // could be int or string depending on mock data
  final String? name;
  final String? email;
  final String? phone;
  final String? password;
  final String? role;
  final int? points;
  final List<String>? sellerCategory;
  // final String? sellerLocation;
  final bool invited;
  final String? invitationCode;
  final String invitationStatus;
  final dynamic invitedBy;
  final DateTime? createdAt;
  final String? token;

  User({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.password,
    this.role,
    this.points,
    this.sellerCategory,
    // this.sellerLocation,
    this.invited = false,
    this.invitationCode,
    this.invitationStatus = "Pending",
    this.invitedBy,
    this.createdAt,
    this.token,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role,
      'points': points,
      'seller_category': sellerCategory,
      // 'seller_location': sellerLocation,
      'invited': invited,
      'invitation_code': invitationCode,
      'invitation_status': invitationStatus,
      'invited_by': invitedBy,
      'createdAt': createdAt?.toIso8601String(),
      'token': token,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] ?? map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      password: map['password'],
      role: map['role'],
      points: map['points'],
      sellerCategory: map['seller_category'] != null
          ? List<String>.from(map['seller_category'])
          : null,
      // sellerLocation: map['seller_location'],
      invited: map['invited'] ?? false,
      invitationCode: map['invitation_code'],
      invitationStatus: map['invitation_status'] ?? 'Pending',
      invitedBy: map['invited_by'],
      createdAt:
          map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      token: map['token'],
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}
