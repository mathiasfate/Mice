import 'dart:io';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'ChatPage.dart';
import 'main.dart';
import 'HomePage.dart';
import 'Presets.dart';
import 'firebase_api.dart';
import 'Widgets.dart';
import 'saves.dart';
import 'user.dart';
import 'utils.dart';
import 'package:image_picker/image_picker.dart';
import 'posts.dart';
import 'comments.dart';
import 'package:after_layout/after_layout.dart';
import 'chats.dart';
import 'member.dart';
//States=======================================================================
class ProfilePage extends StatefulWidget {
  final idUser;
  const ProfilePage({@required this.idUser,Key key}) : super(key: key);

  @override
  ProfilePageState createState() => ProfilePageState();
}
class HeaderProfile extends StatefulWidget {
  final  idUser;
  const HeaderProfile( {@required this.idUser, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HeaderProfileState();
}
class ThemePage extends StatefulWidget {
  const ThemePage({Key key}) : super(key: key);

  @override
  ThemePageState createState() => ThemePageState();
}
class ColorSelectionPage extends StatefulWidget{
  const ColorSelectionPage({Key key}) : super(key: key);
  @override
  ColorSelectionPageState createState() => ColorSelectionPageState();
}
class CommentSection extends StatefulWidget{
  final Post post;
  final moreHeight;
  final postHeight;
  final noText;
  final textHeight;
  final biggerThan;
  final minimum;
  const CommentSection({
    @required this.post,
    this.moreHeight,
    this.postHeight,
    this.textHeight,
    this.biggerThan,
    this.minimum,
    this.noText,Key key}) : super(key: key);
  @override
  CommentSectionState createState() => CommentSectionState();
}
class PostPage extends StatefulWidget{
  const PostPage({Key key}) : super(key: key);
  @override
  PostPageState createState() => PostPageState();
}
class AccountCreationPage extends StatefulWidget{
  const AccountCreationPage({Key key}) : super(key: key);
  @override
  AccountCreationPageState createState() => AccountCreationPageState();
}
class SavedItensPage extends StatefulWidget{
  const SavedItensPage({Key key}) : super(key: key);
  @override
 SavedItensPageState createState() => SavedItensPageState();
}
class CreateChat extends StatefulWidget{
  final List<User> users;
  const CreateChat({@required this.users,Key key}) : super(key: key);
  @override
 CreateChatState createState() => CreateChatState();
}
//Pages======================================================================
class PostPageState extends State<PostPage> {
  final picker = ImagePicker();
  String myUser = ColorService().myUser;
  int numberOfPosts = ColorService().numberOfPosts;
  double charCount = 0;
  String _urlAvatar;
  String urlAvatar;
  String tag = 'Escolher tag';
  String typePost = 'Tipo de post';
  bool isTextPost = false;
  bool isImgPost = false;
  bool isMultImgPost = false;
  bool isPollPost = false;
  bool beforeImage = true;
  bool hasImage = false;
  File _image;
  final textController = TextEditingController();
  String postId;
  @override
  void dispose() {
    textController.dispose();

    super.dispose();
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
    }else {
      print('No image selected.');
      hasImage = false;
    }
  }
  Future getImageCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera,imageQuality: 20);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        hasImage = true;
        beforeImage = false;
      } else {
        print('No image selected.');
        hasImage = false;
      }
    });
  }
  Future uploadPost() async {
      switch(typePost){
        case 'Texto':{
          if(textController.text == ""){
            break;
          }
          var name;
          var subname;
          var myRef =  await FirebaseFirestore.instance.collection('users').doc('$myUser');
          await myRef.get().then((doc)=>{
            name = doc['name'],
            subname = doc['subname']
          });
          final newTextPost = Post(
              postId: 'new',
              idUser: myUser,
              name: name,
              subname: subname,
              postText: textController.text ,
              likes: 0,
              comments: 0,
              saves: 0,
              postDate: DateTime.now(),
              tag: tag,
              typePost: 'textPost',
          );
          DocumentReference docId = await FirebaseFirestore.instance.collection('posts').add(newTextPost.toJson());
          ColorService().numberOfPosts = ColorService().numberOfPosts + 1;
          numberOfPosts = numberOfPosts + 1;
          DocumentSnapshot docSnap = await docId.get();
          var doc_id2 = docSnap.reference.id;
          await docId.set({
            'postId' : doc_id2
          }, SetOptions( merge: true ));
          var userRef =  await FirebaseFirestore.instance.collection('users').doc('$myUser');
          await userRef.set({
            'numberOfPosts': numberOfPosts
          }, SetOptions( merge: true ));
          break;
      }
        case 'Imagem': {
          if(hasImage == false){
            break;
          }
          var name;
          var subname;
          var myRef =  await FirebaseFirestore.instance.collection('users').doc('$myUser');
          await myRef.get().then((doc)=>{
            name = doc['name'],
            subname = doc['subname']
          });
          final newImgPost = Post(
            postId: 'new',
            idUser: myUser,
            name: name,
            subname: subname,
            postText: textController.text ,
            likes: 0,
            comments: 0,
            saves: 0,
            postDate: DateTime.now(),
            tag: tag,
            typePost: 'imagePost',
          );
          DocumentReference docId = await FirebaseFirestore.instance.collection('posts').add(newImgPost.toJson());
          ColorService().numberOfPosts = ColorService().numberOfPosts + 1;
          numberOfPosts = numberOfPosts + 1;
          DocumentSnapshot docSnap = await docId.get();
          var doc_id2 = docSnap.reference.id;
          var userRef =  await FirebaseFirestore.instance.collection('users').doc('$myUser');
          await userRef.set({
            'numberOfPosts': numberOfPosts
          }, SetOptions( merge: true ));
          var downloadUrl;
          var storage = FirebaseStorage.instance.ref().child("image/$doc_id2");
          UploadTask uploadTask =  storage.putFile(_image);
           await uploadTask.whenComplete(() async =>
           await uploadTask.snapshot.ref.getDownloadURL().then((downloadURL) {
             downloadUrl = downloadURL;
           }));
          await docId.set({
            'postId' : doc_id2,
            'imgUrl' : downloadUrl
          }, SetOptions( merge: true ));
          break;
        }
    }
  }
  getInfo() async{
    var userId = ColorService().myUser;
    var user = await FirebaseFirestore.instance.collection('users').doc('$userId');
    await user.get().then((doc) => {
      _urlAvatar = doc['urlAvatar'],
    });
    setState(() {
      urlAvatar = _urlAvatar;
    });
  }
  @override
  initState(){
    getInfo();
    super.initState();
  }
  @override
  Widget build(context) {
    return Scaffold(
      key: scaffoldState,
      backgroundColor: ColorService().CorP,
      appBar: AppBar(
          backgroundColor: ColorService().CorP,
          centerTitle: true,
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              color: ColorService().CorS,
              onPressed: () {
                Navigator.pop(context);
              }
          ),
          title: Icon(Icons.pest_control_rodent_rounded,
              color: ColorService().CorS, size: 40),
          actions: <Widget>[
            Container(
              height: 6,
              width: 90,
              padding: EdgeInsets.only(top: 4, bottom: 4, right: 5),
              child: ElevatedButton(
                  child: Text("Enviar", style: TextStyle(color: ColorService().CorTextP)),
                  style: ElevatedButton.styleFrom(
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                      primary: ColorService().CorS,
                      onPrimary: ColorService().CorTextP
                  ),
                  onPressed: (){
                      if(typePost != 'Tipo de post'){
                        if(tag != "Escolher tag"){
                          uploadPost();
                          Navigator.pop(context);
                        }else showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                                content: Text("Escolha um tipo de post", style: TextStyle(color: ColorService().CorTextS)),
                                backgroundColor: ColorService().CorP),
                            barrierDismissible: true
                        );
                      }else showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                              content: Text("Escolha uma tag", style: TextStyle(color: ColorService().CorTextS)),
                              backgroundColor: ColorService().CorP),
                          barrierDismissible: true
                      );
                  }),
            )
          ],
          toolbarHeight: 45),
      body: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.only(top: 5,left: 5,right: 100),
                child: CircleAvatar(
                    backgroundImage: NetworkImage("$urlAvatar"),
                    radius: 18
                ),
              ),
              Container(
                padding: EdgeInsets.only(top:5, right: 8),
                height:45,
                width: 125,
                child:
                ElevatedButton(
                    child: Text("$typePost", style: TextStyle(color: ColorService().CorTextP)),
                    style: ElevatedButton.styleFrom(
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                        ),
                        primary: ColorService().CorS,
                        onPrimary: ColorService().CorTextP
                    ),
                    onPressed: (){
                      scaffoldState.currentState.showBottomSheet(
                            (context) =>
                            Container(
                                color: ColorService().CorP,
                                height: 200,
                                width: double.infinity,
                                child: SingleChildScrollView(
                                    child: Column(
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            height: 50,
                                            color: ColorService().CorS,
                                            child: Center(child: Text('Tipos de post', style: TextStyle(color: ColorService().CorTextP)))
                                          ),
                                          Container(
                                            height: 60,
                                            padding: EdgeInsets.only(top: 5, right: 5, left: 5),
                                            width: double.infinity,
                                            child: ElevatedButton(
                                                child: Text("Texto", style: TextStyle(color: ColorService().CorTextP)),
                                                style: ElevatedButton.styleFrom(
                                                    shape: new RoundedRectangleBorder(
                                                      borderRadius: new BorderRadius.circular(30.0),
                                                    ),
                                                    primary: ColorService().CorS,
                                                    onPrimary: ColorService().CorTextP
                                                ),
                                                onPressed: (){
                                                  setState(() {
                                                    typePost = 'Texto';
                                                    isTextPost = true;
                                                    isImgPost = false;
                                                    isMultImgPost = false;
                                                    isPollPost = false;
                                                  });
                                                  Navigator.pop(context);
                                                }),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(top: 5, right: 5, left: 5),
                                            height: 60,
                                            width: double.infinity,
                                            child: ElevatedButton(
                                                child: Text("Imagem", style: TextStyle(color: ColorService().CorTextP)),
                                                style: ElevatedButton.styleFrom(
                                                    shape: new RoundedRectangleBorder(
                                                      borderRadius: new BorderRadius.circular(30.0),
                                                    ),
                                                    primary: ColorService().CorS,
                                                    onPrimary: ColorService().CorTextP
                                                ),
                                                onPressed: (){
                                                  setState(() {
                                                    typePost = 'Imagem';
                                                    isTextPost = false;
                                                    isImgPost = true;
                                                    isMultImgPost = false;
                                                    isPollPost = false;
                                                  });
                                                  Navigator.pop(context);
                                                }),
                                          ),
                                          Container(
                                            height: 60,
                                            padding: EdgeInsets.only(top: 5, right: 5, left: 5),
                                            width: double.infinity,
                                            child: ElevatedButton(
                                                child: Text("Mult Imagem", style: TextStyle(color: ColorService().CorTextP)),
                                                style: ElevatedButton.styleFrom(
                                                    shape: new RoundedRectangleBorder(
                                                      borderRadius: new BorderRadius.circular(30.0),
                                                    ),
                                                    primary: ColorService().CorS,
                                                    onPrimary: ColorService().CorTextP
                                                ),
                                                onPressed: (){
                                                  setState(() {
                                                    typePost = 'Mult Imagem';
                                                    isTextPost = false;
                                                    isImgPost = false;
                                                    isMultImgPost = true;
                                                    isPollPost = false;
                                                  });
                                                  Navigator.pop(context);
                                                }),
                                          ),
                                          Container(
                                            height: 60,
                                            padding: EdgeInsets.only(top: 5, right: 5, left: 5),
                                            width: double.infinity,
                                            child: ElevatedButton(
                                                child: Text("Enquete", style: TextStyle(color: ColorService().CorTextP)),
                                                style: ElevatedButton.styleFrom(
                                                    shape: new RoundedRectangleBorder(
                                                      borderRadius: new BorderRadius.circular(30.0),
                                                    ),
                                                    primary: ColorService().CorS,
                                                    onPrimary: ColorService().CorTextP
                                                ),
                                                onPressed: (){
                                                  setState(() {
                                                    typePost = 'Enquete';
                                                    isTextPost = false;
                                                    isImgPost = false;
                                                    isMultImgPost = false;
                                                    isPollPost = true;
                                                  });
                                                  Navigator.pop(context);
                                                }),
                                          ),
                                        ]
                                    )
                                )
                            ),
                      );

                    }),
              ),
              Container(
                padding: EdgeInsets.only(top:5),
                height:45,
                width: 125,
                child:
                ElevatedButton(
                    child: Text("$tag", style: TextStyle(color: ColorService().CorTextP)),
                    style: ElevatedButton.styleFrom(
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                        ),
                        primary: ColorService().CorS,
                        onPrimary: ColorService().CorTextP
                    ),
                    onPressed: (){
                      scaffoldState.currentState.showBottomSheet(
                            (context) =>
                            Container(
                                color: ColorService().CorP,
                                height: 200,
                                width: double.infinity,
                                child: SingleChildScrollView(
                                  child: Column(
                                      children: [
                                        Container(
                                            width: double.infinity,
                                            height: 50,
                                            color: ColorService().CorS,
                                            child: Center(child: Text('Tags', style: TextStyle(color: ColorService().CorTextP)))
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(top: 5, right: 5, left: 5),
                                          height: 60,
                                          width: double.infinity,
                                          child: ElevatedButton(
                                              child: Text("Role", style: TextStyle(color: ColorService().CorTextP)),
                                              style: ElevatedButton.styleFrom(
                                                  shape: new RoundedRectangleBorder(
                                                    borderRadius: new BorderRadius.circular(30.0),
                                                  ),
                                                  primary: ColorService().CorS,
                                                  onPrimary: ColorService().CorTextP
                                              ),
                                              onPressed: (){
                                                setState(() {
                                                  tag = 'Role';
                                                });
                                                Navigator.pop(context);
                                              }),
                                        ),
                                        Container(
                                          height: 60,
                                          padding: EdgeInsets.only(top: 5, right: 5, left: 5),
                                          width: double.infinity,
                                          child: ElevatedButton(
                                              child: Text("Jogo", style: TextStyle(color: ColorService().CorTextP)),
                                              style: ElevatedButton.styleFrom(
                                                  shape: new RoundedRectangleBorder(
                                                    borderRadius: new BorderRadius.circular(30.0),
                                                  ),
                                                  primary: ColorService().CorS,
                                                  onPrimary: ColorService().CorTextP
                                              ),
                                              onPressed: (){
                                                setState(() {
                                                  tag = 'Jogo';
                                                });
                                                Navigator.pop(context);
                                              }),
                                        ),
                                        Container(
                                          height: 60,
                                          padding: EdgeInsets.only(top: 5, right: 5, left: 5),
                                          width: double.infinity,
                                          child: ElevatedButton(
                                              child: Text("Anime", style: TextStyle(color: ColorService().CorTextP)),
                                              style: ElevatedButton.styleFrom(
                                                  shape: new RoundedRectangleBorder(
                                                    borderRadius: new BorderRadius.circular(30.0),
                                                  ),
                                                  primary: ColorService().CorS,
                                                  onPrimary: ColorService().CorTextP
                                              ),
                                              onPressed: (){
                                                setState(() {
                                                  tag = 'Anime';
                                                });
                                                Navigator.pop(context);
                                              }),
                                        ),
                                        Container(
                                          height: 60,
                                          padding: EdgeInsets.only(top: 5, right: 5, left: 5),
                                          width: double.infinity,
                                          child: ElevatedButton(
                                              child: Text("Musica", style: TextStyle(color: ColorService().CorTextP)),
                                              style: ElevatedButton.styleFrom(
                                                  shape: new RoundedRectangleBorder(
                                                    borderRadius: new BorderRadius.circular(30.0),
                                                  ),
                                                  primary: ColorService().CorS,
                                                  onPrimary: ColorService().CorTextP
                                              ),
                                              onPressed: (){
                                                setState(() {
                                                  tag = 'Musica';
                                                });
                                                Navigator.pop(context);
                                              }),
                                        ),
                                        Container(
                                          height: 60,
                                          padding: EdgeInsets.only(top: 5, right: 5, left: 5),
                                          width: double.infinity,
                                          child: ElevatedButton(
                                              child: Text("Shitpost", style: TextStyle(color: ColorService().CorTextP)),
                                              style: ElevatedButton.styleFrom(
                                                  shape: new RoundedRectangleBorder(
                                                    borderRadius: new BorderRadius.circular(30.0),
                                                  ),
                                                  primary: ColorService().CorS,
                                                  onPrimary: ColorService().CorTextP
                                              ),
                                              onPressed: (){
                                                setState(() {
                                                  tag = 'Shitpost';
                                                });
                                                Navigator.pop(context);
                                              }),
                                        ),
                                        Container(
                                          height: 60,
                                          padding: EdgeInsets.only(top: 5, right: 5, left: 5),
                                          width: double.infinity,
                                          child: ElevatedButton(
                                              child: Text("Casinha", style: TextStyle(color: ColorService().CorTextP)),
                                              style: ElevatedButton.styleFrom(
                                                  shape: new RoundedRectangleBorder(
                                                    borderRadius: new BorderRadius.circular(30.0),
                                                  ),
                                                  primary: ColorService().CorS,
                                                  onPrimary: ColorService().CorTextP
                                              ),
                                              onPressed: (){
                                                setState(() {
                                                  tag = 'Casinha';
                                                });
                                                Navigator.pop(context);
                                              }),
                                        ),
                                      ]
                                  )
                                ),
                                )
                      );

                    }),
              ),
            ]
          ),
          Container(
            padding: EdgeInsets.only(right: 5, left: 5, top: 5),
            child: TextField(
                controller: textController,
                keyboardType: TextInputType.multiline,
                maxLength: 250,
                maxLines: 4,
                style: TextStyle(color: ColorService().CorTextP),
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: ColorService().CorS, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  border: OutlineInputBorder(),
                  fillColor: ColorService().CorTextS,
                  filled: true,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  counterStyle: TextStyle(color: ColorService().CorS),
                ),
                onChanged: (value){
                  setState(() {
                    charCount = value.length / 250;
                  });}),
          ),
          Container(
              padding: EdgeInsets.only(right: 5, left: 5),
              child: LinearProgressIndicator(
                  value: charCount,
                  backgroundColor: ColorService().CorTextS,
                  valueColor: new AlwaysStoppedAnimation<Color>(ColorService().CorS)
              )
          ),
          isImgPost ? Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.only(left: 5),
                child: ElevatedButton(
                    child: Icon(Icons.camera_alt, color: ColorService().CorTextP),
                    style: ElevatedButton.styleFrom(
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                        ),
                        primary: ColorService().CorS,
                        onPrimary: ColorService().CorTextP
                    ),
                    onPressed: (){
                      getImageCamera();

    }),
              ),
              Container(
                padding: EdgeInsets.only(left: 5, right: 5),
                child: ElevatedButton(
                    child: Icon(Icons.analytics_outlined, color: ColorService().CorTextP),
                    style: ElevatedButton.styleFrom(
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                        ),
                        primary: ColorService().CorS,
                        onPrimary: ColorService().CorTextP
                    ),
                    onPressed: (){
                      getImageGallery();

                    }),
              )
            ]
          ) : Text(''),
          isImgPost ? Container(
              padding: EdgeInsets.only(left: 5, right: 5, top:5 ),
              child: SizedBox(
                height: 390,
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: hasImage ? Image.file(_image) : beforeImage ? Text("") : Text("Imagem não encontrada", style: TextStyle(color: ColorService().CorTextP))
                )
              )
          ) : Text(""),
          isMultImgPost ? Container(child: Text('fuca')) : Text(''),
          isPollPost ? Container(child: Text('Matotas')) : Text('')

        ]
      )
    );
  }
}
class CommentSectionState extends State<CommentSection>{
  final picker = ImagePicker();
  bool beforeImage = true;
  bool hasImage = false;
  File _image;
  bool showFab = true;
  var date;
  var _hour;
  var hour;
  var saves;
  var imgUrl = null;
  final commentController = TextEditingController();
  void showFoatingActionButton(bool value) {
    setState(() {
      showFab = value;
    });
  }
  Future getImageGallery() async {
    PickedFile pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
        imageQuality: 20
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      hasImage = true;
      beforeImage = false;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content:Text("Imagem selecionada com sucesso", style: TextStyle(color: ColorService().CorTextP)),
              duration: const Duration(seconds: 3), backgroundColor:ColorService().CorS)
      );
    }else {
      print('No image selected.');
      hasImage = false;
    }
  }
  Future getImageCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera,imageQuality: 20);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        hasImage = true;
        beforeImage = false;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content:Text("Imagem selecionada com sucesso", style: TextStyle(color: ColorService().CorTextP)),
                duration: const Duration(seconds: 3), backgroundColor:ColorService().CorS)
        );
      } else {
        print('No image selected.');
        hasImage = false;
      }
    });
  }
  Future uploadComment() async{
    final newComment = Comment(
      postId: widget.post.postId,
      idUser: ColorService().myUser,
      commentText: commentController.text ,
      likes: 0,
      commentDate: DateTime.now(),
      commentId: 'new',
      imgUrl: null,
    );
    DocumentReference docId = await FirebaseFirestore.instance.collection('comments').add(newComment.toJson());
    DocumentSnapshot docSnap = await docId.get();
    var doc_id2 = docSnap.reference.id;
    if(hasImage){
      var storage = FirebaseStorage.instance.ref().child("image/$doc_id2");
      UploadTask uploadTask = storage.putFile(_image);
      imgUrl = doc_id2;
    }
    await docId.set({
      'commentId' : doc_id2,
      'imgUrl' : imgUrl
    }, SetOptions( merge: true ));
    var postRef =  await FirebaseFirestore.instance.collection('posts').doc('${widget.post.postId}');
    await postRef.set({
      'comments': widget.post.comments + 1
    }, SetOptions( merge: true ));
  }
  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }
  @override
  didChangeDependencies(){
    ColorService().isCommentSection = true;
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
        key: scaffoldState,
        floatingActionButton: showFab ? FloatingActionButton(
          backgroundColor: ColorService().CorS,
          child: Icon(Icons.pest_control_rodent, color: ColorService().CorTextP),
          onPressed: (){
            scaffoldState.currentState.showBottomSheet(
                  (context) =>
                  Container(
                      color: ColorService().CorP,
                      height: 200,
                      width: double.infinity,
                      child: Column(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 130),
                                  child: IconButton(
                                    icon: Icon(Icons.arrow_back, color: ColorService().CorTextP),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      showFoatingActionButton(true);
                                    },
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: IconButton(
                                    icon: Icon(Icons.camera_alt, color: ColorService().CorTextP),
                                    onPressed: () {
                                      getImageCamera();
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 0),
                                  child: IconButton(
                                    icon: Icon(Icons.analytics_outlined, color: ColorService().CorTextP),
                                    onPressed: () {
                                      getImageGallery();
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 2.0),
                                  child: TextButton(
                                      child: Container(
                                          height: 35,
                                          width: 90,
                                          decoration: BoxDecoration(
                                            color: ColorService().CorS,
                                            borderRadius: BorderRadius.all(Radius.circular(5)),
                                          ),
                                          child: Center(
                                              child: Text("Enviar",
                                                  style: new TextStyle(fontSize: 18.0, color: ColorService().CorTextP))
                                          )),
                                      onPressed: () {
                                        if(commentController.text.length > 0){
                                          uploadComment();
                                          showFoatingActionButton(true);
                                          Navigator.pop(context);
                                          commentController.clear();
                                        }
                                      }
                                  ),
                                ),
                              ],
                            ),
                            TextField(
                                controller: commentController,
                                keyboardType: TextInputType.multiline,
                                maxLength: 125,
                                maxLines: 4,
                                style: TextStyle(color: ColorService().CorTextP),
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: ColorService().CorS, width: 2.0),
                                      borderRadius: BorderRadius.circular(10.0)
                                  ),
                                  border: OutlineInputBorder(),
                                  fillColor: ColorService().CorTextS,
                                  filled: true,
                                  floatingLabelBehavior: FloatingLabelBehavior.never,
                                  counterStyle: TextStyle(color: ColorService().CorS),
                                ),
                            ),
                          ]
                      )
                  ),
            );
            showFoatingActionButton(false);
          },
        ): Container(),
        backgroundColor: ColorService().CorP,
        appBar: AppBar(
            backgroundColor: ColorService().CorP,
            leading: IconButton(
                icon: Icon(Icons.arrow_back, color: ColorService().CorTextP),
                onPressed: (){
                  if(ColorService().isCommentSection == true){
                    ColorService().isCommentSection = false;
                  }
                  Navigator.pop(context);
                }
            ),
            title: Text("Comentários", style: TextStyle(color: ColorService().CorTextP))
        ),
        body: StreamBuilder<List<Comment>>(
            stream: FirebaseApi.getComments(widget.post.postId),
            builder: (context, snapshot){
              switch(snapshot.connectionState){
                case ConnectionState.waiting:
                  return Center(child: CircularProgressIndicator());
                default: final comments = snapshot.data;
                return ListView(
                    children: [
                        BuildPosts(widget.post),
                        Container(
                        color: ColorService().CorP,
                        height: 35,
                        width: double.infinity,
                        child: Card(
                          color: ColorService().CorP,
                          child: Row(
                              children: [
                                Expanded(child:
                                Container(
                                    width: 115,
                                    margin: EdgeInsets.only(left: 5),
                                    child: Row(
                                        children: [
                                          Text("${widget.post.comments}", style: TextStyle(color: ColorService().CorTextP)),
                                          Text(" Comentários", style: TextStyle(color: ColorService().CorTextS)),
                                        ]
                                    )
                                )),
                                Flexible(child:
                                Container(
                                    width: 50,
                                    margin: EdgeInsets.only(left: 25),
                                    child: Row(
                                        children: [
                                          Text("${widget.post.likes}", style: TextStyle(color: ColorService().CorTextP)),
                                          Text(" Curtidas", style: TextStyle(color: ColorService().CorTextS)),
                                        ]
                                    )
                                )),
                                Expanded(child:
                                Container(
                                    width: 30,
                                    margin: EdgeInsets.only(left: 20),
                                    child: Row(
                                        children: [
                                          Text("${widget.post.saves}", style: TextStyle(color: ColorService().CorTextP)),
                                          Text(" Salvos", style: TextStyle(color: ColorService().CorTextS)),
                                        ]
                                    )
                                )),
                                Flexible(child:
                                Container(
                                  width: 80,
                                  margin: EdgeInsets.only(left: 35),
                                  child: Text("${Utils.toOnlyTime(widget.post.postDate.toString(), context)}", style: TextStyle(color: ColorService().CorTextS)),)),
                                Flexible(
                                    child: Container(
                                      width: 100,
                                      child: Text("${Utils.toOnlyDate(widget.post.postDate.toString())}", style: TextStyle(color: ColorService().CorTextS)),)),]),),),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                           return CommentTileText(comment: comment);},
                        itemCount: comments.length,

              )]
                );
              }}));
  }
}
class ProfilePageState extends State<ProfilePage> {
  bool _pinned = true;
  bool _snap = false;
  bool _floating = false;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: ColorService().CorP,
        body: StreamBuilder<List<Post>>(
          stream: FirebaseApi.getPostsUser(widget.idUser),
          builder: (context, snapshot){
            switch(snapshot.connectionState){
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              default: final posts = snapshot.data;
                return CustomScrollView(
                  slivers:<Widget> [
                    SliverAppBar(
                        backgroundColor: ColorService().CorP,
                        pinned: _pinned,
                        snap: _snap,
                        floating: _floating,
                        expandedHeight: 313,
                        flexibleSpace: FlexibleSpaceBar(background: HeaderProfile(idUser: widget.idUser)),
                        leading: IconButton(
                            icon: Icon(Icons.arrow_back, color: ColorService().CorS),
                            onPressed: (){
                              Navigator.pop(context);
                            }
                        ),

                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final post = posts[index];
                        return BuildPosts(post);
                      }, childCount: snapshot.data.length),
                    )
                  ],
                );
            }
          },
        ));
  }
}
class HeaderProfileState extends State<HeaderProfile> {
  var _name;
  var _subname;
  var _bio;
  var _role;
  var _urlBackground;
  var _urlAvatar;
  var _numberOfPosts;
  DateTime _accountCreationDate;
  var name;
  var subname;
  var bio;
  var role;
  var urlBackground;
  var urlAvatar;
  var numberOfPosts;
  var accountCreationDate;

  getInfo() async{
    print(widget.idUser);
    var userId = widget.idUser;
    var user = await FirebaseFirestore.instance.collection('users').doc('$userId');
    await user.get().then((doc) => {
      _name = doc['name'],
      _subname = doc['subname'],
      _bio = doc['bio'],
      _role = doc['role'],
      _numberOfPosts = doc['numberOfPosts'],
      _urlBackground = doc['urlBackground'],
      _urlAvatar = doc['urlAvatar'],
      _accountCreationDate = Utils.toDateTime(doc['accountCreationDate'])
    });
    setState(() {
      name = _name;
      subname = _subname;
      bio = _bio;
      role = _role;
      urlBackground = _urlBackground;
      urlAvatar = _urlAvatar;
      numberOfPosts = _numberOfPosts;
      accountCreationDate = Utils.toOnlyDate(_accountCreationDate.toString());
    });
  }
  @override
  initState(){
    print(widget.idUser);
    getInfo();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: ColorService().CorP,
        body: Column(children: [
          Stack(clipBehavior: Clip.none, children: <Widget>[
            Container(
                width: double.infinity,
                height: 150,
                child: FittedBox(
                    child: Image.network(
                        "$urlBackground"),//FOTO DE CAPA
                    fit: BoxFit.fill)),
            Positioned(
                top: 115,
                left: 10,
                child: Container(
                  child: CircleAvatar(
                      radius: 37,
                      backgroundColor: ColorService().CorP,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                            "$urlAvatar"),
                        radius: 35,
                      )),
                )), //PROFILE PICTURE
            Positioned(
                top: 190,
                left: 14,
                child: Row(
                  children: [
                    Text("$name",
                        style: TextStyle(
                            color: ColorService().CorTextP,
                            fontSize: 22.0)),
                    //NAME
                    Container(
                      padding: EdgeInsets.only(left: 7),
                      child: Text(
                        "$role",
                        style: TextStyle(fontSize: 12, color: ColorService().CorS),
                      )
                    )//ADMIN - MOD - MEMBER
                  ]
                )),
            Positioned(
                top: 213,
                left: 14,
                child: Text("@$subname",
                    style: TextStyle(
                        color: ColorService().CorTextS,
                        fontSize: 16.0))), //ID @

            Positioned(
              top: 0,
              right: -15,
              child: Container(
                  padding: EdgeInsets.only(right: 15.0, top: 30.0),
                  child: Container(
                    child: IconButton(
                      icon: Icon(Icons.brush_sharp),
                      color: ColorService().CorS,
                      onPressed: () {
                        Navigator.pushNamed(context, 'EditProfilePage');
                      },
                    ),
                  )),
            ),
          ]),
          SizedBox(
            height: 67
          ),
          SizedBox(
            height: 100,
            child: Container(
              margin: EdgeInsets.only(left: 15, top: 6, right: 15),
              child: Row(
                  children: [
                    Flexible(
                        child :Text('$bio',
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 4,
                            style: TextStyle(color: ColorService().CorTextP, fontSize: 15))
                    )
                  ]//BIO PODEM TER ATÉ 144 CARACTERES
              )
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 15),
            child: Row(children: <Widget>[
              Row(
                children: <Widget>[
                  Row(children: <Widget>[
                    Icon(Icons.calendar_today,
                        color: ColorService().CorTextS, size: 15.0),
                    Text("$accountCreationDate",
                        style: TextStyle(
                            color: ColorService().CorTextS, fontSize: 16.0))
                  ]), //MEMBER SINCE
                  Container(
                      padding: EdgeInsets.only(left: 70.0),
                      child: Text("      $numberOfPosts Postagens",
                          style: TextStyle(
                              color: ColorService().CorTextS,
                              fontSize: 16.0)) //NUMBER OF POSTS
                  )
                ],
              )
            ])
          )
        ]));
  }
}
class ThemePageState extends State<ThemePage>{
  String myUser = ColorService().myUser;
  int CorP = ColorService().CorPValue;
  int CorS = ColorService().CorSValue;
  int CorTextP = ColorService().CorTextPValue;
  int CorTextS = ColorService().CorTextSValue;
  Future uploadColors() async{
    var userRef =  await FirebaseFirestore.instance.collection('users').doc('$myUser');
    await userRef.set({
      'CorP': CorP,
      'CorS' : CorS,
      'CorTextP' : CorTextP,
      'CorTextS' : CorTextS,
    }, SetOptions( merge: true ));
  }
  @override
  Widget build(context) {
    return Scaffold(
        backgroundColor: ColorService().CorP,
        appBar: AppBar(
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                color: ColorService().CorS,
                onPressed: () {
                  setState(() {
                    ColorService().CorP = ColorService().CorP;
                    ColorService().CorS = ColorService().CorS;
                    ColorService().CorTextP = ColorService().CorTextP;
                    ColorService().CorTextS = ColorService().CorTextS;
                    uploadColors();
                  });
                  Navigator.pop(context);
                }
            ),
            backgroundColor: ColorService().CorP
        ),
        body: Column(
          children: [
            SizedBox(
                height: 30,
                width: double.infinity,
                child: Container(
                    padding: EdgeInsets.only(left: 20.0, top: 10.0),
                    child: Text("Tema principal",
                        style: TextStyle(
                            color: ColorService().CorTextP, fontSize: 15.0)))),
            SizedBox(
                height: 60,
                width: double.infinity,
                child: Card(
                    color: ColorService().CorTextS,
                    child: Row(children: [
                      Container(
                          padding: EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Row(children: [
                            Container(
                                height: 15,
                                width: 15,
                                decoration: BoxDecoration(border: Border.all(
                                    color: Colors.black,
                                    width: 1.5
                                ),
                                ),
                                child: Container(color: ColorService().CorP)),
                            Text("  Cor primaria",
                                style: TextStyle(
                                    color: ColorService().CorTextP,
                                    fontSize: 15.0))
                          ])),
                      Container(
                          padding: EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Row(children: [
                            Container(
                                height: 15,
                                width: 15,
                                decoration: BoxDecoration(border: Border.all(
                                    color: Colors.black,
                                    width: 1.5
                                ),
                                ),
                                child: Container(color: ColorService().CorS)),
                            Text("  Cor secundaria",
                                style: TextStyle(
                                    color: ColorService().CorTextP,
                                    fontSize: 15.0))
                          ]))
                    ]))),
            SizedBox(
                height: 30,
                width: double.infinity,
                child: Container(
                    padding: EdgeInsets.only(left: 20.0, top: 10.0),
                    child: Text("Tema de texto",
                        style: TextStyle(
                            color: ColorService().CorTextP, fontSize: 15.0)))),
            SizedBox(
                height: 60,
                width: double.infinity,
                child: Card(
                    color: ColorService().CorTextS,
                    child: Row(children: [
                      Container(
                          padding: EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Row(children: [
                            Container(
                                height: 15,
                                width: 15,
                                decoration: BoxDecoration(border: Border.all(
                                    color: Colors.black,
                                    width: 1.5
                                ),
                                ),
                                child: Container(color: ColorService().CorTextP)),
                            Text("  Cor primaria",
                                style: TextStyle(
                                    color: ColorService().CorTextP,
                                    fontSize: 15.0))
                          ])),
                      Container(
                          padding: EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Row(children: [
                            Container(
                                height: 15,
                                width: 15,
                                decoration: BoxDecoration(border: Border.all(
                                    color: Colors.black,
                                    width:1.5
                                ),
                                ),
                                child: Container(color: ColorService().CorTextS)),
                            Text("  Cor secundaria",
                                style: TextStyle(
                                    color: ColorService().CorTextP,
                                    fontSize: 15.0))
                          ]))
                    ]))),
            SizedBox(
                height: 30,
                width: double.infinity,
                child: Container(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Row(
                        children: [
                          Text("Editar",
                              style: TextStyle(
                                  color: ColorService().CorTextP, fontSize: 15.0)),
                          Container(
                              padding: EdgeInsets.only(left: 285, bottom:5),
                              child: IconButton(
                                  icon: Icon(Icons.refresh_rounded, color: ColorService().CorTextP),
                                  onPressed:(){
                                    setState((){
                                      ColorService().CorP = ColorService().CorP;
                                      ColorService().CorS = ColorService().CorS;
                                      ColorService().CorTextP = ColorService().CorTextP;
                                      ColorService().CorTextS = ColorService().CorTextS;
                                    });
                                  }

                              )
                          )
                        ]
                    ))),
            SizedBox(
                height: 60,
                width: double.infinity,
                child: Card(
                    color: Colors.grey[800],
                    child: Row(children: [
                      Container(
                          padding: EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Row(children: [
                            Container(
                                height: 15,
                                width: 15,
                                decoration: BoxDecoration(border: Border.all(
                                    color: Colors.black,
                                    width: 1.5
                                ),
                                ),
                                child: Container(color: ColorService().CorP,)
                            ),
                            Text("  Layout: Cor primaria           ",
                                style: TextStyle(
                                    color: ColorService().CorTextP,
                                    fontSize: 15.0)),
                            OutlinedButton(
                                child: Container(
                                  width: 115,
                                  child: Center(
                                      child: Text("Escolher",
                                          style: new TextStyle(fontSize: 18.0, color: ColorService().CorTextP))
                                  ),
                                ),
                                style: ButtonStyle(
                                    shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))
                                ),
                                onPressed: () {
                                  ColorService().index = 1;
                                  Navigator.pushNamed(context, 'ColorSelectionPage');
                                }
                            )

                          ])),
                    ]))),
            SizedBox(
                height: 60,
                width: double.infinity,
                child: Card(
                    color: Colors.grey[800],
                    child: Row(children: [
                      Container(
                          padding: EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Row(children: [
                            Container(
                              height: 15,
                              width: 15,
                              decoration: BoxDecoration(border: Border.all(
                                  color: Colors.black,
                                  width: 1.5
                              ),
                              ),
                              child: Container(color: ColorService().CorS,),
                            ),
                            Text("  Layout: Cor secundaria      ",
                                style: TextStyle(
                                    color: ColorService().CorTextP,
                                    fontSize: 15.0)),
                            OutlinedButton(
                                child: Container(
                                  width: 115,
                                  child: Center(
                                      child: Text("Escolher",
                                          style: new TextStyle(fontSize: 18.0, color: ColorService().CorTextP))
                                  ),
                                ),
                                style: ButtonStyle(
                                    shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))
                                ),
                                onPressed: () {
                                  ColorService().index = 2;
                                  Navigator.pushNamed(context, 'ColorSelectionPage');
                                }
                            )
                          ])),
                    ]))),
            SizedBox(
                height: 60,
                width: double.infinity,
                child: Card(
                    color: Colors.grey[800],
                    child: Row(children: [
                      Container(
                          padding: EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Row(children: [
                            Container(
                              height: 15,
                              width: 15,
                              decoration: BoxDecoration(border: Border.all(
                                  color: Colors.black,
                                  width: 1.5),
                              ),
                              child: Container(color: ColorService().CorTextP,),
                            ),
                            Text("  Texto: Cor primaria             ",
                                style: TextStyle(
                                    color: ColorService().CorTextP,
                                    fontSize: 15.0)),
                            OutlinedButton(
                                child: Container(
                                  width: 115,
                                  child: Center(
                                      child: Text("Escolher",
                                          style: new TextStyle(fontSize: 18.0, color: ColorService().CorTextP))
                                  ),
                                ),
                                style: ButtonStyle(
                                    shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))
                                ),
                                onPressed: () {
                                  ColorService().index = 3;
                                  Navigator.pushNamed(context, 'ColorSelectionPage');
                                }
                            )
                          ])),
                    ]))),
            SizedBox(
                height: 60,
                width: double.infinity,
                child: Card(
                    color: Colors.grey[800],
                    child: Row(children: [
                      Container(
                          padding: EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Row(children: [
                            Container(
                              height: 15,
                              width: 15,
                              color: ColorService().CorTextS,
                              child: Container(decoration: BoxDecoration(border: Border.all(
                                  color: Colors.black,
                                  width: 1.5
                              ),
                              ),),
                            ),
                            Text("  Texto: Cor secundaria        ",
                                style: TextStyle(
                                    color: ColorService().CorTextP,
                                    fontSize: 15.0)),
                            OutlinedButton(
                                child: Container(
                                  width: 115,
                                  child: Center(
                                      child: Text("Escolher",
                                          style: new TextStyle(fontSize: 18.0, color: ColorService().CorTextP))
                                  ),
                                ),
                                style: ButtonStyle(
                                    shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))
                                ),
                                onPressed: () {
                                  ColorService().index = 4;
                                  Navigator.pushNamed(context, 'ColorSelectionPage');

                                }
                            )
                          ])),
                    ]))),
          ],
        ));
  }
}
class ColorSelectionPageState extends State<ColorSelectionPage>{
  @override
  Widget build (context) {
    return Container(
        color: ColorService().CorP,
        child: GridView.count(
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
            crossAxisCount: 4,
            children: <Widget>[
              OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.white,),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(147);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.black,),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(146);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.pink[50],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(1);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.pink[100],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(2);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.pink[200],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(3);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.pink[300],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(4);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.pink[400],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(5);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.pink[500],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(6);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.pink[600],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(7);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.pink[700],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(8);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.pink[800],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(9);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.pink[900],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(10);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.red[100],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(11);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.red[200],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(12);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.red[300],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(13);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.red[400],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(14);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.red[500],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(15);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.red[600],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(16);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.red[700],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(17);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.red[800],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(18);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.red[900],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(19);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.deepOrangeAccent[100],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(20);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.deepOrangeAccent[200],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () { ColorSelector(21);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.deepOrange[300],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(22);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.deepOrangeAccent[400],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(23);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.deepOrange[500],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(24);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.deepOrange[600],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(25);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.deepOrangeAccent[700],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(26);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.deepOrange[800],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(27);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.deepOrange[900],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(28);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.orange[100],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(29);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.orange[200],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(30);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.orange[300],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(31);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.orange[400],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(32);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.orange[500],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(33);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.orange[600],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(34);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.orange[700],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(35);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.orange[800],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(36);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.orange[900],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(37);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.yellow[100],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(38);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.yellow[200],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(39);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.yellow[300],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(40);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.yellow[400],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(41);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.yellow[500],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(42);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.yellow[600],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(43);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.yellow[700],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(44);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.yellow[800],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(45);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.yellow[900],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(46);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.lime[100],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(47);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.lime[200],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(48);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.lime[300],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(49);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.lime[400],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(50);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.lime[500],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(51);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.lime[600],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(52);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.lime[700],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(53);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.lime[800],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(54);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.lime[900],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(55);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.lightGreen[100],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(56);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.lightGreen[200],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(57);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.lightGreen[300],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(58);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.lightGreen[400],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(59);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.lightGreen[500],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(60);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.lightGreen[600],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(61);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.lightGreen[700],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(62);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.lightGreen[800],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(63);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.lightGreen[900],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(64);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.green[100],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(65);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.green[200],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(66);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.green[300],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(67);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.green[400],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(68);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.green[500],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(69);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.green[600],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(70);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.green[700],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(71);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.green[800],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(72);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.green[900],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(73);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.cyan[100],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(74);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.cyan[200],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(75);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.cyan[300],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(76);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.cyan[400],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(77);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.cyan[500],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(78);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.cyan[600],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(79);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.cyan[700],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(80);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.cyan[800],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(81);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.cyan[900],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(82);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.lightBlue[100],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(83);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.lightBlue[200],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(84);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.lightBlue[300],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(85);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.lightBlue[400],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(86);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.lightBlue[500],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(87);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.lightBlue[600],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(88);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.lightBlue[700],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(89);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.lightBlue[800],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(90);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.lightBlue[900],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(91);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.blue[100],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(92);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.blue[200],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(93);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.blue[300],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(94);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.blue[400],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(95);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.blue[500],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(96);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.blue[600],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () { ColorSelector(97);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.blue[700],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(98);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.blue[800],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(99);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.blue[900],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(100);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.indigo[100],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(101);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.indigo[200],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(102);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.indigo[300],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(103);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.indigo[400],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(104);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.indigo[500],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(105);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.indigo[600],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(106);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.indigo[700],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(107);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.indigo[800],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(108);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.indigo[900],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(109);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.purple[100],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(110);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.purple[200],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(111);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.purple[300],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(112);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.purple[400],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(113);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.purple[500],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(114);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.purple[600],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(115);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.purple[700],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(116);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.purple[800],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(117);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.purple[900],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(118);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.deepPurple[100],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(119);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.deepPurple[200],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(120);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.deepPurple[300],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(121);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.deepPurple[400],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(122);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.deepPurple[500],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(123);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.deepPurple[600],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(124);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.deepPurple[700],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(125);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.deepPurple[800],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(126);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.deepPurple[900],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(127);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.brown[100],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(128);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.brown[200],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(129);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.brown[300],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(130);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.brown[400],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(131);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.brown[500],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(132);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.brown[600],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(133);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.brown[700],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(134);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.brown[800],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(135);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.brown[900],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(136);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.grey[100],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(137);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.grey[200],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(138);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.grey[300],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(139);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.grey[400],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(140);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.grey[500],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(141);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.grey[600],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(142);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.grey[700],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(143);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.grey[800],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(144);Navigator.pop(context);}
              ),OutlinedButton(
                  child: Container(
                    width: 115,
                    color: Colors.grey[900],),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 3, color: Colors.black)))),
                  onPressed: () {ColorSelector(145);Navigator.pop(context);}
              ),
            ]
        )
    );
  }
}
class SavedItensPageState extends State<SavedItensPage>{
  List<String> saves = new List<String>();
  List<Post> posts = new List<Post>();
  @override
  didChangeDependencies(){
    super.didChangeDependencies();
  }
  @override
  void initState(){
    getSaves();
    super.initState();
  }
  getSaves() async{
    final saveRef = await FirebaseFirestore.instance.collection('users').doc("${ColorService().myUser}").collection('saves');
    await saveRef.get().then((querySnapshot) => {
      querySnapshot.docs.forEach((doc) => {
        saves.add(doc['saveId']),

      })
    });
     print(saves.length);
     for (var i=0;i < saves.length; i++) {
      var _postId = saves[i];
      final postRef = await FirebaseFirestore.instance.collection('posts').doc('$_postId');
      int comments;
      String idUser;
      int likes;
      DateTime postDate;
      String postText;
      String postId;
      int _saves;
      String tag;
      String typePost;
      print('$_postId');
      await postRef.get().then((doc) => {
        comments = doc['comments'],
        idUser = doc['idUser'],
        likes = doc['likes'],
        postDate = Utils.toDateTime(doc['postDate']),
        postId = doc['postId'],
        postText = doc['postText'],
        _saves = doc['saves'],
        tag = doc['tag'],
        typePost = doc['typePost'],
        print('$idUser')
      });
       Post post = new Post(
        postId: postId,
        idUser: idUser,
        postText: postText ,
        likes: likes,
        comments: comments,
        saves: _saves,
        postDate: postDate,
        tag: tag,
        typePost: typePost,
      );
      print(post.postText);
      setState(() {
         posts.add(post);
      });
    }
  }

  @override
  Widget build(context){
    return Scaffold(
        backgroundColor: ColorService().CorP,
        appBar: AppBar(
            backgroundColor: ColorService().CorP,
            leading: IconButton(
                icon: Icon(Icons.arrow_back, color: ColorService().CorTextP),
                onPressed: (){
                  Navigator.pop(context);
                }
            ),
            title: Text("Itens salvos", style: TextStyle(color: ColorService().CorTextP))
        ),
        body: CustomScrollView(
          slivers:<Widget> [
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final Post post = posts[index];
                return BuildPosts(post);
              }, childCount: saves.length),
            )
          ],
        )
    );
  }
}
class ConfigPage extends StatelessWidget{
  @override
  Widget build(context){
    return Scaffold(
      backgroundColor: ColorService().CorP,
      appBar: AppBar(
          backgroundColor: ColorService().CorP,
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: ColorService().CorTextP),
              onPressed: (){
                Navigator.pop(context);
              }
          ),
          title: Text("Configurações", style: TextStyle(color: ColorService().CorTextP))
      ),
    );
  }
}
class ChatDrawer extends StatelessWidget{

  @override
  Widget build(context){
    return Scaffold(
      backgroundColor: ColorService().CorP,
      body: SafeArea(
        child: StreamBuilder<List<User>>(
          stream: FirebaseApi.getUsers(),
          builder: (context, snapshot){
            switch(snapshot.connectionState){
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              default:
                if(snapshot.hasError){
                  print(snapshot.error);
                  return buildText('Something went wrong try later');
                } else {
                  final users = snapshot.data;
                  if(users.isEmpty){
                    return buildText('No users found');
                  } else {
                    return Column(
                        children: [
                          ChatHeader(users: users),
                          ChatBody()
                        ]
                    );
                  }
                }
            }
          }
        )
      )
    );


  }
  Widget buildText(String text) => Center(
      child: Text(
          text,
          style: TextStyle(color: ColorService().CorTextP)
      )
  );
}
class AccountCreationPageState extends State<AccountCreationPage>{
  final nameController = TextEditingController();
  final subnameController = TextEditingController();
  final bioController = TextEditingController();
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  final profilePicController = TextEditingController();
  final backgroundPicController = TextEditingController();
  final roleController = TextEditingController();
  String _idUser;
  Future createAccount() async{
        final newUser = User(
            idUser: userController.text,
            password: passwordController.text ,
            name: nameController.text,
            subname: subnameController.text,
            bio: bioController.text,
            accountCreationDate: DateTime.now(),
            lastMessageTime: DateTime.now(),
            urlAvatar: profilePicController.text,
            urlBackground: backgroundPicController.text,
            role: roleController.text,
            CorP: 145,
            CorS: 25,
            CorTextP: 147,
            CorTextS: 141,
            numberOfPosts: 0,
            permissionLvl: 1,
        );

        await FirebaseFirestore.instance.collection('users').doc('$_idUser').set(newUser.toJson());
  }
  @override
  void dispose() {
    nameController.dispose();
    subnameController.dispose();
    bioController.dispose();
    userController.dispose();
    passwordController.dispose();
    profilePicController.dispose();
    backgroundPicController.dispose();
    roleController.dispose();
    super.dispose();
  }
  @override
  Widget build(context){
    return Scaffold(
      backgroundColor: ColorService().CorP,
      appBar: AppBar(
        backgroundColor: ColorService().CorP,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorService().CorTextP),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Criar conta', style: TextStyle(color: ColorService().CorTextP)),
        actions: <Widget>[
          Container(
            height: 6,
            width: 80,
            padding: EdgeInsets.only(top: 4, bottom: 4, right: 5),
            child: ElevatedButton(
                child: Text("Criar ", style: TextStyle(color: ColorService().CorTextP)),
                style: ElevatedButton.styleFrom(
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0),
                    ),
                    primary: ColorService().CorS,
                    onPrimary: ColorService().CorTextP
                ),
                onPressed: (){
                    setState(() {
                      _idUser = userController.text;
                    });
                    createAccount();
                    Navigator.pop(context);
                }),
          )
        ]
      ),
      body: Column(
        children: [
          Container(
            height: 40,
            width: double.infinity,
            color: ColorService().CorTextS,
            padding: EdgeInsets.all(3.0),
              margin: EdgeInsets.all(3.0),
            child: Row(
                children: [
                  Expanded(
                    child: Text('Nome:', style: TextStyle(color: ColorService().CorTextP)),
                  ),
                  Expanded(
                    child: TextField(
                        controller: nameController,
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(color: ColorService().CorTextP),
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: ColorService().CorS, width: 2.0),
                              borderRadius: BorderRadius.circular(10.0)
                          ),
                          border: OutlineInputBorder(),
                          fillColor: ColorService().CorTextS,
                          filled: true,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          counterStyle: TextStyle(color: ColorService().CorS),
                        ),
                        onChanged: (value){
                        }),
                  ),
                ]
            )
          ),
          Container(
              height: 40,
              width: double.infinity,
              color: ColorService().CorTextS,
              padding: EdgeInsets.all(3.0),
              margin: EdgeInsets.all(3.0),
            child: Row(
                children: [
                  Expanded(
                    child: Text('Subnome:', style: TextStyle(color: ColorService().CorTextP)),
                  ),
                  Expanded(
                    child: TextField(
                        controller: subnameController,
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(color: ColorService().CorTextP),
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: ColorService().CorS, width: 2.0),
                              borderRadius: BorderRadius.circular(10.0)
                          ),
                          border: OutlineInputBorder(),
                          fillColor: ColorService().CorTextS,
                          filled: true,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          counterStyle: TextStyle(color: ColorService().CorS),
                        ),
                        onChanged: (value){
                        }),
                  ),
                ]
            )
          ),
          Container(
              height: 40,
              width: double.infinity,
              color: ColorService().CorTextS,
              padding: EdgeInsets.all(3.0),
              margin: EdgeInsets.all(3.0),
            child: Row(
                children: [
                  Expanded(
                    child: Text('Bio:', style: TextStyle(color: ColorService().CorTextP)),
                  ),
                  Expanded(
                    child: TextField(
                        controller: bioController,
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(color: ColorService().CorTextP),
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: ColorService().CorS, width: 2.0),
                              borderRadius: BorderRadius.circular(10.0)
                          ),
                          border: OutlineInputBorder(),
                          fillColor: ColorService().CorTextS,
                          filled: true,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          counterStyle: TextStyle(color: ColorService().CorS),
                        ),
                        onChanged: (value){
                        }),
                  ),
                ]
            )
          ),
          Container(
              height: 40,
              width: double.infinity,
              color: ColorService().CorTextS,
              padding: EdgeInsets.all(3.0),
              margin: EdgeInsets.all(3.0),
            child: Row(
                children: [
                  Expanded(
                    child: Text('Usuário:', style: TextStyle(color: ColorService().CorTextP)),
                  ),
                  Expanded(
                    child: TextField(
                        controller: userController,
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(color: ColorService().CorTextP),
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: ColorService().CorS, width: 2.0),
                              borderRadius: BorderRadius.circular(10.0)
                          ),
                          border: OutlineInputBorder(),
                          fillColor: ColorService().CorTextS,
                          filled: true,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          counterStyle: TextStyle(color: ColorService().CorS),
                        ),
                        onChanged: (value){
                        }),
                  ),
                ]
            )
          ),
          Container(
              height: 40,
              width: double.infinity,
              color: ColorService().CorTextS,
              padding: EdgeInsets.all(3.0),
              margin: EdgeInsets.all(3.0),
            child: Row(
                children: [
                  Expanded(
                    child: Text('Senha:', style: TextStyle(color: ColorService().CorTextP)),
                  ),
                  Expanded(
                    child: TextField(
                        controller: passwordController,
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(color: ColorService().CorTextP),
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: ColorService().CorS, width: 2.0),
                              borderRadius: BorderRadius.circular(10.0)
                          ),
                          border: OutlineInputBorder(),
                          fillColor: ColorService().CorTextS,
                          filled: true,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          counterStyle: TextStyle(color: ColorService().CorS),
                        ),
                        onChanged: (value){
                        }),
                  ),
                ]
            )
          ),
          Container(
              height: 40,
              width: double.infinity,
              color: ColorService().CorTextS,
              padding: EdgeInsets.all(3.0),
              margin: EdgeInsets.all(3.0),
            child: Row(
                children: [
                  Expanded(
                    child: Text('Foto de perfil:', style: TextStyle(color: ColorService().CorTextP)),
                  ),
                  Expanded(
                    child: TextField(
                        controller: profilePicController,
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(color: ColorService().CorTextP),
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: ColorService().CorS, width: 2.0),
                              borderRadius: BorderRadius.circular(10.0)
                          ),
                          border: OutlineInputBorder(),
                          fillColor: ColorService().CorTextS,
                          filled: true,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          counterStyle: TextStyle(color: ColorService().CorS),
                        ),
                        onChanged: (value){
                        }),
                  ),
                ]
            )
          ),
          Container(
              height: 40,
              width: double.infinity,
              color: ColorService().CorTextS,
              padding: EdgeInsets.all(3.0),
              margin: EdgeInsets.all(3.0),
            child: Row(
                children: [
                  Expanded(
                    child: Text('Foto de capa:', style: TextStyle(color: ColorService().CorTextP)),
                  ),
                  Expanded(
                    child: TextField(
                        controller: backgroundPicController,
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(color: ColorService().CorTextP),
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: ColorService().CorS, width: 2.0),
                              borderRadius: BorderRadius.circular(10.0)
                          ),
                          border: OutlineInputBorder(),
                          fillColor: ColorService().CorTextS,
                          filled: true,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          counterStyle: TextStyle(color: ColorService().CorS),
                        ),
                        onChanged: (value){
                        }),
                  ),
                ]
            )
          ),
          Container(
              height: 40,
              width: double.infinity,
              color: ColorService().CorTextS,
              padding: EdgeInsets.all(3.0),
              margin: EdgeInsets.all(3.0),
            child: Row(
                children: [
                  Expanded(
                    child: Text('Role:', style: TextStyle(color: ColorService().CorTextP)),
                  ),
                  Expanded(
                    child: TextField(
                        controller: roleController,
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(color: ColorService().CorTextP),
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: ColorService().CorS, width: 2.0),
                              borderRadius: BorderRadius.circular(10.0)
                          ),
                          border: OutlineInputBorder(),
                          fillColor: ColorService().CorTextS,
                          filled: true,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          counterStyle: TextStyle(color: ColorService().CorS),
                        ),
                        onChanged: (value){
                        }),
                  ),
                ]
            )
          ),
        ]
      )
    );
  }
}
class EditProfilePage extends StatelessWidget {
  @override
  Widget build(context) {
    return Scaffold(backgroundColor: ColorService().CorP);
  }
}
class CreateChatState extends State<CreateChat>{
  List<User> _userMsg = new List<User>();
  bool loading = true;
  @override
  didChangeDependencies(){
    super.didChangeDependencies();
    checkChat(widget.users);
  }
  checkChat(List<User> users) async{
    List<User> userMsg = new List<User>();
    for (var i=0;i < users.length; i++) {
      User user = users[i];
      await FirebaseFirestore.instance.collection('users').doc("${user.idUser}")
          .collection('chats').doc("${ColorService().myUser}").get()
          .then((doc) =>
      {
        if(doc.exists){
        } else
          {
            userMsg.add(user)
          }
      }
      );
    }
    setState((){
      _userMsg = userMsg;
      loading = false;
    });
  }
  createChat(User user) async{
    final newChat = new Chat(
      chatId : 'new',
      members : 2,
    );
    var chatRef = await FirebaseFirestore.instance.collection('chat').add(newChat.toJson());
    var docId = await chatRef.get();
    var doc_id2 = docId.reference.id;
    await chatRef.set({
      'chatId' : doc_id2
    }, SetOptions( merge: true ));
    final myMember = new Member(
        userId : ColorService().myUser,
        chatId : doc_id2
    );
    final newMember = new Member(
        userId : user.idUser,
        chatId : doc_id2
    );
    await FirebaseFirestore.instance.collection('chat').doc('$doc_id2').collection('members').doc('${ColorService().myUser}').set(myMember.toJson());
    await FirebaseFirestore.instance.collection('chat').doc('$doc_id2').collection('members').doc('${user.idUser}').set(newMember.toJson());
    await FirebaseFirestore.instance.collection('users').doc("${ColorService().myUser}").collection('chats').doc('${user.idUser}').set(newMember.toJson());
    await FirebaseFirestore.instance.collection('users').doc("${user.idUser}").collection('chats').doc('${ColorService().myUser}').set(myMember.toJson());
  }
  bool exist = false;
  bool _exist = false;
  @override
  Widget build(context){
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          backgroundColor: ColorService().CorP,
          appBar: AppBar(
              leading: IconButton(icon: Icon(Icons.arrow_back, color: ColorService().CorS,
              ),onPressed: (){Navigator.pop(context);}),
              title: Text("Nova mensagem", style: TextStyle(color: ColorService().CorTextP)),
              backgroundColor: ColorService().CorP,
              bottom: new TabBar(
              tabs: [
                Tab(
                  icon: new Icon(Icons.message_outlined),
                ),
                Tab(
                  icon: new Icon(Icons.group_rounded),
                )
              ],
              labelColor: ColorService().CorS,
              unselectedLabelColor: ColorService().CorTextS,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorPadding: EdgeInsets.all(1.0),
              indicatorColor: ColorService().CorS,
            )
          ),

        body: TabBarView(
          children: [
            loading ? Container(height: 25,child:loadingIndicator()) : Container(
        padding: EdgeInsets.all(7),
        margin: EdgeInsets.only(left: 7, right: 7),
        decoration: BoxDecoration(
          color: ColorService().CorP,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child:  buildChats(_userMsg),
        ),



            Text(''),
          ]
        )
    ),
    );
  }

  Widget buildChats(List<User> users) => ListView.builder(
    physics: BouncingScrollPhysics(),
    itemBuilder: (context, index) {
      final user = users[index];
      return Container(
        color: ColorService().CorP,
        height: 75,
        child: ListTile(
            onTap: () {
              createChat(user);
              Navigator.pop(context);
            },
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(user.urlAvatar),
            ),
            title: Text(user.name, style: TextStyle(color: ColorService().CorTextP, fontSize: 16)),
            subtitle: Text(user.subname, style: TextStyle(color: ColorService().CorTextS, fontSize: 14))
        ),
      );
    },
    itemCount: users.length,
  );
}

BuildPosts(Post post) {
  switch(post.typePost){
    case 'textPost':{
      bool biggerThan = false;
      var minimum = 20.0;
      var textHeight = 20.0;
      bool moreHeight = false;
      var postHeight;
      textSize(){
        if(post.postText.length > 45){
          biggerThan = true;
          textHeight = post.postText.length * 0.48;
        }
        if(post.postText.length > 200){
          moreHeight = true;
        }
        postHeight = textHeight + 90;
      }
      getInfo() async{
        await textSize();

      }
      getInfo();
      return Card(
          color: ColorService().CorS,
          elevation: 1,
          child: Column(
              children: [
                TextPost(
                  post: post,
                  biggerThan: biggerThan,
                  minimum: minimum,
                  moreHeight: moreHeight,
                  postHeight: postHeight,
                  textHeight: textHeight,
                ),
                PostBar(post: post,
                  biggerThan: biggerThan,
                  minimum: minimum,
                  moreHeight: moreHeight,
                  postHeight: postHeight,
                  textHeight: textHeight,)
              ]
          )
      );
    }
    case 'imagePost':{
      bool noText = false;
      bool biggerThan = false;
      var minimum = 20.0;
      var textHeight = 20.0;
      bool moreHeight = false;
      String _name;
      String _subname;
      String _imgUrl;
      var imgId;
      var userId;
      var postHeight;
      textSize(){
        if(post.postText.length > 45){
          biggerThan = true;
          textHeight = post.postText.length * 0.48;
        }
        if(post.postText.length > 200){
          moreHeight = true;
        }
        postHeight = textHeight + 385.0;
      }

      getInfo() async{

        await textSize();
        if(post.postText == ""){
          noText = true;
        }
      }
      getInfo();
      return Card(
          color: ColorService().CorS,
          elevation: 1,
          child: Column(
              children: [
                ImgPost(
                  post: post,
                  biggerThan: biggerThan,
                  minimum: minimum,
                  moreHeight: moreHeight,
                  noText: noText,
                  postHeight: postHeight,
                  textHeight: textHeight,
                ),
                PostBar(post: post,
                  biggerThan: biggerThan,
                  minimum: minimum,
                  moreHeight: moreHeight,
                  noText: noText,
                  postHeight: postHeight,
                  textHeight: textHeight,)
              ]
          )
      );

    }
  };
}



