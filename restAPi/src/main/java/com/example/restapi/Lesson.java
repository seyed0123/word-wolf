package com.example.restapi;

import java.util.List;

public class Lesson {
    private String id;
    private List<Question> questions;
    private List<Word> words;

    public Lesson(List<Question> questions, List<Word> words) {
        this.questions = questions;
        this.words = words;
    }

    public Lesson() {
    }

    public Lesson(String id, List<Question> questions, List<Word> words) {
        this.id = id;
        this.questions = questions;
        this.words = words;
    }

    public List<Question> getQuestions() {
        return questions;
    }

    public void setQuestions(List<Question> questions) {
        this.questions = questions;
    }

    public List<Word> getWords() {
        return words;
    }

    public void setWords(List<Word> words) {
        this.words = words;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }
}
