# Julia-1 direct meaning scores

## Current suggestion flow

1. MADLAD generates a translation for the selected meaning language.
2. The backend sends the original word, generated meaning, source language and
   target language to the local Julia container. It does not read saved words.
3. Julia answers a binary choice: “correct translation” or “incorrect translation”.
4. The adapter returns the full softmax probability of the **correct** option as
   `correctnessProbability`. It does not return the maximum of the two scores.
5. The suggestion card displays `Estimated correctness: N%` to one decimal place,
   with `Julia-1 model estimate; can be wrong.` The meaning remains editable and
   requires the user's existing explicit acceptance/save actions.

For example, a model response of `{correct: 0.08, incorrect: 0.92}` displays 8.0%,
not 92.0%. New words are scored even when the account has no saved vocabulary.
There are no `matches_saved` or `no_reference` shortcuts. If Julia fails or sends
an invalid score, the app retains the translation and says the estimate is
unavailable; it does not substitute a fabricated zero or certainty score.

```json
{
  "meaning": "کتاب",
  "review": {
    "status": "scored",
    "correctnessProbability": 0.93,
    "model": "Julia-1"
  }
}
```

This JSON is an illustrative contract example, not a measured prediction.

## Meaning of the percentage

This is Julia's model probability over the two supplied choices. It has not been
calibrated against a translation benchmark, so it is not a measured chance that a
translation is factually correct. Previous experiments found confident errors;
see [historical unreferenced results](julia-unreferenced-evaluation.json). The app
now exposes the requested direct score rather than requiring saved references.
The [latest direct-score diagnostic](julia-pair-evaluation.json) is separate from
those older prompt experiments. It also returned very high scores for incorrect
examples such as English `book` → Persian `آب`. The displayed percentage is the
requested raw model estimate and must not be interpreted as measured accuracy.

## Lesson advice

Julia sees selected word IDs and mastery values and chooses among bounded review,
recognition and reverse-recall formats. For generated multiple-choice questions,
the backend also sends the prompt, saved correct answer and up to three candidate
distractors in one batch. Only candidates Julia classifies as clearly incorrect
with at least 70% confidence remain. If none remain, the item becomes a review
card instead of a one-option or ambiguous question. The saved answer always stays
authoritative; Julia does not write meanings, answer keys or lesson text.

## Runtime and reproducibility

- Local, offline CPU inference in the `julia` Compose service; no published host port.
- Revision: `a85b127321d580d65176c89ced8273f305745d85`.
- Weight SHA-256: `df853bf7fe424420011f3d0c47a05d7341aa9eefa7fb9f203ea4aada4ad95b72`.
- Python 3.11, CPU PyTorch 2.8.0, publisher's transformers 5.0 constraint.
- Backend timeout defaults to eight seconds; failed scoring does not block manual entry.
- [Official model card](https://huggingface.co/SupersonicLabs/Julia-1).

Run the real-model diagnostic (correct and deliberately incorrect pairs):

```bash
docker compose --env-file restAPi/.env exec -T julia python \
  < scripts/evaluate-julia.py > /tmp/julia-evaluation.json
```

The diagnostic verifies numeric score output and records predictions. It does not
assert that the model assigns the correct probabilities or tune a threshold on
these examples. Java, Flutter and model execution remain in Docker.
