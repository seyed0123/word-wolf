import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:wave_loading_indicator/wave_progress.dart';
import 'package:word_wolf/words/word.dart';
import '../request.dart';

class popularWord extends StatefulWidget {
  const popularWord({Key? key}) : super(key: key);

  @override
  State<popularWord> createState() => _PopularWordState();
}

class _PopularWordState extends State<popularWord> {
  List<Word> words = [];
  bool isLoading = true;

  Future<void> getWords() async {
    setState(() {
      isLoading = true;
    });

    try {
      String? token = await getToken();
      final String response = await sendGetRequest(token!, 'get_popular_word');
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
                title: const Text('word added Successful'),
                content: const Text('word added to your account'),
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
                title: const Text('word adding failed'),
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
    getWords();
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
      body: isLoading
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
          : SingleChildScrollView(
        child: Column(
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 25, // Adjust the radius as needed
                        backgroundImage: AssetImage('assets/flag_of_${word.wordLang}.png'), // Replace with your asset path
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward),
                      const SizedBox(width: 10),
                      Text(word.actualWord),
                    ],
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25, // Adjust the radius as needed
                        backgroundImage: AssetImage('assets/flag_of_${word.meaningLang}.png'), // Replace with your asset path
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward),
                      const SizedBox(width: 10),
                      Text(word.meaning),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      addWord(word.actualWord,word.meaning,word.wordLang,word.meaningLang);
                    },
                    icon: const Icon(Icons.add_box),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
