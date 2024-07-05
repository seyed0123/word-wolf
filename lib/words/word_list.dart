import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:wave_loading_indicator/wave_progress.dart';
import 'package:word_wolf/words/word.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../request.dart';

class word_list extends StatefulWidget {
  const word_list({Key? key}) : super(key: key);

  @override
  State<word_list> createState() => _WordListState();
}

class _WordListState extends State<word_list> {
  List<Word> words = [];
  bool isLoading = true;

  Future<void> getWords() async {
    setState(() {
      isLoading = true;
    });

    try {
      String? token = await getToken();
      final String response = await sendGetRequest(token!, 'get_word');
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

  Future<void> deleteWord(String id) async {
    Map<String, dynamic> word = {
      'id': id,
    };
    String? token = await getToken();

    try {
      final response = await sendRequest(token!, jsonEncode(word), 'del_word');
      Map<String, dynamic> responseData = jsonDecode(response);
      String message = responseData['message'] ?? '';

      if (message == 'ok') {
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('word deleted Successful'),
                content: const Text('word deleted from your account'),
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
                title: const Text('word deleting failed'),
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
    setState(() {
      words.removeWhere((word) => word.ID == id);
    });
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
          ? Center(
        child: WaveProgress(
          borderSize: 3.0,
          size: 180,
          borderColor: Colors.redAccent,
          foregroundWaveColor: Colors.greenAccent,
          backgroundWaveColor: Colors.blueAccent,
          progress: 50, // [0-100]
          innerPadding: 10, // padding between border and waves
        ),
      )
          : SingleChildScrollView(
        child: Column(
          children: words.map((word) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                border: const Border.symmetric(
                  vertical: BorderSide(width: 0.5),
                  horizontal: BorderSide(width: 0.5),
                ),
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
              child: Wrap(
                  spacing: 10.0,
                  runSpacing: 15.0,
                  alignment: WrapAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Center children horizontally
                      children: [
                        CircleAvatar(
                          radius: 25, // Adjust the radius as needed
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
                        LinearPercentIndicator(
                          width: MediaQuery.of(context).size.width * 0.5,
                          animation: true,
                          lineHeight: 20.0,
                          animationDuration: 2000,
                          percent: word.progress / 100,
                          leading: const Text("progress:"),
                          center: Text('${word.progress}%'),
                          linearStrokeCap: LinearStrokeCap.roundAll,
                          progressColor: getProgressColor(word.progress / 100),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Center children horizontally
                      children: [
                        CircleAvatar(
                          radius: 25, // Adjust the radius as needed
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
                            deleteWord(word.ID);
                          },
                          icon: const Icon(Icons.delete_forever),
                        ),
                      ],
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
