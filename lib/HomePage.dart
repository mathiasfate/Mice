import 'dart:async';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'Pages.dart';
import 'Presets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_api.dart';
import 'posts.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
final scaffoldState = GlobalKey<ScaffoldState>();
final routeObserver = RouteObserver<PageRoute>();
final duration = const Duration(milliseconds: 300);
final List<Widget> images = [
  Image.network('https://images.unsplash.com/photo-1586882829491-b81178aa622e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2850&q=80',),
  Image.network('https://pbs.twimg.com/media/Ed5ebR9X0AAv2ui.jpg',),
  Image.network('https://pbs.twimg.com/media/Ed5eb7qWsAIz0-8.jpg'),
  Image.network("https://pbs.twimg.com/profile_images/1273081043424329728/gMNRD4c7_400x400.jpg"),
];

class HomePage extends StatefulWidget {
  const HomePage({
    Key key,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> with RouteAware {

  ScrollController _scrollViewController;
  bool _showAppbar = true;
  bool isScrollingDown = false;
  GlobalKey _fabKey = GlobalKey();
  bool _fabVisible = true;
  ColorService _ColorService = ColorService();
  String _name;
  String _subname;
  String _urlAvatar;
  int _permissionLvl;
  int permissionLvl;
  String name;
  String subname;
  String urlAvatar;
  bool isAdm = false;
  bool newMsg = false;
  void _messageRecieve() {
    FirebaseFirestore.instance.collection("users").doc("${ColorService().myUser}").collection('chats').snapshots().listen((result) {
      result.docs.forEach((result) {
        if(newMsg == false){
          newMsg = true;
        }else newMsg = false;
      });
    });
  }
  showMsg()async{
    bool _newMsg =  false;
    Query ref = await FirebaseFirestore.instance.collection('users').doc("${ColorService().myUser}").collection('chats');
    await ref.get().then((querySnapshot) async => {
      await querySnapshot.docs.forEach((doc) =>{
        if(doc['newMsg'] == true){
          _newMsg = true
        }
      })
    });
    setState(() {
      newMsg = _newMsg;
    });
  }
  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }
  void logoutUser() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs?.clear();
  }
  getInfo() async{

    var userId = ColorService().myUser;
    var user = await FirebaseFirestore.instance.collection('users').doc('$userId');
    await user.get().then((doc) => {
      _name = doc['name'],
      _subname = doc['subname'],
      _urlAvatar = doc['urlAvatar'],
      _permissionLvl = doc['permissionLvl'],

    });

    setState(() {
      name = _name;
      subname = _subname;
      urlAvatar = _urlAvatar;
      permissionLvl = _permissionLvl;
      if(permissionLvl == 3) isAdm = true;

    });
  }
  @override
  void initState (){
    getInfo();
    showMsg();
    _messageRecieve();
    BackButtonInterceptor.add(myInterceptor);
    super.initState();
    ColorService().isCommentSection = false;
    ColorService().isSaved = false;
    _scrollViewController = new ScrollController();
    _scrollViewController.addListener(() {
      if (_scrollViewController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!isScrollingDown) {
          isScrollingDown = true;
          _showAppbar = false;
          setState(() {});
        }
      }

      if (_scrollViewController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (isScrollingDown) {
          isScrollingDown = false;
          _showAppbar = true;
          setState(() {});
        }
      }
    });
  } //Controller do scroll pra dar hide na appbar
  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    setState(() {
      print("BACK BUTTON!"); // Do some stuff.
      ColorService().isCommentSection = false;
    });
    return true;
  }
  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    _scrollViewController.dispose();
    _scrollViewController.removeListener(() {});
    routeObserver.unsubscribe(this);
    super.dispose();
  } //Da dispose no controller do scroll e no routeObserver do PostButton

  @override
  didPopNext() {
    // Show back the FAB on transition back ended
    Timer(duration, () {
      setState(() => _fabVisible = true);
    });
  }
//Meu código
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,

        child: new Scaffold(
          backgroundColor: ColorService().CorP,
          key: _scaffoldKey,
          drawer: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: ColorService().CorP,
            ),
            child: Drawer(
              child: ListView(
                children: <Widget>[
                  new Container(
                    //Cabeçalho da drawer
                    child: new DrawerHeader(
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          new CircleAvatar(
                              backgroundImage: NetworkImage('$urlAvatar'),
                              radius: 35),
                          new Container(
                              padding: EdgeInsets.all(5.0),
                              child: new Text("$name",
                                  style: new TextStyle(
                                      fontSize: 22.0,
                                      color: ColorService().CorTextP))),
                          new Container(
                              padding: EdgeInsets.all(5.0),
                              child: new Text("@$subname",
                                  style: new TextStyle(
                                      fontSize: 14.0,
                                      color: ColorService().CorTextS)))
                        ],
                      ),
                    ),
                    color: ColorService().CorP,
                  ),
                  new OutlinedButton(
                      child: Row(children: <Widget>[
                        Container(
                            child: Icon(Icons.person, color: ColorService().CorTextP),
                            padding: EdgeInsets.all(5.0)),
                        Container(
                            child: Text("Perfil",
                                style: new TextStyle(fontSize: 18.0, color: ColorService().CorTextP)),
                            padding: EdgeInsets.all(8.0))
                      ]),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(idUser: ColorService().myUser),
                            ));
                      }),
                  new OutlinedButton(
                      child: Row(children: <Widget>[
                        Container(
                            child: Icon(Icons.airplay_outlined, color: ColorService().CorTextP),
                            padding: EdgeInsets.all(5.0)),
                        Container(
                            child: Text("Temas",
                                style: new TextStyle(fontSize: 18.0, color: ColorService().CorTextP)),
                            padding: EdgeInsets.all(8.0))
                      ]),
                      onPressed: () {
                        Navigator.pushNamed(context, 'ThemePage');
                      }),
                  new OutlinedButton(
                      child: Row(children: <Widget>[
                        Container(
                            child: Icon(Icons.turned_in_not_rounded, color: ColorService().CorTextP),
                            padding: EdgeInsets.all(5.0)),
                        Container(
                            child: Text("Itens salvos",
                                style: new TextStyle(fontSize: 18.0, color: ColorService().CorTextP)),
                            padding: EdgeInsets.all(8.0))
                      ]),
                      onPressed: () {
                        Navigator.pushNamed(context, 'SavedItensPage');
                      }),
                  new OutlinedButton(
                      child: Row(children: <Widget>[
                        Container(
                            child: Icon(Icons.settings, color: ColorService().CorTextP),
                            padding: EdgeInsets.all(5.0)),
                        Container(
                            child: Text("Configurações",
                                style: new TextStyle(fontSize: 18.0, color: ColorService().CorTextP)),
                            padding: EdgeInsets.all(8.0))
                      ]),
                      onPressed: () {
                        Navigator.pushNamed(context, 'ConfigPage');
                      }),
                  new OutlinedButton(
                      child: Row(children: <Widget>[
                        Container(
                            child: Icon(Icons.exit_to_app_rounded , color: ColorService().CorTextP),
                            padding: EdgeInsets.all(5.0)),
                        Container(
                            child: Text("Sair",
                                style: new TextStyle(fontSize: 18.0, color: ColorService().CorTextP)),
                            padding: EdgeInsets.all(8.0))
                      ]),
                      onPressed: () {
                        logoutUser();
                        Navigator.pushNamed(context, '_LoginScreen');
                      }),
                  isAdm ? OutlinedButton(
                      child: Row(children: <Widget>[
                        Container(
                            child: Icon(Icons.account_box_rounded , color: ColorService().CorTextP),
                            padding: EdgeInsets.all(5.0)),
                        Container(
                            child: Text("Criar conta",
                                style: new TextStyle(fontSize: 18.0, color: ColorService().CorTextP)),
                            padding: EdgeInsets.all(8.0))
                      ]),
                      onPressed: () {
                        Navigator.pushNamed(context, 'AccountCreationPage');
                      }) : Text(''),
                ],
              ),
            ),
          ),
          endDrawer: Drawer(
              child: ChatDrawer()
          ),
          floatingActionButton: Visibility(
            visible: _fabVisible,
            child: _buildFAB(context, key: _fabKey),
          ),
          floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: new Material(
            color: ColorService().CorP,
            child: new TabBar(
              tabs: [
                Tab(
                  icon: new Icon(Icons.home),
                ),
                Tab(
                  icon: new Icon(Icons.rss_feed),
                )
              ],
              labelColor: ColorService().CorS,
              unselectedLabelColor: ColorService().CorTextS,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorPadding: EdgeInsets.all(1.0),
              indicatorColor: ColorService().CorS,
            ),
          ),
          body: TabBarView(
            children: [
              Column(children: <Widget>[

                AnimatedContainer(
                  height: _showAppbar ? 70.0 : 0.0,
                  duration: Duration(milliseconds: 200),
                  child: new AppBar(
                      backgroundColor: ColorService().CorP,
                      leading: new IconButton(
                          icon: Icon(Icons.menu, color: ColorService().CorS),
                          onPressed: () =>
                              _scaffoldKey.currentState.openDrawer()),
                      centerTitle: true,
                      title: Icon(Icons.pest_control_rodent_rounded,
                          color: ColorService().CorS, size: 40),
                      actions: <Widget>[
                        new Container(
                            height: 25,
                            width: 25,
                            child: GestureDetector(
                              child: Stack(clipBehavior: Clip.none, children: <Widget>[
                                Positioned(right: 1, left: 0,top: 5,child: Container(child: Icon(Icons.email_outlined, color: ColorService().CorS, size: 25))),
                                newMsg ? Positioned(left: 12, top:3 ,child: Container(child: Icon(Icons.notifications_on_rounded     , color: ColorService().CorTextP, size: 15.0))):Text(''),
                              ]),
                            onTap: () {_scaffoldKey.currentState.openEndDrawer(); showMsg();}
                            ),
                            padding: EdgeInsets.only(top: 7.0),
                            margin: EdgeInsets.only(right: 10.0)),

                      ],
                      toolbarHeight: 45),
                ),
                Expanded(
                  child:
                    StreamBuilder<List<Post>>(
                        stream: FirebaseApi.getPosts(),
                        builder: (context, snapshot){
                          switch(snapshot.connectionState){
                            default:
                              final posts = snapshot.data;
                              return ListView.builder(
                                controller: _scrollViewController,
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final post = posts[index];
                                  return BuildPosts(post);
                                },
                                itemCount: posts.length,
                              );
                          }
                        },
                    ),

                ),
              ]),
              new Container(child: Text("Matico")),

            ],
          ),
        ));
  }
//Meu codigo
// Construtor do botão de post
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
  Widget _buildFAB(context, {key}) => FloatingActionButton(
    elevation: 0,
    mini: true,
    backgroundColor: ColorService().CorS,
    key: key,
    onPressed: () => _onFabTap(context),
    child: Icon(Icons.pest_control_rodent_rounded, color: ColorService().CorTextP),
  );

  _onFabTap(BuildContext context) {
    // Hide the FAB on transition start
    setState(() => _fabVisible = false);

    final RenderBox fabRenderBox = _fabKey.currentContext.findRenderObject();
    final fabSize = fabRenderBox.size;
    final fabOffset = fabRenderBox.localToGlobal(Offset.zero);

    Navigator.of(context).push(PageRouteBuilder(
      transitionDuration: duration,
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) =>
          PostPage(),
      transitionsBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) =>
          _buildTransition(child, animation, fabSize, fabOffset),
    ));
  }

  Widget _buildTransition(
      Widget page,
      Animation<double> animation,
      Size fabSize,
      Offset fabOffset,
      ) {
    if (animation.value == 1) return page;

    final borderTween = BorderRadiusTween(
      begin: BorderRadius.circular(fabSize.width / 2),
      end: BorderRadius.circular(0.0),
    );
    final sizeTween = SizeTween(
      begin: fabSize,
      end: MediaQuery.of(context).size,
    );
    final offsetTween = Tween<Offset>(
      begin: fabOffset,
      end: Offset.zero,
    );

    final easeInAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.linear,
    );
    final easeAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.linear,
    );

    final radius = borderTween.evaluate(easeInAnimation);
    final offset = offsetTween.evaluate(animation);
    final size = sizeTween.evaluate(easeInAnimation);

    final transitionFab = Opacity(
      opacity: 1 - easeAnimation.value,
      child: _buildFAB(context),
    );

    Widget positionedClippedChild(Widget child) => Positioned(
        width: size.width,
        height: size.height,
        left: offset.dx,
        top: offset.dy,
        child: ClipRRect(
          borderRadius: radius,
          child: child,
        ));

    return Stack(
      children: [
        positionedClippedChild(page),
        positionedClippedChild(transitionFab),
      ],
    );
  }
}
//ROUBADOS DO GITHUB ===============================================================================
class CarouselWithIndicatorDemo extends StatefulWidget {
  //CARROUSELSLIDER DO GITHUB
  @override
  State<StatefulWidget> createState() {
    return _CarouselWithIndicatorState();
  }
} //ROUBADO DO GITHUB
class _CarouselWithIndicatorState extends State<CarouselWithIndicatorDemo> {
  //CARROUSELSLIDER DO GITHUB
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    var imageSliders;
    return Scaffold(
      backgroundColor: ColorService().CorP,
      body: Column(children: [
        CarouselSlider(
          items: images,
          options: CarouselOptions(
              autoPlay: false,
              enlargeCenterPage: true,
              height: 300,
              enableInfiniteScroll: false,
              reverse: false,
              initialPage: 0,
              viewportFraction: 1.0,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: images.map((url) {
            int index = images.indexOf(url);
            return Container(
              width: 8.0,
              height: 8.0,
              margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 2.0),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _current == index
                      ? ColorService().CorS
                      : ColorService().CorTextS
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }
} //ROUBADO DO GITHUB
//Funções==============================================================================================
changeText(int i) {
  String textHolder = 'Desmutar post';
  if(i == 1){
    textHolder = 'Mutar post';
    i = 2;
  }else{
    textHolder = "Desmutar post";
    i = 1;
  }
  return textHolder;
}
ColorSelector(int value) {
  Color Cor;
  switch (value) {
    case 1:{Cor = Colors.pink[50];break;}
    case 2:{Cor = Colors.pink[100];break;}
    case 3:{Cor = Colors.pink[200];break;}
    case 4:{Cor = Colors.pink[300];break;}
    case 5:{Cor = Colors.pink[400];break;}
    case 6:{Cor = Colors.pink;break;}
    case 7:{Cor = Colors.pink[600];break;}
    case 8:{Cor = Colors.pink[700];break;}
    case 9:{Cor = Colors.pink[800];break;}
    case 10:{Cor = Colors.pink[900];break;}
    case 11:{Cor = Colors.red[100];break;}
    case 12:{Cor = Colors.red[200];break;}
    case 13:{Cor = Colors.red[300];break;}
    case 14:{Cor = Colors.red[400];break;}
    case 15:{Cor = Colors.red;break;}
    case 16:{Cor = Colors.red[600];break;}
    case 17:{Cor = Colors.red[700];break;}
    case 18:{Cor = Colors.red[800];break;}
    case 19:{Cor = Colors.red[900];break;}
    case 20:{Cor = Colors.deepOrangeAccent[100];break;}
    case 21:{Cor = Colors.deepOrangeAccent[200];break;}
    case 22:{Cor = Colors.deepOrange[300];break;}
    case 23:{Cor = Colors.deepOrangeAccent[400];break;}
    case 24:{Cor = Colors.deepOrangeAccent;break;}
    case 25:{Cor = Colors.deepOrange[600];break;}
    case 26:{Cor = Colors.deepOrangeAccent[700];break;}
    case 27:{Cor = Colors.deepOrange[800];break;}
    case 28:{Cor = Colors.deepOrange[900];break;}
    case 29:{Cor = Colors.orange[100];break;}
    case 30:{Cor = Colors.orange[200];break;}
    case 31:{Cor = Colors.orange[300];break;}
    case 32:{Cor = Colors.orange[400];break;}
    case 33:{Cor = Colors.orange;break;}
    case 34:{Cor = Colors.orange[600];break;}
    case 35:{Cor = Colors.orange[700];break;}
    case 36:{Cor = Colors.orange[800];break;}
    case 37:{Cor = Colors.orange[900];break;}
    case 38:{Cor = Colors.yellow[100];break;}
    case 39:{Cor = Colors.yellow[200];break;}
    case 40:{Cor = Colors.yellow[300];break;}
    case 41:{Cor = Colors.yellow[400];break;}
    case 42:{Cor = Colors.yellow;break;}
    case 43:{Cor = Colors.yellow[600];break;}
    case 44:{Cor = Colors.yellow[700];break;}
    case 45:{Cor = Colors.yellow[800];break;}
    case 46:{Cor = Colors.yellow[900];break;}
    case 47:{Cor = Colors.lime[100];break;}
    case 48:{Cor = Colors.lime[200];break;}
    case 49:{Cor = Colors.lime[300];break;}
    case 50:{Cor = Colors.lime[400];break;}
    case 51:{Cor = Colors.lime;break;}
    case 52:{Cor = Colors.lime[600];break;}
    case 53:{Cor = Colors.lime[700];break;}
    case 54:{Cor = Colors.lime[800];break;}
    case 55:{Cor = Colors.lime[900];break;}
    case 56:{Cor = Colors.lightGreen[100];break;}
    case 57:{Cor = Colors.lightGreen[200];break;}
    case 58:{Cor = Colors.lightGreen[300];break;}
    case 59:{Cor = Colors.lightGreen[400];break;}
    case 60:{Cor = Colors.lightGreen;break;}
    case 61:{Cor = Colors.lightGreen[600];break;}
    case 62:{Cor = Colors.lightGreen[700];break;}
    case 63:{Cor = Colors.lightGreen[800];break;}
    case 64:{Cor = Colors.lightGreen[900];break;}
    case 65:{Cor = Colors.green[100];break;}
    case 66:{Cor = Colors.green[200];break;}
    case 67:{Cor = Colors.green[300];break;}
    case 68:{Cor = Colors.green[400];break;}
    case 69:{Cor = Colors.green;break;}
    case 70:{Cor = Colors.green[600];break;}
    case 71:{Cor = Colors.green[700];break;}
    case 72:{Cor = Colors.green[800];break;}
    case 73:{Cor = Colors.green[900];break;}
    case 74:{Cor = Colors.cyan[100];break;}
    case 75:{Cor = Colors.cyan[200];break;}
    case 76:{Cor = Colors.cyan[300];break;}
    case 77:{Cor = Colors.cyan[400];break;}
    case 78:{Cor = Colors.cyan;break;}
    case 79:{Cor = Colors.cyan[600];break;}
    case 80:{Cor = Colors.cyan[700];break;}
    case 81:{Cor = Colors.cyan[800];break;}
    case 82:{Cor = Colors.cyan[900];break;}
    case 83:{Cor = Colors.lightBlue[100];break;}
    case 84:{Cor = Colors.lightBlue[200];break;}
    case 85:{Cor = Colors.lightBlue[300];break;}
    case 86:{Cor = Colors.lightBlue[400];break;}
    case 87:{Cor = Colors.lightBlue;break;}
    case 88:{Cor = Colors.lightBlue[600];break;}
    case 89:{Cor = Colors.lightBlue[700];break;}
    case 90:{Cor = Colors.lightBlue[800];break;}
    case 91:{Cor = Colors.lightBlue[900];break;}
    case 92:{Cor = Colors.blue[100];break;}
    case 93:{Cor = Colors.blue[200];break;}
    case 94:{Cor = Colors.blue[300];break;}
    case 95:{Cor = Colors.blue[400];break;}
    case 96:{Cor = Colors.blue;break;}
    case 97:{Cor = Colors.blue[600];break;}
    case 98:{Cor = Colors.blue[700];break;}
    case 99:{Cor = Colors.blue[800];break;}
    case 100:{Cor = Colors.blue[900];break;}
    case 101:{Cor = Colors.indigo[100];break;}
    case 102:{Cor = Colors.indigo[200];break;}
    case 103:{Cor = Colors.indigo[300];break;}
    case 104:{Cor = Colors.indigo[400];break;}
    case 105:{Cor = Colors.indigo[500];break;}
    case 106:{Cor = Colors.indigo[600];break;}
    case 107:{Cor = Colors.indigo[700];break;}
    case 108:{Cor = Colors.indigo[800];break;}
    case 109:{Cor = Colors.indigo[900];break;}
    case 110:{Cor = Colors.purple[100];break;}
    case 111:{Cor = Colors.purple[200];break;}
    case 112:{Cor = Colors.purple[300];break;}
    case 113:{Cor = Colors.purple[400];break;}
    case 114:{Cor = Colors.purple[500];break;}
    case 115:{Cor = Colors.purple[600];break;}
    case 116:{Cor = Colors.purple[700];break;}
    case 117:{Cor = Colors.purple[800];break;}
    case 118:{Cor = Colors.purple[900];break;}
    case 119:{Cor = Colors.deepPurple[100];break;}
    case 120:{Cor = Colors.deepPurple[200];break;}
    case 121:{Cor = Colors.deepPurple[300];break;}
    case 122:{Cor = Colors.deepPurple[400];break;}
    case 123:{Cor = Colors.deepPurple[500];break;}
    case 124:{Cor = Colors.deepPurple[600];break;}
    case 125:{Cor = Colors.deepPurple[700];break;}
    case 126:{Cor = Colors.deepPurple[800];break;}
    case 127:{Cor = Colors.deepPurple[900];break;}
    case 128:{Cor = Colors.brown[100];break;}
    case 129:{Cor = Colors.brown[200];break;}
    case 130:{Cor = Colors.brown[300];break;}
    case 131:{Cor = Colors.brown[400];break;}
    case 132:{Cor = Colors.brown[500];break;}
    case 133:{Cor = Colors.brown[600];break;}
    case 134:{Cor = Colors.brown[700];break;}
    case 135:{Cor = Colors.brown[800];break;}
    case 136:{Cor = Colors.brown[900];break;}
    case 137:{Cor = Colors.grey[100];break;}
    case 138:{Cor = Colors.grey[200];break;}
    case 139:{Cor = Colors.grey[300];break;}
    case 140:{Cor = Colors.grey[400];break;}
    case 141:{Cor = Colors.grey[500];break;}
    case 142:{Cor = Colors.grey[600];break;}
    case 143:{Cor = Colors.grey[700];break;}
    case 144:{Cor = Colors.grey[800];break;}
    case 145:{Cor = Colors.grey[900];break;}
    case 146:{Cor = Colors.black;break;}
    case 147:{Cor = Colors.white;break;}
  }
  var a = ColorService().index;
  if(ColorService().index == 1){
    ColorService().CorP = Cor;
    ColorService().CorPValue = value;
  }else if(ColorService().index == 2){
    ColorService().CorS = Cor;
    ColorService().CorSValue = value;
  }else if(ColorService().index == 3){
    ColorService().CorTextP = Cor;
    ColorService().CorTextPValue = value;
  }else if(ColorService().index == 4){
    ColorService().CorTextSValue = value;
    ColorService().CorTextS = Cor;}

  return print("$Cor, $a");
}

