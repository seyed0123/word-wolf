package com.example.restapi;

import org.json.JSONObject;

public class User {
    private String id;
    private String username;
    private String email; //  verification (later)
    private String password;
    private int strikeLevel;
    private int xp;
    private int level;
    private int strike;
    private boolean isPracticeToday;

    public User (String username) {
        this.username = username;
    }

    public User(String id, String username, String email, String password, int strikeLevel, int xp, int level, int strike, boolean isPracticeToday) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.password = password;
        this.strikeLevel = strikeLevel;
        this.xp = xp;
        this.level = level;
        this.strike = strike;
        this.isPracticeToday = isPracticeToday;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public int getStrikeLevel() {
        return strikeLevel;
    }

    public void setStrikeLevel(int strikeLevel) {
        this.strikeLevel = strikeLevel;
    }

    public int getXp() {
        return xp;
    }

    public void setXp(int xp) {
        this.xp = xp;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public int getStrike() {
        return strike;
    }

    public void setStrike(int strike) {
        this.strike = strike;
    }

    public boolean isPracticeToday() {
        return isPracticeToday;
    }

    public void setPracticeToday(boolean practiceToday) {
        isPracticeToday = practiceToday;
    }
}
