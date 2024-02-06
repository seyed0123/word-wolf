import 'package:flutter/material.dart';
import 'package:word_wolf/words/word.dart';
import 'package:percent_indicator/percent_indicator.dart';


class word_list extends StatefulWidget {
  const word_list({Key? key}) : super(key: key);

  @override
  State<word_list> createState() => _word_listState();
}

class _word_listState extends State<word_list> {
  String mother_tongue = 'Persian';
  List<Word> words = [];

  void getWords(){
    words = [Word('hello','سلام','English',0),Word('hallo','سلام','German',75),Word('سلام','سلام','Arabic',50),Word('Bonjour','سلام','French',30),Word('Hola','سلام','Spanish',60)];
  }
  @override
  void initState() {
    getWords();
    super.initState();
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
                color: Colors.grey[500], // Background color for the padding area
                borderRadius: BorderRadius.circular(8.0), // Optional: Add rounded corners
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  LinearPercentIndicator(
                    width: MediaQuery.of(context).size.width*0.25,
                    animation: true,
                    lineHeight: 20.0,
                    animationDuration: 2000,
                    percent: word.progress/100,
                    leading: const Text("progress"),
                    center: Text('${word.progress}%'),
                    linearStrokeCap: LinearStrokeCap.roundAll,
                    progressColor: Colors.blueAccent,
                  ),
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
                      backgroundImage: AssetImage('assets/flag_of_$mother_tongue.png'), // Replace with your asset path
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward),
                    const SizedBox(width: 10),
                    Text(word.meaning),
                  ],
                ),
                ],
              ),
            );
          }).toList(),
        ),
      )
    );
  }
}
