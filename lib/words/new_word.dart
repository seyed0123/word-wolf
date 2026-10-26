import 'dart:convert';
import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../request.dart';
import 'language_label.dart';

class new_word extends StatefulWidget {
  const new_word({super.key});
  @override
  State<new_word> createState() => _NewWordState();
}

class _NewWordState extends State<new_word> {
  final wordController = TextEditingController();
  final meaningController = TextEditingController();
  String from = 'English';
  String to = 'English';
  static const languages = [
    'English',
    'Persian',
    'German',
    'French',
    'Spanish',
    'Arabic',
  ];
  bool suggesting = false;
  bool saving = false;
  String? message;
  String? suggestion;
  double? correctnessProbability;

  String get reviewMessage => correctnessProbability == null
      ? 'Julia correctness estimate is unavailable. You can still use or edit this meaning.'
      : 'Estimated correctness: ${(correctnessProbability! * 100).toStringAsFixed(1)}%';
  bool failed = false;

  @override
  void dispose() {
    wordController.dispose();
    meaningController.dispose();
    super.dispose();
  }

  Future<void> suggest() async {
    final word = wordController.text.trim();
    if (word.isEmpty) {
      setState(() {
        message = 'Enter a word first.';
        failed = true;
      });
      return;
    }
    if (from == to) {
      setState(() {
        message =
            'Choose different languages for translation, or type a definition below.';
        failed = true;
      });
      return;
    }
    final source = from;
    final target = to;
    setState(() {
      suggesting = true;
      correctnessProbability = null;
      suggestion = null;
      message = null;
    });
    try {
      final token = await getToken();
      if (token == null) throw Exception('Sign in again.');
      final response = await sendRequest(
        token,
        jsonEncode({'word': word, 'wordLang': source, 'meaningLang': target}),
        'suggest_meaning',
      ).timeout(const Duration(seconds: 140));
      if (!mounted) return;
      // Ignore an old response if the vocabulary or language changed during inference.
      if (wordController.text.trim() == word &&
          from == source &&
          to == target) {
        setState(() {
          final data = jsonDecode(response) as Map<String, dynamic>;
          suggestion = data['meaning'] as String;
          final review = data['review'];
          final probability = review is Map
              ? review['correctnessProbability']
              : null;
          correctnessProbability =
              review is Map &&
                  review['status'] == 'scored' &&
                  probability is num &&
                  probability.isFinite &&
                  probability >= 0 &&
                  probability <= 1
              ? probability.toDouble()
              : null;
        });
      }
    } catch (_) {
      if (mounted)
        setState(() {
          failed = true;
          message =
              'Local suggestions are unavailable. You can still type a meaning below.';
        });
    } finally {
      if (mounted)
        setState(() {
          suggesting = false;
        });
    }
  }

  Future<void> save() async {
    if (wordController.text.trim().isEmpty ||
        meaningController.text.trim().isEmpty) {
      setState(() {
        message = 'Enter both a word and its meaning.';
        failed = true;
      });
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save this word?'),
        content: Text(
          '${wordController.text.trim()} — ${meaningController.text.trim()}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save word'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      saving = true;
      message = null;
    });
    try {
      final token = await getToken();
      if (token == null) throw Exception('Sign in again.');
      final response = await sendRequest(
        token,
        jsonEncode({
          'word': wordController.text.trim(),
          'wordMeaning': meaningController.text.trim(),
          'wordLang': from,
          'meaningLang': to,
        }),
        'add_word',
      );
      if (jsonDecode(response)['message'] != 'ok')
        throw Exception('Could not save word.');
      if (!mounted) return;
      setState(() {
        wordController.clear();
        meaningController.clear();
        suggestion = null;
        failed = false;
        message = 'Word saved. Ready for your next discovery.';
      });
    } catch (_) {
      if (mounted)
        setState(() {
          failed = true;
          message = 'Could not save your word. Please try again.';
        });
    } finally {
      if (mounted)
        setState(() {
          saving = false;
        });
    }
  }

  Widget language(
    String label,
    String value,
    ValueChanged<String?> onChanged,
  ) => DropdownButtonFormField<String>(
    initialValue: value,
    decoration: InputDecoration(labelText: label),
    isExpanded: true,
    items: languages
        .map(
          (language) =>
              DropdownMenuItem(value: language, child: LanguageLabel(language)),
        )
        .toList(),
    onChanged: saving ? null : onChanged,
  );

  @override
  Widget build(BuildContext context) => TaskPage(
    title: 'Add a word',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'A new word.\nA little more possibility.',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Keep the words you want to remember. Make their meanings your own.',
        ),
        const SizedBox(height: 32),
        LayoutBuilder(
          builder: (context, constraints) {
            final fields = [
              language(
                'Word language',
                from,
                (value) => setState(() {
                  from = value!;
                  suggestion = null;
                }),
              ),
              language(
                'Meaning language',
                to,
                (value) => setState(() {
                  to = value!;
                  suggestion = null;
                }),
              ),
            ];
            return constraints.maxWidth < 450
                ? Column(
                    children: [
                      fields[0],
                      const SizedBox(height: 16),
                      fields[1],
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: fields[0]),
                      const SizedBox(width: 16),
                      Expanded(child: fields[1]),
                    ],
                  );
          },
        ),
        const SizedBox(height: 24),
        TextField(
          controller: wordController,
          enabled: !saving,
          maxLength: 200,
          onChanged: (_) {
            if (suggestion != null)
              setState(() {
                suggestion = null;
              });
          },
          decoration: const InputDecoration(
            labelText: 'Word or phrase',
            hintText: 'What did you discover?',
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: suggesting || saving ? null : suggest,
          icon: suggesting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.auto_awesome_outlined),
          label: Text(
            suggesting ? 'Translating and checking…' : 'Suggest a meaning',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Translated locally with MADLAD. Check the meaning before saving.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (suggestion != null) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SUGGESTED MEANING',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    suggestion!,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 12),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      reviewMessage,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (correctnessProbability != null) ...[
                    const SizedBox(height: 4),
                    const Text('Julia-1 model estimate; can be wrong.'),
                  ],
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: saving
                        ? null
                        : () => setState(() {
                            meaningController.text = suggestion!;
                            suggestion = null;
                          }),
                    icon: const Icon(Icons.south),
                    label: const Text('Use this meaning'),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        TextField(
          controller: meaningController,
          enabled: !saving,
          minLines: 2,
          maxLines: 5,
          maxLength: 1000,
          decoration: const InputDecoration(
            labelText: 'Meaning',
            hintText: 'Write or edit the translation',
          ),
        ),
        if (message != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Semantics(
              liveRegion: true,
              child: Text(
                message!,
                style: TextStyle(
                  color: failed ? Theme.of(context).colorScheme.error : forest,
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: saving ? null : save,
          icon: const Icon(Icons.add),
          label: Text(saving ? 'Saving…' : 'Save word'),
        ),
      ],
    ),
  );
}
