package com.example.restapi;

import com.fasterxml.uuid.UUIDGenerator;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashSet;
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
    public static void changePassword(String id, String newPassword){
        try {
            String query = "UPDATE user SET password = ? WHERE id = ? ;";
            PreparedStatement stmt = connection.prepareStatement(query);
            stmt.setString(1, hashPassword(newPassword));
            stmt.setString(2,id);
            stmt.executeUpdate();
            System.out.println("Password changed");

        } catch (SQLException e) {
            System.out.println("Password didn't changed");
            throw new RuntimeException(e);
        }
    }
    public static void changeUsername(String id, String newUsername){
        try {
            String query = "UPDATE user SET username = ? WHERE id = ? ;";
            PreparedStatement stmt = connection.prepareStatement(query);
            stmt.setString(1,newUsername);
            stmt.setString(2,id);
            stmt.executeUpdate();
            System.out.println("username changed");

        } catch (SQLException e) {
            System.out.println("username didn't changed");
            throw new RuntimeException(e);
        }
    }
    public static void changeEmail(String id, String newEmail){
        try {
            String query = "UPDATE user SET email = ? WHERE id = ? ;";
            PreparedStatement stmt = connection.prepareStatement(query);
            stmt.setString(1,newEmail);
            stmt.setString(2,id);
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

    public static void addWord(String ID, String actualWord, String meaning, String wordLang, String meaningLang) throws SQLException {
        String query = "insert into word (id, actword, meaning, wordlang, meanLang) values (?,?,?,?,?)";
        PreparedStatement stmt = connection.prepareStatement(query);
        stmt.setString(1, ID);
        stmt.setString(2,actualWord);
        stmt.setString(3, meaning);
        stmt.setString(4,wordLang);
        stmt.setString(5,meaningLang);
        stmt.executeUpdate();
    }
    public static void delWord(String wordId) throws SQLException {
        String query = "delete from word where id = ?";
        PreparedStatement stmt = connection.prepareStatement(query);
        stmt.setString(1, wordId);
        stmt.executeUpdate();
    }
    public static void delWordUser(String wordId,String userId) throws SQLException {
        String query = "delete from word_user where userid= ? and wordid = ?";
        PreparedStatement stmt = connection.prepareStatement(query);
        stmt.setString(1, userId);
        stmt.setString(2, wordId);
        stmt.executeUpdate();
    }

    public static void addWordUser(String wordID,String userId) throws SQLException {
        String query = "insert into word_user (wordid, userid, progress) VALUES (?,?,?)";
        PreparedStatement stmt = connection.prepareStatement(query);
        stmt.setString(1, wordID);
        stmt.setString(2,userId);
        stmt.setInt(3, 0);
        stmt.executeUpdate();
    }
    public static ArrayList<Word> getPopularWords() throws SQLException {
        String query = "SELECT \n" +
                "    *, \n" +
                "    COUNT(*) AS frequency, \n" +
                "    AVG(progress) AS avg_progress\n" +
                "FROM \n" +
                "    word_user\n" +
                "GROUP BY \n" +
                "    wordid, \n" +
                "    userid\n" +
                "ORDER BY \n" +
                "    frequency DESC;\n";
        PreparedStatement stmt = connection.prepareStatement(query);
        ResultSet rs = stmt.executeQuery();
        ArrayList<Word> ret = new ArrayList<>();
        HashSet<String> seen = new HashSet<>();
        while (rs.next()){
            String wordId = rs.getString("wordid");
            if (seen.contains(wordId)) {
                continue;
            }
            double progress = rs.getDouble("progress");
            String wordQuery = "select * from word where id = ?";
            PreparedStatement wordStmt = connection.prepareStatement(wordQuery);
            wordStmt.setString(1,wordId);
            ResultSet wordRs = wordStmt.executeQuery();
            wordRs.next();
            ret.add(new Word(wordRs.getString(1),wordRs.getString(2),wordRs.getString(3),wordRs.getString(4),wordRs.getString(5),progress));
            seen.add(wordId);
        }
        return ret;
    }


    public static ArrayList<Word> getWords(String userId) throws SQLException {
        String query = "select * from word_user where userid = ?;";
        PreparedStatement stmt = connection.prepareStatement(query);
        stmt.setString(1, userId);
        ResultSet rs = stmt.executeQuery();
        ArrayList<Word> ret = new ArrayList<>();
        while (rs.next()){
            String wordId = rs.getString("wordid");
            double progress = rs.getDouble("progress");
            String wordQuery = "select * from word where id = ?";
            PreparedStatement wordStmt = connection.prepareStatement(wordQuery);
            wordStmt.setString(1,wordId);
            ResultSet wordRs = wordStmt.executeQuery();
            wordRs.next();
            ret.add(new Word(wordRs.getString(1),wordRs.getString(2),wordRs.getString(3),wordRs.getString(4),wordRs.getString(5),progress));
        }
        return ret;
    }

    public static String getWordMean(String actWord,String meaning ,String wordLang,String meaningLang) throws SQLException {
        String query = "select id from word where actword = '"+actWord+"' and meaning = '"+meaning+"' and wordlang = '"+wordLang+"' and meanLang = '"+meaningLang+"' ";
        PreparedStatement stmt = connection.prepareStatement(query);
        ResultSet rs = stmt.executeQuery();
        if(rs.wasNull()){
            throw new SQLException();
        }
        rs.next();
        return rs.getString(1);
    }
}
