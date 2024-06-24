

import 'package:flutter/material.dart';

class Notification {
  late int id;
  String? userId;
  String? message;
  String? createdAt;


  Notification({required this.id,
  this.userId,
  this.message,
  this.createdAt});

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] ?? 0,
      message: json['message'],
      createdAt: json['createdAt'],
      userId: json['userId'],
    );
}

}