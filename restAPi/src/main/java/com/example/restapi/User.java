package com.example.restapi;

import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.*;

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
    private List<String> levels = Arrays.asList("Clown", "Noob", "Novice","Average","Sigma","Chad","Absolute Chad","Giga Chad","Absolute Giga Chad");
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

        this.PracticeToday = isPracticeToday;
        this.isPracticeToday = isPractice(0);

        if (!isPractice(-1) && !this.isPracticeToday){
            this.strike = 0;
        }else{
            this.strike = strike;
        }

        this.strikeLevelName= settingStrikeLevelName();
    }

    public boolean isPracticeToday() {
        return isPracticeToday;
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
        int newLevel = (int)Math.log10(xp)+1;
        this.setLevel(newLevel);
    }
    public void setLevel(int level) {
        this.level = level;
    }
    public void setStrike(int strike) {
        this.strike = strike;
        DataBase.setStrike(id, strike);
        int newStrikeLevel = (int)(Math.log(strike) / Math.log(2));
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
        if (strike ==0) return levels.get(0);

        int result = (int)(Math.log(strike) / Math.log(2))+1;

        if (result >= levels.size()) {
            return levels.get(levels.size()-1);
        }
        return levels.get(result);
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
    public boolean isPractice(int day) {
        Date date = new Date();
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(date);
        calendar.add(Calendar.DAY_OF_YEAR, day);
        Date pastDate = calendar.getTime();

        SimpleDateFormat fmt = new SimpleDateFormat("yyyyMMdd");
        String dateStr = fmt.format(pastDate);
        return PracticeToday.equals(dateStr);
    }
    public String getPracticeDate() {
        return PracticeToday;
    }

    public void setPracticeToday(boolean practiceToday) {
        isPracticeToday = practiceToday;
    }
}
