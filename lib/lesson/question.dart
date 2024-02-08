class Question{
  String question;
  List<Answer> answers;
  int correct;

  Question(this.question, this.answers, this.correct);
}

class Answer{
  String text;
  int chossen=0;
  int num = -1;

  Answer(this.text);
}