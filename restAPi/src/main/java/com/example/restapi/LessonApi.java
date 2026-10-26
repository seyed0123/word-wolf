package com.example.restapi;

import com.auth0.jwt.interfaces.DecodedJWT;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.web.bind.annotation.*;

import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

import static com.example.restapi.jsonWT.verifyToken;

@RestController
public class LessonApi {
    private final LocalDecisionService decisions;

    public LessonApi(LocalDecisionService decisions) {
        this.decisions = decisions;
    }


    public static List<Word> selectRandomWords(List<Word> words, int count) {
        return LessonGenerator.selectWords(words, count, new Random());
    }

    @GetMapping("/new_lesson")
    public String newLesson(@RequestHeader(value = "Authorization") String token) throws JsonProcessingException {
        String userId = verifyToken(token).getClaim("userid").asString();
        try {
            List<Word> userWords = DataBase.getWords(userId, 1, 500);
            List<Word> pool = new ArrayList<>(userWords);
            Set<String> pairs = new HashSet<>();
            for (Word word : userWords) {
                if (pairs.add(word.getWordLang() + ":" + word.getMeaningLang())) {
                    pool.addAll(DataBase.searchWords("", "", word.getWordLang(), word.getMeaningLang(), 1, 200));
                }
            }
            Random random = new Random();
            List<Word> selected = LessonGenerator.selectWords(userWords, 6, random);
            Lesson lesson = LessonGenerator.generateSelected(selected, pool, random, decisions.lessonPlan(selected));
            decisions.filterLessonOptions(lesson, selected);
            String data = new ObjectMapper().writeValueAsString(lesson);
            if (!lesson.getWords().isEmpty()) {
                DataBase.addLesson(lesson.getId(), LocalDateTime.now().format(
                        DateTimeFormatter.ofPattern("yyyyMMddHHmmss")), data, userId);
            }
            return data;
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public static int isOneDayApart(String date1, LocalDate date2) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");

        // Parse the string date1 to LocalDate
        LocalDate localDate1 = LocalDate.parse(date1, formatter);

        // Check if date2 is exactly one day after date1
        if(localDate1.plusDays(1).equals(date2))
            return 1;
        else if(localDate1.equals(date2))
            return 2;
        else
            return 3;
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
        String saved = DataBase.getLessonForUser(lessonId, userId);
        if (saved == null) throw new org.springframework.web.server.ResponseStatusException(
                org.springframework.http.HttpStatus.NOT_FOUND, "Lesson not found.");
        Lesson lesson = objectMapper.readValue(saved, Lesson.class);

        List<Question> questions = lesson.getQuestions();
        if (ansList.size() > questions.size() || (success && ansList.size() != questions.size())) {
            throw new org.springframework.web.server.ResponseStatusException(
                    org.springframework.http.HttpStatus.BAD_REQUEST, "Answers do not match the lesson.");
        }
        User user = DataBase.getUserByID(userId);

        // update strike level


        // update words progress & xp & todayPractice
        int xp = user.getXp();
        for (int i = 0; i < ansList.size(); i++) {
            if (ansList.get(i)) {
                xp++;
                double newP = DataBase.getProgress(userId, questions.get(i).getQWord());
                if (newP <= 90)
                    DataBase.setProgress(userId, questions.get(i).getQWord(), newP + 10);
                else{
                    DataBase.setProgress(userId, questions.get(i).getQWord(), 100);
                }
            }else{
                double newP = DataBase.getProgress(userId, questions.get(i).getQWord());
                if (newP >= 10)
                    DataBase.setProgress(userId, questions.get(i).getQWord(), newP - 10);
                else{
                    DataBase.setProgress(userId, questions.get(i).getQWord(), 0);
                }
            }
        }
        if (success){
            xp += 10;
            String date1 = user.getPracticeDate();
            LocalDate date2 = LocalDate.now();
            switch (isOneDayApart(date1, date2)) {
                case 1 -> {
                    int strike = user.getStrike();
                    user.setStrike(strike + 1);
                }
                case 3 -> user.setStrike(1);
            }
            user.setPracticeToday();
        }
        user.setXp(xp);

        DataBase.deleteLesson(lessonId);
    }
}
