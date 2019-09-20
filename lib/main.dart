import 'package:flutter/material.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'ble.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  /*final routes = <String, WidgetBuilder>{
    LoginPage.tag: (context) => LoginPage(),
    HomePage.tag: (context) => HomePage(),
  };*/

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title : 'SafarPe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Nunito',
      ),
      initialRoute: './',
      routes: {
        '/' : (context) => LoginPage(),
        '/home' : (context) => MyHomePageState(),
        '/ble' : (context) => Ble(),
      },
    );
  }
}