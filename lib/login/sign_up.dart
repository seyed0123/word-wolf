import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:word_wolf/request.dart';
import 'dart:convert';

class Sign_up extends StatefulWidget {
  const Sign_up({Key? key}) : super(key: key);

  @override
  State<Sign_up> createState() => _Sign_upState();
}

class _Sign_upState extends State<Sign_up> {

  final username = TextEditingController();
  final password = TextEditingController();
  final rePassword = TextEditingController();
  final email = TextEditingController();
  bool _isChecked = false;
  final ScrollController _scrollController = ScrollController();



  String error = '';
  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> sendData() async {
    String err = '';
    if(username.text.isEmpty || password.text.isEmpty|| rePassword.text.isEmpty || email.text.isEmpty){
      err = 'All fields are required';
    }else if (password.text != rePassword.text) {
      err = 'password doesn\'t match';
    }else if(_isChecked == false){
      err='Agree the terms';
    }
    if( err!=''){
      setState(() {
        error = err;
      });
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds:  200),
        curve: Curves.linear,
      );
      return;
    }
    Map<String, dynamic> user = {
      'username': username.text,
      'password': password.text,
      'email': email.text,
    };

    try {
      final response = await sendRequest('', jsonEncode(user), 'sign_up');
      Map<String, dynamic> responseData = jsonDecode(response);
      String message = responseData['message'] ?? '';

      if (message == 'ok') {
        await saveToken(responseData['token'] ?? '');
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Sign up Successful'),
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
                title: const Text('sign_up Failed'),
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
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
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
                height: 25,
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
                height: 25,
              ),

              TextField(
                obscureText: true,
                controller: rePassword,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'enter password again',
                ),
              ),
              const SizedBox(
                  height: 25,
                ),
              TextField(
                controller: email,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'email',
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                children: <Widget>[
                  Checkbox(
                    value: _isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isChecked = value!;
                      });
                    },
                  ),
                  Text('I agree to the terms and conditions'),
                ],
              ),
              const SizedBox(
                height: 75,
              ),
              ElevatedButton(
                onPressed: () {
                  sendData();
                },
                style: ElevatedButton.styleFrom(
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
                ),
                child: const Text('sign up'),
              ),
            ],
          ),
        ),
      )
    );
  }
}
