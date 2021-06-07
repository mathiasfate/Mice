import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'firebase_api.dart';
import 'utils.dart';

class Member {
  final String userId;
  final String chatId;
  final bool newMsg;
  final DateTime lastMessageTime;

  const Member({
    this.userId,
    this.chatId,
    this.newMsg,
    this.lastMessageTime,
  });

  Member copyWith({
    String userId,
    String chatId,
    bool newMsg,
    String lastMessageTime



  }) =>
      Member(
        userId: userId ?? this.userId,
        chatId: chatId ?? this.chatId,
        newMsg: newMsg ?? this.newMsg,
        lastMessageTime: lastMessageTime ?? this.lastMessageTime



      );

  static Member fromJson(Map<String, dynamic> json) => Member(
    userId: json ['userId'],
    chatId: json ['chatId'],
    newMsg: json ['newMsg'],
    lastMessageTime: Utils.toDateTime(json['lastMessageTime']),

  );
  Map<String, dynamic> toJson() => {
    'userId' : userId,
    'chatId' : chatId,
    'newMsg' : newMsg,
    'lastMessageTime' : Utils.fromDateTimeToJson(lastMessageTime),

  };
}