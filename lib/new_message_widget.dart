import 'dart:io';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_api.dart';
import 'main.dart';
import 'message.dart';
import 'utils.dart';
class NewMessageWidget extends StatefulWidget {
  final String idUser;
  final username;
  final urlAvatar;
  final chatId;

  const NewMessageWidget({
    @required this.idUser,
    @required this.username,
    @required this.urlAvatar,
    @required this.chatId,
    Key key,
  }) : super(key: key);

  @override
  _NewMessageWidgetState createState() => _NewMessageWidgetState();
}

class _NewMessageWidgetState extends State<NewMessageWidget> {
  final _controller = TextEditingController();
  final picker = ImagePicker();
  String message = '';
  FocusNode _focus = new FocusNode();
  bool _onFocus = false;
  bool moreHeight = false;
  var textSize;
  File _image;
  bool beforeImage = true;
  bool hasImage = false;
  double minimum = 63.0;
  Future getImageCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera,imageQuality: 20);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        hasImage = true;
        beforeImage = false;
        sendImgMessage();
      } else {
        print('No image selected.');
        hasImage = false;
      }
    });
  }
  Future getImageGallery() async {
    PickedFile pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      imageQuality: 20,
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      hasImage = true;
      beforeImage = false;
      sendImgMessage();
    }else {
      print('No image selected.');
      hasImage = false;
    }
  }
  void TextSize(){
    if(_controller.text.length > 36){
      setState(() {
        textSize = _controller.text.length;
        moreHeight = true;
        textSize = minimum + (textSize * 0.42);
      });
    }
  }
    buttonsBack(){
    setState(() {
      FocusScope.of(context).unfocus();
    });
  }
  void sendMessage() async {
    FocusScope.of(context).unfocus();
    _controller.clear();
    setState(() {
      moreHeight = false;
      textSize = minimum;
    });
    await FirebaseApi.uploadMessage(widget.idUser, message, widget.urlAvatar, widget.username, widget.chatId, null);
    var userRef = await FirebaseFirestore.instance.collection('users').doc(widget.idUser).collection('chats').doc(widget.username);
    await userRef.set({
      'newMsg': true,
      'lastMessageTime': Utils.fromDateTimeToJson(DateTime.now())
    }, SetOptions( merge: true ));
  }
  void sendImgMessage() async {
    FocusScope.of(context).unfocus();
    _controller.clear();
    setState(() {
      moreHeight = false;
      textSize = minimum;
    });
    final refMessages =
    FirebaseFirestore.instance.collection('chat').doc('${widget.chatId}').collection('messages');
    final newMessage = Message(
      idUser: widget.idUser,
      urlAvatar: widget.urlAvatar,
      username: widget.username,
      createdAt: DateTime.now(),
    );
    DocumentReference docId = await refMessages.add(newMessage.toJson());
    DocumentSnapshot docSnap = await docId.get();
    var doc_id2 = docSnap.reference.id;
    var downloadUrl;
    var storage = FirebaseStorage.instance.ref().child("image/$doc_id2");
    UploadTask uploadTask =  storage.putFile(_image);
    await uploadTask.whenComplete(() async =>
    await uploadTask.snapshot.ref.getDownloadURL().then((downloadURL) {
      downloadUrl = downloadURL;
    }));
    await docId.set({
      'imgUrl' : downloadUrl
    }, SetOptions( merge: true ));

    var userRef = await FirebaseFirestore.instance.collection('users').doc(widget.idUser).collection('chats').doc(widget.username);
    await userRef.set({
      'newMsg': true,
      'lastMessageTime': Utils.fromDateTimeToJson(DateTime.now())
    }, SetOptions( merge: true ));
  }

  @override
  void initState(){
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    _focus.addListener(_onFocusChange);

  }
  @override
  void dispose(){
    super.dispose();
    _focus.dispose();
    BackButtonInterceptor.remove(myInterceptor);
  }
  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    setState(() {
      FocusScope.of(context).unfocus();
    });
    return true;
  }
  void _onFocusChange(){
    setState(() {
     if( _onFocus){
       _onFocus = false;
       FocusScope.of(context).unfocus();
     }else _onFocus = true;

    });
  }
  @override
  Widget build(BuildContext context) => Container(
    height: moreHeight ? textSize : minimum,
    color: ColorService().CorP,
    padding: EdgeInsets.only(left: 2, right: 8, top: 8, bottom: 8),
    child: Row(
      children: <Widget>[
        _onFocus ? Container(
          width: 25,
          margin: EdgeInsets.only(right: 15),
          child: IconButton(
              icon: Icon(Icons.arrow_forward_ios , color: ColorService().CorTextP, size: 25),
            onPressed:(){buttonsBack();}
          ),
        ) : Text(''),
        _onFocus ? Text('') : Container(
          width: 25,

          child: IconButton(
              icon: Icon(Icons.analytics_outlined, color: ColorService().CorTextP, size: 25),
            onPressed: (){getImageGallery();},
          ),
        ),
        _onFocus ? Text('') : Container(
          width: 52,
          padding: EdgeInsets.only(left: 10, right: 5),
          child: IconButton(
              icon: Icon(Icons.camera_alt, color: ColorService().CorTextP, size: 25),
            onPressed: (){getImageCamera();},
          ),
        ),
        Expanded(
          child: TextField(
            focusNode: _focus,
            controller: _controller,
            textCapitalization: TextCapitalization.sentences,
            autocorrect: true,
            enableSuggestions: true,
            keyboardType: TextInputType.multiline,
            maxLength: 125,
            maxLines: 20,
            style: TextStyle(color: ColorService().CorTextP),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: ColorService().CorTextS,
              counterText: "",
              labelStyle: TextStyle(
                color: ColorService().CorTextP,
              ),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: ColorService().CorS, width: 2.0),
                  borderRadius: BorderRadius.circular(35.0)
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: ColorService().CorS, width: 0),
                borderRadius: BorderRadius.circular(25),
              ),

            ),
            onChanged: (value) => setState(() {
              message = value;
              TextSize();
            }),
          ),
        ),

        SizedBox(width: 5),
        GestureDetector(
          onTap: message.trim().isEmpty ? null : sendMessage,
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorService().CorS,
            ),
              child: Icon(Icons.send, color: ColorService().CorTextP, size: 20)
            ,
          ),
        ),
      ],
    ),
  );
}