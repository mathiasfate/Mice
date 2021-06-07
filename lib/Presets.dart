import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Pages.dart';
import 'comments.dart';
import 'likes.dart';
import 'main.dart';
import 'HomePage.dart';
import 'Widgets.dart';
import 'saves.dart';
import 'utils.dart';
import 'posts.dart';
//States================================================
class MultImgPost extends StatefulWidget{
  const MultImgPost({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return MultImgPostState();
  }
}
class PollPost extends StatefulWidget{
  const PollPost({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return PollPostState();
  }
}
class CommentTileText extends StatefulWidget{
  final Comment comment;
  const CommentTileText({@required this.comment, Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return CommentTileTextState();
  }
}
class PostBar extends StatefulWidget{
  final Post post;
  final moreHeight;
  final postHeight;
  final noText;
  final textHeight;
  final biggerThan;
  final minimum;
  const PostBar({
    @required this.post,
    this.moreHeight,
    this.postHeight,
    this.textHeight,
    this.biggerThan,
    this.minimum,
    this.noText,
    Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return PostBarState();
  }
}
//Presets===============================================
class TextPost extends StatelessWidget {
  final Post post;
  final moreHeight;
  final postHeight;
  final noText;
  final textHeight;
  final biggerThan;
  final minimum;
  const TextPost({
    @required this.post,
    this.moreHeight,
    this.postHeight,
    this.textHeight,
    this.biggerThan,
    this.minimum,
    this.noText,
    Key key}) : super(key: key);
  @override
  Widget build(context) {
    return Container(
      //SAMPLE de TEXT POST
      width: double.infinity,
      height: moreHeight ? 215.0 : postHeight,
      child: Card(
        color: ColorService().CorS,
        elevation: 0,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          ListTile(
              leading: UserIcon(
                  idUser: post.idUser
              ) ,
              title: Text("${post.name}",
                  style: TextStyle(color: ColorService().CorTextP)),
              subtitle: Text("@${post.subname}",
                  style: TextStyle(color: ColorService().CorTextS)),
              trailing: PopupPost(idUser: post.idUser, post: post)
          ),
          Container(
              height: biggerThan ? textHeight : minimum,
              width: double.infinity,
              padding: EdgeInsets.only(right: 1.0, top: 1.0, bottom: 1.0, left: 10),
              child: Row(
                  children: [
                    Flexible(
                        child :Text("${post.postText}",
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            maxLines: 15,
                            style: TextStyle(color: ColorService().CorTextP, fontSize: 15))
                    )
                  ]
              )),
        ]),
      ),
    );
  }
}
class ImgPost extends StatelessWidget {
  final Post post;
  final moreHeight;
  final postHeight;
  final noText;
  final textHeight;
  final biggerThan;
  final minimum;
  const ImgPost({
    @required this.post,
    this.moreHeight,
    this.postHeight,
    this.textHeight,
    this.biggerThan,
    this.minimum,
    this.noText,
    Key key}) : super(key: key);
  @override
  Widget build(context) {
    return Container(
      //SAMPLE de IMG POST
      width: double.infinity,
      height: moreHeight ? 489.0 : postHeight,
      child: Card(
        color: ColorService().CorS,
        elevation: 0,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          ListTile(
              leading: UserIcon(
                  idUser: post.idUser
              ) ,
              title: Text("${post.name}",
                  style: TextStyle(color: ColorService().CorTextP)),
              subtitle: Text("@${post.subname}",
                  style: TextStyle(color: ColorService().CorTextS)),
              trailing: PopupPost(idUser: post.idUser, post: post)
          ),
          noText ? Text('')  : Container(
              height: biggerThan ? textHeight : minimum,
              width: double.infinity,
              padding: EdgeInsets.only(right: 1.0, top: 1.0, bottom: 1.0, left: 10),
              margin: EdgeInsets.only(bottom: 5.0),
              child: Row(
                  children:[
                    Flexible(
                        child :Text("${post.postText}",
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            maxLines: 15,
                            style: TextStyle(color: ColorService().CorTextP, fontSize: 15))
                    )
                  ]
              )),
          SizedBox(
              width: double.infinity,
              height: 300,
              child: GestureDetector(
                  onTap: () {
                    showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
                        barrierColor: ColorService().CorP,
                        transitionDuration: const Duration(milliseconds: 200),
                        pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation){
                          return Center(
                              child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height -  300,
                                  padding: EdgeInsets.all(20),
                                  child: Image.network("${post.imgUrl}")
                              )
                          );
                        }
                    );
                  },
                  child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      child: Image.network("${post.imgUrl}", fit: BoxFit.fill)
                  )
                    ) ,)


        ]),
      ),
    );
  }
}
class MultImgPostState extends State<MultImgPost> {
  Color _favIconColor = ColorService().CorTextS;
  Color _SavedIconColor = ColorService().CorTextS;
  @override
  Widget build(context) {
    return SizedBox(
      //SAMPLE de IMG POST COM MAIS DE UMA FOTO
      width: double.infinity,
      height: 534.0,
      child: Card(
        color: ColorService().CorP,
        elevation: 1,
        child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
          ListTile(
              leading: UserIcon(),
              title: Text("Matico",
                  style: TextStyle(color: ColorService().CorTextP)),
              subtitle: Text("@MatiquimDelas",
                  style: TextStyle(color: ColorService().CorTextS)),
              trailing: PopupPost()
          ),
          Container(
              padding: EdgeInsets.all(1.0),
              child: Text(
                  "Os posts de texto podem ter até 250 caracteres, aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
                  style: TextStyle(color: ColorService().CorTextP))),
          SizedBox(
              width: double.infinity,
              height: 308,
              child: CarouselWithIndicatorDemo()),
          Row(children: <Widget>[
            Expanded(
                child: IconButton(
                  icon: Icon(Icons.chat_bubble_outline_rounded),
                  color: ColorService().CorTextS,
                  onPressed: (){
                    if(ColorService().isCommentSection == false){
                      Navigator.pushNamed(context, 'CommentSection');
                    }
                  }, //IMPLEMENTAR FUNÇÃO COMENTARIO
                )),
            Expanded(
                child: IconButton(
                    icon: Icon(Icons.favorite),
                    color: _favIconColor,
                    splashColor: ColorService().CorS,
                    onPressed: () {
                      setState(() {
                        if (_favIconColor == ColorService().CorTextS) {
                          _favIconColor = ColorService().CorS;
                        } else {
                          _favIconColor = ColorService().CorTextS;
                        }
                      });
                    })), //IMPLEMENTAR FUNÇÃO LIKE
            Expanded(
                child: IconButton(
                    icon: Icon(Icons.save),
                    color: _SavedIconColor,
                    onPressed: (){
                      setState((){
                        if(ColorService().isSaved == false){
                          _SavedIconColor = ColorService().CorS;
                          ColorService().isSaved = true;
                        } else {
                          _SavedIconColor = ColorService().CorTextS;
                          ColorService().isSaved = false;
                        }
                      });
                    }
                  //IMPLEMENTAR FUNÇÃO SALVAR POST
                )),
          ]),
        ]),
      ),
    );
  }
}
class PollPostState extends State<PollPost>{
  Color _favIconColor = ColorService().CorTextS;
  Color _SavedIconColor = ColorService().CorTextS;
  bool option1 = true;
  bool option2 = true;
  bool option3 = true;
  bool option4 = true;
  bool option5 = true;
  double pollIndicator1 = 0;
  double pollIndicator2 = 0.25;
  double pollIndicator3 = 0.5;
  double pollIndicator4 = 0.75;
  double pollIndicator5 = 1;
  int pollPercentage1 = 0;
  int pollPercentage2 = 25;
  int pollPercentage3 = 50;
  int pollPercentage4 = 75;
  int pollPercentage5 = 100;
  bool checkboxVisible1 = true;
  bool checkboxVisible2 = true;
  bool checkboxVisible3 = true;
  bool checkboxVisible4 = true;
  bool checkboxVisible5 = true;
  bool checkboxValue1 = false;
  bool checkboxValue2= false;
  bool checkboxValue3 = false;
  bool checkboxValue4 = false;
  bool checkboxValue5 = false;
  @override
  Widget build( context){
    return SizedBox(
      //SAMPLE de PollPost
      width: double.infinity,
      height: 466.0,
      child: Card(
        color: ColorService().CorP,
        elevation: 1,
        child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
          ListTile(
              leading: UserIcon() ,
              title: Text("Matico",
                  style: TextStyle(color: ColorService().CorTextP)),
              subtitle: Text("@MatiquimDelas",
                  style: TextStyle(color: ColorService().CorTextS)),
              trailing: PopupPost()
          ),
          Container(
              padding: EdgeInsets.all(1.0),
              child: Text(
                  "Os posts de texto podem ter até 250 caracteres, aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
                  style: TextStyle(color: ColorService().CorTextP))),
          Container(
            child: Column(
              children: [
                option1 ? Row(
                    children: [
                      Container(
                        width: 320,
                        padding: EdgeInsets.only(right: 5, top: 7),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child:Expanded(child: LinearProgressIndicator(
                              value: pollIndicator1,
                              backgroundColor: ColorService().CorTextS,
                              valueColor: new AlwaysStoppedAnimation<Color>(ColorService().CorS),
                              minHeight: 25
                          )),
                        )
                      ),
                      Expanded(child: Text('$pollPercentage1 %', style: TextStyle(color: ColorService().CorTextP),)),
                      checkboxVisible1 ? Theme(
                        data: ThemeData(unselectedWidgetColor: ColorService().CorS),
                        child: Checkbox(
                        value: checkboxValue1,
                        checkColor: ColorService().CorP,
                        activeColor: ColorService().CorS,
                        onChanged: (value){
                          setState(() {
                            checkboxVisible2 = false;
                            checkboxVisible3 = false;
                            checkboxVisible4 = false;
                            checkboxVisible5 = false;
                            checkboxValue1 = true;
                          });
                        } ,
                      )
                      ) : Text('')

                    ]
                ) : Text(''),
                option2 ? Row(
                    children: [
                      Container(
                        width: 320,
                        padding: EdgeInsets.only(right: 5, top: 7),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: Expanded(child: LinearProgressIndicator(
                              value: pollIndicator2,
                              backgroundColor: ColorService().CorTextS,
                              valueColor: new AlwaysStoppedAnimation<Color>(ColorService().CorS),
                              minHeight: 25
                          )),
                        )
                      ),
                      Expanded(child: Text('$pollPercentage2 %', style: TextStyle(color: ColorService().CorTextP),)),
                      checkboxVisible2 ? Theme(
                        data: ThemeData(unselectedWidgetColor: ColorService().CorS),
                        child: Checkbox(
                          value: checkboxValue2,
                          checkColor: ColorService().CorP,
                          activeColor: ColorService().CorS,
                          onChanged: (value){
                            setState(() {
                              checkboxVisible1 = false;
                              checkboxVisible3 = false;
                              checkboxVisible4 = false;
                              checkboxVisible5 = false;
                              checkboxValue2 = true;
                            });
                          } ,
                        )
                      ) : Text('')
                    ]
                ) : Text(''),
                option3 ? Row(
                    children: [
                      Container(
                        width: 320,
                        padding: EdgeInsets.only(right: 5, top: 7),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: Expanded(child: LinearProgressIndicator(
                              value: pollIndicator3,
                              backgroundColor: ColorService().CorTextS,
                              valueColor: new AlwaysStoppedAnimation<Color>(ColorService().CorS),
                              minHeight: 25
                          )),
                        )
                      ),
                      Expanded(child: Text('$pollPercentage3 %', style: TextStyle(color: ColorService().CorTextP),)),
                      checkboxVisible3 ? Theme(
                        data: ThemeData(unselectedWidgetColor: ColorService().CorS),
                        child: Checkbox(
                          value: checkboxValue3,
                          checkColor: ColorService().CorP,
                          activeColor: ColorService().CorS,
                          onChanged: (value){
                            setState(() {
                              checkboxVisible1 = false;
                              checkboxVisible2 = false;
                              checkboxVisible4 = false;
                              checkboxVisible5 = false;
                              checkboxValue3 = true;
                            });
                          } ,
                        )
                      ) : Text('')
                    ]
                ) : Text(''),
                option4 ? Row(
                    children: [
                      Container(
                        width: 320,
                        padding: EdgeInsets.only(right: 5, top: 7),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: Expanded(child: LinearProgressIndicator(
                              value: pollIndicator4,
                              backgroundColor: ColorService().CorTextS,
                              valueColor: new AlwaysStoppedAnimation<Color>(ColorService().CorS),
                              minHeight: 25
                          )),
                        )
                      ),
                      Expanded(child: Text('$pollPercentage4 %', style: TextStyle(color: ColorService().CorTextP),)),
                      checkboxVisible4 ? Theme(
                        data: ThemeData(unselectedWidgetColor: ColorService().CorS),
                        child:  Checkbox(
                            value: checkboxValue4,
                            checkColor: ColorService().CorP,
                            activeColor: ColorService().CorS,
                            onChanged: (value){
                              setState(() {
                                checkboxVisible1 = false;
                                checkboxVisible2 = false;
                                checkboxVisible3 = false;
                                checkboxVisible5 = false;
                                checkboxValue4 = true;
                              });
                            } ,
                          )
                      ): Text('')
                    ]
                ) : Text(''),
                option5 ? Row(
                    children: [
                      Container(
                        width: 320,
                        padding: EdgeInsets.only(right: 5, top: 7),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: Expanded(child: LinearProgressIndicator(
                              value: pollIndicator5,
                              backgroundColor: ColorService().CorTextS,
                              valueColor: new AlwaysStoppedAnimation<Color>(ColorService().CorS),
                              minHeight: 25
                          )),
                        )
                      ),
                      Expanded(child: Text('$pollPercentage5 %', style: TextStyle(color: ColorService().CorTextP),)),
                      checkboxVisible5 ? Theme(
                        data: ThemeData(unselectedWidgetColor: ColorService().CorS),
                        child: Checkbox(
                          value: checkboxValue5,
                          checkColor: ColorService().CorP,
                          activeColor: ColorService().CorS,
                          onChanged: (value){
                            setState(() {
                              checkboxVisible1 = false;
                              checkboxVisible2 = false;
                              checkboxVisible3 = false;
                              checkboxVisible4 = false;
                              checkboxValue5 = true;
                            });
                          } ,
                        )
                      ) : Text('')
                    ]
                ) : Text(''),
              ]
            )
          ),
          Row(children: <Widget>[
            Expanded(
                child: IconButton(
                  icon: Icon(Icons.chat_bubble_outline_rounded),
                  color: ColorService().CorTextS,
                  onPressed: (){
                    if(ColorService().isCommentSection == false){
                      Navigator.pushNamed(context, 'CommentSection');
                    }
                  }, //IMPLEMENTAR FUNÇÃO COMENTARIO
                )),
            Expanded(
                child: IconButton(
                    icon: Icon(Icons.favorite),
                    color: _favIconColor,
                    splashColor: ColorService().CorS,
                    onPressed: () {
                      setState(() {
                        if (_favIconColor == ColorService().CorTextS) {
                          _favIconColor = ColorService().CorS;
                        } else {
                          _favIconColor = ColorService().CorTextS;
                        }
                      });
                    })), //IMPLEMENTAR FUNÇÃO LIKE
            Expanded(
                child: IconButton(
                    icon: Icon(Icons.save),
                    color: _SavedIconColor,
                    onPressed: (){
                      setState((){
                        if(ColorService().isSaved == false){
                          _SavedIconColor = ColorService().CorS;
                          ColorService().isSaved = true;
                        } else {
                          _SavedIconColor = ColorService().CorTextS;
                          ColorService().isSaved = false;
                        }
                      });
                    }
                  //IMPLEMENTAR FUNÇÃO SALVAR POST
                )),
          ]),
        ]),
      ),
    );
  }
}
class CommentTileTextState extends State<CommentTileText>{
  var _favIconColor = ColorService().CorTextS;
  var _name;
  var _subname;
  var _urlAvatar;
  var urlAvatar;
  var name;
  var subname;
  var commentText;
  bool biggerThan = false;
  var minimum = 20.0;
  var textHeight = 20.0;
  var tileHeight = 0.0;
  var hasImg = false;
  var imgUrl;
  bool liked = false;
  bool _liked = false;
  textSize(){
    setState(() {
      if(commentText.length > 45){
        biggerThan = true;
        textHeight = commentText.length * 0.65;
        tileHeight = textHeight + 128.0;
      }
      if(hasImg){
        biggerThan = true;
        tileHeight = tileHeight + 450.0;
      }
    });
  }
  likeFunction(String id) async{
    if(liked == false){
      final like = Like(
          likeId: id
      );
      await FirebaseFirestore.instance.collection('users').doc('${ColorService().myUser}').collection('likes').doc("$id").set(like.toJson());
      var postRef =  await FirebaseFirestore.instance.collection('comments').doc('${widget.comment.commentId}');
      await postRef.set({
        'likes': widget.comment.likes + 1
      }, SetOptions( merge: true ));
      setState(() {
        liked = true;
      });
    }
    else{
      final likeRef = await FirebaseFirestore.instance
          .collection('users')
          .doc('${ColorService().myUser}')
          .collection('likes')
          .doc("${widget.comment.commentId}");
      await likeRef.delete();
      var postRef =  await FirebaseFirestore.instance.collection('comments').doc('${widget.comment.commentId}');
      await postRef.set({
        'likes': widget.comment.likes - 1
      }, SetOptions( merge: true ));
      setState(() {
        liked = false;
      });
    }
  }
  getInfo() async{
    var userId = widget.comment.idUser;
    final likeRef = await FirebaseFirestore.instance
        .collection('users')
        .doc('${ColorService().myUser}')
        .collection('likes')
        .doc("${widget.comment.commentId}");
    await likeRef.get().then((doc) => {
      if(doc.exists) {
        _liked = true
      }else _liked = false
    });
    var user = await FirebaseFirestore.instance.collection('users').doc('$userId');
    await user.get().then((doc) => {
      _name = doc['name'],
      _subname = doc['subname'],
      _urlAvatar = doc['urlAvatar'],
    });
    setState(() {
      name = _name;
      subname = _subname;
      urlAvatar = _urlAvatar;
      commentText = widget.comment.commentText;
      liked = _liked;
    });

    if(widget.comment.imgUrl != null){
      hasImg = true;
      var storage = FirebaseStorage.instance.ref().child("image/${widget.comment.imgUrl}");
      var downloadUrl = await storage.getDownloadURL();
      setState(() {
        imgUrl = downloadUrl;
      });
    }
    await textSize();

  }
  @override
  didChangeDependencies(){
    super.didChangeDependencies();
    getInfo();
  }
  @override
  void initState(){
    super.initState();
  }
  @override
  Widget build(context){
    return Container(
      width: double.infinity,
      height: biggerThan ? tileHeight : 180.0,
      child: Card(
        color: ColorService().CorP,
        elevation: 1,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          ListTile(
              leading: UserIcon(idUser: widget.comment.idUser) ,
              title: Text("$name",
                  style: TextStyle(color: ColorService().CorTextP)),
              subtitle: Text("@$subname",
                  style: TextStyle(color: ColorService().CorTextS)),
              trailing: PopupComment(comment: widget.comment)
          ),
          Container(
              height: biggerThan ? textHeight : minimum,
              width: double.infinity,
              padding: EdgeInsets.only(right: 1.0, top: 1.0, bottom: 1.0, left: 10),
              child: Row(
                  children: [
                    Flexible(
                        child :Text("$commentText",
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            maxLines: 15,
                            style: TextStyle(color: ColorService().CorTextP, fontSize: 15))
                    )
                  ]
              )),
          hasImg ? SizedBox(
              width: double.infinity,
              height: 300,
              child: GestureDetector(
                  onTap: () {
                    showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
                        barrierColor: ColorService().CorP,
                        transitionDuration: const Duration(milliseconds: 200),
                        pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation){
                          return Center(
                              child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height -  300,
                                  padding: EdgeInsets.all(20),
                                  child: Image.network("$imgUrl",)
                              )
                          );
                        }
                    );
                  },
                  child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      child: Image.network("$imgUrl", fit: BoxFit.fill)
                  ))) : Text(""),
          Row(children: <Widget>[
            Expanded(
                child: IconButton(
                    icon: Icon(Icons.favorite),
                    color: liked ? ColorService().CorS : ColorService().CorTextS,
                    splashColor: ColorService().CorS,
                    onPressed: () {
                      likeFunction(widget.comment.commentId);
                    })),
            Container(padding: EdgeInsets.only(right: 40.0), child: Text("${widget.comment.likes}", style: TextStyle(color: ColorService().CorTextP))),
            Container(padding: EdgeInsets.only(left: 150.0), child: Text("${Utils.toOnlyTime(widget.comment.commentDate.toString(), context)}", style: TextStyle(color: ColorService().CorTextS))),
            Container(padding: EdgeInsets.only(left: 10.0), child: Text("${Utils.toOnlyDate(widget.comment.commentDate.toString())}", style: TextStyle(color: ColorService().CorTextS)))
          ]),
        ]),
      ),
    );
  }

}
class PostBarState extends State<PostBar>{
  bool liked = false;
  bool saved =  false;
  @override
  void initState(){
    getInfo();
    super.initState();
  }
  getInfo()async{
    final likeRef = await FirebaseFirestore.instance
        .collection('users')
        .doc('${ColorService().myUser}')
        .collection('likes')
        .doc("${widget.post.postId}");
    await likeRef.get().then((doc) => {
      if(doc.exists) {
        liked = true
      }else liked = false
    });
    final saveRef = await FirebaseFirestore.instance
        .collection('users')
        .doc('${ColorService().myUser}')
        .collection('saves')
        .doc("${widget.post.postId}");
    await saveRef.get().then((doc) => {
      if(doc.exists) {
        saved = true
      }else saved = false
    });
    setState(() {
    });
  }
  likeFunction(String id) async{
    if(liked == false){
      final like = Like(
          likeId: id
      );
      await FirebaseFirestore.instance.collection('users').doc('${ColorService().myUser}').collection('likes').doc("$id").set(like.toJson());
      var postRef =  await FirebaseFirestore.instance.collection('posts').doc('${widget.post.postId}');
      await postRef.set({
        'likes': widget.post.likes + 1
      }, SetOptions( merge: true ));
      setState(() {
        liked = true;
      });
    }
    else{
      final likeRef = await FirebaseFirestore.instance
          .collection('users')
          .doc('${ColorService().myUser}')
          .collection('likes')
          .doc("${widget.post.postId}");
      await likeRef.delete();
      var postRef =  await FirebaseFirestore.instance.collection('posts').doc('${widget.post.postId}');
      await postRef.set({
        'likes': widget.post.likes - 1
      }, SetOptions( merge: true ));
      setState(() {
        liked = false;
      });
    }
  }
  saveFunction(String id) async{
    if(saved == false){
      final save = Save(
          saveId: id
      );
      await FirebaseFirestore.instance.collection('users').doc('${ColorService().myUser}').collection('saves').doc("$id").set(save.toJson());
      var postRef =  await FirebaseFirestore.instance.collection('posts').doc('${widget.post.postId}');
      await postRef.set({
        'saves': widget.post.saves + 1
      }, SetOptions( merge: true ));
      setState(() {
        saved = true;
      });
    }
    else{
      final saveRef = await FirebaseFirestore.instance
          .collection('users')
          .doc('${ColorService().myUser}')
          .collection('saves')
          .doc("${widget.post.postId}");
      await saveRef.delete();
      var postRef =  await FirebaseFirestore.instance.collection('posts').doc('${widget.post.postId}');
      await postRef.set({
        'saves': widget.post.likes - 1
      }, SetOptions( merge: true ));
      setState(() {
        saved = false;
      });
    }
  }
  @override
  Widget build(context){
    return ColorService().isCommentSection ?
    Row(children: <Widget>[
      Expanded(
          child: IconButton(
              icon: Icon(Icons.favorite),
              color: liked ? ColorService().CorTextP : ColorService().CorP,
              splashColor: ColorService().CorS,
              onPressed: () {
                likeFunction(widget.post.postId);
              })),
      Expanded(
          child: IconButton(
              icon: Icon(Icons.save),
              color: saved ? ColorService().CorTextP : ColorService().CorP,
              onPressed: (){
                saveFunction(widget.post.postId);
              }
            //IMPLEMENTAR FUNÇÃO SALVAR POST
          )),
    ])
    : Row(children: <Widget>[
      Expanded(
          child: IconButton(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            color: ColorService().CorP,
            onPressed: (){
              print(ColorService().isCommentSection);
              if(ColorService().isCommentSection == false){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommentSection(post: widget.post,
                        biggerThan: widget.biggerThan,
                        minimum: widget.minimum,
                        moreHeight: widget.moreHeight,
                        noText: widget.noText,
                        postHeight: widget.postHeight,
                        textHeight: widget.textHeight,),
                    ));
              }
            }, //IMPLEMENTAR FUNÇÃO COMENTARIO
          )),
      Expanded(
          child: IconButton(
              icon: Icon(Icons.favorite),
              color: liked ? ColorService().CorTextP : ColorService().CorP,
              splashColor: ColorService().CorS,
              onPressed: () {
                likeFunction(widget.post.postId);
              })),
      Expanded(
          child: IconButton(
              icon: Icon(Icons.save),
              color: saved ? ColorService().CorTextP : ColorService().CorP ,
              onPressed: (){
                saveFunction(widget.post.postId);
              }
            //IMPLEMENTAR FUNÇÃO SALVAR POST
          )),
    ]);
  }
}


