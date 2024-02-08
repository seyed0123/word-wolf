import 'package:word_wolf/lesson/question.dart';
import 'package:word_wolf/words/word.dart';
class Lesson{
  List<Question> questions;
  List<Word> words;
  int progress=0;
  int score=0;
  int numWord=0;
  int numQues=0;

  Lesson(this.questions, this.words);

  void addProgress(){
    progress += (100 / (words.length+questions.length)).floor();
    if(progress>=100){
      progress=100;
    }
  }
}