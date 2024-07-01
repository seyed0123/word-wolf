
class User{
  String id;
  String username;
  String password;
  String email;
  String strikeLevelName;
  int strikeLevel;
  int xp;
  int level;
  int strike;
  bool isPracticeToday;

  User(this.id, this.username, this.password, this.email,
      this.xp, this.level, this.strike,this.isPracticeToday,this.strikeLevel,this.strikeLevelName);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['id'],
      json['name'],
      json['password'],
      json['username'],
      json['xp'],
      json['level'],
      json['strike'],
      json['isPracticeToday'],
      json['strikeLevel'],
      json['strikeLevelName'],
    );
  }
}