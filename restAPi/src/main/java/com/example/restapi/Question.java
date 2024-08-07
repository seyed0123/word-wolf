package com.example.restapi;

import java.util.List;

public class Question {
    private String question;
    private List<String> answers;
    private int correct;
    private String QWord;
    public Question(){}

    public Question(String question, List<String> answers, int correct,String Qword) {
        this.question = question;
        this.answers = answers;
        this.correct = correct;
        this.QWord = Qword;
    }

    public String getQuestion() {
        return question;
    }

    public void setQuestion(String question) {
        this.question = question;
    }

    public List<String> getAnswers() {
        return answers;
    }

    public void setAnswers(List<String> answers) {
        this.answers = answers;
    }

    public int getCorrect() {
        return correct;
    }

    public void setCorrect(int correct) {
        this.correct = correct;
    }

    public String getQWord() {
        return QWord;
    }

    public void setQWord(String QWord) {
        this.QWord = QWord;
    }
}
