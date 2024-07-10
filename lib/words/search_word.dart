import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:wave_loading_indicator/wave_progress.dart';
import 'package:word_wolf/words/word.dart';
import '../request.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List<Word> words = [];
  bool isLoading = false;
  final wordController = TextEditingController();
  final wordMeaningController = TextEditingController();
  String dropdownValue = 'Any';
  String dropdownValueMeaning = 'Any';
  final List<String> dropdownOptions = ['Any','English', 'Persian', 'German', 'French', 'Spanish', 'Arabic'];

  Future<void> getWords() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> wordJ = {
      'word': wordController.text,
      'wordMeaning': wordMeaningController.text,
      'wordLang': dropdownValue,
      'meaningLang': dropdownValueMeaning
    };

    try {
      String? token = await getToken();
      final String response = await sendRequest(token!,jsonEncode(wordJ), 'search');
      final parsed = jsonDecode(response).cast<Map<String, dynamic>>();
      setState(() {
        words = parsed.map<Word>((json) => Word.fromJson(json)).toList();
        isLoading = false;
      });
    } catch (e) {
      // Handle error
      setState(() {
        isLoading = false;
      });
    }
  }

  Color getProgressColor(double progress) {
    int red = (255 * (1 - progress)).floor();
    int green = (255 * progress).floor();
    int blue = (1024 * (-1 * (progress - 1) * progress)).floor();
    return Color.fromRGBO(red, green, blue, 1);
  }

  Future<void> addWord(String word, String meaning,String wordLang,String meaningLang) async {
    Map<String, dynamic> wordJ = {
      'word': word,
      'wordMeaning': meaning,
      'wordLang': wordLang,
      'meaningLang': meaningLang
    };
    String? token = await getToken();

    try {
      final response = await sendRequest(token!, jsonEncode(wordJ), 'add_word');
      Map<String, dynamic> responseData = jsonDecode(response);
      String message = responseData['message'] ?? '';

      if (message == 'ok') {
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Word Added Successfully'),
                content: const Text('Word added to your account'),
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
                title: const Text('Word Adding Failed'),
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
  void initState() {
    super.initState();
  }

  Color hexToColor(String hexCode) {
    final hexColor = hexCode;
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Wolf'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            border: const Border.symmetric(
                vertical: BorderSide(width: 0.5),
                horizontal: BorderSide(width: 0.5)),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            color: hexToColor('DBE2EF'),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5), // Shadow color
                spreadRadius: 5, // Spread radius
                blurRadius: 7, // Blur radius
                offset: const Offset(0, 2), // Position of shadow
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: wordController,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        labelText: 'Word',
                      ),
                    ),
                  ),
                  const SizedBox(width: 25),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('This word belongs to which language?'),
                        DropdownButton<String>(
                          isExpanded: true,
                          value: dropdownValue,
                          icon: const Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
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
                          items: dropdownOptions
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundImage: AssetImage(
                                        'assets/flag_of_$value.png'),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(value),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: wordMeaningController,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        labelText: 'Word Meaning',
                      ),
                    ),
                  ),
                  const SizedBox(width: 25),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('The word\'s meaning belongs to which language?'),
                        DropdownButton<String>(
                          isExpanded: true,
                          value: dropdownValueMeaning,
                          icon: const Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
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
                          items: dropdownOptions
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundImage: AssetImage(
                                        'assets/flag_of_$value.png'),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(value),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  getWords();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Background color
                  foregroundColor: Colors.white, // Text color
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
                child: const Text('Search'),
              ),
              const SizedBox(
                height: 40,
              ),
              isLoading
                  ? Center(child: WaveProgress(
                        borderSize: 3.0,
                        size: 180,
                        borderColor: Colors.redAccent,
                        foregroundWaveColor: Colors.greenAccent,
                        backgroundWaveColor: Colors.blueAccent,
                        progress: 30, // [0-100]
                        innerPadding: 10, // padding between border and waves
                      ),
                  )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: words.map((word) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    decoration: BoxDecoration(
                      border: const Border.symmetric(
                          vertical: BorderSide(width: 0.5),
                          horizontal: BorderSide(width: 0.5)),
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      color: hexToColor('F1F8E8'),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5), // Shadow color
                          spreadRadius: 5, // Spread radius
                          blurRadius: 7, // Blur radius
                          offset: const Offset(0, 2), // Position of shadow
                        ),
                      ],
                    ),
                    child: Wrap(
                      spacing: 10.0,
                      runSpacing: 15.0,
                      alignment: WrapAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 15, // Adjust the radius as needed
                              backgroundImage: AssetImage('assets/flag_of_${word.wordLang}.png'), // Replace with your asset path
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.arrow_forward),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                  word.actualWord,
                                  overflow: TextOverflow.clip,
                                  softWrap: true,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 15, // Adjust the radius as needed
                              backgroundImage: AssetImage('assets/flag_of_${word.meaningLang}.png'), // Replace with your asset path
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.arrow_forward),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                word.meaning,
                                overflow: TextOverflow.clip,
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                addWord(word.actualWord,word.meaning,word.wordLang,word.meaningLang);
                              },
                              icon: const Icon(Icons.add_box),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
