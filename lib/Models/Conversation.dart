import 'dart:convert';

class Converstation {
  final int? userId; // Changed the name to userId
  final String? name;

  Converstation({this.userId, this.name}); // Changed parameter name to userId

  Map<String, dynamic> toMap() {
    return {"user_id": userId, "name": name}; // Changed "id" to "user_id"
  }

  factory Converstation.fromJson(Map<String, dynamic> json) {
    return Converstation(
      name: json['name'],
      userId: json['user_id'], // Changed key to user_id
    );
  }

  String toJson() => json.encode(toMap());
}
