import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:word_wolf/home/User.dart';
import 'package:word_wolf/request.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  late User user;
  late TextEditingController username = TextEditingController();
  late TextEditingController email = TextEditingController();
  late TextEditingController oldPass = TextEditingController();
  late TextEditingController newPass = TextEditingController();

  Future<void> getUser() async {
    // user = User('1','seyed','123','seyed123ali123',200,8,100,true,2,'pro');
    final String response = sendGetRequest(getToken() as String,'getUser') as String;
    if(response == '') {
      return;
    }
    final Map<String, dynamic> data = jsonDecode(response);
    setState(() {
      user = User.fromJson(data);
    });

    username.text = user.username;
    email.text = user.email;
  }

  void submitChanges(){
    Map<String, dynamic> user = {
      'username': username.text,
      'password': oldPass.text,
      'email':email.text
    };

    final response = sendRequest('',jsonEncode(user),'ChangeSetting') as String;
    Map<String, dynamic> responseData = jsonDecode(response);
    String message  = responseData['message'];
    saveToken(responseData['token']);
    if(message=='ok') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Saved Successful'),
            content: const Text('Information updated!'),
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
    }else{
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Saved Failed'),
            content: const Text('Failed to Save. Please try again.'),
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

  void logout(){
    removeToken();
    Navigator.pushReplacementNamed(context, '/');
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
    primary: Colors.lightBlueAccent, // Background color
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
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Word Wolf'),
            ElevatedButton(onPressed: (){submitChanges();}, style:buttonStyle , child: const Text('Sumbit Changes')),
            ElevatedButton(onPressed: (){logout();}, style:buttonStyle , child: const Text('logout')),
          ],
        ),
      ),
      body: GridView.count(
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
    );
  }
}