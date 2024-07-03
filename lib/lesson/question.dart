class Question{
  String question;
  List<Answer> answers;
  int correct;

  Question(this.question, this.answers, this.correct);

  factory Question.fromJson(Map<String, dynamic> json) {
    var answersFromJson = json['answers'] as List;
    List<Answer> answersList = answersFromJson.map((i) => Answer.fromJson(i)).toList();

    return Question(json['question'], answersList, json['correct']);
  }
}

class Answer{
  String text;
  int chossen=0;
  int num = -1;

  Answer(this.text);

  factory Answer.fromJson(String text) {
    return Answer(text);
  }
}