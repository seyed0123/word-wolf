package com.example.restapi;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class DataBase {
    private static Connection connection;

    public static void connect() {
        try {
            Class.forName("org.postgresql.Driver");
            connection = DriverManager.getConnection("jdbc:postgresql://postgres_db/worldWolf", "worldWolfAdm", "r4lNXKcL3GMh");
            System.out.println("Database connected");
        } catch (SQLException e) {
            System.err.println(e.getMessage());
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }
    }

    public static void close() {
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
        String createUserTable = "CREATE TABLE IF NOT EXISTS person ("
                + "id TEXT PRIMARY KEY,"
                + "username TEXT NOT NULL,"
                + "password TEXT NOT NULL,"
                + "email TEXT,"
                + "strike_level INTEGER,"
                + "xp INTEGER,"
                + "level INTEGER,"
                + "strike INTEGER,"
                + "is_practice_today TEXT"
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
                + "progress DOUBLE PRECISION,"
                + "PRIMARY KEY (wordid, userid),"
                + "FOREIGN KEY (wordid) REFERENCES word(id) ON DELETE CASCADE ON UPDATE CASCADE,"
                + "FOREIGN KEY (userid) REFERENCES person(id) ON DELETE CASCADE ON UPDATE CASCADE"
                + ");";

        String createLessonTable = "CREATE TABLE IF NOT EXISTS lesson("
                + "id TEXT PRIMARY KEY,"
                + "userid TEXT,"
                + "date TEXT,"
                + "data TEXT,"
                + "FOREIGN KEY (userid) REFERENCES person(id) ON DELETE CASCADE ON UPDATE CASCADE"
                + ");";

        try {
            connect();
            Statement stmt = connection.createStatement();
            // Create new tables
            stmt.execute(createUserTable);
            stmt.execute(createWordTable);
            stmt.execute(createWordUserTable);
            stmt.execute(createLessonTable);
            System.out.println("Tables created or already exist.");
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }finally {
            close();
        }
    }

    // user
    public static boolean usernameExist(String username) {
        try {
            connect();
            String query = "SELECT EXISTS (SELECT 1 FROM person WHERE username = ?)";
            PreparedStatement stmt = connection.prepareStatement(query);
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            rs.next();
            return rs.getBoolean(1);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }finally {
            close();
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

    public static boolean checkPassword(String username, String password) {
        try {
            connect();
            String query = "select password from person where username = ?";
            PreparedStatement stmt = connection.prepareStatement(query);
            stmt.setString(1, username);
            ResultSet resultSet = stmt.executeQuery();
            resultSet.next();
            return resultSet.getString(1).equals(hashPassword(password));
        } catch (SQLException e) {
            return false;
        }finally {
            close();
        }
    }

    public static void changePassword(String id, String newPassword) {
        try {
            connect();
            String query = "UPDATE person SET password = ? WHERE id = ? ;";
            PreparedStatement stmt = connection.prepareStatement(query);
            stmt.setString(1, hashPassword(newPassword));
            stmt.setString(2, id);
            stmt.executeUpdate();

        } catch (SQLException e) {
            throw new RuntimeException(e);
        }finally {
            close();
        }
    }

    public static void changeUsername(String id, String newUsername) {
        try {
            connect();
            String query = "UPDATE person SET username = ? WHERE id = ? ;";
            PreparedStatement stmt = connection.prepareStatement(query);
            stmt.setString(1, newUsername);
            stmt.setString(2, id);
            stmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }finally {
            close();
        }
    }

    public static void changeEmail(String id, String newEmail) {
        try {
            connect();
            String query = "UPDATE person SET email = ? WHERE id = ? ;";
            PreparedStatement stmt = connection.prepareStatement(query);
            stmt.setString(1, newEmail);
            stmt.setString(2, id);
            stmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }finally {
            close();
        }
    }

    public static void addUser(String id, String username, String email, String password) {
        try {
            connect();
            String query = "insert into person (id, username, password, email,strike_level, xp,level,strike,is_practice_today) values (?, ?, ?, ?,?, ?, ?, ?,?)";
            LocalDate yesterday = LocalDate.now().minusDays(1);
            String formattedDate = yesterday.format(DateTimeFormatter.ofPattern("yyyyMMdd"));

            PreparedStatement stmt = connection.prepareStatement(query);
            stmt.setString(1, id);
            stmt.setString(2, username);
            stmt.setString(3, hashPassword(password));
            stmt.setString(4, email);
            stmt.setInt(5, 0);
            stmt.setInt(6, 0);
            stmt.setInt(7, 0);
            stmt.setInt(8, 0);
            stmt.setString(9, formattedDate);
            stmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }finally {
            close();
        }
    }

    public static User getUserByUsername(String username) {
        try {
            connect();
            String query = "SELECT * from person where username = ?";
            PreparedStatement stmt = connection.prepareStatement(query);
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            rs.next();
            return new User(rs.getString(1), rs.getString(2), rs.getString(3),
                    rs.getString(4), rs.getInt(5), rs.getInt(6), rs.getInt(7),
                    rs.getInt(8), rs.getString(9));
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }finally {
            close();
        }
    }

    public static User getUserByID(String id) {
        try {
            connect();
            String query = "SELECT * from person where id = ?";
            PreparedStatement stmt = connection.prepareStatement(query);
            stmt.setString(1, id);
            ResultSet rs = stmt.executeQuery();
            rs.next();
            return new User(rs.getString(1), rs.getString(2), rs.getString(3),
                    rs.getString(4), rs.getInt(5), rs.getInt(6), rs.getInt(7),
                    rs.getInt(8), rs.getString(9));
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }finally {
            close();
        }
    }

    public static String getEmail(String username) {
        try {
            connect();
            String query = "SELECT email from person where name = ?";
            PreparedStatement stmt = connection.prepareStatement(query);
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            rs.next();
            return rs.getString(1);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }finally {
            close();
        }
    }

    public static void deleteUser() {
    }

    // public static boolean rememberMe(String deviceId) {return false;}
    public static void setIsPracticeToday(String userID, String dateStr) {
        try {
            connect();
            String query = "UPDATE person SET is_practice_today = ? WHERE id = ? ;";
            PreparedStatement stmt = connection.prepareStatement(query);
            stmt.setString(1, dateStr);
            stmt.setString(2, userID);
            stmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }finally {
            close();
        }
    }

    public static String getIsPracticeToday(String userID) throws SQLException {
        try {
            connect();
            String query = "SELECT is_practice_today from person where name = ?";
            PreparedStatement stmt = connection.prepareStatement(query);
            stmt.setString(1, userID);
            ResultSet rs = stmt.executeQuery();
            rs.next();
            return rs.getString(1);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }finally {
            close();
        }
    }

    public static void setXp(String userID, int xp) {
        try {
            connect();
            String query = "UPDATE person SET xp = ? WHERE id = ? ;";
            PreparedStatement stmt = connection.prepareStatement(query);
            stmt.setInt(1, xp);
            stmt.setString(2, userID);
            stmt.executeUpdate();

            // update level
            query = "UPDATE person SET level = ? WHERE id = ? ;";
            stmt = connection.prepareStatement(query);
            stmt.setInt(1, (int) Math.log10(xp) + 1);
            stmt.setString(2, userID);
            stmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }finally {
            close();
        }
    }

    public static void setStrike(String userID, int strike) {
        try {
            connect();
            String query = "UPDATE person SET strike = ? WHERE id = ? ;";
            PreparedStatement stmt = connection.prepareStatement(query);
            stmt.setInt(1, strike);
            stmt.setString(2, userID);
            stmt.executeUpdate();

            // update level
            query = "UPDATE person SET strike_level = ? WHERE id = ? ;";
            stmt = connection.prepareStatement(query);
            stmt.setInt(1, (int) (Math.log(strike) / Math.log(2)));
            stmt.setString(2, userID);
            stmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }finally {
            close();
        }
    }

    public static void setProgress(String userID, String wordID, double progress) {
        try {
            connect();
            String query = "UPDATE word_user SET progress = ? WHERE wordid = ? AND userid = ? ;";
            PreparedStatement stmt = connection.prepareStatement(query);
            stmt.setDouble(1, progress);
            stmt.setString(2, wordID);
            stmt.setString(3, userID);
            stmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }finally {
            close();
        }
    }

    public static double getProgress(String userID, String wordID) {
        try {
            connect();
            String query = "SELECT progress from word_user WHERE wordid = ? AND userid = ? ";
            PreparedStatement stmt = connection.prepareStatement(query);
            stmt.setString(1, wordID);
            stmt.setString(2, userID);
            ResultSet rs = stmt.executeQuery();
            rs.next();
            return rs.getDouble(1);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }finally {
            close();
        }
    }

    // word
    public static void addWord(String ID, String actualWord, String meaning, String wordLang, String meaningLang) throws SQLException {
        connect();
        String query = "insert into word (id, actword, meaning, wordlang, meanLang) values (?,?,?,?,?)";
        PreparedStatement stmt = connection.prepareStatement(query);
        stmt.setString(1, ID);
        stmt.setString(2, actualWord);
        stmt.setString(3, meaning);
        stmt.setString(4, wordLang);
        stmt.setString(5, meaningLang);
        stmt.executeUpdate();
        close();
    }

    public static void delWord(String wordId) throws SQLException {
        connect();
        String query = "delete from word where id = ?";
        PreparedStatement stmt = connection.prepareStatement(query);
        stmt.setString(1, wordId);
        stmt.executeUpdate();
        close();
    }

    public static void delWordUser(String wordId, String userId) throws SQLException {
        connect();
        String query = "delete from word_user where userid= ? and wordid = ?";
        PreparedStatement stmt = connection.prepareStatement(query);
        stmt.setString(1, userId);
        stmt.setString(2, wordId);
        stmt.executeUpdate();
        close();
    }

    public static void addWordUser(String wordID, String userId) throws SQLException {
        connect();
        String query = "insert into word_user (wordid, userid, progress) VALUES (?,?,?)";
        PreparedStatement stmt = connection.prepareStatement(query);
        stmt.setString(1, wordID);
        stmt.setString(2, userId);
        stmt.setInt(3, 0);
        stmt.executeUpdate();
        close();
    }

    public static ArrayList<Word> getPopularWords(int page,int size) throws SQLException {
        connect();
        int offset = (page - 1) * size;
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
                "    frequency DESC LIMIT ? OFFSET ?;\n ";
        PreparedStatement stmt = connection.prepareStatement(query);
        stmt.setInt(1, size);
        stmt.setInt(2, offset);
        ResultSet rs = stmt.executeQuery();
        ArrayList<Word> ret = new ArrayList<>();
        HashSet<String> seen = new HashSet<>();
        while (rs.next()) {
            String wordId = rs.getString("wordid");
            if (seen.contains(wordId)) {
                continue;
            }
            double progress = rs.getDouble("progress");
            String wordQuery = "select * from word where id = ?";
            PreparedStatement wordStmt = connection.prepareStatement(wordQuery);
            wordStmt.setString(1, wordId);
            ResultSet wordRs = wordStmt.executeQuery();
            wordRs.next();
            ret.add(new Word(wordRs.getString(1), wordRs.getString(2), wordRs.getString(3), wordRs.getString(4), wordRs.getString(5), progress));
            seen.add(wordId);
        }
        close();
        return ret;
    }

    public static ArrayList<Word> getWords(String userId, int page, int size) throws SQLException {
        int offset = (page - 1) * size; // Calculate offset
        connect();
        // Modify the query to include LIMIT and OFFSET for pagination
        String query = "SELECT * FROM word_user WHERE userid = ? LIMIT ? OFFSET ?;";
        PreparedStatement stmt = connection.prepareStatement(query);
        stmt.setString(1, userId);
        stmt.setInt(2, size);     // Limit the number of rows
        stmt.setInt(3, offset);   // Offset to skip rows for pagination
        ResultSet rs = stmt.executeQuery();

        ArrayList<Word> ret = new ArrayList<>();
        while (rs.next()) {
            String wordId = rs.getString("wordid");
            double progress = rs.getDouble("progress");

            String wordQuery = "SELECT * FROM word WHERE id = ?";
            PreparedStatement wordStmt = connection.prepareStatement(wordQuery);
            wordStmt.setString(1, wordId);
            ResultSet wordRs = wordStmt.executeQuery();
            if (wordRs.next()) {
                ret.add(new Word(
                        wordRs.getString(1),
                        wordRs.getString(2),
                        wordRs.getString(3),
                        wordRs.getString(4),
                        wordRs.getString(5),
                        progress
                ));
            }
        }
        close();
        return ret;
    }

    public static String getWordMean(String actWord, String meaning, String wordLang, String meaningLang) throws SQLException {
        connect();
        String query = "select id from word where actword = '" + actWord + "' and meaning = '" + meaning + "' and wordlang = '" + wordLang + "' and meanLang = '" + meaningLang + "' ";
        PreparedStatement stmt = connection.prepareStatement(query);
        ResultSet rs = stmt.executeQuery();
        rs.next();
        close();
        return rs.getString(1);
    }

    public static ArrayList<Word> searchWords(String word, String wordMeaning, String wordLang, String meaningLang, int page, int size) {
        int offset = (page - 1) * size;
        ArrayList<Word> result = new ArrayList<>();
        connect();
        String query = "SELECT * FROM word WHERE " +
                "(? IS NULL OR actword LIKE ?) " +
                "AND (? IS NULL OR meaning LIKE ?) " +
                "AND (? IS NULL OR wordLang = ?) " +
                "AND (? IS NULL OR meanLang = ?) LIMIT ? OFFSET ?;";

        try {

            word = word != null && word.isEmpty() ? null : word;
            wordMeaning = wordMeaning != null && wordMeaning.isEmpty() ? null : wordMeaning;
            wordLang = wordLang != null && wordLang.equals("Any") ? null : wordLang;
            meaningLang = meaningLang != null && meaningLang.equals("Any") ? null : meaningLang;


            PreparedStatement pstmt = connection.prepareStatement(query);
            pstmt.setString(1, word);
            pstmt.setString(2, word != null ? "%" + word + "%" : null);
            pstmt.setString(3, wordMeaning);
            pstmt.setString(4, wordMeaning != null ? "%" + wordMeaning + "%" : null);
            pstmt.setString(5, wordLang);
            pstmt.setString(6, wordLang);
            pstmt.setString(7, meaningLang);
            pstmt.setString(8, meaningLang);
            pstmt.setInt(9, size);
            pstmt.setInt(10, offset);

            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                result.add(new Word(rs.getString(1), rs.getString(2), rs.getString(3), rs.getString(4), rs.getString(5), 0));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        close();
        return result;
    }

    //    lesson
    public static void addLesson(String lessonId, String date, String data, String userid) throws SQLException {
        connect();
        String query = "insert into lesson (id, date, data, userid) VALUES (?,?,?,?);";
        PreparedStatement stmt = connection.prepareStatement(query);
        stmt.setString(1, lessonId);
        stmt.setString(2, date);
        stmt.setString(3, data);
        stmt.setString(4, userid);
        stmt.executeUpdate();
        close();
    }

    public static String getLesson(String lessonId) throws SQLException {
        connect();
        String query = "select data from lesson where id = ?";
        PreparedStatement stmt = connection.prepareStatement(query);
        stmt.setString(1, lessonId);
        ResultSet rs = stmt.executeQuery();
        rs.next();
        close();
        return rs.getString(1);
    }

    public static void deleteLesson(String lessonId) throws SQLException {
        connect();
        String query = "delete from lesson where id = ?;";
        PreparedStatement stmt = connection.prepareStatement(query);
        stmt.setString(1, lessonId);
        stmt.executeUpdate();
        close();
    }

    public static void cleanUpLessonTable() {

        System.out.println("Unit ready to clean up the database");


        Runnable task = () -> {
            System.out.println("Starting to Clean up the DataBase.");
            LocalDateTime now = LocalDateTime.now();
            LocalDateTime twoHoursBefore = now.minusHours(2);

            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

            try {
                connect();
                String sql = "DELETE FROM lesson WHERE date < ?";
                try (PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
                    preparedStatement.setString(1, twoHoursBefore.format(formatter));
                    preparedStatement.executeUpdate();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }finally {
                close();
            }
            System.out.println("DataBase cleaned.");

            System.out.println("Decreasing all the word progresses.");
            try {
                connect();
                String sql = "update word_user set progress = progress - 2 where progress >= 2 ;";
                try (PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
                    preparedStatement.executeUpdate();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }finally {
                close();
            }
            System.out.println("All progresses updated :)");
        };


        ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime nextRun = now.withHour(0).withMinute(0).withSecond(0).withNano(0);
        if (now.compareTo(nextRun) >= 0) {
            nextRun = nextRun.plusDays(1);
        }
        System.out.println("NEXT run:" + nextRun);

        long initialDelay = now.until(nextRun, TimeUnit.SECONDS.toChronoUnit());
        long period = TimeUnit.DAYS.toSeconds(1);

        scheduler.scheduleAtFixedRate(task, initialDelay, period, TimeUnit.SECONDS);
    }
}
