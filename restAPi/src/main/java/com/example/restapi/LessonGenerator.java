package com.example.restapi;

import java.util.*;

/** Pure lesson generation: saved vocabulary is the authoritative answer source. */
public final class LessonGenerator {
    private LessonGenerator() {}

    public static List<Word> selectWords(List<Word> words, int count, Random random) {
        List<Word> remaining = new ArrayList<>(new LinkedHashSet<>(words));
        List<Word> selected = new ArrayList<>();
        while (!remaining.isEmpty() && selected.size() < count) {
            double total = remaining.stream().mapToDouble(LessonGenerator::weight).sum();
            double ticket = random.nextDouble() * total;
            int index = 0;
            while (index < remaining.size() - 1 && (ticket -= weight(remaining.get(index))) >= 0) index++;
            selected.add(remaining.remove(index));
        }
        return selected;
    }

    private static double weight(Word word) {
        return 1 + (100 - Math.max(0, Math.min(100, word.getProgress()))) / 10;
    }

    private static String key(String value) {
        return value.trim().toLowerCase(Locale.ROOT);
    }

    public static Lesson generate(List<Word> userWords, List<Word> pool, Random random) {
        return generateSelected(selectWords(userWords, 6, random), pool, random, Map.of());
    }

    public static Lesson generateSelected(List<Word> selected, List<Word> pool, Random random,
                                          Map<String, String> modes) {
        List<Question> questions = new ArrayList<>();
        List<Word> review = new ArrayList<>();
        for (int i = 0; i < selected.size(); i++) {
            Word target = selected.get(i);
            String mode = modes.getOrDefault(target.getID(), "default");
            if (target.getProgress() < 60 || mode.equals("review")) review.add(target);
            // Keep the established recall mix even if the model always chooses recognition.
            boolean reverse = target.getProgress() >= 50 &&
                    (mode.equals("reverse") || i % 2 == 1);
            String correct = (reverse ? target.getActualWord() : target.getMeaning()).trim();
            String prompt = reverse ? target.getMeaning() : target.getActualWord();
            // Exclude every accepted translation of this prompt, not only this row.
            Set<String> accepted = new HashSet<>();
            accepted.add(key(correct));
            for (Word candidate : pool) {
                if (samePair(target, candidate) && key(reverse ? candidate.getMeaning() : candidate.getActualWord()).equals(key(prompt)))
                    accepted.add(key(reverse ? candidate.getActualWord() : candidate.getMeaning()));
            }
            Map<String, String> distinct = new LinkedHashMap<>();
            for (Word candidate : pool) {
                if (!samePair(target, candidate)) continue;
                String answer = (reverse ? candidate.getActualWord() : candidate.getMeaning()).trim();
                if (!answer.isBlank() && !accepted.contains(key(answer))) distinct.putIfAbsent(key(answer), answer);
            }
            List<String> alternatives = new ArrayList<>(distinct.values());
            Collections.shuffle(alternatives, random);
            if (alternatives.isEmpty()) {
                if (!review.contains(target)) review.add(target);
                continue;
            }
            List<String> answers = new ArrayList<>(alternatives.subList(0, Math.min(3, alternatives.size())));
            answers.add(correct);
            Collections.shuffle(answers, random);
            String question = reverse
                    ? "Which " + target.getWordLang() + " word means \"" + prompt + "\"?"
                    : "What does \"" + prompt + "\" mean in " + target.getMeaningLang() + "?";
            questions.add(new Question(question, answers, answers.indexOf(correct), target.getID()));
        }
        if (review.isEmpty() && !selected.isEmpty()) review.add(selected.get(0));
        review.sort(Comparator.comparingDouble(Word::getProgress));
        Collections.shuffle(questions, random);
        return new Lesson(UUID.randomUUID().toString(), questions, review);
    }

    private static boolean samePair(Word first, Word second) {
        return first.getWordLang().equalsIgnoreCase(second.getWordLang())
                && first.getMeaningLang().equalsIgnoreCase(second.getMeaningLang());
    }
}
