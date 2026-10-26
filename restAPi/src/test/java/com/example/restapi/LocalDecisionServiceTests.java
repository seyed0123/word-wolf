package com.example.restapi;

import com.sun.net.httpserver.HttpServer;
import org.junit.jupiter.api.*;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.util.*;
import static org.junit.jupiter.api.Assertions.*;

class LocalDecisionServiceTests {
    HttpServer server;
    LocalDecisionService service;
    String response = "{\"status\":\"scored\",\"correctnessProbability\":0.08}";
    int status = 200;

    @BeforeEach void start() throws Exception {
        server = HttpServer.create(new InetSocketAddress("127.0.0.1", 0), 0);
        server.createContext("/", exchange -> {
            exchange.getRequestBody().readAllBytes();
            byte[] bytes = response.getBytes(StandardCharsets.UTF_8);
            exchange.sendResponseHeaders(status, bytes.length);
            exchange.getResponseBody().write(bytes);
            exchange.close();
        });
        server.start();
        service = new LocalDecisionService("http://127.0.0.1:" + server.getAddress().getPort(), 1);
    }
    @AfterEach void stop() { server.stop(0); }

    @Test void returnsTheUnroundedCorrectnessProbabilityIncludingLowAndBoundaryValues() {
        for (double probability : List.of(0.0, .08, .934567, 1.0)) {
            response = "{\"status\":\"scored\",\"correctnessProbability\":" + probability + "}";
            var result = service.review("book", "English", "Persian", "کتاب");
            assertEquals("scored", result.get("status"));
            assertEquals(probability, result.get("correctnessProbability"));
        }
    }
    @Test void disabledMalformedAndDownServicesPreserveFallback() {
        assertTrue(new LocalDecisionService("", 1).lessonPlan(List.of()).isEmpty());
        for (String body : List.of("garbage", "null", "{}", "{\"status\":\"scored\"}",
                "{\"status\":\"scored\",\"correctnessProbability\":-0.1}",
                "{\"status\":\"scored\",\"correctnessProbability\":1.1}",
                "{\"status\":\"scored\",\"correctnessProbability\":\"0.93\"}",
                "{\"status\":\"scored\",\"correctnessProbability\":true}",
                "{\"status\":\"scored\",\"correctnessProbability\":1e999}")) {
            response = body;
            var result = service.review("book", "English", "Persian", "کتاب");
            assertEquals("unavailable", result.get("status"));
            assertFalse(result.containsKey("correctnessProbability"));
        }
        status = 503;
        assertEquals("unavailable", service.review("book", "English", "Persian", "کتاب").get("status"));
    }
    @Test void lessonPlanRejectsForeignIdsInvalidModesAndPrematureReverseRecall() {
        response = "{\"modes\":{\"new\":\"reverse\",\"known\":\"reverse\",\"bad\":\"delete\",\"foreign\":\"review\"}}";
        var words = List.of(new Word("new", "book", "کتاب", "English", "Persian", 0),
                new Word("known", "water", "آب", "English", "Persian", 80),
                new Word("bad", "sun", "خورشید", "English", "Persian", 20));
        assertEquals(Map.of("known", "reverse"), service.lessonPlan(words));
        status = 503;
        assertTrue(service.lessonPlan(words).isEmpty());
    }
    @Test void lessonOptionsKeepTheSavedAnswerAndOnlyModelApprovedDistractors() {
        Word word = new Word("book", "book", "کتاب", "English", "Persian", 20);
        Question question = new Question("What does book mean?", new ArrayList<>(List.of("کتاب", "دفتر", "آب")), 0, "book");
        Lesson lesson = new Lesson("lesson", new ArrayList<>(List.of(question)), new ArrayList<>());
        response = "{\"options\":{\"book\":[\"آب\"]}}";

        service.filterLessonOptions(lesson, List.of(word));

        assertEquals(List.of("کتاب", "آب"), question.getAnswers());
        assertEquals(0, question.getCorrect());
    }

    @Test void lessonOptionsTurnAQuestionWithoutSafeDistractorsIntoReview() {
        Word word = new Word("book", "book", "کتاب", "English", "Persian", 20);
        Lesson lesson = new Lesson("lesson", new ArrayList<>(List.of(
                new Question("What does book mean?", new ArrayList<>(List.of("دفتر", "کتاب")), 1, "book"))),
                new ArrayList<>());
        response = "{\"options\":{\"book\":[]}}";

        service.filterLessonOptions(lesson, List.of(word));

        assertTrue(lesson.getQuestions().isEmpty());
        assertEquals(List.of(word), lesson.getWords());
    }
    @Test void rejectsRemoteOrAmbiguousOrigins() {
        for (String url : List.of("https://example.com", "http://example.com", "http://julia/path", "http://julia?x=y", "http://user@julia"))
            assertThrows(IllegalArgumentException.class, () -> new LocalDecisionService(url, 1));
    }
}
