import 'package:flutter/material.dart';
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

  void sendData(){
    if(username.text == '' || password.text == ''){
      setState(() {
        error = 'All fields are required';
      });
      return;
    }
    Map<String, dynamic> user = {
      'username': username.text,
      'password': password.text
    };

    final response = sendRequest('',jsonEncode(user),'login') as String;
    Map<String, dynamic> responseData = jsonDecode(response);
    String message  = responseData['message'];
    saveToken(responseData['token']);
    if(message=='ok') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Login Successful'),
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
    }else{
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Login Failed'),
            content: const Text('Failed to login. Please try again.'),
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
    print(username.text+password.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Word Wolf')),
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
