package org.example;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

public class DataBase {
    private static Connection connection;
    public static void connect() {
        try {
            connection = DriverManager.getConnection("jdbc:sqlite:filename.db");
            System.out.println("Database connected");
        } catch (SQLException e) {
            System.err.println(e.getMessage());
        }
    }
    public static void close(){
        try {
            Statement statement = connection.createStatement();
            statement.close();
            connection.close();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    // user
    public static void addUser(){}
    public static void deleteUser(){}
    public static boolean checkUserPassword(String username, String password){
        return true;
    }
    public static void changePassword(){}
    public static boolean rememberMe(String deviceId, String username) {
        return false;
    }
    // word
    public static void getUserWords(){}

}
