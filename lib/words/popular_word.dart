import 'package:flutter/material.dart';
import 'package:word_wolf/words/word.dart';
import 'package:percent_indicator/percent_indicator.dart';

class popularWord extends StatefulWidget {
  const popularWord({Key? key}) : super(key: key);

  @override
  State<popularWord> createState() => _popularWordState();
}

class _popularWordState extends State<popularWord> {
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

  void addWord(String id){
    //TODO: send the data to the server
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
