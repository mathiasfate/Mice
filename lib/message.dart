import 'package:flutter/material.dart';

import 'utils.dart';

class MessageField {
  static final String createdAt = 'createdAt';
}

class Message {
  final String idUser;
  final String imgUrl;
  final String urlAvatar;
  final String username;
  final String message;
  final DateTime createdAt;

  const Message({
    @required this.idUser,
    @required this.imgUrl,
    @required this.urlAvatar,
    @required this.username,
    @required this.message,
    @required this.createdAt,
  });

  static Message fromJson(Map<String, dynamic> json) => Message(
    idUser: json['idUser'],
    imgUrl: json['imgUrl'],
    urlAvatar: json['urlAvatar'],
    username: json['username'],
    message: json['message'],
    createdAt: Utils.toDateTime(json['createdAt']),
  );

  Map<String, dynamic> toJson() => {
    'idUser': idUser,
    'imgUrl': imgUrl,
    'urlAvatar': urlAvatar,
    'username': username,
    'message': message,
    'createdAt': Utils.fromDateTimeToJson(createdAt),
  };
}