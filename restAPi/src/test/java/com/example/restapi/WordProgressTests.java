package com.example.restapi;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

import static org.junit.jupiter.api.Assertions.assertEquals;

@EnabledIfEnvironmentVariable(named = "PROGRESS_TEST_DB_URL", matches = ".+")
class WordProgressTests {
    @Test
    void catchesUpMissedDaysOnceAndProtectsNewWordsAndFutureDates() throws Exception {
        try (Connection connection = DriverManager.getConnection(
                System.getenv("PROGRESS_TEST_DB_URL"), "progress_test", "progress_test");
             Statement sql = connection.createStatement()) {
            // Session-local table: this test never modifies application data.
            sql.execute("CREATE TEMP TABLE word_user (wordid TEXT, progress DOUBLE PRECISION, "
                    + "progress_updated_on DATE NOT NULL DEFAULT CURRENT_DATE)");
            sql.execute("INSERT INTO word_user VALUES "
                    + "('missed', 80, CURRENT_DATE - 3),"
                    + "('low', 3, CURRENT_DATE - 10),"
                    + "('zero', 0, CURRENT_DATE - 1),"
                    + "('future', 50, CURRENT_DATE + 1)");
            sql.execute("INSERT INTO word_user (wordid, progress) VALUES ('new', 30)");

            DataBase.catchUpWordProgress(connection);
            assertProgress(sql, "missed", 74);
            assertProgress(sql, "low", 0);
            assertProgress(sql, "zero", 0);
            assertProgress(sql, "new", 30);
            assertProgress(sql, "future", 50);
            try (ResultSet result = sql.executeQuery("SELECT count(*) FROM word_user "
                    + "WHERE progress_updated_on < CURRENT_DATE")) {
                result.next();
                assertEquals(0, result.getInt(1));
            }

            // Re-running the catch-up uses the saved date and does not charge twice.
            DataBase.catchUpWordProgress(connection);
            assertProgress(sql, "missed", 74);
            sql.execute("UPDATE word_user SET progress_updated_on = CURRENT_DATE - 1 "
                    + "WHERE wordid = 'missed'");
            DataBase.catchUpWordProgress(connection);
            assertProgress(sql, "missed", 72);
        }
    }

    private void assertProgress(Statement sql, String id, double expected) throws Exception {
        try (ResultSet result = sql.executeQuery("SELECT progress FROM word_user WHERE wordid = '" + id + "'")) {
            result.next();
            assertEquals(expected, result.getDouble(1));
        }
    }
}
