package com.example.restapi;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.*;
import java.time.Duration;
import java.util.*;

/** Optional local advice. Failure must not prevent vocabulary entry or practice. */
@Service
public class LocalDecisionService {
    private static final Logger log = LoggerFactory.getLogger(LocalDecisionService.class);
    private static final Set<String> MODES = Set.of("review", "forward", "reverse");
    private final URI base;
    private final Duration timeout;
    private final HttpClient client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(2)).build();
    private final ObjectMapper mapper = new ObjectMapper();

    public LocalDecisionService(@Value("${local.decision.url:}") String url,
                                @Value("${local.decision.timeout-seconds:8}") int seconds) {
        base = url.isBlank() ? null : URI.create(url.replaceAll("/+$", ""));
        if (base != null && (!"http".equals(base.getScheme()) || base.getHost() == null ||
                !Set.of("localhost", "127.0.0.1", "[::1]", "julia", "host.docker.internal").contains(base.getHost()) ||
                base.getRawUserInfo() != null || base.getRawQuery() != null || base.getRawFragment() != null ||
                (base.getPath() != null && !base.getPath().isEmpty()))) {
            throw new IllegalArgumentException("Decision URL must be a local HTTP origin");
        }
        timeout = Duration.ofSeconds(Math.max(1, Math.min(10, seconds)));
    }

    public Map<String, Object> review(String word, String from, String to, String meaning) {
        JsonNode result = post("/review", Map.of("word", word, "wordLang", from,
                "meaningLang", to, "meaning", meaning));
        if (result != null && result.path("status").asText().equals("scored")
                && result.path("correctnessProbability").isNumber()) {
            double probability = result.path("correctnessProbability").asDouble();
            if (Double.isFinite(probability) && probability >= 0 && probability <= 1)
                return Map.of("status", "scored", "correctnessProbability", probability, "model", "Julia-1");
        }
        return Map.of("status", "unavailable", "model", "Julia-1");
    }

    public Map<String, String> lessonPlan(List<Word> selected) {
        if (selected.isEmpty()) return Map.of();
        List<Map<String, Object>> words = selected.stream().map(word -> Map.<String, Object>of(
                "id", word.getID(), "progress", Math.max(0, Math.min(100, word.getProgress())))).toList();
        JsonNode result = post("/lesson-plan", Map.of("words", words));
        if (result == null || !result.path("modes").isObject()) return Map.of();
        Map<String, String> modes = new HashMap<>();
        for (Word word : selected) {
            String mode = result.path("modes").path(word.getID()).asText();
            if (MODES.contains(mode) && (!mode.equals("reverse") || word.getProgress() >= 50)
                    && (!mode.equals("review") || word.getProgress() < 80))
                modes.put(word.getID(), mode);
        }
        return modes;
    }

    public void filterLessonOptions(Lesson lesson, List<Word> selected) {
        if (lesson.getQuestions().isEmpty()) return;
        Map<String, Word> words = new HashMap<>();
        for (Word word : selected) words.put(word.getID(), word);
        List<Map<String, Object>> questions = new ArrayList<>();
        for (Question question : lesson.getQuestions()) {
            Word word = words.get(question.getQWord());
            if (word == null || question.getCorrect() < 0 || question.getCorrect() >= question.getAnswers().size()) return;
            boolean reverse = question.getQuestion().startsWith("Which ");
            String correct = question.getAnswers().get(question.getCorrect());
            questions.add(Map.of(
                    "id", word.getID(),
                    "prompt", reverse ? word.getMeaning() : word.getActualWord(),
                    "promptLang", reverse ? word.getMeaningLang() : word.getWordLang(),
                    "answerLang", reverse ? word.getWordLang() : word.getMeaningLang(),
                    "correct", correct,
                    "candidates", question.getAnswers().stream().filter(answer -> !answer.equals(correct)).toList()));
        }
        JsonNode result = post("/lesson-options", Map.of("questions", questions));
        if (result == null || !result.path("options").isObject()) return;
        Map<String, Set<String>> approved = new HashMap<>();
        for (Question question : lesson.getQuestions()) {
            JsonNode options = result.path("options").path(question.getQWord());
            if (!options.isArray()) return;
            Set<String> candidates = new HashSet<>(question.getAnswers());
            candidates.remove(question.getAnswers().get(question.getCorrect()));
            Set<String> safe = new HashSet<>();
            for (JsonNode option : options) {
                if (!option.isTextual() || !candidates.contains(option.asText())) return;
                safe.add(option.asText());
            }
            approved.put(question.getQWord(), safe);
        }
        Iterator<Question> iterator = lesson.getQuestions().iterator();
        while (iterator.hasNext()) {
            Question question = iterator.next();
            String correct = question.getAnswers().get(question.getCorrect());
            List<String> answers = question.getAnswers().stream()
                    .filter(answer -> answer.equals(correct) || approved.get(question.getQWord()).contains(answer)).toList();
            if (answers.size() == 1) {
                iterator.remove();
                Word word = words.get(question.getQWord());
                if (!lesson.getWords().contains(word)) lesson.getWords().add(word);
            } else {
                question.setAnswers(answers);
                question.setCorrect(answers.indexOf(correct));
            }
        }
    }

    private JsonNode post(String path, Object payload) {
        if (base == null) return null;
        try {
            HttpRequest request = HttpRequest.newBuilder(URI.create(base + path)).timeout(timeout)
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(mapper.writeValueAsString(payload))).build();
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() != 200 || response.body().length() > 16000)
                throw new IllegalStateException("Invalid decision response");
            return mapper.readTree(response.body());
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            return null;
        } catch (Exception e) {
            log.warn("Local decision model unavailable for {}; using fallback ({})", path, e.getClass().getSimpleName());
            return null;
        }
    }
}
