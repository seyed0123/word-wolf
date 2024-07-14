package com.example.restapi;

import com.auth0.jwt.interfaces.DecodedJWT;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.json.JSONObject;
import org.springframework.web.bind.annotation.*;

import java.sql.SQLException;
import java.util.Date;
import java.util.Objects;

import static com.example.restapi.DataBase.*;
import static com.example.restapi.jsonWT.verifyToken;

@RestController
public class UserApi {

    @GetMapping("/get_user")
    public String getUser(@RequestHeader(value = "Authorization") String token) throws SQLException, JsonProcessingException {
        DecodedJWT jwt = verifyToken(token);
        String userId = jwt.getClaim("userid").asString();
        Date expireDate = jwt.getClaim("expiredate").asDate();
        User user = getUserByID(userId);
        ObjectMapper objectMapper = new ObjectMapper();
        return objectMapper.writeValueAsString(user);
    }
    @PostMapping("/edit_user")
    public String editUser(@RequestHeader(value = "Authorization") String token,@RequestBody String body){
        DecodedJWT jwt = verifyToken(token);
        String userId = jwt.getClaim("userid").asString();
        Date expireDate = jwt.getClaim("expiredate").asDate();
        JSONObject ret = new JSONObject();
        try {
            User user = getUserByID(userId);
            JSONObject obj = new JSONObject(body);
            String username = obj.getString("username");
            String oldPassword = obj.getString("oldPassword");
            String newPassword = obj.getString("newPassword");
            String email = obj.getString("email");
            if(!Objects.equals(user.getUsername(), username) && !usernameExist(username)){
                changeUsername(user.getId(),username);
            }
            if(!Objects.equals(oldPassword, "") && !Objects.equals(newPassword,"") && checkPassword(user.getUsername(),oldPassword)){
                changePassword(user.getId(),newPassword);
            }if(!Objects.equals(user.getEmail(), email)){
                changeEmail(user.getId(),email);
            }
            ret.put("message","ok");
            return ret.toString();
        } catch (Exception e) {
            ret.put("message","failed due to:"+e.getMessage());
            return ret.toString();
        }
    }
}
