package com.example.restapi;

import com.auth0.jwt.interfaces.DecodedJWT;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.json.JSONObject;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

import java.sql.SQLException;
import java.util.Date;

import static com.example.restapi.DataBase.getUserByID;
import static com.example.restapi.jsonWT.verifyToken;

@RestController
public class UserApi {

    @GetMapping("/get_user")
    public String getWithHeader(@RequestHeader(value = "Authorization") String token) throws SQLException, JsonProcessingException {
        DecodedJWT jwt = verifyToken(token);
        String userId = jwt.getClaim("userid").asString();
        Date expireDate = jwt.getClaim("expiredate").asDate();
        User user = getUserByID(userId);
        ObjectMapper objectMapper = new ObjectMapper();
        return objectMapper.writeValueAsString(user);
    }
}
