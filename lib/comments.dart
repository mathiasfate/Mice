import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'firebase_api.dart';
import 'utils.dart';

class CommentField {
  static final String commentDate = 'commentDate';
}
class Comment {
  final String postId;
  final String idUser;
  final String commentText;
  final int likes;
  final DateTime commentDate;
  final String commentId;
  final String imgUrl;

  const Comment({
    this.idUser,
    @required this.postId,
    @required this.commentText,
    @required this.likes,
    @required this.commentDate,
    @required this.commentId,
    @required this.imgUrl,
  });

  Comment copyWith({
    String postId,
    String idUser,
    String commentText,
    int likes,
    DateTime commentDate,
    String commentId,
    String imgUrl,
  }) =>
      Comment(
        postId: postId ?? this.postId,
        idUser: idUser ?? this.idUser,
        commentText: commentText ?? this.commentText,
        likes: likes ?? this.likes,
        commentDate: commentDate ?? this.commentDate,
        commentId: commentId ?? this.commentId,
        imgUrl: imgUrl ?? this.imgUrl,

      );

  static Comment fromJson(Map<String, dynamic> json) => Comment(
      postId: json ['postId'],
      idUser: json['idUser'],
      commentText: json['commentText'],
      commentDate: Utils.toDateTime(json['commentDate']),
      likes: json['likes'],
      commentId: json['commentId'],
      imgUrl: json['imgUrl'],
  );
  Map<String, dynamic> toJson() => {
    'postId' : postId,
    'idUser': idUser,
    'commentText': commentText,
    'likes': likes,
    'commentDate': Utils.fromDateTimeToJson(commentDate),
    'commentId' : commentId,
    'imgUrl' : imgUrl,
  };
}