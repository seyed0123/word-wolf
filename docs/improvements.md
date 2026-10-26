# Local learning improvements

## Scope and build order
1. Local suggestions: authenticated POST /suggest_meaning takes word, wordLang,
   meaningLang; returns an editable meaning. Spring calls only the configured
   local MADLAD adapter backed by llama.cpp. Bound input/output and timeouts; failure leaves manual entry usable.
2. Lessons: select up to six words without modifying input, favor low progress,
   review weak words first, mix forward/reverse recall, deduplicate answers within
   the same language pair, allow two to four choices, and handle empty/single-word
   libraries without crashes. Saved vocabulary remains the source of truth.
3. UI: preserve accounts, vocabulary CRUD/search/discovery, flashcard review,
   lessons, hearts, XP, streaks and settings. Use a coherent paper/forest palette,
   readable type, constrained content widths and responsive navigation.
4. Docker: build Flutter and Java inside containers, mount the existing GGUF
   read-only, keep inference on the Compose network, and exercise the stack.

## Verification
Backend JUnit tests cover selection, small pools, language isolation, duplicate
answers and local-model errors using a local HTTP stub. Flutter widget tests cover
responsive navigation and editable suggestion states. Build and test using Docker;
exercise real model inference and app HTTP flows when Docker access is available.
No Java or Flutter installation on the host. Do not overwrite existing user changes
or database volumes. No cloud inference or automatic acceptance of AI suggestions.

## Design contract
Dashboard's primary action is practice, with progress and vocabulary actions nearby.
Forms remain scrollable at 320px. Desktop content is bounded, with comfortable
spacing and native Material keyboard/focus behavior. Loading, error and empty
states have useful text and a next action. Preserve existing achievement artwork.

## Verification status
- Live Docker stack rebuilt and running at http://localhost:8080 with the local GGUF.
- Fixed live suggestion 404: the previous backend image lacked `/suggest_meaning`.
- Backend: 26 JUnit tests passed in Docker; Flutter: 22 widget tests passed in Docker;
  MADLAD adapter: 4 tests passed in Docker. The earlier Julia adapter suite passed 5 tests.
- Real-model HTTP smoke tests passed, including Persian, German and French meanings,
  account access, vocabulary, lessons, XP, streaks and frontend assets.
- Browser checks passed at 320, 768, 1024 and 1440px: login, language flags,
  Persian suggestion acceptance/save, flashcards, questions, lesson completion,
  search, popular words, deletion, streaks, settings and logout. No console/page errors.
- Flags use the existing artwork beside readable language names in pickers,
  vocabulary cards and lesson flashcards. Mobile layout visually inspected.
- Static analysis has existing informational style notices; no errors or warnings
  were reported in the Docker analysis run.
- The small local model can mistranslate words. Suggestions require review and
  remain editable; a working endpoint does not guarantee translation accuracy.

Browser regression runner: `scripts/browser-check.cjs`. It creates a fresh test
account and needs Playwright plus Chromium; Java and Flutter still run in Docker.
Screenshots: [mobile word form](../shots/word-form-320.png) and
[desktop suggestion](../shots/suggestion-1440.png).

## Julia and splash follow-up (historical; scoring flow superseded below)
- Separate offline Julia-1 container is running with pinned, checksum-verified weights.
- Real-model evaluation failed unreferenced translation verification; production
  review is restricted to saved-reference comparison and possible disagreement.
  See [design and limits](julia.md) and [final diagnostic](julia-evaluation.json).
- API checks confirmed `no_reference` for new words and `matches_saved` for an
  existing saved meaning. Stopping Julia preserved suggestions and lessons; the
  container was restarted and returned healthy.
- Browser checks passed the visible splash transition and all existing flows,
  including language flags and review messages, without console/page errors.
- [First splash frame](../shots/splash-first.png) and
  [second splash frame](../shots/splash-second.png) were visually inspected.

## MADLAD and full-height splash follow-up

- MADLAD replaces the Llama-3.2 suggester. The original local GGUF is mounted
  read-only; a compatible copy lives in a Docker volume with verified unchanged
  tensor bytes. The native completion executable handles encoder-decoder inference.
- Real Persian, German, French, Arabic and reverse Persian-to-English translations
  were checked. [Compatibility details and results](madlad.md).
- 26 backend, 22 Flutter and 4 MADLAD adapter tests passed. The deployed API smoke
  test and full browser flows passed without console errors.
- Splash images now use 100% of available screen height; mobile/desktop widget
  sizing tests and the desktop browser screenshot confirm the result. Updated
  [splash screenshot](../shots/splash-second.png).
- Final stack is running at http://localhost:8080. The obsolete Llama container
  was removed; database volumes and the original model file were preserved.

## Direct Julia correctness scoring

Every MADLAD suggestion now goes directly to Julia with the source word, generated
meaning and both languages. There is no saved-vocabulary lookup or reference gate.
The API returns `review.status=scored` and numeric `correctnessProbability` in
[0, 1]; the UI displays that correct-option probability as a percentage. Missing
or failed reviews remain unavailable, never a fabricated 0% score. Suggestions
still require explicit acceptance and save. The lesson flow is unchanged.

26 backend tests, 22 Flutter tests and five Julia adapter tests passed in Docker.
The live API smoke test passed with numerical scores. The 14-case diagnostic is
recorded in [direct pair results](julia-pair-evaluation.json); it confirms that the
model can still assign very high probability to incorrect translations. These are
uncalibrated model estimates, as labeled in the interface.

The fresh-account Chromium check also passed: its first suggestion displayed the
exact Julia score returned by the API, before any word was saved. All existing
browser learning flows passed without console/page errors. The updated
[suggestion screenshot](../shots/suggestion-1440.png) shows the percentage.
