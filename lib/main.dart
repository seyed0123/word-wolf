import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:word_wolf/login/login.dart';
import 'package:word_wolf/home/home.dart';
import 'package:word_wolf/login/sign_up.dart';
import 'package:word_wolf/words/new_word.dart';
import 'package:word_wolf/words/word_list.dart';
import 'package:word_wolf/lesson/lesson_page.dart';
import 'package:word_wolf/words/popular_word.dart';
import 'package:word_wolf/setting/setting.dart';
import 'package:word_wolf/words/search_word.dart';
void main() async  {
  await dotenv.load(fileName: "assets/env.txt");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) =>  const Home() ,
        '/login': (context) =>  const login(),
        '/sign_up':(context) => const Sign_up(),
        '/new_word':(context) => const new_word(),
        '/word_list':(context) => const word_list(),
        '/lesson':(context) => const Lesson_page(),
        '/popular_word':(context) =>const popularWord(),
        '/setting':(context) => const Setting(),
        '/search':(context) => const Search(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
const SplashScreen({Key? key}) : super(key: key);

@override
_SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showFirstIcon = true;

  @override
  void initState() {
    super.initState();
    _startIconAnimation();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
              (route) => false,
        );
      }
    });
  }

  void _startIconAnimation() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showFirstIcon = !_showFirstIcon;
        });
        _startIconAnimation();
      }
    });
  }

  Color hexToColor(String hexCode) {
    final hexColor = hexCode;
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hexToColor('E1F0DA'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(seconds: 1),
              child: _showFirstIcon
                  ? Image.asset('assets/icon1.jpg', key: const ValueKey(1),height: MediaQuery.of(context).size.height)
                  : Image.asset('assets/icon2.jpg', key: const ValueKey(2),height: MediaQuery.of(context).size.height),
            ),
          ],
        ),
      ),
    );
  }
}