package com.example.restapi;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import static com.example.restapi.DataBase.*;

@SpringBootApplication
public class RestAPiApplication {

    public static void main(String[] args) {
        connect();
        createTables();
        SpringApplication.run(RestAPiApplication.class, args);
        cleanUpLessonTable();
    }

}
