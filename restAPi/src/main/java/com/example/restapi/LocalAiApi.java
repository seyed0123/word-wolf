package com.example.restapi;

import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
public class LocalAiApi {
    private final LocalAiService ai;
    private final LocalDecisionService decisions;
    public LocalAiApi(LocalAiService ai, LocalDecisionService decisions) {
        this.ai = ai;
        this.decisions = decisions;
    }
    public record SuggestionRequest(String word, String wordLang, String meaningLang) {}

    @PostMapping("/suggest_meaning")
    public Map<String, Object> suggest(@RequestHeader("Authorization") String token,
                                       @RequestBody SuggestionRequest request) {
        jsonWT.verifyToken(token);
        String meaning = ai.suggest(request.word(), request.wordLang(), request.meaningLang());
        return Map.of("meaning", meaning, "review", decisions.review(
                request.word(), request.wordLang(), request.meaningLang(), meaning));
    }
}
