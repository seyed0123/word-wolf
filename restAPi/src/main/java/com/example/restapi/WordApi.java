package com.example.restapi;

import com.auth0.jwt.interfaces.DecodedJWT;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.json.JSONObject;
import org.springframework.web.bind.annotation.*;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.UUID;

import static com.example.restapi.DataBase.*;
import static com.example.restapi.jsonWT.verifyToken;

@RestController
public class WordApi {

    @GetMapping("/get_word")
    public String getWords(@RequestHeader(value = "Authorization") String token) throws SQLException, JsonProcessingException {
        DecodedJWT jwt = verifyToken(token);
        String userId = jwt.getClaim("userid").asString();
        Date expireDate = jwt.getClaim("expiredate").asDate();
        ArrayList<Word> words = DataBase.getWords(userId);
        ObjectMapper objectMapper = new ObjectMapper();
        return objectMapper.writeValueAsString(words);
    }

    @GetMapping("/get_popular_word")
    public String getPopularWords() throws SQLException, JsonProcessingException {
        ArrayList<Word> words = DataBase.getPopularWords();
        ObjectMapper objectMapper = new ObjectMapper();
        return objectMapper.writeValueAsString(words);
    }

    @PostMapping("/add_word")
    public String addWord(@RequestHeader(value = "Authorization") String token, @RequestBody String body) {
        DecodedJWT jwt = verifyToken(token);
        String userId = jwt.getClaim("userid").asString();
        Date expireDate = jwt.getClaim("expiredate").asDate();
        JSONObject ret = new JSONObject();
        JSONObject obj = new JSONObject(body);
        String word = obj.getString("word");
        String wordMeaning = obj.getString("wordMeaning");
        String wordLang = obj.getString("wordLang");
        String meaningLang = obj.getString("meaningLang");
        String id = null;
        try{
            id = DataBase.getWordMean(word,wordMeaning,wordLang,meaningLang);
        }catch (SQLException e){
            id = UUID.randomUUID().toString();
            try {
                DataBase.addWord(id,word,wordMeaning,wordLang,meaningLang);
            } catch (SQLException ex) {
                ret.put("message","failed due to:"+e.getMessage());
                return ret.toString();
            }
        }
        try {
            addWordUser(id,userId);
        } catch (SQLException e) {
            ret.put("message","failed due to:"+e.getMessage());
            return ret.toString();
        }
        ret.put("message","ok");
        return ret.toString();
    }

    @PostMapping("/del_word")
    public String delWord(@RequestHeader(value = "Authorization") String token, @RequestBody String body){
        DecodedJWT jwt = verifyToken(token);
        String userId = jwt.getClaim("userid").asString();
        Date expireDate = jwt.getClaim("expiredate").asDate();
        JSONObject ret = new JSONObject();
        JSONObject obj = new JSONObject(body);
        String wordId = obj.getString("id");
        try {
//            DataBase.delWord(wordId);
            delWordUser(wordId,userId);
        } catch (SQLException e) {
            ret.put("message","failed due to:"+e.getMessage());
            return ret.toString();
        }
        ret.put("message","ok");
        return ret.toString();
    }
}
