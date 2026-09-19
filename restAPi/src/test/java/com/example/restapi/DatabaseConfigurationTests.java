package com.example.restapi;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.springframework.boot.test.context.ConfigDataApplicationContextInitializer;
import org.springframework.boot.test.context.runner.ApplicationContextRunner;
import org.springframework.mock.env.MockEnvironment;

import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.DriverManager;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class DatabaseConfigurationTests {
    @TempDir
    Path directory;

    @Test
    void loadsEnvFileAndUsesItsDatabaseCredentials() throws Exception {
        Path envFile = directory.resolve(".env");
        Files.writeString(envFile, "DB_URL=jdbc:postgresql://example.invalid:5432/test\n"
                + "DB_USERNAME=test-user\nDB_PASSWORD=test-password\n");

        new ApplicationContextRunner()
                .withInitializer(new ConfigDataApplicationContextInitializer())
                .withPropertyValues("spring.config.import=file:" + envFile + "[.properties]")
                .run(context -> {
                    assertNull(context.getStartupFailure());
                    DataBase.configure(context.getEnvironment());
                    Connection expected = mock(Connection.class);
                    try (var driver = mockStatic(DriverManager.class)) {
                        driver.when(() -> DriverManager.getConnection(
                                "jdbc:postgresql://example.invalid:5432/test",
                                "test-user", "test-password")).thenReturn(expected);
                        assertSame(expected, DataBase.connect());
                    }
                });
    }

    @Test
    void rejectsMissingOrBlankSettingsWithoutRevealingCredentials() {
        for (String setting : new String[]{"DB_URL", "DB_USERNAME", "DB_PASSWORD"}) {
            MockEnvironment environment = new MockEnvironment()
                    .withProperty("DB_URL", "jdbc:postgresql://example.invalid/test")
                    .withProperty("DB_USERNAME", "test-user")
                    .withProperty("DB_PASSWORD", "test-password");
            environment.setProperty(setting, " ");
            assertEquals("Missing required database setting: " + setting,
                    assertThrows(IllegalStateException.class,
                            () -> DataBase.configure(environment)).getMessage());
        }
        assertThrows(IllegalStateException.class, () -> DataBase.configure(new MockEnvironment()));
    }
}
