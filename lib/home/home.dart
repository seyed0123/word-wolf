import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:word_wolf/home/User.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  User ?user;
  final host = 'localhost'; // Replace with your server's hostname or IP address
  final port = 6666; // Replace with your server's port

  Future<void>  getUser() async {
    user = User('1','seyed','123','seyed123ali123','Persian',200,8,100,true,2,'pro');
    print('hello world');
    final httpClient = HttpClient();
    final url = Uri.parse('http://localhost:8080/hello');

    try {
      final request = await httpClient.getUrl(url);
      final response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        final responseBody = await response.transform(utf8.decoder).join();
        print('Response: $responseBody');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      httpClient.close();
    }


    final httpClient1 = HttpClient();
    final url1 = Uri.parse('http://localhost:8080/hello');

    try {
      final request = await httpClient1.postUrl(url1);
      // Add any request headers if needed (e.g., content-type).
      // request.headers.add(HttpHeaders.contentTypeHeader, 'application/json');

      // Write data to the request body (if required).
      request.write('{"key": "value"}');

      final response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        final responseBody = await response.transform(utf8.decoder).join();
        print('Response: $responseBody');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      httpClient1.close();
    }
  }
  // void getUser() async{
  //
  //
  //   final WebSocket webSocket = WebSocket('ws://192.168.122.11:1234');
  //
  //   sendMessage(webSocket, {
  //   'type': 'greeting',
  //   'content': 'Hello, World!'
  //   });
  //
  //   // webSocket.onOpen.listen((event) {
  //   //   print('WebSocket connection opened');
  //   //
  //   //   // Create a JSON object
  //   //   var message = {
  //   //     'type': 'greeting',
  //   //     'content': 'Hello, World!'
  //   //   };
  //   //
  //   //   // Serialize the JSON object to a string
  //   //   String jsonString = jsonEncode(message);
  //   //   print('Sending JSON: $jsonString');
  //   //
  //   //   // Send the JSON string over the WebSocket
  //   //   webSocket.send(jsonString);
  //   // });
  //   //
  //   // webSocket.onMessage.listen((event) {
  //   //   print('Received: ${event.data}');
  //   // });
  //   //
  //   // webSocket.onError.listen((event) {
  //   //   print('WebSocket error: $event');
  //   // });
  //   //
  //   // webSocket.onClose.listen((event) {
  //   //   print('WebSocket connection closed');
  //   // });
  //
  //   //TODO:get user

  // }


  Color hexToColor(String hexCode) {
    final hexColor = hexCode;
    return Color(int.parse('FF$hexColor', radix:  16));
  }

  Color? getRowColor() {
    return user!.isPracticeToday ? Colors.orange : hexToColor('B4B4B8');
  }

  @override
  void initState() {
    getUser();
    super.initState();
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
    if(user==null){
      return Scaffold(
        body:Center(
          child: ElevatedButton(onPressed: (){
            Navigator.pop(context); // pop the current stage
            Navigator.pushNamed(context, '/login');}
            ,child: Text('login'),
          ),
        )
      );
    }else {
      return Scaffold(
          backgroundColor: hexToColor('E1F0DA'),
          appBar: AppBar(
            toolbarHeight:  120,
            backgroundColor: hexToColor('DBE2EF'),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text('Word Wolf'),
                CircularPercentIndicator(
                  radius: 40.0,
                  lineWidth: 5.0,
                  animation: true,
                  percent: user!.xp / pow(2 , user?.level as num),
                  header: const Text('Level'),
                  center: Text(
                    '${user?.level}',
                    style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                  footer: Text(
                    '${user!.xp}/${pow(2 , user?.level as num)}',
                    style:
                    const TextStyle(fontSize: 10.0),
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
                      ) :Icon(
                        Icons.local_fire_department_outlined,
                      color: getRowColor(),
                      ),
                  ],
                )
              ],
            ),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CircleAvatar(
                  radius:  100,
                  backgroundImage: AssetImage('assets/strike_${user!.strikeLevel}.png'),
                ),
                Text(
                  user!.strikeLevelName,
                  style: GoogleFonts.jaldi(
                      textStyle: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      )
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FilledButton(onPressed: () {
                      Navigator.pushNamed(context, '/new_word');
                    },
                        style: buttonStyle,
                        child: const Text("new word")
                    ),
                    FilledButton(onPressed: () {
                      Navigator.pushNamed(context, '/lesson');
                    },
                        style: buttonStyle,
                        child: const Text("lesson")
                    ),
                    FilledButton(onPressed: () {
                      Navigator.pushNamed(context, '/word_list');
                    },
                        style: buttonStyle,
                        child: const Text("word list")
                    ),
                    FilledButton(onPressed: () {
                      Navigator.pushNamed(context, '/popular_word');
                    },
                        style: buttonStyle,
                        child: const Text("Popular word")
                    ),
                    FilledButton(onPressed: () {
                      Navigator.pushNamed(context, '/setting');
                    },
                        style: buttonStyle,
                        child: const Text("Setting")
                    ),
                  ],
                ),
              ],
            ),
          )
      );
    }
  }
}
