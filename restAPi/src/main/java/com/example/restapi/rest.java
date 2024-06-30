package com.example.restapi;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class rest {

    @GetMapping("/hello")
    public String helloGet() {
        return "{text : Hello, GET request2!}";
    }

    @PostMapping("/hello")
    public String helloPost(@RequestBody String message) {
        return "Hello, POST request Message: " + message;
    }
}
