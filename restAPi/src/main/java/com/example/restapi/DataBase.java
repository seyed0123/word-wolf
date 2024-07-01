package com.example.restapi;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.*;
import java.util.ArrayList;

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
    public static boolean usernameExist(String username) {
        try {
            String query = "SELECT EXISTS(SELECT 1 FROM users WHERE name = ?)";
            PreparedStatement stmt = connection.prepareStatement(query);
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            rs.next();
            return rs.getBoolean(1);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
    public static String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes());
            StringBuilder sb = new StringBuilder();
            for (byte b : hash) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            return null;
        }
    }
    public static boolean checkPassword(String username,String password)  {
        try {
            String query = "select hash_password from users where name = ?";
            PreparedStatement stmt = null;
            stmt = connection.prepareStatement(query);
            stmt.setString(1, username);
            ResultSet resultSet = stmt.executeQuery();
            resultSet.next();
            return resultSet.getString(1).equals(hashPassword(password));
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
    public static void changePassword(String username, String newPassword){
        try {
            String query = "UPDATE users SET hash_password = ? WHERE name = ? ;";
            PreparedStatement stmt = connection.prepareStatement(query);
            stmt.setString(1, hashPassword(newPassword));
            stmt.setString(2,username);
            stmt.executeUpdate();
            System.out.println("Password changed");

        } catch (SQLException e) {
            System.out.println("Password didn't changed");
            throw new RuntimeException(e);
        }
    }
    public static void changeUsername(String username, String newUsername){
        try {
            String query = "UPDATE users SET name = ? WHERE name = ? ;";
            PreparedStatement stmt = connection.prepareStatement(query);
            stmt.setString(1,newUsername);
            stmt.setString(2,username);
            stmt.executeUpdate();
            System.out.println("username changed");

        } catch (SQLException e) {
            System.out.println("username didn't changed");
            throw new RuntimeException(e);
        }
    }
    public static void changeEmail(String username, String newEmail){
        try {
            String query = "UPDATE users SET email = ? WHERE name = ? ;";
            PreparedStatement stmt = connection.prepareStatement(query);
            stmt.setString(1,newEmail);
            stmt.setString(2,username);
            stmt.executeUpdate();
            System.out.println("email changed");

        } catch (SQLException e) {
            System.out.println("email didn't changed");
            throw new RuntimeException(e);
        }
    }
    public static void addUser(String name, String password, String email, String deviceID){
        try {
            String query = "insert into users (name, email, hash_password, deviceID) values (?, ?, ?, ?)";
            PreparedStatement stmt = connection.prepareStatement(query);
            stmt.setString(1,name);
            stmt.setString(2,email);
            stmt.setString(3, hashPassword(password));
            stmt.setString(4, deviceID);
            stmt.executeUpdate();

            System.out.println("User added");
        } catch (SQLException e) {
            System.out.println("User didn't add");
            throw new RuntimeException(e);
        }
    }
    public static void addUser(String name, String password, String email){
        try {
            String query = "insert into users (name, email, hash_password) values (?, ?, ?)";
            PreparedStatement stmt = connection.prepareStatement(query);
            stmt.setString(1,name);
            stmt.setString(2,email);
            stmt.setString(3, hashPassword(password));
            stmt.executeUpdate();

            System.out.println("User added");
        } catch (SQLException e) {
            System.out.println("User didn't add");
            throw new RuntimeException(e);
        }
    }
    public static int getDeviceID(String username){
        try {
            String query = "SELECT deviceID from users where name = ?";
            PreparedStatement stmt = connection.prepareStatement(query);
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            rs.next();
            return rs.getInt(1);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
    public static String getUsernameByID(int deviceID){
        try {
            String query = "SELECT name from users where deviceID = ?";
            PreparedStatement stmt = connection.prepareStatement(query);
            stmt.setInt(1, deviceID);
            ResultSet rs = stmt.executeQuery();
            rs.next();
            return rs.getString(1);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
    public static String getEmail(String username){
        try {
            String query = "SELECT email from users where name = ?";
            PreparedStatement stmt = connection.prepareStatement(query);
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            rs.next();
            return rs.getString(1);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public static void deleteUser(){}
    public static boolean rememberMe(String deviceId) {
        return false;
    }
    public static User getUser(String deviceID) {
        return new User("");
    }
    // word
    public static void getUserWords(){}

}
