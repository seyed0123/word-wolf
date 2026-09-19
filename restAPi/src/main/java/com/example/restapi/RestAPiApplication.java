package com.example.restapi;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import static com.example.restapi.DataBase.*;

@SpringBootApplication
public class RestAPiApplication {

    public static void main(String[] args) {
        SpringApplication application = new SpringApplication(RestAPiApplication.class);
        application.addInitializers(context -> {
            DataBase.configure(context.getEnvironment());
            createTables();
        });
        application.run(args);
        cleanUpLessonTable();
    }

}
