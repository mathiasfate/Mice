import 'package:meta/meta.dart';
import 'utils.dart';

class UserField{
  static final String lastMessageTime = 'lastMessageTime';
}

class User {
  final String idUser;
  final String name;
  final String subname;
  final String urlAvatar;
  final DateTime lastMessageTime;
  final int CorP;
  final int CorS;
  final int CorTextP;
  final int CorTextS;
  final String bio;
  final DateTime accountCreationDate;
  final int numberOfPosts;
  final String urlBackground;
  final String role;
  final int permissionLvl;
  final String password;

  const User({
    this.idUser,
    @required this.name,
    @required this.urlAvatar,
    @required this.lastMessageTime,
    @required this.subname,
    @required this.CorP,
    @required this.CorS,
    @required this.CorTextP,
    @required this.CorTextS,
    @required this.bio,
    @required this.accountCreationDate,
    @required this.numberOfPosts,
    @required this.role,
    @required this.urlBackground,
    @required this.permissionLvl,
    @required this.password,
});

  User copyWith({
    String idUser,
    String name,
    String urlAvatar,
    String lastMessageTime,
    String subname,
    int CorP,
    int CorS,
    int CorTextP,
    int CorTextS,
    String bio,
    String role,
    String accountCreationDate,
    int numberOfPosts,
    String urlBackground,
    int permissionLvl,
    String password,

}) =>
      User(
        idUser: idUser ?? this.idUser,
        name: name ?? this.name,
        urlAvatar: urlAvatar ?? this.urlAvatar,
        lastMessageTime: lastMessageTime ?? this.lastMessageTime,
        subname: subname ?? this.subname,
        CorP: CorP ?? this.CorP,
        CorS: CorP ?? this.CorS,
        CorTextP: CorP ?? this.CorTextP,
        CorTextS: CorP ?? this.CorTextS,
        bio: bio ?? this.bio,
        role:  role ?? this.role,
        urlBackground: urlBackground ?? this.urlBackground,
        numberOfPosts: numberOfPosts ?? this.numberOfPosts,
        accountCreationDate: accountCreationDate ?? this.accountCreationDate,
        permissionLvl: permissionLvl ?? this.permissionLvl,
        password: password ?? this.password,
      );

  static User fromJson(Map<String, dynamic> json) => User(
        idUser: json['idUser'],
        name: json['name'],
        urlAvatar: json['urlAvatar'],
        lastMessageTime: Utils.toDateTime(json['lastMessageTime']),
        subname: json['subname'],
        CorP: json['CorP'],
        CorS: json['CorS'],
        CorTextP: json['CorTextP'],
        CorTextS: json['CorTextS'],
        bio: json['bio'],
        role: json['role'],
        urlBackground: json['urlBackground'],
        accountCreationDate: Utils.toDateTime(json['accountCreationDate']),
        numberOfPosts: json['numberOfPosts'],
        permissionLvl: json['permissionLvl'],
        password: json['password'],
  );

  Map<String, dynamic> toJson() => {
        'idUser': idUser,
        'name': name,
        'urlAvatar': urlAvatar,
        'lastMessageTime': Utils.fromDateTimeToJson(lastMessageTime),
        'subname': subname,
        'CorP': CorP,
        'CorS': CorS,
        'CorTextP': CorTextP,
        'CorTextS': CorTextS,
        'bio' : bio,
        'urlBackground' : urlBackground,
        'role' : role,
        'numberOfPosts' : numberOfPosts,
        'accountCreationDate' : accountCreationDate,
        'permissionLvl' : permissionLvl,
        'password' : password,
  };
}