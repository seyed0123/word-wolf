import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:word_wolf/home/User.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:word_wolf/request.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  User? user;
  bool isLoading = true;

  Future<void> getUser() async {
    String? token = await getToken();
    if (token == null) {
      navigateToLogin();
      return;
    }

    final String response = await sendGetRequest(token, 'get_user');
    if (response.isEmpty) {
      navigateToLogin();
      return;
    }

    final Map<String, dynamic> data = jsonDecode(response);
    setState(() {
      user = User.fromJson(data);
      isLoading = false;
    });
  }

  void navigateToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (Route<dynamic> route) => false);
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  Color hexToColor(String hexCode) {
    final hexColor = hexCode;
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  Color? getRowColor() {
    return user!.isPracticeToday ? Colors.orange : hexToColor('B4B4B8');
  }

  ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    primary: Colors.blue, // Background color
    onPrimary: Colors.white, // Text color
    elevation: 5, // Shadow depth
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30), // Rounded corners
    ),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Button padding
    textStyle: const TextStyle(
      fontWeight: FontWeight.bold, // Bold text
      fontSize: 16, // Text size
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: hexToColor('E1F0DA'),
      appBar: AppBar(
        toolbarHeight: 120,
        backgroundColor: hexToColor('DBE2EF'),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text('Word Wolf'),
            CircularPercentIndicator(
              radius: 40.0,
              lineWidth: 5.0,
              animation: true,
              percent: user!.xp / pow(2, user!.level as num),
              header: const Text('Level'),
              center: Text(
                '${user!.level}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
              footer: Text(
                '${user!.xp}/${pow(2, user!.level as num)}',
                style: const TextStyle(fontSize: 10.0),
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: hexToColor('3F72AF'),
            ),
            Text(
              user!.username,
              style: GoogleFonts.gabriela(),
            ),
            Row(
              children: [
                Text(
                  '${user!.strike}',
                  style: GoogleFonts.qahiri(
                    textStyle: TextStyle(color: getRowColor(), letterSpacing: .5),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                user!.isPracticeToday
                    ? Icon(
                  Icons.local_fire_department_rounded,
                  color: getRowColor(),
                )
                    : Icon(
                  Icons.local_fire_department_outlined,
                  color: getRowColor(),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CircleAvatar(
              radius: 100,
              backgroundImage: AssetImage('${user!.strikeLevelName}.png'),
            ),
            Text(
              user!.strikeLevelName,
              style: GoogleFonts.jaldi(
                textStyle: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FilledButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/new_word');
                  },
                  style: buttonStyle,
                  child: const Text("new word"),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/lesson');
                  },
                  style: buttonStyle,
                  child: const Text("lesson"),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/word_list');
                  },
                  style: buttonStyle,
                  child: const Text("word list"),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/popular_word');
                  },
                  style: buttonStyle,
                  child: const Text("Popular word"),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/setting');
                  },
                  style: buttonStyle,
                  child: const Text("Setting"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
