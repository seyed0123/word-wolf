import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:word_wolf/words/word.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../request.dart';

class popularWord extends StatefulWidget {
  const popularWord({Key? key}) : super(key: key);

  @override
  State<popularWord> createState() => _popularWordState();
}

class _popularWordState extends State<popularWord> {
  List<Word> words = [];

  void getWords(){
    words = [Word('1','hello','سلام','English','Persian',10),Word('2','hallo','سلام','German','Persian',75),Word('3','سلام','سلام','Arabic','Persian',100),Word('4','Bonjour','سلام','French','Persian',30),Word('5','Hola','سلام','Spanish','Persian',60)];
    final String response = sendGetRequest(getToken() as String,'popularWords') as String;
    final parsed = jsonDecode(response).cast<Map<String, dynamic>>();
    words = parsed.map<Word>((json) => Word.fromJson(json)).toList();
  }


  Color getProgressColor(double progress) {
    int red = (255 * (1-progress)).floor();
    int green = (255 * progress).floor();
    int blue = (1024 * ( -1*(progress-1)*(progress) )).floor();
    return Color.fromRGBO(red, green,  blue,  1);
  }

  void addWord(String id){
    Map<String, dynamic> user = {
      'word_id': id,
    };

    final response = sendRequest(getToken() as String,jsonEncode(user),'add_popular_word') as String;
    Map<String, dynamic> responseData = jsonDecode(response);
    String message  = responseData['message'];
    if(message=='ok') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('deleting Successful'),
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
            title: const Text('deleting Failed'),
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
    getWords();
    setState(() {});
  }

  @override
  void initState() {
    getWords();
    super.initState();
  }


  Color hexToColor(String hexCode) {
    final hexColor = hexCode;
    return Color(int.parse('FF$hexColor', radix:  16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Word Wolf'),
        ),
        body:SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: words.map((word) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
                margin:const EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                decoration:BoxDecoration(
                  border: const Border.symmetric(vertical: BorderSide(width: 0.5),horizontal: BorderSide(width: 0.5)),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  color: hexToColor('DBE2EF'),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5), // Shadow color
                      spreadRadius:  5, // Spread radius
                      blurRadius:  7, // Blur radius
                      offset: const Offset(0,  2), // Position of shadow
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
                          radius:  25, // Adjust the radius as needed
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
                          radius:  25, // Adjust the radius as needed
                          backgroundImage: AssetImage('assets/flag_of_${word.meaningLang}.png'), // Replace with your asset path
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward),
                        const SizedBox(width: 10),
                        Text(word.meaning),
                      ],
                    ),
                    IconButton(onPressed: (){addWord(word.ID);}, icon: const Icon(Icons.add_box))
                  ],
                ),
              );
            }).toList(),
          ),
        )
    );
  }
}
