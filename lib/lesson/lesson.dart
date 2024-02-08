import 'package:word_wolf/lesson/question.dart';
import 'package:word_wolf/words/word.dart';
class Lesson{
  List<Question> questions;
  List<Word> words;
  int progress;
  int score;
  int numWord;

  Lesson(this.questions, this.words, this.progress, this.score,this.numWord);

  void addProgress(){
    progress += (100 / (words.length+questions.length)).floor();
    if(progress>=100){
      progress=100;
    }
  }
}