import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'firebase_api.dart';
import 'utils.dart';

class Chat {
  final String chatId;
  final int members;


  const Chat({
    this.chatId,
    this.members,


  });

  Chat copyWith({
    String chatId,
    int members,




  }) =>
      Chat(
        chatId: chatId ?? this.chatId,
        members: members ?? this.members,



      );

  static Chat fromJson(Map<String, dynamic> json) => Chat(
    chatId: json ['chatId'],
    members: json['members'],

  );
  Map<String, dynamic> toJson() => {
    'chatId' : chatId,
    'members' : members,



  };
}