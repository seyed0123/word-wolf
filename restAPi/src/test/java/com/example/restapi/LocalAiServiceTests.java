package com.example.restapi;

import com.sun.net.httpserver.HttpServer;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.*;
import org.springframework.web.server.ResponseStatusException;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.util.*;
import static org.junit.jupiter.api.Assertions.*;

class LocalAiServiceTests {
    HttpServer server;
    LocalAiService service;
    Object content = "سلام";
    String finishReason = "stop";
    int status = 200;
    String requestBody;
    @BeforeEach void start() throws Exception {
        server = HttpServer.create(new InetSocketAddress("127.0.0.1", 0), 0);
        server.createContext("/v1/completions", exchange -> {
            requestBody = new String(exchange.getRequestBody().readAllBytes(), StandardCharsets.UTF_8);
            byte[] body = new ObjectMapper().writeValueAsBytes(Map.of("choices", List.of(Map.of(
                    "finish_reason", finishReason, "text", content))));
            exchange.sendResponseHeaders(status, body.length);
            exchange.getResponseBody().write(body);
            exchange.close();
        });
        server.start();
        service = new LocalAiService("http://127.0.0.1:" + server.getAddress().getPort(), 2);
    }
    @AfterEach void stop() { server.stop(0); }
    @Test void returnsUnicodeTranslationWithMadladLanguageTag() throws Exception {
        assertEquals("سلام", service.suggest(" hello ", "English", "Persian"));
        var payload = new ObjectMapper().readTree(requestBody);
        assertEquals("<2fa> hello", payload.path("prompt").asText());
        assertEquals(0, payload.path("temperature").asInt());
        assertFalse(payload.path("stream").asBoolean());
        assertFalse(payload.has("messages"));
        assertFalse(payload.has("response_format"));
    }
    @Test void allTargetLanguagesUseMadladTagsIncludingReverseTranslation() throws Exception {
        var codes = Map.of("English", "en", "Persian", "fa", "German", "de", "French", "fr", "Spanish", "es", "Arabic", "ar");
        for (var entry : codes.entrySet()) {
            service.suggest("word", entry.getKey().equals("English") ? "Persian" : "English", entry.getKey());
            assertEquals("<2" + entry.getValue() + "> word", new ObjectMapper().readTree(requestBody).path("prompt").asText());
        }
    }
    @Test void rejectsInvalidInputBeforeInference() {
        assertEquals(400, assertThrows(ResponseStatusException.class,
                () -> service.suggest(" ", "English", "Persian")).getStatusCode().value());
        assertThrows(ResponseStatusException.class, () -> service.suggest("hello", "Unknown", "Persian"));
        assertThrows(ResponseStatusException.class, () -> service.suggest("x".repeat(201), "English", "Persian"));
        assertNull(requestBody);
    }
    @Test void sameLanguageNeedsManualDefinitionRatherThanEchoedTranslation() {
        assertEquals(400, assertThrows(ResponseStatusException.class,
                () -> service.suggest("book", "English", "English")).getStatusCode().value());
        assertNull(requestBody);
    }
    @Test void invalidOrFailedResponsesHaveRecoverableError() {
        for (Object value : List.of("", " ", 42, "x".repeat(1001))) {
            content = value;
            assertEquals(503, assertThrows(ResponseStatusException.class,
                    () -> service.suggest("hello", "English", "Persian")).getStatusCode().value());
        }
        status = 500;
        assertThrows(ResponseStatusException.class, () -> service.suggest("hello", "English", "Persian"));
    }
    @Test void truncatedTranslationIsNotPresentedAsACompleteMeaning() {
        finishReason = "length";
        assertEquals(503, assertThrows(ResponseStatusException.class,
                () -> service.suggest("hello", "English", "Persian")).getStatusCode().value());
    }
    @Test void rejectsCloudEndpoints() {
        assertThrows(IllegalArgumentException.class, () -> new LocalAiService("https://example.com", 2));
    }
}
