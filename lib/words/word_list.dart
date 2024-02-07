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
    words = [Word('1','hello','سلام','English',10),Word('2','hallo','سلام','German',75),Word('3','سلام','سلام','Arabic',100),Word('4','Bonjour','سلام','French',30),Word('5','Hola','سلام','Spanish',60)];
  }


  Color getProgressColor(double progress) {
    int red = (255 * (1-progress)).floor();
    int green = (255 * progress).floor();
    int blue = (1024 * ( -1*(progress-1)*(progress) )).floor();
    return Color.fromRGBO(red, green,  blue,  1);
  }
  void deleteWord(String id){
    for(var i = 0 ; i < words.length ; i++){
      if(words[i].ID == id){
        words.removeAt(i);
      }
    }
    setState(() {});
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
              LinearPercentIndicator(
                width: MediaQuery.of(context).size.width *  0.25,
                animation: true,
                lineHeight:  20.0,
                animationDuration:  2000,
                percent: word.progress /  100,
                leading: const Text("progress"),
                center: Text('${word.progress}%'),
                linearStrokeCap: LinearStrokeCap.roundAll,
                progressColor: getProgressColor(word.progress /  100),
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
                 IconButton(onPressed: (){deleteWord(word.ID);}, icon: const Icon(Icons.delete_forever))
                ],
              ),
            );
          }).toList(),
        ),
      )
    );
  }
}