import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'firebase_api.dart';
import 'utils.dart';

class PostField {
  static final String postDate = 'postDate';
}
class Post {
  final String postId;
  final String idUser;
  final String name;
  final String subname;
  final String postText;
  final int likes;
  final int comments;
  final int saves;
  final DateTime postDate;
  final String tag;
  final String typePost;
  final String imgUrl;


  const Post({
    this.idUser,
    @required this.postId,
    @required this.name,
    @required this.subname,
    @required this.tag,
    @required this.postText,
    @required this.likes,
    @required this.comments,
    @required this.saves,
    @required this.postDate,
    @required this.typePost,
    this.imgUrl,
  });

  Post copyWith({
    String postId,
    String idUser,
    String name,
    String subname,
    String postText,
    int likes,
    int saves,
    int comments,
    String postDate,
    String tag,
    String typePost,
    String imgUrl,
  }) =>
      Post(
          postId: postId ?? this.postId,
          idUser: idUser ?? this.idUser,
          name: name ?? this.name,
          subname: subname ?? this.subname,
          postText: postText ?? this.postText,
          likes: likes ?? this.likes,
          comments: comments ?? this.comments,
          saves: saves ?? this.saves,
          postDate: postDate ?? this.postDate,
          tag: tag ?? this.tag,
          imgUrl: imgUrl ?? this.imgUrl,
          typePost: typePost ?? this.typePost,

      );

  static Post fromJson(Map<String, dynamic> json) => Post(
      postId: json ['postId'],
      typePost: json['typePost'],
      idUser: json['idUser'],
      name: json['name'],
      subname: json['subname'],
      postText: json['postText'],
      postDate: Utils.toDateTime(json['postDate']),
      likes: json['likes'],
      comments: json['comments'],
      saves: json['saves'],
      tag: json['tag'],
      imgUrl: json['imgUrl']
  );
  Map<String, dynamic> toJson() => {
    'postId' : postId,
    'typePost' : typePost,
    'name' : name,
    'subname' : subname,
    'idUser': idUser,
    'postText': postText,
    'likes': likes,
    'postDate': Utils.fromDateTimeToJson(postDate),
    'comments': comments,
    'saves': saves,
    'tag' : tag,
    'imgUrl' : imgUrl,
  };
}