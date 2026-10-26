import 'dart:async';
import 'app_theme.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/env.txt");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: wordWolfTheme(),
      initialRoute: '/splash',
      // Avoid creating Home underneath the splash and starting auth twice.
      onGenerateInitialRoutes: (_) => [
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: '/splash'),
          builder: (_) => const SplashScreen(),
        ),
      ],
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const Home(),
        '/login': (context) => const login(),
        '/sign_up': (context) => const Sign_up(),
        '/new_word': (context) => const new_word(),
        '/word_list': (context) => const word_list(),
        '/lesson': (context) => const Lesson_page(),
        '/popular_word': (context) => const popularWord(),
        '/setting': (context) => const Setting(),
        '/search': (context) => const Search(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showFirstIcon = true;
  Timer? _iconTimer;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _iconTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _showFirstIcon = false);
    });
    _navigationTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    });
  }

  @override
  void dispose() {
    _iconTimer?.cancel();
    _navigationTimer?.cancel();
    super.dispose();
  }

  Color hexToColor(String hexCode) {
    final hexColor = hexCode;
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hexToColor('E1F0DA'),
      body: SizedBox.expand(
        child: LayoutBuilder(
          builder: (context, constraints) => AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Image.asset(
              _showFirstIcon ? 'assets/icon1.jpg' : 'assets/icon2.jpg',
              key: ValueKey(_showFirstIcon ? 1 : 2),
              height: constraints.maxHeight,
              fit: BoxFit.fitHeight,
            ),
          ),
        ),
      ),
    );
  }
}
