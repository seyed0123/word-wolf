import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:word_wolf/home/User.dart';
import 'package:word_wolf/request.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  late User user;
  bool isLoading = true;

  late TextEditingController username = TextEditingController();
  late TextEditingController email = TextEditingController();
  late TextEditingController oldPass = TextEditingController();
  late TextEditingController newPass = TextEditingController();

  Future<void> getUser() async {
    String? token = await getToken();
    if (token == null) {
      return;
    }

    final String response = await sendGetRequest(token, 'get_user');

    final Map<String, dynamic> data = jsonDecode(response);
    setState(() {
      user = User.fromJson(data);
      isLoading = false;
      username.text = user.username;
      email.text = user.email;
    });

  }

  Future<void> submitChanges() async {
    Map<String, dynamic> user = {
      'username': username.text,
      'oldPassword': oldPass.text,
      'newPassword': newPass.text,
      'email':email.text
    };

    String? token = await getToken();

    try {
      final response = await sendRequest(token!, jsonEncode(user), 'edit_user');
      Map<String, dynamic> responseData = jsonDecode(response);
      String message = responseData['message'] ?? '';

      if (message == 'ok') {
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Changed Successful'),
                content: const Text('your information has been updated'),
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
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('updating failed'),
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

  Future<void> logout() async {
    await removeToken();
    navigateToLogin();
  }

  void navigateToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (Route<dynamic> route) => false);
    });
  }

  @override
  void dispose() {
    username.dispose();
    email.dispose();
    newPass.dispose();
    oldPass.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.white, backgroundColor: Colors.blue, // Text color
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
      body: Wrap(
            spacing: 10.0,
          runSpacing: 10.0,
          alignment: WrapAlignment.center,
          children:[
            Column(
                children: [
                GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    padding: EdgeInsets.all(10),
                    childAspectRatio: 2,
                  children: [
                      Center(
                        child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: username,
                          cursorColor: Colors.blueAccent,
                          style: const TextStyle(fontSize:  18.0, color: Colors.black),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(color: Colors.blueAccent, width:  2.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(color: Colors.blueAccent, width:  2.0),
                          ),
                          labelText: 'username',
                          labelStyle: const TextStyle(color: Colors.blueAccent),
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.person, color: Colors.blueAccent),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: email,
                          cursorColor: Colors.blueAccent,
                          style: const TextStyle(fontSize:  18.0, color: Colors.black),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(color: Colors.blueAccent, width:  2.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(color: Colors.blueAccent, width:  2.0),
                            ),
                            labelText: 'email',
                            labelStyle: const TextStyle(color: Colors.blueAccent),
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(Icons.email, color: Colors.blueAccent),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: newPass,
                          obscureText: true,
                          cursorColor: Colors.blueAccent,
                          style: const TextStyle(fontSize:  18.0, color: Colors.black),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(color: Colors.blueAccent, width:  2.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(color: Colors.blueAccent, width:  2.0),
                            ),
                            labelText: 'new pass',
                            labelStyle: const TextStyle(color: Colors.blueAccent),
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(Icons.password_outlined, color: Colors.blueAccent),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: oldPass,
                          obscureText: true,
                          cursorColor: Colors.blueAccent,
                          style: const TextStyle(fontSize:  18.0, color: Colors.black),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(color: Colors.blueAccent, width:  2.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(color: Colors.blueAccent, width:  2.0),
                            ),
                            labelText: 'old pass',
                            labelStyle: const TextStyle(color: Colors.blueAccent),
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(Icons.password_outlined, color: Colors.blueAccent),
                          ),
                        ),
                      ),
                    ),
                  ]
                ),
              ],
            ),
            ElevatedButton(onPressed: (){submitChanges();}, style:buttonStyle , child: const Text('Submit Changes')),
            ElevatedButton(onPressed: (){logout();}, style:buttonStyle , child: const Text('logout')),
          ],
      )
    );
  }
}