package com.example.restapi;

import com.auth0.jwt.interfaces.DecodedJWT;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.json.JSONObject;
import org.springframework.web.bind.annotation.*;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.Objects;
import java.util.UUID;

import static com.example.restapi.DataBase.*;
import static com.example.restapi.jsonWT.verifyToken;

@RestController
public class WordApi {

    @GetMapping("/get_word")
    public String getWords(
            @RequestHeader(value = "Authorization") String token,
            @RequestParam(defaultValue = "1") int page,       // Default to first page
            @RequestParam(defaultValue = "10") int size       // Default size is 10
    ) throws SQLException, JsonProcessingException {
        DecodedJWT jwt = verifyToken(token);
        String userId = jwt.getClaim("userid").asString();
        Date expireDate = jwt.getClaim("expiredate").asDate();
        ArrayList<Word> words = DataBase.getWords(userId, page, size);
        ObjectMapper objectMapper = new ObjectMapper();
        return objectMapper.writeValueAsString(words);
    }

    @GetMapping("/get_popular_word")
    public String getPopularWords(
            @RequestParam(defaultValue = "1") int page,       // Default to first page
            @RequestParam(defaultValue = "10") int size
    ) throws SQLException, JsonProcessingException {
        ArrayList<Word> words = DataBase.getPopularWords(page, size);
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
            if(Objects.equals(id, "") || id == null){
                throw new SQLException();
            }
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

    @PostMapping("/search")
    public String search(@RequestHeader(value = "Authorization") String token, @RequestBody String body,
                 @RequestParam(defaultValue = "1") int page,       // Default to first page
                 @RequestParam(defaultValue = "10") int size
    ) throws SQLException, JsonProcessingException {
        DecodedJWT jwt = verifyToken(token);
        String userId = jwt.getClaim("userid").asString();
        Date expireDate = jwt.getClaim("expiredate").asDate();
        JSONObject ret = new JSONObject();
        JSONObject obj = new JSONObject(body);
        String word = obj.getString("word");
        String wordMeaning = obj.getString("wordMeaning");
        String wordLang = obj.getString("wordLang");
        String meaningLang = obj.getString("meaningLang");

        ArrayList<Word> words = DataBase.searchWords(word, wordMeaning, wordLang, meaningLang,page,size);
        ObjectMapper objectMapper = new ObjectMapper();
        return objectMapper.writeValueAsString(words);
    }
}
