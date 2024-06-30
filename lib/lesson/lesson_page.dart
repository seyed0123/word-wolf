import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:word_wolf/lesson/question.dart';
import 'package:word_wolf/words/word.dart';
import 'lesson.dart';
import 'gifManager.dart';
// import 'package:word_wolf/flip_card/flip_card.dart';
import 'package:flip_card/flip_card.dart';

class Lesson_page extends StatefulWidget {
  const Lesson_page({Key? key}) : super(key: key);

  @override
  State<Lesson_page> createState() => _Lesson_pageState();
}

class _Lesson_pageState extends State<Lesson_page> {

  late Lesson lesson;

  void getLesson(){
      //TODO: getting lesson from server
      lesson = Lesson([Question('Question 1: hey', [Answer('no'),Answer('yes'),Answer('hello'),Answer('thanks')], 2),Question('Question 2:hallo', [Answer('1'),Answer('2'),Answer('3'),Answer('4')], 2),Question('Question 3:hola',[Answer('1'),Answer('2'),Answer('3'),Answer('4')], 3)], [Word('1', 'yes', 'ja', 'English','German', 1),Word('1', 'ei', 'egg', 'German','english', 1)]);
  }

  void finishLesson(bool success,BuildContext context0){
      Navigator.pop(context0);
      if(success){
        showPopup(context0);
      }else{
        lossPopup(context0);
      }
  //    TODO: send the result the lesson to the server
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

  int chossen = -1;
  String quesButtonText = "Submit";
  int numAns = 0;
  bool is_checked = false;
  @override
  void initState() {
    getLesson();
    super.initState();
  }

  Future<void> lossPopup(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Good but not enough.'),
          content: const Text('Unfortunately you ran out of hearts, try harder next time.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  Future<void> showPopup(BuildContext context) async {
    List<String> gifItems = ['Option  1', 'Option  2', 'Option  3'];
    String selectedOption = gifItems[0];
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose an option'),
          content: Container(
            width: double.maxFinite,
            child: DropdownButtonFormField<String>(
              value: selectedOption,
              hint: Text('Select an option'),
              items: gifItems
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedOption = newValue!;
                });
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                // Handle the selected option here
                print('Selected option: $selectedOption');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void losePopUp(){

}

  Container option(Answer e){
    e.num = numAns;
    numAns+=1;
    return Container(
      margin: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width *  0.25,
      height: MediaQuery.of(context).size.width *  0.1,
      child: TextButton(onPressed: is_checked ?(){}:(){
        e.chossen = 1 ;
        if(chossen == e.num){
          chossen = -1;
          e.chossen = 0;
        }else {
          if (chossen != -1) {
            lesson.questions[lesson.numQues].answers[chossen]
                .chossen = 0;
            chossen = -1;
          }
          chossen = e.num;
        }
        numAns=0;
        setState(() {});
      },
          style: TextButton.styleFrom(
            backgroundColor: e.chossen==1 ? hexToColor('ECB159'): e.chossen==0 ? hexToColor('F9F7F7') : e.chossen==2 ? hexToColor('FF8080'):hexToColor('74E291'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
          ),
          child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(20),
            child: Text(e.text),
          )),
    );
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
            Row(
              children: [
                Text('${lesson.heart}'),
                const SizedBox(
                  width: 10,
                ),
                const Icon(
                    Icons.favorite,
                    color: Colors.red,
                ),

              ],
            )
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
                  fill: Fill.fillBack, // Fill the back side of the card to make in the same size as the front.
                  direction: lesson.numWord % 2==0 ?FlipDirection.HORIZONTAL:FlipDirection.VERTICAL, // default
                  side: CardSide.FRONT, // The side to initially display.
                  front: Container(
                    color: hexToColor('3F72AF'),
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.4,
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
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Center(
                        child:Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(lesson.words[lesson.numWord].meaning),
                            const SizedBox(
                              width: 50,
                            ),
                            CircleAvatar(
                              radius:  50, // Adjust the radius as needed
                              backgroundImage: AssetImage('assets/flag_of_${lesson.words[lesson.numWord].meaningLang}.png'), // Replace with your asset path
                            ),
                          ],
                        )
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
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
        : Container(
          padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
          margin:const EdgeInsets.symmetric(vertical: 40,horizontal: 30),
          decoration:BoxDecoration(
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
        child: Center(
          child: Column(
            children: [
              Text(
                  lesson.questions[lesson.numQues].question,
                style: GoogleFonts.radley(),
              ),
              const SizedBox(
                height: 50,
              ),
              Column(
                // children:lesson.questions[lesson.numQues].answers.map((e) {return option(e);}
                //     ).toList(),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      option(lesson.questions[lesson.numQues].answers[0]),
                      option(lesson.questions[lesson.numQues].answers[1]),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      option(lesson.questions[lesson.numQues].answers[2]),
                      option(lesson.questions[lesson.numQues].answers[3]),
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              FilledButton(
                onPressed: () {

                  if(quesButtonText=='Next') {
                    lesson.numQues += 1;
                    lesson.addProgress();
                    quesButtonText = "Submit";
                    numAns=0;
                    chossen =-1;
                    is_checked = false;
                  }else{
                    if(chossen==-1){
                      return;
                    }
                    if(chossen != lesson.questions[lesson.numQues].correct){
                      lesson.questions[lesson.numQues].answers[chossen].chossen=2;
                      lesson.heart--;
                      if(lesson.heart==0){
                        finishLesson(false,context);
                      }
                    }
                    lesson.questions[lesson.numQues].answers[lesson.questions[lesson.numQues].correct].chossen = 3;
                    quesButtonText = "Next";
                    numAns=0;
                    is_checked = true;
                  }

                  if(lesson.numQues >= lesson.questions.length){
                    finishLesson(true,context);
                  }else{
                    setState(() {});
                  }

                },
                style: buttonStyle,
                child: Text(quesButtonText),
              ),
            ],
          ),
        ),
      ),
    );
  }

}