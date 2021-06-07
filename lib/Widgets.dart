import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'chats.dart';
import 'comments.dart';
import 'main.dart';
import 'HomePage.dart';
import 'member.dart';
import 'user.dart';
import 'Pages.dart';
import 'message.dart';
import 'firebase_api.dart';
import 'ChatPage.dart';
import 'Presets.dart';
import 'posts.dart';
import 'utils.dart';
//States================================
class PopupPost extends StatefulWidget{
  final String idUser;
  final Post post;
  const PopupPost({@required this.idUser,@required this.post, Key key}) : super(key: key);
  @override
  PopupPostState createState() => PopupPostState();
}
class PopupComment extends StatefulWidget{
  final Comment comment;
  const PopupComment({@required this.comment, Key key}) : super(key: key);
  @override
  PopupCommentState createState() => PopupCommentState();
}
class UserIcon extends StatefulWidget{
  final idUser;

  const UserIcon({@required this.idUser,
    Key key}) : super(key: key);
  @override
  UserIconState createState() => UserIconState();
}
class ChatBody extends StatefulWidget{

  const ChatBody({
    Key key}) : super(key: key);
  @override
  ChatBodyState createState() => ChatBodyState();
}
class ChatHeader extends StatefulWidget{
  final List<User> users;
  const ChatHeader({@required this.users,
    Key key}) : super(key: key);
  @override
  ChatHeaderState createState() => ChatHeaderState();
}
//Widgets===============================
class PopupPostState extends State<PopupPost>{
  var i = 1;
  var PostOwner = false;
  int _permissionLvl;
  int permissionLvl;
  deletePost() async{
    String id = widget.post.postId;
    print(id);
    var storage = FirebaseStorage.instance.ref().child("image/$id");
    storage.delete();
    await FirebaseFirestore.instance.collection('posts').doc("$id").delete().then((value) => {
    setState((){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content:Text("Post deletado com sucesso", style: TextStyle(color: ColorService().CorTextP)),
          duration: const Duration(seconds: 3), backgroundColor:ColorService().CorS)
    );
    })
    });
  }
  getInfo() async{
    var userId = ColorService().myUser;
    var user = await FirebaseFirestore.instance.collection('users').doc('$userId');
    await user.get().then((doc) => {
      _permissionLvl = doc['permissionLvl'],
    });
    setState(() {
      permissionLvl = _permissionLvl;
    });
  }
  @override
  initState(){
    getInfo();
    super.initState();
  }
  @override
  Widget build(BuildContext context){
    if(ColorService().myUser == widget.idUser){
      PostOwner = true;
    }
    return PopupMenuButton<int>(
        color: ColorService().CorP,
        onSelected: (value){
          if(value == 1){
            if(PostOwner == true || permissionLvl > 1){
                deletePost();
              }else{
              setState((){
                showDialog(
                    context: context,
                    builder: (_) => AlertDialog(title: Text("Permissão negada", style: TextStyle(color: ColorService().CorTextP)),
                        content: Text("Apenas moderadores ou o dono do post podem deletar um post", style: TextStyle(color: ColorService().CorTextS)),
                        backgroundColor: ColorService().CorP),
                    barrierDismissible: true
                );
              }
              );
            }
          } else if(value == 2){
            if(i == 1){
              i = 2;
              setState((){
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content:Text("Post mutado", style: TextStyle(color: ColorService().CorTextP)),
                        duration: const Duration(seconds: 3), backgroundColor:ColorService().CorS)
                );
              });
            } else{
              i = 1;
              setState((){
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content:Text("Post desmutado", style: TextStyle(color: ColorService().CorTextP)),
                        duration: const Duration(seconds: 3), backgroundColor:ColorService().CorS)
                );
              });
            }
          }},
        icon: Icon(Icons.more_vert, color: ColorService().CorTextP),
        itemBuilder: (context) => [
          PopupMenuItem(
              value: 1,
              child: Text("Deletar post", style: TextStyle(color: ColorService().CorTextP))
          ),
          PopupMenuItem(
              value: 2,
              child: Text(changeText(i), style: TextStyle(color: ColorService().CorTextP))
          )
        ]
    );
  }
}
class PopupCommentState extends State<PopupComment>{
  var commentOwner = false;
  int _permissionLvl;
  int permissionLvl;
  int comments = 0;
  Future deleteComment() async{
    String id = widget.comment.commentId;
    var postRef =  await FirebaseFirestore.instance.collection('posts').doc('${widget.comment.postId}');
    await postRef.get().then((doc) => {
      comments = doc['comments']
    });
    comments = comments - 1;
    await postRef.set({
      'comments': comments
    }, SetOptions( merge: true ));
    var storage = FirebaseStorage.instance.ref().child("image/${widget.comment.commentId}");
    storage.delete();
    await FirebaseFirestore.instance.collection('comments').doc("${widget.comment.commentId}").delete().then((value) => {
      setState((){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content:Text("Comentário deletado com sucesso", style: TextStyle(color: ColorService().CorTextP)),
                duration: const Duration(seconds: 3), backgroundColor:ColorService().CorS)
        );
      })
    });

  }
  getInfo()async{
    var userId = ColorService().myUser;
    var user = await FirebaseFirestore.instance.collection('users').doc('$userId');
    await user.get().then((doc) => {
      _permissionLvl = doc['permissionLvl'],
    });
    setState(() {
      permissionLvl = _permissionLvl;
    });
    if(widget.comment.idUser == ColorService().myUser){
      commentOwner = true;
    }
  }
  @override
  void initState(){
    super.initState();
    getInfo();
  }
  @override
  Widget build(context){
    return PopupMenuButton<int>(
        color: ColorService().CorP,
        onSelected: (value){
          if(value == 1){
            if(commentOwner == false && permissionLvl <= 1){
              setState((){
                showDialog(
                    context: context,
                    builder: (_) => AlertDialog(title: Text("Permissão negada", style: TextStyle(color: ColorService().CorTextP)),
                        content: Text("Apenas moderadores, o dono do post e o dono do comentário podem deletar um comentário", style: TextStyle(color: ColorService().CorTextS)),
                        backgroundColor: ColorService().CorP),
                    barrierDismissible: true
                );
              }
              );}
            if(commentOwner == true || permissionLvl > 1){
              deleteComment();
            }
          } },
        icon: Icon(Icons.more_vert, color: ColorService().CorTextP),
        itemBuilder: (context) => [
          PopupMenuItem(
              value: 1,
              child: Text("Deletar comentário", style: TextStyle(color: ColorService().CorTextP))
          ),
        ]
    );
  }
}
class UserIconState extends State<UserIcon>{
  var idUser;
  var name;
  var subname;
  var urlAvatar;
  var urlBackground;
  var bio;
  var role;
  var numberOfPosts;
  var accountCreationDate;
  var _name;
  var _subname;
  var _urlAvatar;
  var _urlBackground;
  var _bio;
  var _role;
  var _numberOfPosts;
  var _accountCreationDate;
  getInfo() async{
    idUser = widget.idUser;
    var user = await FirebaseFirestore.instance.collection('users').doc('$idUser');
    await user.get().then((doc) => {
      _name = doc['name'],
      _subname = doc['subname'],
      _urlAvatar = doc['urlAvatar'],
      _urlBackground = doc['urlBackground'],
      _bio = doc['bio'],
      _role = doc['role'],
      _accountCreationDate = Utils.toDateTime(doc['accountCreationDate']),
      _numberOfPosts = doc['numberOfPosts'],
    });
    setState(() {
      name = _name;
      subname = _subname;
      urlAvatar = _urlAvatar;
      urlBackground = _urlBackground;
      bio = _bio;
      role = _role;
      numberOfPosts = _numberOfPosts;
      accountCreationDate = Utils.toOnlyDate(_accountCreationDate.toString());
    });
  }
  @override
  void initState() {
    getInfo();
    super.initState();
  }
  @override
  Widget build(context){
    return InkWell(
      onTap: () => showDialog(
          context: context,
          builder: (BuildContext context){
            return SimpleDialog(
                backgroundColor: ColorService().CorP,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                contentPadding: EdgeInsets.all(2.0),
                insetPadding: EdgeInsets.all(5.0),
                children: <Widget>[
                  SizedBox(
                      width: double.infinity,
                      height: 385,
                      child: Container(
                          color: ColorService().CorP,
                          child: Stack(clipBehavior: Clip.none, children: <Widget>[
                            Container(
                                width: double.infinity,
                                height: 150,
                                child: FittedBox(
                                    child: Image.network(
                                        "$urlBackground"),
                                    //Foto de capa
                                    fit: BoxFit.fill)),
                            Positioned(
                                top: 115,
                                left: 8,
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
                                left: 10,
                                child: Text("$name",
                                    style: TextStyle(
                                        color: ColorService().CorTextP,
                                        fontSize: 22.0))), //NAME
                            Positioned(
                                top: 213,
                                left: 10,
                                child: Text("@$subname",
                                    style: TextStyle(
                                        color: ColorService().CorTextS,
                                        fontSize: 16.0))), //ID @
                            Positioned(
                                top: 333,

                                child: Container(
                                    height: 55,
                                    width: 380,
                                    child: OutlinedButton(
                                        style: ButtonStyle(
                                            shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width:1.5, color: Colors.black)))),
                                        child: Container(color: ColorService().CorS, child: Center(child: Text("Visitar perfil", style: TextStyle(color: ColorService().CorTextP, fontSize: 20.0)))),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ProfilePage(idUser: idUser),
                                              ));
                                        }
                                    )
                                )
                            ),
                            Positioned(
                              top: 300,
                              left: 10,
                              child: Row(
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
                            ),
                          ])
                      )
                  )
                ]);
          }
      ),
      child: CircleAvatar(
        radius: 25,
        backgroundImage: NetworkImage(
            "$urlAvatar"),
      ),);
  }
}
class ChatHeaderState extends State<ChatHeader> {
  List<User> _userMsg = new List<User>();
  bool loading = false;
  @override
  didChangeDependencies(){
    super.didChangeDependencies();
    checkChat(widget.users);
  }
  checkChat(List<User> users) async{
    loading = true;
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
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
    width: double.infinity,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: ColorService().CorP,
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _userMsg.length,
            itemBuilder: (context, index) {
              final user = _userMsg[index];
              if (index == 0) {
                return Container(
                  color: ColorService().CorP,
                  margin: EdgeInsets.only(right: 12),
                  child: CircleAvatar(
                    backgroundColor: ColorService().CorS,
                    radius: 24,
                    child: IconButton(icon: Icon(Icons.search, color: ColorService().CorTextP),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CreateChat(users: widget.users),
                          ));
                        }
                    ),

                  ),
                );
              } else {
                return Container(
                  color: ColorService().CorP,
                  margin: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      createChat(user);
                      setState(() {
                        checkChat(widget.users);
                        Navigator.pop(context);
                      });
                    },
                    child:  CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(user.urlAvatar),
                    ),
                  ),
                );
              }
            },
          ),
        )
      ],
    ),
  );
}
class ChatBodyState extends State<ChatBody> {
  bool newMsg = false;
  List<bool> _newMsgs = new List<bool>();
  List<bool> newMsgs = new List<bool>();
  @override
   didChangeDependencies(){
    super.didChangeDependencies;
    getUsers();
}
  viewMsg(User user) async{
    var userRef = await FirebaseFirestore.instance.collection('users').doc("${ColorService().myUser}").collection("chats").doc("${user.idUser}");
    await userRef.set({
      'newMsg': false,
    }, SetOptions( merge: true ));
  }
  List<User> _users = new List<User>();
  getUsers()async{
    bool _newMsg = false;
    DocumentReference userRef;
    List<String> users = new List<String>();
    Query ref = await FirebaseFirestore.instance.collection('users').doc("${ColorService().myUser}").collection('chats').orderBy('lastMessageTime', descending: true);
      await ref.get().then((querySnapshot) async => {
      await querySnapshot.docs.forEach((documentSnapshot) =>{
        users.add(documentSnapshot['userId']),
        _newMsg = documentSnapshot['newMsg'],
        _newMsgs.add(_newMsg)
      })
      });
    for (var i=0;i < users.length; i++) {
      var _userId = users[i];
      final userRef = await FirebaseFirestore.instance.collection('users').doc('$_userId');
      String idUser;
      String name;
      String subname;
      String urlAvatar;
      await userRef.get().then((doc) => {
        idUser = doc['idUser'],
        name = doc['name'],
        subname = doc['subname'],
        urlAvatar = doc['urlAvatar'],
      });
      User user = new User(
        idUser: idUser,
        name: name,
        subname: subname,
        urlAvatar: urlAvatar
      );
      setState(() {
       _users.add(user);
        newMsgs = _newMsgs;
        print(_newMsg);
        print(newMsgs.length);
      });
    }
  }
  @override
  Widget build(BuildContext context) =>
      Expanded(
        child: Container(
          padding: EdgeInsets.all(7),
          margin: EdgeInsets.only(left: 7, right: 7),
          decoration: BoxDecoration(
            color: ColorService().CorS,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: buildChats(_users),
        ),
      );

  Widget buildChats(List<User> users) => ListView.builder(
    physics: BouncingScrollPhysics(),
    itemBuilder: (context, index) {
      final user = users[index];
       if(newMsgs[index] == true){
         return Container(
          color: ColorService().CorS,
          height: 75,
          child: ListTile(
              onTap: () {
                viewMsg(user);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ChatPage(user: user),
                ));
              },
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(user.urlAvatar),
              ),
              title: Text(user.name, style: TextStyle(color: ColorService().CorP, fontSize: 16)),
              subtitle: Text(user.subname, style: TextStyle(color: ColorService().CorTextS, fontSize: 14))
          ),
        );
          } else{
         return Container(
           color: ColorService().CorS,
           height: 75,
           child: ListTile(
               onTap: () {
                 Navigator.of(context).push(MaterialPageRoute(
                   builder: (context) => ChatPage(user: user),
                 ));
               },
               leading: CircleAvatar(
                 radius: 25,
                 backgroundImage: NetworkImage(user.urlAvatar),
               ),
               title: Text(user.name, style: TextStyle(color: ColorService().CorTextP, fontSize: 16,fontWeight: FontWeight.bold)),
               subtitle: Text(user.subname, style: TextStyle(color: ColorService().CorTextS, fontSize: 14,fontWeight: FontWeight.bold))
           ),
         );
       }
    },
    itemCount: users.length,
  );
}
class MessageWidget extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageWidget({
    @required this.message,
    @required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(12);
    final borderRadius = BorderRadius.all(radius);

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        if (!isMe)
          CircleAvatar(
              radius: 16, backgroundImage: NetworkImage(message.urlAvatar)),
        Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.all(16),
          constraints: BoxConstraints(maxWidth: 140),
          decoration: BoxDecoration(
            color: isMe ? ColorService().CorTextP : ColorService().CorP,
            borderRadius: isMe
                ? borderRadius.subtract(BorderRadius.only(bottomRight: radius))
                : borderRadius.subtract(BorderRadius.only(bottomLeft: radius)),
          ),
          child: buildMessage(),
        ),
      ],
    );
  }

  Widget buildMessage() => Column(
    crossAxisAlignment:
    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        message.message,
        style: TextStyle(color: isMe ? ColorService().CorTextS : ColorService().CorTextP),
        textAlign: isMe ? TextAlign.end : TextAlign.start,
      ),
    ],
  );
}
class MessagesWidget extends StatelessWidget {
  final String idUser;
  final String chatId;
  const MessagesWidget({
    @required this.idUser,
    @required this.chatId,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => StreamBuilder<List<Message>>(
    stream: FirebaseApi.getMessages(chatId),
    builder: (context, snapshot) {
      switch (snapshot.connectionState) {
        case ConnectionState.waiting:
          return Center(child: CircularProgressIndicator());
        default:
          if (snapshot.hasError) {
            return buildText('Something Went Wrong Try later');
          } else {
            final messages = snapshot.data;

            return messages.isEmpty
                ? buildText('Diga oi..')
                : ListView.builder(
              physics: BouncingScrollPhysics(),
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                if(message.imgUrl == null){
                  return MessageWidget(
                    message: message,
                    isMe: message.username == ColorService().myUser,
                  );
                }else {
                  return ImgMessage(
                    message: message,
                    isMe: message.username == ColorService().myUser,
                  );
                }

              },
            );
          }
      }
    },
  );

  Widget buildText(String text) => Center(
    child: Text(
      text,
      style: TextStyle(color: ColorService().CorTextP, fontSize: 24),
    ),
  );
}
class ImgMessage extends StatelessWidget {
  final Message message;
  final bool isMe;

  const ImgMessage({
    @required this.message,
    @required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(12);
    final borderRadius = BorderRadius.all(radius);

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        if (!isMe)
          CircleAvatar(
              radius: 16, backgroundImage: NetworkImage(message.urlAvatar)),
        Container(
          height: 250,
          width: 250,
          padding: EdgeInsets.all(3),
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isMe ? ColorService().CorTextP : ColorService().CorP,
            borderRadius: isMe
                ? borderRadius.subtract(BorderRadius.only(bottomRight: radius))
                : borderRadius.subtract(BorderRadius.only(bottomLeft: radius)),
          ),
          child: buildMessage(context),
        ),
      ],
    );
  }

  Widget buildMessage(BuildContext context) {
    final radius = Radius.circular(12);
    final borderRadius = BorderRadius.all(radius);

    return Column(
      crossAxisAlignment:
      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            height: 244,
            width: 256,
            decoration: BoxDecoration(
              color: isMe ? ColorService().CorTextP : ColorService().CorP,
              borderRadius: isMe
                  ? borderRadius.subtract(BorderRadius.only(bottomRight: radius))
                  : borderRadius.subtract(BorderRadius.only(bottomLeft: radius)),
            ),
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
                                child: Image.network("${message.imgUrl}")
                            )
                        );
                      }
                  );
                },
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: Image.network("${message.imgUrl}", fit: BoxFit.fill)
                ))
        )
      ],
    );
  }
}
class ProfileHeaderWidget extends StatelessWidget {
final String name;
final idUser;
final subname;
final urlAvatar;
final bio;
final urlBackground;
final role;
final accountCreationDate;
final numberOfPosts;
const ProfileHeaderWidget({
@required this.name,
@required this.idUser,
@required this.subname,
@required this.numberOfPosts,
@required this.urlBackground,
@required this.accountCreationDate,
@required this.role,
@required this.bio,
@required this.urlAvatar,
Key key,
}) : super(key: key);

@override
Widget build(BuildContext context) => Container(
  height: 82,
  padding: EdgeInsets.all(16).copyWith(left: 0),
  child: Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: Icon(Icons.arrow_back, color: ColorService().CorTextP),
          onPressed:(){
            Navigator.pop(context);
          }),
          Container(padding: EdgeInsets.only(right: 10), child:
          UserIcon(
            idUser: idUser,
            )),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 24,
                color: ColorService().CorTextP,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

        ],
      )
    ],
  ),
);

Widget buildIcon(IconData icon) => Container(
  padding: EdgeInsets.all(5),
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: ColorService().CorTextP,
  ),
  child: Icon(icon, size: 25, color: ColorService().CorTextP),
);
}
class loadingIndicator extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return LinearProgressIndicator(
        backgroundColor: ColorService().CorP,
        valueColor: new AlwaysStoppedAnimation<Color>(ColorService().CorS),

    );
  }
}