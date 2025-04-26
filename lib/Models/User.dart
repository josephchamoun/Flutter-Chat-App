import 'dart:convert';

class User {
  final int? id;
  final String? name;
  final String? email;
  final String? oldpassword;
  final String? password;
  final String? password_confirmation;

  User({
    this.id,
    this.name,
    this.email,
    this.oldpassword,
    this.password,
    this.password_confirmation,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "password": password,
      "password_confirmation": password_confirmation,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(name: json['name'], email: json['email'], id: json['id']);
  }

  String toJson() => json.encode(toMap());
}
