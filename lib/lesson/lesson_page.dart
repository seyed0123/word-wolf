import 'dart:convert';
import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../request.dart';
import '../words/language_label.dart';
import 'lesson.dart';

class Lesson_page extends StatefulWidget {
  const Lesson_page({super.key});
  @override
  State<Lesson_page> createState() => _LessonPageState();
}

class _LessonPageState extends State<Lesson_page> {
  Lesson? lesson;
  String? error;
  bool revealed = false;
  bool checked = false;
  bool saving = false;
  bool? pendingSuccess;
  int? selected;
  final answers = <bool>[];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      error = null;
    });
    try {
      final token = await getToken();
      if (token == null) throw Exception('Sign in to practice.');
      final data = await sendGetRequest(token, 'new_lesson');
      if (mounted)
        setState(() {
          lesson = Lesson.fromJson(jsonDecode(data));
        });
    } catch (_) {
      if (mounted)
        setState(() {
          error = 'Could not load a lesson. Please try again.';
        });
    }
  }

  Future<void> finish(bool success) async {
    if (saving) return;
    setState(() {
      saving = true;
      error = null;
      pendingSuccess = success;
    });
    try {
      final token = await getToken();
      await sendRequest(
        token!,
        jsonEncode({
          'lesson_id': lesson!.id,
          'success': success,
          'ans': answers,
        }),
        'res_lesson',
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(success ? 'Practice complete' : 'Keep learning'),
          content: Text(
            lesson!.questions.isEmpty
                ? 'You reviewed your words. Add more vocabulary to unlock recall questions.'
                : '${answers.where((answer) => answer).length} of ${answers.length} answers correct. ${success ? "Your progress is saved." : "Your tricky words will get more practice."}',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted)
        setState(() {
          error = 'Could not save your practice. Please retry.';
        });
    } finally {
      if (mounted)
        setState(() {
          saving = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = lesson;
    if (current == null)
      return TaskPage(
        title: 'Practice',
        child: Center(
          child: error == null
              ? const CircularProgressIndicator()
              : Column(
                  children: [
                    Text(error!),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: load,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
        ),
      );
    if (current.words.isEmpty && current.questions.isEmpty)
      return TaskPage(
        title: 'Practice',
        child: Column(
          children: [
            const Icon(Icons.menu_book_outlined, size: 64, color: forest),
            const SizedBox(height: 24),
            const Text(
              'Your first lesson starts with a word.',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Save some vocabulary, then come back to practice.'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/new_word'),
              child: const Text('Add your first word'),
            ),
          ],
        ),
      );
    final reviewing = current.numWord < current.words.length;
    final total = current.words.length + current.questions.length;
    final completed = current.numWord + current.numQues;
    return TaskPage(
      title: 'Practice',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  reviewing ? 'REVIEW & REMEMBER' : 'PUT IT INTO PRACTICE',
                  style: const TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(Icons.favorite, color: Color(0xFFA3443A), size: 20),
              const SizedBox(width: 8),
              Text('${current.heart}'),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: completed / total,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text('$completed of $total steps'),
          const SizedBox(height: 32),
          if (pendingSuccess != null) ...[
            const Text(
              'Saving your progress',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (error != null) Text(error!),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: saving ? null : () => finish(pendingSuccess!),
              child: Text(saving ? 'Saving…' : 'Retry save'),
            ),
          ] else if (reviewing) ...[
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(() {
                  revealed = !revealed;
                }),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      LanguageLabel(
                        revealed
                            ? current.words[current.numWord].meaningLang
                            : current.words[current.numWord].wordLang,
                      ),
                      const SizedBox(height: 28),
                      Text(
                        revealed
                            ? current.words[current.numWord].meaning
                            : current.words[current.numWord].actualWord,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 28),
                      TextButton.icon(
                        onPressed: () => setState(() {
                          revealed = !revealed;
                        }),
                        icon: const Icon(Icons.flip),
                        label: Text(revealed ? 'Show word' : 'Reveal meaning'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                if (current.numWord + 1 == current.words.length &&
                    current.questions.isEmpty) {
                  finish(true);
                } else {
                  setState(() {
                    current.numWord++;
                    revealed = false;
                  });
                }
              },
              child: Text(
                current.numWord + 1 == current.words.length
                    ? (current.questions.isEmpty
                          ? 'Finish review'
                          : 'Start questions')
                    : 'Next word',
              ),
            ),
          ] else ...[
            Text(
              current.questions[current.numQues].question,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            ...current.questions[current.numQues].answers.asMap().entries.map((
              entry,
            ) {
              final correct =
                  current.questions[current.numQues].correct == entry.key;
              final isSelected = selected == entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(20),
                    foregroundColor: ink,
                    disabledForegroundColor: ink,
                    backgroundColor: checked && correct
                        ? const Color(0xFFDCEBD4)
                        : isSelected
                        ? const Color(0xFFE7EADB)
                        : Colors.white,
                    side: BorderSide(
                      color: isSelected ? forest : const Color(0xFFD5DDD6),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: checked
                      ? null
                      : () => setState(() {
                          selected = entry.key;
                        }),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.value.text,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      if (checked && correct)
                        const Icon(
                          Icons.check_circle,
                          semanticLabel: 'Correct answer',
                        )
                      else if (checked && isSelected)
                        const Icon(
                          Icons.cancel_outlined,
                          semanticLabel: 'Incorrect answer',
                        )
                      else if (isSelected)
                        const Icon(Icons.radio_button_checked),
                    ],
                  ),
                ),
              );
            }),
            if (checked)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    answers.last
                        ? 'That’s right. Nicely remembered!'
                        : 'Keep this one in mind. The correct answer is highlighted.',
                  ),
                ),
              ),
            FilledButton(
              onPressed: selected == null
                  ? null
                  : () {
                      if (checked) {
                        if (current.heart == 0 ||
                            current.numQues + 1 >= current.questions.length) {
                          finish(current.heart > 0);
                        } else {
                          setState(() {
                            current.numQues++;
                            selected = null;
                            checked = false;
                          });
                        }
                      } else {
                        setState(() {
                          final correct =
                              selected ==
                              current.questions[current.numQues].correct;
                          answers.add(correct);
                          if (!correct) current.heart--;
                          checked = true;
                        });
                      }
                    },
              child: Text(
                checked
                    ? (current.heart == 0 ||
                              current.numQues + 1 >= current.questions.length
                          ? 'Finish lesson'
                          : 'Next question')
                    : 'Check answer',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
