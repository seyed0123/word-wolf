package com.example.restapi;
public class User {
    private String id;
    private String name;
    private String password;
    private String username;
    private String language;
    private int xp;
    private int level;
    private int strike;
    private boolean isPracticeToday;
    private int strikeLevel;
    private String strikeLevelName;

    public User() {
    }

    public User(String id, String name, String password, String username, String language, int xp,
                int level, int strike, boolean isPracticeToday, int strikeLevel, String strikeLevelName) {
        this.id = id;
        this.name = name;
        this.password = password;
        this.username = username;
        this.language = language;
        this.xp = xp;
        this.level = level;
        this.strike = strike;
        this.isPracticeToday = isPracticeToday;
        this.strikeLevel = strikeLevel;
        this.strikeLevelName = strikeLevelName;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getLanguage() {
        return language;
    }

    public void setLanguage(String language) {
        this.language = language;
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

    public int getStrikeLevel() {
        return strikeLevel;
    }

    public void setStrikeLevel(int strikeLevel) {
        this.strikeLevel = strikeLevel;
    }

    public String getStrikeLevelName() {
        return strikeLevelName;
    }

    public void setStrikeLevelName(String strikeLevelName) {
        this.strikeLevelName = strikeLevelName;
    }

    // Getters and setters
}

