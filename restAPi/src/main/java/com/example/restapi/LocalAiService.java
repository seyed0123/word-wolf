package com.example.restapi;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;

import java.net.URI;
import java.net.http.*;
import java.time.Duration;
import java.util.*;

@Service
public class LocalAiService {
    private static final Map<String, String> LANG_CODES = Map.of(
            "English", "en", "Persian", "fa", "German", "de",
            "French", "fr", "Spanish", "es", "Arabic", "ar");
    private final URI endpoint;
    private final Duration timeout;
    private final HttpClient client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(3)).build();
    private final ObjectMapper mapper = new ObjectMapper();

    public LocalAiService(@Value("${local.ai.url:http://localhost:8081}") String url,
                          @Value("${local.ai.timeout-seconds:60}") int seconds) {
        endpoint = URI.create(url.replaceAll("/+$", "") + "/v1/completions");
        // Configuration is operator-controlled; reject public endpoints to keep inference local.
        String host = endpoint.getHost();
        if (!"http".equals(endpoint.getScheme()) || host == null ||
                !(host.equals("localhost") || host.equals("ai") || host.equals("host.docker.internal") ||
                  host.equals("127.0.0.1") || host.equals("[::1]"))) {
            throw new IllegalArgumentException("Local AI URL must use localhost, ai, or host.docker.internal over HTTP");
        }
        timeout = Duration.ofSeconds(Math.max(1, Math.min(120, seconds)));
    }

    public String suggest(String word, String from, String to) {
        if (word == null || word.isBlank() || word.length() > 200 ||
                !LANG_CODES.containsKey(from == null ? "" : from) || !LANG_CODES.containsKey(to == null ? "" : to))
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Enter a word (up to 200 characters) and supported languages.");
        if (from.equals(to))
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Choose different languages for translation, or enter a definition yourself.");
        try {
            String prompt = "<2" + LANG_CODES.get(to) + "> " + word.trim();
            var payload = Map.of("model", "local-vocabulary", "prompt", prompt,
                    "temperature", 0, "max_tokens", 160, "stream", false);
            HttpRequest request = HttpRequest.newBuilder(endpoint).timeout(timeout)
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(mapper.writeValueAsString(payload))).build();
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() != 200 || response.body().length() > 32000) throw new IllegalStateException();
            JsonNode choice = mapper.readTree(response.body()).path("choices").path(0);
            if (choice.path("finish_reason").asText().equals("length")) throw new IllegalStateException();
            if (!choice.path("text").isTextual()) throw new IllegalStateException();
            String meaning = choice.path("text").asText().trim();
            if (meaning.isBlank() || meaning.length() > 1000)
                throw new IllegalStateException();
            return meaning;
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw unavailable();
        } catch (Exception e) {
            throw unavailable();
        }
    }

    private ResponseStatusException unavailable() {
        return new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE,
                "Local suggestions are unavailable. You can still enter a meaning yourself.");
    }
}
