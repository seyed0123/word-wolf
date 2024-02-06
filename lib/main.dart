import 'package:flutter/material.dart';
import 'package:word_wolf/login/login.dart';
import 'package:word_wolf/home/home.dart';
import 'package:word_wolf/login/sign_up.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) =>  const Home() ,
        '/login': (context) =>  const login(),
        '/sign_up':(context) => const Sign_up(),
      },
    );
  }
}