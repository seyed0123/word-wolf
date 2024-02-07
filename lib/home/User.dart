
class User{
  String id;
  String username;
  String password;
  String email;
  String motherTongue;
  String strikeLevelName;
  int strikeLevel;
  int xp;
  int level;
  int strike;
  bool isPracticeToday;

  User(this.id, this.username, this.password, this.email, this.motherTongue,
      this.xp, this.level, this.strike,this.isPracticeToday,this.strikeLevel,this.strikeLevelName);
}