package com.example.restapi;

public class Word {
    private String ID;
    private String actualWord;
    private String meaning;
    private String wordLang;
    private String meaningLang;
    private double progress;

    public Word(String ID, String actualWord, String meaning, String wordLang, String meaningLang, double progress) {
        this.ID = ID;
        this.actualWord = actualWord;
        this.meaning = meaning;
        this.wordLang = wordLang;
        this.meaningLang = meaningLang;
        this.progress = progress;
    }

    public String getID() {
        return ID;
    }

    public void setID(String ID) {
        this.ID = ID;
    }

    public String getActualWord() {
        return actualWord;
    }

    public void setActualWord(String actualWord) {
        this.actualWord = actualWord;
    }

    public String getMeaning() {
        return meaning;
    }

    public void setMeaning(String meaning) {
        this.meaning = meaning;
    }

    public String getWordLang() {
        return wordLang;
    }

    public void setWordLang(String wordLang) {
        this.wordLang = wordLang;
    }

    public String getMeaningLang() {
        return meaningLang;
    }

    public void setMeaningLang(String meaningLang) {
        this.meaningLang = meaningLang;
    }

    public double getProgress() {
        return progress;
    }

    public void setProgress(double progress) {
        this.progress = progress;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Word word = (Word) o;
        return ID.equals(word.ID);
    }

    @Override
    public int hashCode() {
        return ID.hashCode();
    }
}
