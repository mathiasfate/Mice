import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomePage.dart';
import 'Pages.dart';
import 'Widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
void main() => runApp(LoginPage());

class LoginPage extends StatelessWidget{
  final CorP;
  final CorS;
  final CorTextP;
  final CorTextS;
  final String idUser;
  final int numberOfPosts;
  const LoginPage({
    @required this.idUser,
    @required this.CorP,
    @required this.CorS,
    @required this.CorTextP,
    @required this.CorTextS,
    @required this.numberOfPosts,

    Key key,
  }) : super(key: key);

  @override
  Widget build(context){
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '_LoginScreen',
        routes: {
          '_LoginScreen': (context) => _LoginScreen(),
          'HomePage': (context) => HomePage(),
          'ProfilePage': (context) => ProfilePage(),
          'ThemePage': (context) => ThemePage(),
          'ColorSelectionPage': (context) => ColorSelectionPage(),
          'EditProfilePage': (context) => EditProfilePage(),
          'CommentSection': (context) => CommentSection(),
          'SavedItensPage': (context) => SavedItensPage(),
          'ConfigPage': (context) => ConfigPage(),
          'AccountCreationPage': (context) => AccountCreationPage(),
        },
        navigatorObservers: [routeObserver],
        theme: new ThemeData(
            appBarTheme: AppBarTheme(
                color: ColorService().CorP
            ),
            scaffoldBackgroundColor: ColorService().CorP,
            outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                    primary: ColorService().CorTextS,
                    backgroundColor: ColorService().CorP,
                    padding: EdgeInsets.all(12.0),
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadiusDirectional.circular(1.0)))),
            primaryColor: ColorService().CorP,
            accentColor: ColorService().CorS,
            canvasColor: ColorService().CorP,
            inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(),
                labelStyle: TextStyle(
                    color: ColorService().CorTextS
                ))
        ),
      home: _LoginScreen()
    );
  }
}
class _LoginScreen extends StatefulWidget{

  const _LoginScreen({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _LoginScreenState();
  }
}
class _LoginScreenState extends State<_LoginScreen> {
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  bool _loading = true;
  var myId;
  var myUrlAvatar;

  @override
  void dispose() {
    userController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    FirebaseStart();
  }
  Future FirebaseStart() async{
    await Firebase.initializeApp();
    FirebaseStorage storage =
        FirebaseStorage.instance;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var status = prefs.getBool('isLoggedIn') ?? false;
    if(status){
      var userId = prefs.getString('userId')??'';
      var user = await FirebaseFirestore.instance.collection('users').doc('$userId');
      await user.get().then((doc) => {
        ColorService().myUser = userId,
        ColorService().index = 1,
        ColorSelector(doc['CorP']),
        ColorService().index = 2,
        ColorSelector(doc['CorS']),
        ColorService().index = 3,
        ColorSelector(doc['CorTextP']),
        ColorService().index = 4,
        ColorSelector(doc['CorTextS']),
        ColorService().numberOfPosts = doc['numberOfPosts'],
        ColorService().myUrlAvatar = doc['urlAvatar'],
      });
      return  Navigator.pushNamed(context, 'HomePage');
    }
  }
  bool Val = false;
  onSwitchValueChanged(bool newVal){
    setState((){
      Val = newVal;
    });
  }
  @override
  didChangeDependencies(){
    super.didChangeDependencies();
  }
  Login(String x, String y) async{
    String userId = x;
    String password = y;
    bool auth;
    var user = await FirebaseFirestore.instance.collection('users').doc('$userId');
    await user.get().then((doc) => {
      if(doc.exists){
        if(doc['password'] == password){
          ColorService().myUser = userId,
          ColorService().index = 1,
          ColorSelector(doc['CorP']),
          ColorService().index = 2,
          ColorSelector(doc['CorS']),
          ColorService().index = 3,
          ColorSelector(doc['CorTextP']),
          ColorService().index = 4,
          ColorSelector(doc['CorTextS']),
          ColorService().numberOfPosts = doc['numberOfPosts'],
          auth = true,
          ColorService().myUrlAvatar = doc['urlAvatar']
        }else auth = false
      }else auth = false
    });
    if(auth) {
      if(Val){
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs?.setBool("isLoggedIn", true);
        prefs?.setString("userId", "$userId");
        return  Navigator.pushNamed(context, 'HomePage');
      } else return  Navigator.pushNamed(context, 'HomePage');
    }
    else {
      setState(() {
        _loading = false;
      });
    }
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))
          ),
       content: SizedBox(
        height: _loading ? 200 : 30,
        width: _loading ? 100 : 170,
        child: _loading ? CircularProgressIndicator(
            backgroundColor: Colors.white,
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrangeAccent),
        ) : Text("Usuário ou senha incorreto", style: TextStyle(color: Colors.white,fontSize: 19)),
      ),
          backgroundColor: Colors.grey[900]),
    );
  }
  @override
  Widget build(context){
    return Scaffold(
        backgroundColor: Colors.grey[900],
        body: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 73,
            ),
            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 90, top: 39),
                    child: Icon(Icons.pest_control_rodent, color: Colors.deepOrangeAccent, size: 75),
                ),
                Container(
                    margin: EdgeInsets.only(left: 10, top: 65),
                  child: Text("Mice", style: TextStyle(color: Colors.white, fontSize: 40))
                ),
              ],
            ),
            Container(
                width: 300,
                height: 70,
                margin: EdgeInsets.only(top: 20),
                child: TextField(
                    controller: userController,
                    keyboardType: TextInputType.text,
                    maxLength: 20,
                    decoration:  InputDecoration(
                        counter: Offstage(),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepOrangeAccent, width: 1.0),
                            borderRadius: BorderRadius.circular(40.0)
                        ),
                        hintStyle:  TextStyle(color: Colors.grey[800]),
                        hintText: "    Usuário",
                        border:  OutlineInputBorder(
                          borderRadius:  BorderRadius.all(
                            Radius.circular(40.0),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey),
                  )

            ),
            Container(
                width: 300,
                height: 70,
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      maxLength: 20,
                      decoration:  InputDecoration(
                          counter: Offstage(),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.deepOrangeAccent, width: 1.0),
                              borderRadius: BorderRadius.circular(45.0)
                          ),
                          hintStyle:  TextStyle(color: Colors.grey[800]),
                          hintText: "    Senha",
                          border:  OutlineInputBorder(
                            borderRadius:  BorderRadius.all(
                              Radius.circular(45.0),
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey),
                    )
            ),
            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 60),
                  child: Switch(
                      value: Val,
                      splashRadius: 10.0,
                      activeColor: Colors.deepOrangeAccent,
                      activeTrackColor: Colors.deepOrangeAccent,
                      inactiveTrackColor: Colors.white,
                      onChanged: (newVal){
                        onSwitchValueChanged(newVal);
                      }
                  ),
                ),
                Text("Permanecer conectado", style: TextStyle(color: Colors.white))
              ],
            ),
            Container(
              height: 45,
              width: 300,
              child: ElevatedButton(
                  child: Text("Entrar", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                      primary: Colors.deepOrangeAccent,
                      onPrimary: Colors.white
                  ),
                  onPressed: (){
                    Login(userController.text, passwordController.text);
                  }),
            ),

            TextButton(
                child: Text('Esqueci minha senha', style: TextStyle(color: Colors.grey[500])),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20.0))
                          ),
                          title: Text("Fala com o matico", style: TextStyle(color: Colors.white)),
                          backgroundColor: Colors.grey[900]),
                      barrierDismissible: true
                  );
                }
            ),
            SizedBox(
              height: 230
            ),
            Text("Seita Corp™", style: TextStyle(color: Colors.grey[500]))


          ],
        )
    );
  }
}

class ColorService {
  static final ColorService _instance = ColorService._internal();

  factory ColorService() => _instance;

  ColorService._internal() {
    int _index;
    bool _isCommentSection = false;
    bool _isSaved = false;
    Color _CorP = Colors.grey[900]; //COR PRIMARIA
    Color _CorS = Colors.deepOrangeAccent; //COR SECUNDARIA
    Color _CorTextP = Colors.white; // COR PRIMARIA DE TEXTO
    Color _CorTextS = Colors.grey; //COR SECUNDARIA DE TEXTO
    String _myUser;
    String _myUrlAvatar;
    bool _auth = false;
    int _numberOfPosts;
    int _CorPValue;
    int _CorSValue;
    int _CorTextPValue;
    int _CorTextSValue;
  }

  bool _auth;
  String _myUser;
  String _myUrlAvatar;
  int _index;
  bool _isCommentSection;
  bool _isSaved;
  Color _CorP;
  Color _CorS;
  Color _CorTextP;
  Color _CorTextS;
  int _numberOfPosts;
  int _CorPValue;
  int _CorSValue;
  int _CorTextPValue;
  int _CorTextSValue;

  int get CorPValue => _CorPValue;

  int get CorSValue => _CorSValue;

  int get CorTextPValue => _CorTextPValue;

  int get CorTextSValue => _CorTextSValue;

  int get numberOfPosts => _numberOfPosts;

  bool get auth => _auth;

  String get myUser => _myUser;

  String get myUrlAvatar => _myUrlAvatar;

  int get index => _index;

  bool get isCommentSection => _isCommentSection;

  bool get isSaved => _isSaved;

  Color get CorP => _CorP;

  Color get CorS => _CorS;

  Color get CorTextP => _CorTextP;

  Color get CorTextS => _CorTextS;

  set CorPValue (value) => _CorPValue = value;

  set CorSValue (value) => _CorSValue = value;

  set CorTextPValue (value) => _CorTextPValue = value;

  set CorTextSValue (value) => _CorTextSValue = value;

  set numberOfPosts(value) => _numberOfPosts = value;

  set auth(bool value) => _auth = value;

  set myUser(value) => _myUser = value;

  set myUrlAvatar(value) => _myUrlAvatar = value;

  set index(value) => _index = value;

  set isCommentSection(bool value) => _isCommentSection = value;

  set isSaved(bool value) => _isSaved = value;

  set CorP(Color value) => _CorP = value;

  set CorS(Color value) => _CorS = value;

  set CorTextP(Color value) => _CorTextP = value;

  set CorTextS(Color value) => _CorTextS = value;
} //INSTANCIA UM OBJETO CONTROLADOR PRA PASSAR OS DADOS DAS CORES(ACABEI USANDO PRA OUTRAS COISAS TB)