package com.example.restapi;

import org.junit.jupiter.api.Test;
import org.mockito.MockedStatic;
import java.util.*;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class LocalAiApiTests {
    @Test void everyGeneratedPairIsScoredWithoutReadingSavedWords() {
        var ai = mock(LocalAiService.class);
        var decisions = mock(LocalDecisionService.class);
        when(ai.suggest("book", "English", "Persian")).thenReturn("کتاب");
        when(decisions.review("book", "English", "Persian", "کتاب"))
                .thenReturn(Map.of("status", "scored", "correctnessProbability", .93, "model", "Julia-1"));
        try (MockedStatic<DataBase> db = mockStatic(DataBase.class)) {
            var result = new LocalAiApi(ai, decisions).suggest(jsonWT.createToken("user"),
                    new LocalAiApi.SuggestionRequest("book", "English", "Persian"));
            assertEquals("کتاب", result.get("meaning"));
            assertEquals(.93, ((Map<?, ?>) result.get("review")).get("correctnessProbability"));
            var order = inOrder(ai, decisions);
            order.verify(ai).suggest("book", "English", "Persian");
            order.verify(decisions).review("book", "English", "Persian", "کتاب");
            db.verifyNoInteractions();
        }
    }

    @Test void failedJuliaReviewRetainsTranslationWithoutInventingAProbability() {
        var ai = mock(LocalAiService.class);
        var decisions = mock(LocalDecisionService.class);
        when(ai.suggest("book", "English", "Persian")).thenReturn("کتاب");
        when(decisions.review("book", "English", "Persian", "کتاب"))
                .thenReturn(Map.of("status", "unavailable", "model", "Julia-1"));
        var result = new LocalAiApi(ai, decisions).suggest(jsonWT.createToken("user"),
                new LocalAiApi.SuggestionRequest("book", "English", "Persian"));
        assertEquals("کتاب", result.get("meaning"));
        var review = (Map<?, ?>) result.get("review");
        assertEquals("unavailable", review.get("status"));
        assertFalse(review.containsKey("correctnessProbability"));
    }
}
