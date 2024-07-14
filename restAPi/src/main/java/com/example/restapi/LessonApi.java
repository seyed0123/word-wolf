package com.example.restapi;

import com.auth0.jwt.interfaces.DecodedJWT;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.web.bind.annotation.*;

import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

import static com.example.restapi.jsonWT.verifyToken;

@RestController
public class LessonApi {

    public static List<Word> selectRandomWords(List<Word> userWords, int numberOfWords) {
        List<Word> selectedWords = new ArrayList<>();
        Random random = new Random();

        numberOfWords = Math.min(numberOfWords, userWords.size());

        // Calculate the total weight
        double totalWeight = 0;
        for (Word word : userWords) {
            totalWeight += getWeight(word);
        }

        // Select words based on their weights
        for (int i = 0; i < numberOfWords; i++) {
            double r = random.nextDouble() * totalWeight;
            double cumulativeWeight = 0;
            for (Word word : userWords) {
                cumulativeWeight += getWeight(word);
                if (r <= cumulativeWeight) {
                    selectedWords.add(word);
                    totalWeight -= getWeight(word); // Decrease the total weight by the weight of the selected word
                    userWords.remove(word); // Remove the selected word to avoid duplicates
                    break;
                }
            }
        }

        return selectedWords;
    }

    private static double getWeight(Word word) {
        // Define your weighting mechanism
        if (word.getProgress() < 50) {
            return 10; // High weight for low progress
        } else {
            return 1;  // Low weight for high progress
        }
    }

    @GetMapping("/new_lesson")
    public String newLesson(@RequestHeader(value = "Authorization") String token) throws JsonProcessingException {
        DecodedJWT jwt = verifyToken(token);
        String userId = jwt.getClaim("userid").asString();
        Date expireDate = jwt.getClaim("expiredate").asDate();
        try {
            List<Word> userWords = DataBase.getWords(userId);
            Random random = new Random();
            int questionWithoutShow = random.nextInt(3);
            int WordNumber = 3 + questionWithoutShow;
            Collections.shuffle(userWords);
//            select words
            List<Word> QWords = selectRandomWords(userWords,WordNumber);
            List<Word> questionWithoutShowWords = new ArrayList<>(QWords);

            for (int i = 0; i < questionWithoutShow; i++) {
                int raInd = random.nextInt(QWords.size());
                QWords.remove(raInd);
            }

            List<Question> questions = new ArrayList<>();

            for (Word questionWithoutShowWord : questionWithoutShowWords) {
                // select 3 wrong answers
                HashSet<Integer> chossen = new HashSet<>();
                ArrayList<String> answers = new ArrayList<>();
                ArrayList<Word> ans_option = DataBase.searchWords("", "", "Any", questionWithoutShowWord.getMeaningLang());
                ans_option.remove(questionWithoutShowWord);
                int correctAnsIndex = (random.nextInt(4));
                for (int j = 0; j < 4; j++) {
                    if (j == correctAnsIndex) {
                        answers.add(questionWithoutShowWord.getMeaning());
                    } else {
                        int rand = (random.nextInt(ans_option.size()));
                        if (rand != correctAnsIndex && !chossen.contains(rand)) {
                            chossen.add(rand);
                            answers.add(ans_option.get(rand).getMeaning());
                        } else j--;
                    }
                }
                questions.add(new Question("What is meaning of \"" + questionWithoutShowWord.getActualWord() + "\" ?", answers, correctAnsIndex,questionWithoutShowWord.getID()));
            }

            LocalDateTime now = LocalDateTime.now();
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
            String formattedDateTime = now.format(formatter);
            String id = UUID.randomUUID().toString();
            Lesson lesson = new Lesson(id,questions,QWords);
            ObjectMapper objectMapper = new ObjectMapper();
            String data = objectMapper.writeValueAsString(lesson);

            DataBase.addLesson(id,formattedDateTime,data,userId);
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
        Lesson lesson = objectMapper.readValue(DataBase.getLesson(lessonId), Lesson.class);

        List<Question> questions = lesson.getQuestions();
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
            }else{
                double newP = DataBase.getProgress(userId, questions.get(i).getQWord());
                if (newP >= 10)
                    DataBase.setProgress(userId, questions.get(i).getQWord(), newP - 10);
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
