import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'firebase_api.dart';
import 'utils.dart';

class Like {
  final String likeId;



  const Like({
    this.likeId,


  });

  Like copyWith({
    String likeId,


  }) =>
      Like(
        likeId: likeId ?? this.likeId,


      );

  static Like fromJson(Map<String, dynamic> json) => Like(
    likeId: json ['likeId'],
  );
  Map<String, dynamic> toJson() => {
    'likeId' : likeId,
  };
}