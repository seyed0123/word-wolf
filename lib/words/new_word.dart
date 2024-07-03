import 'dart:convert';
import 'package:flutter/material.dart';
import '../request.dart';

class new_word extends StatefulWidget {
  const new_word({Key? key}) : super(key: key);

  @override
  State<new_word> createState() => _NewWordState();
}

class _NewWordState extends State<new_word> {
  final wordController = TextEditingController();
  final wordMeaningController = TextEditingController();
  String dropdownValue = 'English';
  String dropdownValueMeaning = 'English';
  final List<String> dropdownOptions = ['English', 'Persian', 'German', 'French', 'Spanish', 'Arabic'];
  String error = '';
  bool ok = false;

  @override
  void dispose() {
    wordController.dispose();
    wordMeaningController.dispose();
    super.dispose();
  }

  void sendData(BuildContext context) {
    String err = '';
    if (wordController.text.isEmpty || wordMeaningController.text.isEmpty) {
      err = 'All fields are required';
    }
    if (err.isNotEmpty) {
      setState(() {
        error = err;
      });
      return;
    }
    showAlertDialog(context, wordController.text, wordMeaningController.text);
  }

  Future<void> verify(bool flag, BuildContext context) async {
    if (flag) {
      Map<String, dynamic> wordJ = {
        'word': wordController.text,
        'wordMeaning': wordMeaningController.text,
        'wordLang': dropdownValue,
        'meaningLang': dropdownValueMeaning
      };
      String? token = await getToken();
      try {
        final response = await sendRequest(token!, jsonEncode(wordJ), 'add_word');
        Map<String, dynamic> responseData = jsonDecode(response);
        String message = responseData['message'] ?? '';

        if (message == 'ok') {
          if (mounted) {
            wordController.text = '';
            wordMeaningController.text = '';
            dropdownValue  = 'English';
            dropdownValueMeaning = 'English';
            ok = false;
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Word Added Successfully'),
                  content: const Text('New word added!'),
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
          showErrorDialog(context, 'Word Adding Failed', message);
        }
      } catch (e) {
        showErrorDialog(context, 'Error', 'An error occurred: $e');
      }
    }
  }

  void showAlertDialog(BuildContext context, String word, String meaning) {
    Widget okButton = TextButton(
      child: const Text("Yes"),
      onPressed: () {
        Navigator.of(context).pop();  // Close the confirmation dialog
        verify(true, context);
      },
    );
    Widget noButton = TextButton(
      child: const Text("No"),
      onPressed: () {
        Navigator.of(context).pop();  // Close the confirmation dialog
        verify(false, context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Do you confirm the word meaning?"),
      content: Text(
        '$word: $meaning',
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        noButton,
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Wolf'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Center(
          child: Column(
            children: [
              const Text(
                'Add new word',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              Text(
                error,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 20,
                ),
              ),
              TextField(
                controller: wordController,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'word',
                ),
              ),
              const SizedBox(height: 25),
              const Row(
                children: [
                  Text('This word belongs to which language?'),
                  Icon(Icons.arrow_circle_down),
                ],
              ),
              DropdownButton<String>(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                isExpanded: true,
                value: dropdownValue,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 100,
                style: const TextStyle(color: Colors.black),
                underline: Container(
                  height: 1,
                  color: Colors.black45,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
                items: dropdownOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 10, // Adjust the radius as needed
                          backgroundImage: AssetImage('assets/flag_of_$value.png'), // Replace with your asset path
                        ),
                        const SizedBox(width: 10),
                        Text(value),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: wordMeaningController,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'word meaning',
                ),
              ),
              const SizedBox(height: 25),
              const Row(
                children: [
                  Text('The word\'s meaning belongs to which language?'),
                  Icon(Icons.arrow_circle_down),
                ],
              ),
              DropdownButton<String>(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                isExpanded: true,
                value: dropdownValueMeaning,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 100,
                style: const TextStyle(color: Colors.black),
                underline: Container(
                  height: 1,
                  color: Colors.black45,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValueMeaning = newValue!;
                  });
                },
                items: dropdownOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 10, // Adjust the radius as needed
                          backgroundImage: AssetImage('assets/flag_of_$value.png'), // Replace with your asset path
                        ),
                        const SizedBox(width: 10),
                        Text(value),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  sendData(context);
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
                child: const Text('Add word'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}