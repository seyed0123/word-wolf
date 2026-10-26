import 'dart:convert';
import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../request.dart';
import 'word.dart';
import 'language_label.dart';

enum VocabularyView { mine, popular, search }

class VocabularyPage extends StatefulWidget {
  final VocabularyView view;
  const VocabularyPage({super.key, required this.view});
  @override
  State<VocabularyPage> createState() => _VocabularyPageState();
}

class _VocabularyPageState extends State<VocabularyPage> {
  final word = TextEditingController();
  final meaning = TextEditingController();
  String from = 'Any', to = 'Any';
  List<Word> words = [];
  int page = 1;
  bool loading = false, searched = false, hasNext = false;
  String? error;
  final busy = <String>{};
  bool get mine => widget.view == VocabularyView.mine;
  bool get search => widget.view == VocabularyView.search;

  @override
  void initState() {
    super.initState();
    if (!search) load(1);
  }

  @override
  void dispose() {
    word.dispose();
    meaning.dispose();
    super.dispose();
  }

  Future<void> load(int nextPage) async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final token = await getToken();
      final response = search
          ? await sendRequest(
              token!,
              jsonEncode({
                'word': word.text,
                'wordMeaning': meaning.text,
                'wordLang': from,
                'meaningLang': to,
              }),
              'search?page=$nextPage&size=10',
            )
          : await sendGetRequest(
              token ?? '',
              '${mine ? "get_word" : "get_popular_word"}?page=$nextPage&size=10',
            );
      final result = (jsonDecode(response) as List)
          .map((entry) => Word.fromJson(entry))
          .toList();
      if (!mounted) return;
      setState(() {
        searched = true;
        hasNext = result.length == 10;
        if (result.isNotEmpty || nextPage == 1) {
          words = result;
          page = nextPage;
        }
      });
    } catch (_) {
      if (mounted)
        setState(() {
          error = 'Could not load words. Please try again.';
        });
    } finally {
      if (mounted)
        setState(() {
          loading = false;
        });
    }
  }

  Future<void> updateWord(Word entry) async {
    if (mine) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Remove from your words?'),
          content: Text(entry.actualWord),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remove'),
            ),
          ],
        ),
      );
      if (confirm != true || !mounted) return;
    }
    setState(() {
      busy.add(entry.ID);
    });
    try {
      final token = await getToken();
      final response = await sendRequest(
        token!,
        jsonEncode(
          mine
              ? {'id': entry.ID}
              : {
                  'word': entry.actualWord,
                  'wordMeaning': entry.meaning,
                  'wordLang': entry.wordLang,
                  'meaningLang': entry.meaningLang,
                },
        ),
        mine ? 'del_word' : 'add_word',
      );
      if (jsonDecode(response)['message'] != 'ok') throw Exception();
      if (!mounted) return;
      if (mine) await load(page);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mine ? 'Word removed.' : 'Added to your words.'),
          ),
        );
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not update your words. Please try again.'),
          ),
        );
    } finally {
      if (mounted)
        setState(() {
          busy.remove(entry.ID);
        });
    }
  }

  Widget language(
    String label,
    String value,
    ValueChanged<String?> changed,
  ) => DropdownButtonFormField<String>(
    initialValue: value,
    isExpanded: true,
    decoration: InputDecoration(labelText: label),
    items: [
      'Any',
      'English',
      'Persian',
      'German',
      'French',
      'Spanish',
      'Arabic',
    ].map((v) => DropdownMenuItem(value: v, child: LanguageLabel(v))).toList(),
    onChanged: loading ? null : changed,
  );

  @override
  Widget build(BuildContext context) => TaskPage(
    title: mine
        ? 'My words'
        : search
        ? 'Find a word'
        : 'Popular words',
    maxWidth: 880,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          mine
              ? 'Your growing collection.'
              : search
              ? 'Find your next word.'
              : 'A world of words to discover.',
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Text(
          mine
              ? 'Every word you save is another step forward.'
              : 'Explore vocabulary and save something worth remembering.',
        ),
        const SizedBox(height: 24),
        if (search) ...[
          TextField(
            controller: word,
            enabled: !loading,
            decoration: const InputDecoration(labelText: 'Word'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: meaning,
            enabled: !loading,
            decoration: const InputDecoration(labelText: 'Meaning'),
          ),
          const SizedBox(height: 16),
          language(
            'Word language',
            from,
            (v) => setState(() {
              from = v!;
            }),
          ),
          const SizedBox(height: 16),
          language(
            'Meaning language',
            to,
            (v) => setState(() {
              to = v!;
            }),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: loading ? null : () => load(1),
            icon: const Icon(Icons.search),
            label: const Text('Search words'),
          ),
          const SizedBox(height: 24),
        ],
        if (mine)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () async {
                await Navigator.pushNamed(context, '/new_word');
                if (mounted) load(1);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add a word'),
            ),
          ),
        if (loading)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (error != null)
          Column(
            children: [
              Text(error!),
              TextButton(
                onPressed: () => load(page),
                child: const Text('Try again'),
              ),
            ],
          )
        else if (words.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text(
              search && !searched
                  ? 'Search by word, meaning, or either language.'
                  : mine
                  ? 'No words yet. Add your first word to start practicing.'
                  : 'No words found. Try another search or add your own.',
            ),
          )
        else
          ...words.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    LanguageLabel(
                                      entry.wordLang,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelMedium,
                                    ),
                                    const Icon(Icons.arrow_forward, size: 16),
                                    LanguageLabel(
                                      entry.meaningLang,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  entry.actualWord,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  entry.meaning,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: mine ? 'Remove word' : 'Save word',
                            onPressed: busy.contains(entry.ID)
                                ? null
                                : () => updateWord(entry),
                            icon: Icon(
                              mine
                                  ? Icons.delete_outline
                                  : Icons.bookmark_add_outlined,
                            ),
                          ),
                        ],
                      ),
                      if (mine) ...[
                        const SizedBox(height: 20),
                        LinearProgressIndicator(
                          value: (entry.progress / 100).clamp(0, 1),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        Text('${entry.progress.round()}% familiar'),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (words.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: 'Previous page',
                onPressed: !loading && page > 1 ? () => load(page - 1) : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('Page $page'),
              ),
              IconButton(
                tooltip: 'Next page',
                onPressed: !loading && hasNext ? () => load(page + 1) : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
      ],
    ),
  );
}
