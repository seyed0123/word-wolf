package com.example.restapi;

import org.json.JSONObject;

public class User {
    private String username;
    private String email; //  verification (later)

    private String id;
    private String password;
    private String strikeLevelName;
    private int strikeLevel;
    private int xp;
    private int level;
    private int strike;
    private boolean isPracticeToday;


    private String deviceID;
    private boolean rememberMe = false;

    public User (String username) {
        this.username = username;
    }
    public User (JSONObject json){
        this.username = json.getString("username");
        this.email = json.getString("email");
        this.deviceID = json.getString("deviceID");
        this.rememberMe = json.getBoolean("rememberMe");
    }
    // getters
    public String getUsername() {
        return username;
    }
    public String getEmail() {
        return email;
    }
    public String getDeviceID() {
        return deviceID;
    }
    public boolean isRememberMe() {
        return rememberMe;
    }

    // setters
    public void setEmail(String email) {
        this.email = email;
    }
    public void setDeviceID(String deviceID) {
        this.deviceID = deviceID;
    }
    public void setRememberMe(boolean boo){
        this.rememberMe = boo;
    }
}
