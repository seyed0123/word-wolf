package com.example.restapi;

import com.example.restapi.User;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

@RestController
public class UserController {

    @CrossOrigin(origins = "*")
    @GetMapping("/user")
    public String getUser() throws JsonProcessingException {
        User user = new User(
                "1",
                "seyed13",
                "123",
                "seyed123ali123",
                "Persian",
                200,
                10,
                150,
                true,
                2,
                "pro"
        );
        ObjectMapper objectMapper = new ObjectMapper();
        String jsonString = objectMapper.writeValueAsString(user);
        return jsonString;
    }
}