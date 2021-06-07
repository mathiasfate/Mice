import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'firebase_api.dart';
import 'utils.dart';

class Save {
  final String saveId;



  const Save({
    this.saveId,


  });

  Save copyWith({
    String saveId,


  }) =>
      Save(
        saveId: saveId ?? this.saveId,


      );

  static Save fromJson(Map<String, dynamic> json) => Save(
    saveId: json ['saveId'],
  );
  Map<String, dynamic> toJson() => {
    'saveId' : saveId,
  };
}