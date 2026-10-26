import 'package:flutter/material.dart';
import '../app_theme.dart';
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
    rePassword.dispose();
    email.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> sendData() async {
    String err = '';
    if (username.text.isEmpty ||
        password.text.isEmpty ||
        rePassword.text.isEmpty ||
        email.text.isEmpty) {
      err = 'All fields are required';
    } else if (password.text != rePassword.text) {
      err = 'password doesn\'t match';
    } else if (_isChecked == false) {
      err = 'Agree the terms';
    }
    if (err != '') {
      setState(() {
        error = err;
      });
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

  @override
  Widget build(BuildContext context) => TaskPage(
    title: 'Create an account',
    maxWidth: 440,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Start with a word.',
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        const Text('Build a vocabulary that belongs to you.'),
        const SizedBox(height: 32),
        TextField(
          controller: username,
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: password,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: rePassword,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Confirm password'),
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('I agree to the terms and conditions'),
          value: _isChecked,
          onChanged: (value) => setState(() {
            _isChecked = value ?? false;
          }),
        ),
        if (error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              error,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        const SizedBox(height: 16),
        FilledButton(onPressed: sendData, child: const Text('Create account')),
      ],
    ),
  );
}
