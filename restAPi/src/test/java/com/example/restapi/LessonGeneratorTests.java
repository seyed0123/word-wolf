package com.example.restapi;

import org.junit.jupiter.api.Test;
import java.util.*;
import static org.junit.jupiter.api.Assertions.*;

class LessonGeneratorTests {
    private Word word(String id, String meaning, double progress) {
        return new Word(id, "word" + id, meaning, "English", "German", progress);
    }

    @Test void selectionDoesNotMutateInputOrRepeatWords() {
        List<Word> words = List.of(word("1", "eins", 0), word("2", "zwei", 100));
        var selected = LessonGenerator.selectWords(words, 6, new Random(1));
        assertEquals(2, selected.size());
        assertEquals(2, new HashSet<>(selected).size());
        assertEquals(2, words.size());
    }

    @Test void weakWordsAreSelectedMoreOften() {
        var words = List.of(word("weak", "eins", 0), word("strong", "zwei", 100));
        Random random = new Random(7);
        int weak = 0;
        for (int i = 0; i < 1000; i++)
            if (LessonGenerator.selectWords(words, 1, random).get(0).getProgress() == 0) weak++;
        assertTrue(weak > 750);
    }

    @Test void emptyAndSingleWordPoolsAreSafe() {
        assertTrue(LessonGenerator.generate(List.of(), List.of(), new Random(1)).getQuestions().isEmpty());
        Word one = word("1", "eins", 0);
        Lesson lesson = LessonGenerator.generate(List.of(one), List.of(one), new Random(1));
        assertEquals(1, lesson.getWords().size());
        assertTrue(lesson.getQuestions().isEmpty());
    }

    @Test void smallPoolsHaveDistinctAnswersAndCorrectIndex() {
        var words = List.of(word("1", "eins", 0), word("2", "zwei", 10));
        var lesson = LessonGenerator.generate(words, words, new Random(2));
        assertEquals(2, lesson.getQuestions().size());
        for (Question question : lesson.getQuestions()) {
            assertEquals(2, question.getAnswers().size());
            assertEquals(2, new HashSet<>(question.getAnswers()).size());
            var target = words.stream().filter(w -> w.getID().equals(question.getQWord())).findFirst().orElseThrow();
            assertEquals(target.getMeaning(), question.getAnswers().get(question.getCorrect()));
        }
    }

    @Test void duplicateMeaningsAndOtherLanguagesAreNotDistractors() {
        Word target = word("1", "eins", 0);
        var pool = List.of(target, word("2", " EINS ", 0),
                new Word("3", "three", "trois", "English", "French", 0));
        assertTrue(LessonGenerator.generate(List.of(target), pool, new Random(1)).getQuestions().isEmpty());
    }

    @Test void practicedWordsIncludeReverseRecall() {
        var words = List.of(word("1", "eins", 80), word("2", "zwei", 80), word("3", "drei", 80));
        var lesson = LessonGenerator.generate(words, words, new Random(2));
        assertTrue(lesson.getQuestions().stream().anyMatch(q -> q.getQuestion().startsWith("Which English")));
        assertFalse(lesson.getWords().isEmpty());
    }
    @Test void decisionModesKeepSavedAnswersAndMandatoryWeakWordReview() {
        var weak = word("weak", "eins", 0);
        var strong = word("strong", "zwei", 80);
        var words = List.of(weak, strong);
        var lesson = LessonGenerator.generateSelected(words, words, new Random(1),
                Map.of("weak", "reverse", "strong", "reverse"));
        assertTrue(lesson.getWords().contains(weak));
        for (Question question : lesson.getQuestions()) {
            boolean reverse = question.getQWord().equals("strong");
            assertEquals(reverse ? strong.getActualWord() : weak.getMeaning(),
                    question.getAnswers().get(question.getCorrect()));
        }
        lesson = LessonGenerator.generateSelected(words, words, new Random(1), Map.of("strong", "review"));
        assertTrue(lesson.getWords().contains(strong));
    }

    @Test void repeatedModelRecognitionAdviceStillIncludesReverseRecall() {
        var words = List.of(word("1", "eins", 80), word("2", "zwei", 80));
        var lesson = LessonGenerator.generateSelected(words, words, new Random(1),
                Map.of("1", "forward", "2", "forward"));
        assertTrue(lesson.getQuestions().stream().anyMatch(q -> q.getQuestion().startsWith("Which English")));
    }

}
