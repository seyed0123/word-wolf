import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:word_wolf/lesson/question.dart';
import 'package:word_wolf/words/word.dart';
import 'lesson.dart';
import 'package:word_wolf/flip_card/flip_card.dart';


class Lesson_page extends StatefulWidget {
  const Lesson_page({Key? key}) : super(key: key);

  @override
  State<Lesson_page> createState() => _Lesson_pageState();
}

class _Lesson_pageState extends State<Lesson_page> {

  late Lesson lesson;

  void getLesson(){
      lesson = Lesson([Question('hey', ['1','2','3','4'], 3),Question('hallo', ['1','2','3','4'], 4),Question('hola', ['1','2','3','4'], 5)], [Word('1', 'yes', 'ja', 'English', 1),Word('1', 'ei', 'egg', 'German', 1)], 0, 0, 0);
  }

  Color hexToColor(String hexCode) {
    final hexColor = hexCode;
    return Color(int.parse('FF$hexColor', radix:  16));
  }

  ButtonStyle buttonStyle = ElevatedButton.styleFrom(
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
  );

  bool _isFlipped = false;

  void _toggleCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  void initState() {
    getLesson();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hexToColor('F9F7F7'),
      appBar: AppBar(
        backgroundColor: hexToColor('DBE2EF'),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
          const Text('Word Wolf'),
          LinearPercentIndicator(
            width: MediaQuery.of(context).size.width * 0.5,
            animation: true,
            lineHeight: 20.0,
            animationDuration: 1000,
            percent: lesson.progress/100,
            linearStrokeCap: LinearStrokeCap.roundAll,
            progressColor: hexToColor('112D4E'),
            ),
          ]
        )
      ),
      body: lesson.words.length > lesson.numWord
          ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FlipCard(
                  fill: Fill.none, // Fill the back side of the card to make in the same size as the front.
                  direction: Axis.horizontal, // default
                  initialSide: CardSide.front, // The side to initially display.
                  front: Container(
                    color: hexToColor('3F72AF'),
                    width: 400,
                    height: 400,
                    child: Center(
                        child:Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(lesson.words[lesson.numWord].actualWord),
                            const SizedBox(
                              width: 50,
                            ),
                            CircleAvatar(
                              radius:  50, // Adjust the radius as needed
                              backgroundImage: AssetImage('assets/flag_of_${lesson.words[lesson.numWord].wordLang}.png'), // Replace with your asset path
                            ),
                          ],
                        )
                    ),
                  ),
                  back: Container(
                    color: hexToColor('3F72AF'),
                    width: 400,
                    height: 400,
                    child: Center(
                        child:Text(lesson.words[lesson.numWord].meaning)
                    ),
                  ),
                ),
                const SizedBox(
                  height: 100,
                ),
                FilledButton(onPressed: () {
                  lesson.numWord+=1;
                  lesson.addProgress();
                  setState(() {

                  });
                },
                    style: buttonStyle,
                    child: const Text("Next")
                ),
              ],
            ),
          )
        : Container(),
    );
  }

}

