package com.example.restapi;

import com.auth0.jwt.interfaces.DecodedJWT;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.web.bind.annotation.*;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.UUID;

import static com.example.restapi.jsonWT.verifyToken;

@RestController
public class LessonApi {

    @GetMapping("/new_lesson")
    public String newLesson(@RequestHeader(value = "Authorization") String token) throws JsonProcessingException {
        DecodedJWT jwt = verifyToken(token);
        String userId = jwt.getClaim("userid").asString();
        Date expireDate = jwt.getClaim("expiredate").asDate();
        //        TODO: generate a lesson for the user using it's id
//                  A temp lesson for tessing the api and client
        List<Word> words = new ArrayList<>();
        words.add(new Word("123","hello","سلام","English","Persian",0));
        words.add(new Word("123","egg","ei","English","German",0));
        List<Question> questions = new ArrayList<>();
        ArrayList<String> answers = new ArrayList<>();
        answers.add("no");
        answers.add("yes");
        answers.add("hello");
        answers.add("thanks");
        questions.add(new Question("hey",answers,2));
        questions.add(new Question("hello",answers,2));
        questions.add(new Question("hallo",answers,2));
        String id = UUID.randomUUID().toString();
        Lesson lesson = new Lesson(id,questions,words);
        ObjectMapper objectMapper = new ObjectMapper();
        String data = objectMapper.writeValueAsString(lesson);
        try {
            DataBase.addLesson(id,userId,data);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return data;
    }

    @PostMapping("/res_lesson")
    public void resLesson(@RequestHeader(value = "Authorization") String token, @RequestBody String body) throws SQLException, JsonProcessingException {
        DecodedJWT jwt = verifyToken(token);
        String userId = jwt.getClaim("userid").asString();
        Date expireDate = jwt.getClaim("expiredate").asDate();
        JSONObject obj = new JSONObject(body);
        String lessonId = obj.getString("lesson_id");
        boolean success = obj.getBoolean("success");
        JSONArray ansArray = obj.getJSONArray("ans");
        List<Boolean> ansList = new ArrayList<>();
        for (int i = 0; i < ansArray.length(); i++) {
            ansList.add(ansArray.getBoolean(i));
        }
        ObjectMapper objectMapper = new ObjectMapper();
        Lesson lesson = objectMapper.readValue(DataBase.getLesson(lessonId), Lesson.class);

//       TODO: get the lesson data from db and analyse them with the lesson results that received from, client, update the user information such as strike,xp , strike_level_ is practice today and...
//        update the progress of the words that the user study them in this lesson in word_user table
//        and every updates that is necessary for this part. Good luck :)
//
    }
}
