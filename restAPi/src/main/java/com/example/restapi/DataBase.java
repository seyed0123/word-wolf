package com.example.restapi;

import com.fasterxml.uuid.UUIDGenerator;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.*;
import java.util.ArrayList;
import java.util.UUID;

public class DataBase {
    private static Connection connection;
    public static void connect() {
        try {
            connection = DriverManager.getConnection("jdbc:sqlite:DB.sqlite");
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

    public static void createTables() {
        // SQL statements for creating tables
        String createUserTable = "CREATE TABLE IF NOT EXISTS user ("
                + "id TEXT PRIMARY KEY,"
                + "username TEXT NOT NULL,"
                + "password TEXT NOT NULL,"
                + "email TEXT,"
                + "strike_level INTEGER,"
                + "xp INTEGER,"
                + "level INTEGER,"
                + "strike INTEGER,"
                + "is_practice_today BOOLEAN"
                + ");";

        String createWordTable = "CREATE TABLE IF NOT EXISTS word ("
                + "id TEXT PRIMARY KEY,"
                + "actword TEXT NOT NULL,"
                + "meaning TEXT,"
                + "wordlang TEXT,"
                + "meanLang TEXT"
                + ");";

        String createWordUserTable = "CREATE TABLE IF NOT EXISTS word_user ("
                + "wordid TEXT,"
                + "userid TEXT,"
                + "progress DOUBLE,"
                + "PRIMARY KEY (wordid, userid)"
                + ");";

        try {
            Statement stmt = connection.createStatement();
            // create new tables
            stmt.execute(createUserTable);
            stmt.execute(createWordTable);
            stmt.execute(createWordUserTable);
            System.out.println("Tables created or already exist.");
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
    }


    // user
    public static boolean usernameExist(String username) {
        try {
            String query = "SELECT EXISTS (SELECT 1 FROM user WHERE username = ?)";
            PreparedStatement stmt = connection.prepareStatement(query);
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            rs.next();
            return rs.getBoolean(1);
        } catch (SQLException e) {
            return true;
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
            String query = "select password from user where username = ?";
            PreparedStatement stmt = connection.prepareStatement(query);
            stmt.setString(1, username);
            ResultSet resultSet = stmt.executeQuery();
            resultSet.next();
            return resultSet.getString(1).equals(hashPassword(password));
        } catch (SQLException e) {
            return false;
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
    public static void addUser(String id,String username, String email, String password) throws SQLException {
            String query = "insert into user (id, username, password, email,strike_level, xp,level,strike,is_practice_today) values (?, ?, ?, ?,?, ?, ?, ?,?)";
            PreparedStatement stmt = connection.prepareStatement(query);
            stmt.setString(1, id);
            stmt.setString(2,username);
            stmt.setString(3, hashPassword(password));
            stmt.setString(4,email);
            stmt.setInt(5,0);
            stmt.setInt(6, 0);
            stmt.setInt(7,0);
            stmt.setInt(8,0);
            stmt.setBoolean(9, false);
            stmt.executeUpdate();
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
    public static User getUserByUsername(String username) throws SQLException {
        String query = "SELECT * from user where username = ?";
        PreparedStatement stmt = connection.prepareStatement(query);
        stmt.setString(1, username);
        ResultSet rs = stmt.executeQuery();
        rs.next();
        return new User(rs.getString(1),rs.getString(2),rs.getString(3),rs.getString(4),rs.getInt(5),rs.getInt(6),rs.getInt(7),rs.getInt(8),rs.getBoolean(9));
    }

    public static User getUserByID(String id) throws SQLException {
        String query = "SELECT * from user where id = ?";
        PreparedStatement stmt = connection.prepareStatement(query);
        stmt.setString(1, id);
        ResultSet rs = stmt.executeQuery();
        rs.next();
        return new User(rs.getString(1),rs.getString(2),rs.getString(3),rs.getString(4),rs.getInt(5),rs.getInt(6),rs.getInt(7),rs.getInt(8),rs.getBoolean(9));
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
