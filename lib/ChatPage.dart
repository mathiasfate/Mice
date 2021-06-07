import 'package:cloud_firestore/cloud_firestore.dart';

import 'user.dart';
import 'Widgets.dart';
import 'new_message_widget.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'utils.dart';
class ChatPage extends StatefulWidget {
  final User user;

  const ChatPage({
    @required this.user,
    Key key,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String chatId;
  String _chatId;
  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    getInfo();
  }
  getInfo() async{
    await FirebaseFirestore.instance.collection('users').doc("${ColorService().myUser}").collection('chats').doc("${widget.user.idUser}").get().then((doc) =>{
      _chatId = doc['chatId']
    });
    setState(() {
      chatId = _chatId;
      print(chatId);
      print(widget.user.idUser);
    });
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    extendBodyBehindAppBar: true,
    backgroundColor: ColorService().CorP,
    body: SafeArea(
      child: Column(
        children: [
          ProfileHeaderWidget(
            name: widget.user.name,
            idUser: widget.user.idUser,
            urlBackground: widget.user.urlBackground,
            urlAvatar: widget.user.urlAvatar,
            subname: widget.user.subname,
            role: widget.user.role,
            numberOfPosts: widget.user.numberOfPosts,
            bio: widget.user.bio,
            ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ColorService().CorS,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: MessagesWidget(idUser: widget.user.idUser, chatId: chatId),
            ),
          ),
          NewMessageWidget(idUser: widget.user.idUser,urlAvatar: ColorService().myUrlAvatar,username: ColorService().myUser,chatId: chatId,)
        ],
      ),
    ),
  );
}