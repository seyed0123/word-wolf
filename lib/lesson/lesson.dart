import 'package:word_wolf/lesson/question.dart';
import 'package:word_wolf/words/word.dart';
class Lesson{
  List<Question> questions;
  List<Word> words;
  String id;
  int progress = 0;
  int score = 0;
  int numWord = 0;
  int numQues = 0;
  int heart = 2;

  Lesson(this.id,this.questions, this.words);

  factory Lesson.fromJson(Map<String, dynamic> json) {
    var questionsFromJson = json['questions'] as List;
    List<Question> questionsList = questionsFromJson.map((i) => Question.fromJson(i)).toList();

    var wordsFromJson = json['words'] as List;
    List<Word> wordsList = wordsFromJson.map((i) => Word.fromJson(i)).toList();

    return Lesson(json['id'],questionsList, wordsList);
  }

  void addProgress(){
    progress += (100 / (words.length+questions.length)).floor();
    if(progress>=100){
      progress=100;
    }
  }
}