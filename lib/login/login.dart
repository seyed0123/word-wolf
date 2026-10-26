import 'package:flutter/material.dart';
import '../app_theme.dart';
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

  @override
  Widget build(BuildContext context) => TaskPage(
    title: 'word wolf',
    maxWidth: 440,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Icon(Icons.menu_book_outlined, size: 48, color: forest),
        const SizedBox(height: 24),
        const Text(
          'More words.\nMore possibilities.',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 16),
        const Text('Sign in to continue your learning journey.'),
        const SizedBox(height: 32),
        TextField(
          controller: username,
          autofillHints: const [AutofillHints.username],
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: password,
          obscureText: true,
          autofillHints: const [AutofillHints.password],
          onSubmitted: (_) => sendData(),
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        if (error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              error,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        const SizedBox(height: 24),
        FilledButton(onPressed: sendData, child: const Text('Sign in')),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/sign_up'),
          child: const Text('New here? Create an account'),
        ),
      ],
    ),
  );
}
