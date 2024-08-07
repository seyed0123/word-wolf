import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:wave_loading_indicator/wave_progress.dart';
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
    setState(() {
      isLoading = true;
    });

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
      return Scaffold(
        backgroundColor: hexToColor('E1F0DA'),
        body: Center(
          child: WaveProgress(
            borderSize: 3.0,
            size: 180,
            borderColor: Colors.redAccent,
            foregroundWaveColor: Colors.greenAccent,
            backgroundWaveColor: Colors.blueAccent,
            progress: 30, // [0-100]
            innerPadding: 10, // padding between border and waves
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: hexToColor('E1F0DA'),
      appBar: AppBar(
        toolbarHeight: 120,
        backgroundColor: hexToColor('749BC2'),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(onPressed: getUser, icon: const Icon(Icons.refresh_sharp)),
            Text(
              'Word Wolf',
              style: GoogleFonts.baskervville(
                textStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 3,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                  letterSpacing: 2,
                  wordSpacing: 4,
                ),
              ),
            ),
            CircularPercentIndicator(
              radius: 35.0,
              lineWidth: 5.0,
              animation: true,
              percent: user!.xp / pow(10, user!.level as num),
              header: Text(
                'Level',
                style: GoogleFonts.gabriela(color: Colors.white),
              ),
              center: Text(
                '${user!.level}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.white,
                ),
              ),
              footer: Text(
                '${user!.xp}/${pow(10, user!.level as num)}',
                style: const TextStyle(
                  fontSize: 10.0,
                  color: Colors.white,
                ),
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: hexToColor('3F72AF'),
            ),
            Flexible(
              child: Text(
                user!.username,
                style: GoogleFonts.gabriela(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                overflow: TextOverflow.ellipsis,
              ),
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
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 220, // Adjust the size as needed
                    height: 220, // Adjust the size as needed
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [hexToColor('6FDCE3'), hexToColor('FAFFAF')],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2), // Shadow color
                          spreadRadius: 5, // Spread radius
                          blurRadius: 15, // Blur radius
                          offset: const Offset(0, 5), // Shadow offset
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0), // Padding between the border and the avatar
                      child: CircleAvatar(
                        radius: 100, // Adjust the radius as needed
                        backgroundImage: AssetImage('assets/${user!.strikeLevelName}.png'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user!.strikeLevelName,
                    style: GoogleFonts.jaldi(
                      textStyle: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            color: hexToColor('E1F0DA'),
            child: Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/new_word');
                  },
                  style: buttonStyle,
                  child: const Text("New Word"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/lesson');
                  },
                  style: buttonStyle,
                  child: const Text("Lesson"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/word_list');
                  },
                  style: buttonStyle,
                  child: const Text("Word List"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/popular_word');
                  },
                  style: buttonStyle,
                  child: const Text("Popular Word"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/setting');
                  },
                  style: buttonStyle,
                  child: const Text("Setting"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/search');
                  },
                  style: buttonStyle,
                  child: const Text("Search"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
