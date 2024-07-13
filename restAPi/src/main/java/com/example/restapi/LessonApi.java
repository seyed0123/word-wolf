package com.example.restapi;

import com.auth0.jwt.interfaces.DecodedJWT;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.web.bind.annotation.*;

import java.sql.SQLException;
import java.text.SimpleDateFormat;
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
        try {
            List<Word> userWords = DataBase.getWords(userId);
            List<Word> QWords = new ArrayList<>();
            int selectWordProgress = 80;
            List<Question> questions = new ArrayList<>();
            int questionNumber = 6;

            // select word
            for (int i = 0; i < questionNumber; i++) {
                for (int j = 0; j < userWords.size(); j++) {
                    if (userWords.get(j).getProgress() >= selectWordProgress) {
                        QWords.add(userWords.get(j));
                        break;
                    } else if (userWords.size() == j - 1) {
                        selectWordProgress -= 20;
                        i = -1;
                    }
                }
                if (selectWordProgress < 0) break;
            }

            for (int i = 0; i < QWords.size(); i++) {
                // select 3 wrong answers
                ArrayList<String> answers = new ArrayList<>();
                int correctAnsIndex = (int) ((Math.random() * 10)) % 4;
                for (int j = 0; j < 4; j++) {
                    if (j == correctAnsIndex) {
                        answers.add(QWords.get(i).getMeaning());
                    } else {
                        int rand = (int) (Math.random() * userWords.size());
                        if (rand != correctAnsIndex) answers.add(userWords.get(rand).getMeaning());
                        else j--;
                    }
                }
                questions.add(new Question("What is meaning of \"" + QWords.get(i).getActualWord() + "\" ?", answers, correctAnsIndex));
            }

            String id = UUID.randomUUID().toString();
            Lesson lesson = new Lesson(id,questions,QWords);
            ObjectMapper objectMapper = new ObjectMapper();
            String data = objectMapper.writeValueAsString(lesson);

            DataBase.addLesson(id,userId,data);
            return data;
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
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

        List<Word> words = lesson.getWords();
        User user = DataBase.getUserByID(userId);
        // update strike level
        Date date1 = DataBase.getIsPracticeToday();
        Date date2 = new Date();
        SimpleDateFormat fmt = new SimpleDateFormat("yyyyMMdd");
        int fmt1 = Integer.parseInt(fmt.format(date1));
        int fmt2 = Integer.parseInt(fmt.format(date2));
        if(fmt2 - fmt1 == 1){
            int strike = user.getStrike();
            DataBase.setStrike(strike + 1);
        }

        // update words progress & xp & todayPractice
        int xp = 0;
        for (int i = 0; i < ansList.size(); i++) {
            if (ansList.get(i)) {
                xp++;
                int newP = DataBase.getProgress(userId, words.get(i).getID());
                if (newP < 100)
                    DataBase.setProgress(userId, words.get(i).getID(), newP + 10);
            }
        }
        if (success) xp += 10;
        user.setXp(xp);
        user.setPracticeToday();
    }
}
