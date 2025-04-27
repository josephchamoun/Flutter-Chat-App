import 'package:chatapp/Models/User.dart';

class Message {
  int? id;
  int? userId;
  int? conversationId;
  String? message;
  String? createdAt;
  String? updatedAt;
  User? user;

  Message({
    this.id,
    this.userId,
    this.conversationId,
    this.message,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      userId: json['user_id'],
      conversationId: json['conversation_id'],
      message: json['message'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'conversation_id': conversationId,
      'message': message,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user': user?.toMap(), // Using toMap from your User model
    };
  }
}
