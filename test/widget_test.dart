import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_wolf/app_theme.dart';
import 'package:word_wolf/home/home.dart';
import 'package:word_wolf/main.dart';
import 'package:word_wolf/lesson/lesson_page.dart';
import 'package:word_wolf/login/login.dart';
import 'package:word_wolf/words/new_word.dart';
import 'package:word_wolf/words/word_list.dart';
import 'package:word_wolf/words/language_label.dart';

void main() {
  setUp(() {
    dotenv.testLoad(fileInput: 'SERVER_URL=http://localhost/api');
    SharedPreferences.setMockInitialValues({'token': 'test-token'});
  });

  Widget app(Widget screen) =>
      MaterialApp(theme: wordWolfTheme(), home: screen);
  Map<String, dynamic> word(String id) => {
    'id': id,
    'actualWord': 'hello',
    'meaning': 'سلام',
    'wordLang': 'English',
    'meaningLang': 'Persian',
    'progress': 0.0,
  };

  Future<void> choosePersian(WidgetTester tester) async {
    await tester.tap(find.byType(DropdownButtonFormField<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Persian').last);
    await tester.pumpAndSettle();
  }

  testWidgets('Startup creates only the splash route before authentication', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    expect(find.byType(Home, skipOffstage: false), findsNothing);
    expect(find.byKey(const ValueKey(1)), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const ValueKey(2)), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byKey(const ValueKey(1)), findsNothing);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.byType(login), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'stable-user');
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('stable-user'), findsOneWidget);
  });

  for (final size in [const Size(320, 900), const Size(1440, 1000)]) {
    testWidgets('Splash image fills screen height at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(app(const SplashScreen()));
      expect(tester.getSize(find.byKey(const ValueKey(1))).height, size.height);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 550));
      expect(tester.getSize(find.byKey(const ValueKey(2))).height, size.height);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'Language pickers retain flags when the meaning language changes',
    (tester) async {
      await tester.pumpWidget(app(const new_word()));
      await tester.tap(find.byType(DropdownButtonFormField<String>).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Persian').last);
      await tester.pumpAndSettle();
      expect(find.widgetWithText(LanguageLabel, 'Persian'), findsWidgets);
      final images = tester.widgetList<Image>(find.byType(Image));
      expect(
        images.any(
          (image) =>
              image.image is AssetImage &&
              (image.image as AssetImage).assetName ==
                  'assets/flag_of_Persian.png',
        ),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );

  for (final width in [320.0, 768.0, 1024.0, 1440.0]) {
    testWidgets('Word form fits width $width and validates input', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(app(const new_word()));
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Suggest a meaning'));
      await tester.tap(find.text('Suggest a meaning'));
      await tester.pump();
      expect(find.text('Enter a word first.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Same-language suggestions explain that definitions are manual', (
    tester,
  ) async {
    var requests = 0;
    await http.runWithClient(
      () async {
        await tester.pumpWidget(app(const new_word()));
        await tester.enterText(find.byType(TextField).first, 'book');
        await tester.ensureVisible(find.text('Suggest a meaning'));
        await tester.tap(find.text('Suggest a meaning'));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('Choose different languages'),
          findsOneWidget,
        );
        await tester.enterText(
          find.byType(TextField).last,
          'a set of written pages',
        );
        expect(requests, 0);
        expect(find.text('a set of written pages'), findsOneWidget);
      },
      () => MockClient((_) async {
        requests++;
        return http.Response('', 500);
      }),
    );
  });

  testWidgets('Suggestion does not overwrite manual meaning until accepted', (
    tester,
  ) async {
    await http.runWithClient(
      () async {
        await tester.pumpWidget(app(const new_word()));
        await choosePersian(tester);
        await tester.enterText(find.byType(TextField).at(0), 'hello');
        await tester.enterText(find.byType(TextField).at(1), 'my definition');
        await tester.ensureVisible(find.text('Suggest a meaning'));
        await tester.tap(find.text('Suggest a meaning'));
        await tester.pumpAndSettle();
        expect(find.text('سلام'), findsOneWidget);
        expect(find.text('my definition'), findsOneWidget);
        await tester.ensureVisible(find.text('Use this meaning'));
        await tester.tap(find.text('Use this meaning'));
        await tester.pumpAndSettle();
        expect(find.text('my definition'), findsNothing);
        expect(find.text('سلام'), findsOneWidget);
      },
      () => MockClient(
        (request) async => http.Response(
          jsonEncode({'meaning': 'سلام'}),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      ),
    );
  });

  for (final probability in <double?>[0, .08, .93, 1, null]) {
    testWidgets(
      'Julia probability $probability is shown without accepting the suggestion',
      (tester) async {
        await http.runWithClient(
          () async {
            await tester.pumpWidget(app(const new_word()));
            await choosePersian(tester);
            await tester.enterText(find.byType(TextField).first, 'book');
            await tester.enterText(find.byType(TextField).last, 'my meaning');
            await tester.ensureVisible(find.text('Suggest a meaning'));
            await tester.tap(find.text('Suggest a meaning'));
            await tester.pumpAndSettle();
            if (probability == null) {
              expect(
                find.textContaining(
                  'Julia correctness estimate is unavailable',
                ),
                findsOneWidget,
              );
              expect(
                find.textContaining('Estimated correctness:'),
                findsNothing,
              );
            } else {
              expect(
                find.text(
                  'Estimated correctness: ${(probability * 100).toStringAsFixed(1)}%',
                ),
                findsOneWidget,
              );
              expect(
                find.text('Julia-1 model estimate; can be wrong.'),
                findsOneWidget,
              );
            }
            expect(find.text('my meaning'), findsOneWidget);
            expect(find.text('Use this meaning'), findsOneWidget);
          },
          () => MockClient(
            (_) async => http.Response(
              jsonEncode({
                'meaning': 'a book',
                'review': {
                  'status': probability == null ? 'unavailable' : 'scored',
                  if (probability != null)
                    'correctnessProbability': probability,
                  'model': 'Julia-1',
                },
              }),
              200,
            ),
          ),
        );
      },
    );
  }

  testWidgets('Failed suggestions keep manual entry usable', (tester) async {
    await http.runWithClient(() async {
      await tester.pumpWidget(app(const new_word()));
      await choosePersian(tester);
      await tester.enterText(find.byType(TextField).first, 'hello');
      await tester.ensureVisible(find.text('Suggest a meaning'));
      await tester.tap(find.text('Suggest a meaning'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Local suggestions are unavailable'),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextField).last, 'manual definition');
      expect(find.text('manual definition'), findsOneWidget);
    }, () => MockClient((request) async => http.Response('', 503)));
  });

  testWidgets('Stale suggestion is ignored after word changes', (tester) async {
    final response = Completer<http.Response>();
    await http.runWithClient(() async {
      await tester.pumpWidget(app(const new_word()));
      await choosePersian(tester);
      await tester.enterText(find.byType(TextField).first, 'hello');
      await tester.ensureVisible(find.text('Suggest a meaning'));
      await tester.tap(find.text('Suggest a meaning'));
      await tester.pump();
      await tester.enterText(find.byType(TextField).first, 'goodbye');
      response.complete(
        http.Response(
          '{"meaning":"greeting","review":{"status":"scored","correctnessProbability":0.9}}',
          200,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('greeting'), findsNothing);
      expect(find.textContaining('Estimated correctness:'), findsNothing);
    }, () => MockClient((request) => response.future));
  });

  testWidgets('Empty lesson offers a next action', (tester) async {
    await http.runWithClient(
      () async {
        await tester.pumpWidget(app(const Lesson_page()));
        await tester.pumpAndSettle();
        expect(find.text('Add your first word'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
      () => MockClient(
        (request) async =>
            http.Response('{"id":"empty","words":[],"questions":[]}', 200),
      ),
    );
  });

  testWidgets(
    'Single-word review finishes and saves without indexing a question',
    (tester) async {
      var saved = false;
      await http.runWithClient(
        () async {
          await tester.pumpWidget(app(const Lesson_page()));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Reveal meaning'));
          await tester.pumpAndSettle();
          expect(find.text('سلام'), findsOneWidget);
          await tester.ensureVisible(find.text('Finish review'));
          await tester.tap(find.text('Finish review'));
          await tester.pumpAndSettle();
          expect(saved, isTrue);
          expect(find.text('Practice complete'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
        () => MockClient((request) async {
          if (request.method == 'POST') {
            saved = true;
            return http.Response('', 200);
          }
          return http.Response(
            jsonEncode({
              'id': 'lesson',
              'words': [word('one')],
              'questions': [],
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );
    },
  );

  testWidgets('Two-choice lesson provides feedback and retries failed saves', (
    tester,
  ) async {
    var saves = 0;
    await http.runWithClient(
      () async {
        await tester.pumpWidget(app(const Lesson_page()));
        await tester.pumpAndSettle();
        await tester.tap(find.text('greeting'));
        await tester
            .pump(); // Rebuild the submit button after selecting an answer.
        await tester.tap(find.text('Check answer'));
        await tester.pumpAndSettle();
        expect(find.text('That’s right. Nicely remembered!'), findsOneWidget);
        await tester.tap(find.text('Finish lesson'));
        await tester.pumpAndSettle();
        expect(find.text('Retry save'), findsOneWidget);
        await tester.tap(find.text('Retry save'));
        await tester.pumpAndSettle();
        expect(saves, 2);
        expect(find.text('Practice complete'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
      () => MockClient((request) async {
        if (request.method == 'POST')
          return http.Response('', ++saves == 1 ? 503 : 200);
        return http.Response(
          jsonEncode({
            'id': 'lesson',
            'words': [],
            'questions': [
              {
                'question': 'What does hello mean?',
                'answers': ['greeting', 'farewell'],
                'correct': 0,
              },
            ],
          }),
          200,
        );
      }),
    );
  });

  testWidgets(
    'Dashboard retains all learning destinations on a narrow screen',
    (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await http.runWithClient(
        () async {
          await tester.pumpWidget(app(const Home()));
          await tester.pumpAndSettle();
          for (final label in [
            'Start a lesson',
            'Add word',
            'My words',
            'Find a word',
            'Popular words',
            'Explore streak levels',
          ]) {
            expect(find.text(label), findsOneWidget);
          }
          expect(find.byTooltip('Account settings'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
        () => MockClient(
          (request) async => http.Response(
            jsonEncode({
              'id': '1',
              'username': 'Learner',
              'password': '',
              'email': '',
              'xp': 1,
              'level': 1,
              'strike': 0,
              'practiceToday': false,
              'strikeLevel': 0,
              'strikeLevelName': 'Clown',
            }),
            200,
          ),
        ),
      );
    },
  );

  testWidgets('Vocabulary empty state and mobile login do not overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await http.runWithClient(() async {
      await tester.pumpWidget(app(const word_list()));
      await tester.pumpAndSettle();
      expect(find.textContaining('No words yet'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(app(const login()));
      await tester.pumpAndSettle();
      expect(find.text('Sign in'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }, () => MockClient((request) async => http.Response('[]', 200)));
  });
}
