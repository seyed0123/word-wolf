package com.example.restapi;

import org.json.JSONException;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.json.JSONObject;

import java.sql.SQLException;
import java.util.UUID;

import static com.example.restapi.DataBase.*;
import static com.example.restapi.jsonWT.createToken;

@RestController
public class Login {

    @PostMapping("/login")
    public String login(@RequestBody String body) {
        JSONObject ret = new JSONObject();
        JSONObject obj = new JSONObject(body);
        try {
            String username = obj.getString("username");
            String password = obj.getString("password");
            if(!usernameExist(username)){
                ret.put("message","Username or password incorrect");
                return ret.toString();
            }else if(!checkPassword(username,password)){
                ret.put("message","Username or password incorrect");
                return ret.toString();
            }
            try {
                ret.put("message","ok");
                ret.put("token",createToken(getUserByUsername(username).getId()));
            } catch (SQLException e) {
                ret.put("message","login failed");
            }
            return ret.toString();
        } catch (JSONException e) {
            ret.put("message","Username or password incorrect");
            return ret.toString();
        }
    }

    @PostMapping("/sign_up")
    public String  signUp(@RequestBody String body){
        JSONObject ret = new JSONObject();
        JSONObject obj = new JSONObject(body);
        String username = obj.getString("username");
        String password = obj.getString("password");
        String email = obj.getString("email");
        if(usernameExist(username)){
            ret.put("message","Username already exist");
            return ret.toString();
        }
        try {
            String id = UUID.randomUUID().toString();
            addUser(id,username,email,password);
            ret.put("message","ok");
            ret.put("token",createToken(id));
            return ret.toString();
        } catch (SQLException e) {
            ret.put("message","failed due to:"+e.getMessage());
            return ret.toString();
        }
    }
}
