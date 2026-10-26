# MADLAD suggester

The app now uses the existing `~/models/madlad400-3b-mt-q8_0.gguf` in place of
Llama-3.2. `LOCAL_MODEL_PATH` can override that input. Julia remains the separate,
direct word–meaning scoring and lesson-advice service.

## Compatibility fixes

The supplied GGUF had custom metadata and tensor names; llama.cpp failed with
`key not found in model: t5.context_length`. A Docker preparation job maps the
names to the official T5 format and supplies the pinned official SentencePiece
metadata after checking that every token ID matches. It writes a separate file
into the `madlad_model` Docker volume and verifies the raw tensor region has the
same SHA-256 before and after. No tensor is dequantized, requantized or replaced.
The original download is never modified. Preparation is cached by source hash,
adapter hash and tokenizer hash; it reruns if any of those change.

Reference tensor samples were compared against small HTTP byte ranges of Google's
original checkpoint to verify the attention and feed-forward mappings. The raw
quantized tensor SHA-256 for this download is:
`3253aa03bad68733d5ce3ce6af5d63e3e19cf5fb0cb4575c5e8351945adadaab`.

The tested llama.cpp build (`5262471`) loaded T5 in `llama-server`, but its server
inference path did not encode the source text; outputs were punctuation. Its
`llama-completion` executable correctly runs encoder-decoder inference. The local
Python HTTP adapter runs that executable with literal arguments (no shell), one
translation at a time, a 55-second deadline and a 160-token limit. It discards
incomplete output rather than presenting it as a complete translation.

Each request loads the model, taking about 2.5–2.8 seconds for short examples on
this machine. The operating system caches the weight file between calls. This is
simpler than maintaining a patched server and avoids relying on its unsupported
inference path. The CPU thread setting remains `LLAMA_THREADS`.

## Prompt and behavior

The prompt is `<2fa> book` for Persian, `<2de> book` for German, and similarly for
English (`en`), French (`fr`), Spanish (`es`) and Arabic (`ar`). The previously tried
`>>fas<<` format belongs to a different model convention and is not used.
Source language is inferred by MADLAD; its native prompt specifies the target.
This is a translation model, so same-language definitions remain manual.

Real local adapter checks produced:

| Input | Target | Output |
| --- | --- | --- |
| book | Persian | کتاب |
| hello | Persian | سلام |
| apple | Persian | سیب |
| book | German | Buch |
| water | French | eau |
| کتاب | English | Book |
| book | Arabic | كتاب |

An isolated `sun` with Spanish target returned `Sun`, so short ambiguous words
still need human review. This sample is an integration diagnostic, not a general
translation-quality benchmark.

## Sources

- [MADLAD model card and target-language prompting](https://huggingface.co/google/madlad400-3b-mt)
- [Official T5 conversion](https://github.com/ggml-org/llama.cpp/blob/master/conversion/t5.py)
- [Official T5 runtime](https://github.com/ggml-org/llama.cpp/blob/master/src/models/t5.cpp)
- Tokenizer revision: `fa184c675da0b5c9e1c8694fccd4e12e2d422094` in `google/madlad400-3b-mt`.

## Splash

Both images fill the available screen height and retain their aspect ratio, with
horizontal cropping on narrow screens. The cross-fade and navigation timing remain
400 ms / 500 ms / 1600 ms, with timers cancelled on disposal. Tests cover full height
at 320×900 and 1440×1000.

## Verification

Docker builds passed 26 backend tests, 22 Flutter widget tests and four translation
adapter tests. Real API smoke tests passed accounts, vocabulary, lessons, XP,
streaks and Persian/German/French suggestions. Chromium checks passed the splash
animation, real suggestion/save flow and all learning/navigation flows at
320–1440px without console/page errors. The full-height desktop screenshot was
visually inspected. All five long-running services are up; `model-prep` exits
successfully after preparing or checking its cached model.
