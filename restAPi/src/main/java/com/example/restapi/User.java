package com.example.restapi;

import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.Date;

public class User {
    private String id;
    private String username;
    private String email; //  verification (later)
    private String password;
    private int strikeLevel;
    private String strikeLevelName;
    private int xp;
    private int level;
    private int strike;
    private boolean isPracticeToday;
    private String PracticeToday;

    public User (String username) {
        this.username = username;
    }
    public User(String id, String username, String password, String email, int strikeLevel, int xp, int level, int strike, String isPracticeToday) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.password = password;
        this.strikeLevel = strikeLevel;
        this.xp = xp;
        this.level = level;
        this.strike = strike;
        this.PracticeToday = isPracticeToday;
        this.isPracticeToday = isPracticeToday();
        this.strikeLevelName= settingStrikeLevelName();
    }

    // setters
    public void setId(String id) {
        this.id = id;
    }
    public void setUsername(String username) {
        this.username = username;
    }
    public void setStrikeLevelName(String strikeLevelName) {
        this.strikeLevelName = strikeLevelName;
    }
    public void setEmail(String email) {
        this.email = email;
    }
    public void setPassword(String password) {
        this.password = password;
    }
    public void setXp(int xp) {
        this.xp = xp;
        DataBase.setXp(id, xp);
        int newLevel = (int)Math.log(xp);
        this.setLevel(newLevel);
    }
    public void setLevel(int level) {
        this.level = level;
    }
    public void setStrike(int strike) {
        this.strike = strike;
        DataBase.setStrike(id, strike);
        int newStrikeLevel = (int)(Math.log(strike)/Math.log(2));
        setStrikeLevel(newStrikeLevel);
    }
    public void setStrikeLevel(int strikeLevel) {
        this.strikeLevel = strikeLevel;
    }
    public void setPracticeToday() {
        Date date = new Date();
        SimpleDateFormat fmt = new SimpleDateFormat("yyyyMMdd");
        String dateStr = fmt.format(date);
        this.PracticeToday = dateStr;
        DataBase.setIsPracticeToday(this.id, dateStr);
    }
    public String settingStrikeLevelName(){
        if (strike > 8) {
            return "Absolute Giga Chad";
        }
        return switch (strikeLevel) {
            case 0 -> "Clown";
            case 1 -> "Noob";
            case 2 -> "Novice";
            case 3 -> "Average";
            case 4 -> "Sigma";
            case 5 -> "Chad";
            case 6 -> "Absolute_chad";
            case 7 -> "Giga_chad";
            case 8 -> "Absolute_Giga_chad";
            default -> "";
        };
    }

    // getters
    public String getId() {
        return id;
    }
    public String getUsername() {
        return username;
    }
    public String getStrikeLevelName() {
        return strikeLevelName;
    }
    public String getEmail() {
        return email;
    }
    public String getPassword() {
        return password;
    }
    public int getStrikeLevel() {
        return strikeLevel;
    }
    public int getXp() {
        return xp;
    }
    public int getLevel() {
        return level;
    }
    public int getStrike() {
        return strike;
    }
    public boolean isPracticeToday() {
        Date date = new Date();
        SimpleDateFormat fmt = new SimpleDateFormat("yyyyMMdd");
        String dateStr = fmt.format(date);
        return PracticeToday.equals(dateStr);
    }
    public String getPracticeDate() {
        return PracticeToday;
    }

    public void setPracticeToday(boolean practiceToday) {
        isPracticeToday = practiceToday;
    }
}
