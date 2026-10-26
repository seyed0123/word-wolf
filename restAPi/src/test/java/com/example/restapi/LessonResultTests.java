package com.example.restapi;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.mockito.MockedStatic;
import org.springframework.web.server.ResponseStatusException;
import java.util.List;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class LessonResultTests {
    @Test void unknownOrOtherUsersLessonCannotBeSubmitted() {
        try (MockedStatic<DataBase> database = mockStatic(DataBase.class)) {
            assertEquals(404, assertThrows(ResponseStatusException.class, () -> new LessonApi(mock(LocalDecisionService.class)).resLesson(
                    jsonWT.createToken("user"), "{\"lesson_id\":\"other\",\"success\":true,\"ans\":[]}")).getStatusCode().value());
            database.verify(() -> DataBase.getLessonForUser("other", "user"));
            database.verify(() -> DataBase.getUserByID("user"), never());
        }
    }
    @Test void incompleteSuccessfulLessonIsRejectedBeforeProgressChanges() throws Exception {
        try (MockedStatic<DataBase> database = mockStatic(DataBase.class)) {
            String saved = new ObjectMapper().writeValueAsString(new Lesson("lesson", List.of(
                    new Question("question", List.of("a", "b"), 0, "word")), List.of()));
            database.when(() -> DataBase.getLessonForUser("lesson", "user")).thenReturn(saved);
            assertEquals(400, assertThrows(ResponseStatusException.class, () -> new LessonApi(mock(LocalDecisionService.class)).resLesson(
                    jsonWT.createToken("user"), "{\"lesson_id\":\"lesson\",\"success\":true,\"ans\":[]}")).getStatusCode().value());
            database.verify(() -> DataBase.getUserByID("user"), never());
        }
    }
}
