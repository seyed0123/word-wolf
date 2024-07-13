import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:word_wolf/request.dart';
import 'dart:convert';

class login extends StatefulWidget {
  const login({Key? key}) : super(key: key);

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {


  final username = TextEditingController();
  final password = TextEditingController();
  String error = '';


  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> sendData() async {
    if (username.text.isEmpty || password.text.isEmpty) {
      if (mounted) {
        setState(() {
          error = 'All fields are required';
        });
      }
      return;
    }

    Map<String, dynamic> user = {
      'username': username.text,
      'password': password.text,
    };

    try {
      final response = await sendRequest('', jsonEncode(user), 'login');
      Map<String, dynamic> responseData = jsonDecode(response);
      String message = responseData['message'] ?? '';

      if (message == 'ok') {
        await saveToken(responseData['token'] ?? '');
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Log in up Successful'),
                content: const Text('You are logged in!'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();

                      Navigator.pushReplacementNamed(context, '/');
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('login Failed'),
                content: Text(message),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('An error occurred: $e'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  Color hexToColor(String hexCode) {
    final hexColor = hexCode;
    return Color(int.parse('FF$hexColor', radix: 16));
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: hexToColor('749BC2'),
        title: Center(
          child: Text(
            'Word Wolf',
            style: GoogleFonts.baskervville(
              textStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w200,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: const Offset(2, 2),
                    blurRadius: 3,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
                letterSpacing: 2,
                wordSpacing: 4,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          children: <Widget>[
            Text(
                '$error',
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 20,
              ),
            ),
            TextField(
              controller: username,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                labelText: 'username',
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            TextField(
              obscureText: true,
              controller: password,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                labelText: 'password',
              ),
            ),
            const SizedBox(
              height: 100,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    sendData();
                  },
                  style: ElevatedButton.styleFrom(
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
                  ),
                  child: const Text('Login'),
                ),
                const SizedBox(width:  20),
                ElevatedButton(
                    onPressed: (){Navigator.pushNamed(context, '/sign_up');},
                    style: ElevatedButton.styleFrom(
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
                    ),
                    child: const Text('sign_up')
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
