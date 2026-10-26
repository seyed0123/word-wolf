import 'dart:convert';

import 'package:flutter/material.dart';
import '../app_theme.dart';
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

  String? loadError;
  Future<void> getUser() async {
    setState(() {
      isLoading = true;
      loadError = null;
    });
    try {
      final token = await getToken();
      if (token == null) throw Exception();
      final response = await sendGetRequest(token, 'get_user');
      if (!mounted) return;
      setState(() {
        user = User.fromJson(jsonDecode(response));
        username.text = user.username;
        email.text = user.email;
      });
    } catch (_) {
      if (mounted)
        setState(() {
          loadError = 'Could not load your account.';
        });
    } finally {
      if (mounted)
        setState(() {
          isLoading = false;
        });
    }
  }

  Future<void> submitChanges() async {
    Map<String, dynamic> user = {
      'username': username.text,
      'oldPassword': oldPass.text,
      'newPassword': newPass.text,
      'email': email.text,
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
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (Route<dynamic> route) => false,
      );
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

  @override
  Widget build(BuildContext context) => TaskPage(
    title: 'Account settings',
    child: isLoading
        ? const Center(child: CircularProgressIndicator())
        : loadError != null
        ? Column(
            children: [
              Text(loadError!),
              TextButton(onPressed: getUser, child: const Text('Try again')),
              TextButton(onPressed: logout, child: const Text('Sign out')),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Make yourself at home.',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              const Text('Update your profile or change your password.'),
              const SizedBox(height: 32),
              TextField(
                controller: username,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Change password',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Leave these fields empty to keep your current password.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: oldPass,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current password',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPass,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New password'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: submitChanges,
                child: const Text('Save changes'),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: logout,
                icon: const Icon(Icons.logout),
                label: const Text('Sign out'),
              ),
            ],
          ),
  );
}
