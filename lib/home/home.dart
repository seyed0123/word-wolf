import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:word_wolf/home/User.dart';
import 'package:word_wolf/request.dart';
import '../app_theme.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User? user;
  String? error;
  static const levels = [
    'Clown',
    'Noob',
    'Novice',
    'Average',
    'Sigma',
    'Chad',
    'Absolute Chad',
    'Giga Chad',
    'Absolute Giga Chad',
  ];

  @override
  void initState() {
    super.initState();
    getUser();
  }

  Future<void> getUser() async {
    try {
      final token = await getToken();
      if (!mounted) return;
      if (token == null) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
        return;
      }
      final response = await sendGetRequest(token, 'get_user');
      final data = User.fromJson(jsonDecode(response));
      if (mounted)
        setState(() {
          user = data;
          error = null;
        });
    } catch (_) {
      if (mounted)
        setState(() {
          error = 'Could not load your progress. Please try again.';
        });
    }
  }

  Future<void> open(String route) async {
    await Navigator.pushNamed(context, route);
    if (mounted) getUser();
  }

  void showLevels() => showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .7,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Your streak journey',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...levels.asMap().entries.map(
              (entry) => ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage('assets/${entry.value}.jpg'),
                ),
                title: Text(entry.value),
                subtitle: Text('${pow(2, entry.key - 1).floor()}+ days'),
                trailing: user?.strikeLevelName == entry.value
                    ? const Icon(Icons.check_circle, color: forest)
                    : null,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget destination(
    IconData icon,
    String title,
    String subtitle,
    String route,
  ) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: Icon(icon, color: forest),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward, size: 20),
      onTap: () => open(route),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'word wolf',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -.8),
        ),
        actions: [
          IconButton(
            tooltip: 'Account settings',
            onPressed: () => open('/setting'),
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: user == null
          ? Center(
              child: error == null
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: getUser,
                          child: const Text('Try again'),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/login'),
                          child: const Text('Sign in'),
                        ),
                      ],
                    ),
            )
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: getUser,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1040),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              'YOUR DAILY PRACTICE',
                              style: TextStyle(
                                color: forest,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.8,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Welcome back, ${user!.username}.',
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Small steps today. More words for your world.',
                              style: TextStyle(fontSize: 17),
                            ),
                            if (error != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text(error!),
                              ),
                            const SizedBox(height: 32),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final practice = Container(
                                  padding: const EdgeInsets.all(28),
                                  decoration: BoxDecoration(
                                    color: forest,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.school_outlined,
                                        color: Color(0xFFD6E7B5),
                                        size: 32,
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        user!.isPracticeToday
                                            ? 'Keep your momentum.'
                                            : 'A few words. A fresh start.',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 27,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Review your vocabulary, then test what you remember. Your less familiar words come first.',
                                        style: TextStyle(
                                          color: Color(0xFFE1E9DF),
                                          height: 1.6,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      FilledButton.icon(
                                        style: FilledButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFD6E7B5,
                                          ),
                                          foregroundColor: ink,
                                        ),
                                        onPressed: () => open('/lesson'),
                                        icon: const Icon(Icons.arrow_forward),
                                        label: const Text('Start a lesson'),
                                      ),
                                    ],
                                  ),
                                );
                                final progress = Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 28,
                                              backgroundImage: AssetImage(
                                                'assets/${user!.strikeLevelName}.jpg',
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    user!.strikeLevelName,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  Text('Level ${user!.level}'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        Text(
                                          '${user!.xp} XP',
                                          style: const TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        LinearProgressIndicator(
                                          value:
                                              (user!.xp / pow(10, user!.level))
                                                  .clamp(0.0, 1.0),
                                          minHeight: 8,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${pow(10, user!.level).toInt()} XP to the next level',
                                        ),
                                        const Divider(height: 32),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons
                                                  .local_fire_department_outlined,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                '${user!.strike}-day streak · ${user!.isPracticeToday ? "Practiced today" : "Let’s practice"}',
                                              ),
                                            ),
                                          ],
                                        ),
                                        TextButton(
                                          onPressed: showLevels,
                                          child: const Text(
                                            'Explore streak levels',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                                return constraints.maxWidth < 760
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          practice,
                                          const SizedBox(height: 20),
                                          progress,
                                        ],
                                      )
                                    : Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(flex: 3, child: practice),
                                          const SizedBox(width: 24),
                                          Expanded(flex: 2, child: progress),
                                        ],
                                      );
                              },
                            ),
                            const SizedBox(height: 36),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Build your vocabulary',
                                    style: TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () => open('/new_word'),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add word'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            destination(
                              Icons.book_outlined,
                              'My words',
                              'Revisit your collection and track each word.',
                              '/word_list',
                            ),
                            const SizedBox(height: 12),
                            destination(
                              Icons.search,
                              'Find a word',
                              'Search by word, meaning, or language.',
                              '/search',
                            ),
                            const SizedBox(height: 12),
                            destination(
                              Icons.explore_outlined,
                              'Popular words',
                              'Discover what other learners are saving.',
                              '/popular_word',
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
