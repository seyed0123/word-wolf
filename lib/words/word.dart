class Word{
  String ID;
  String actualWord;
  String meaning;
  String wordLang;
  String meaningLang;
  double progress;

  Word(this.ID , this.actualWord, this.meaning, this.wordLang, this.meaningLang, this.progress);

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      json['id'] as String,
      json['actualWord'] as String,
      json['meaning'] as String,
      json['wordLang'] as String,
      json['meaningLang'] as String,
      json['progress'] as double,
    );
  }

}