package org.example;

public class User {
    String username;
    String password;
    String phoneNumber; // phone verification (later)
    boolean rememberMe = false;

    public User (String username, String password) {
        this.username =username;
        this.password = password;
    }

    public static boolean checkUserPassword(String username, String password) {
        return true;
    }

    public void setRememberMe(boolean boo){
        this.rememberMe = boo;
    }
}
