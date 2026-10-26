import unittest
from server import review, lesson_options, lesson_plan


class Engine:
    def __init__(self, choice='review', confidence=0.95, correct=0.95):
        self.choice, self.confidence, self.correct = choice, confidence, correct
        self.calls = []

    def predict(self, **kwargs):
        self.calls.append(kwargs)
        if 'option-0-0' in kwargs['questions']:
            return {'answers': {
                'option-0-0': {'choice': 'correct', 'max_probability': .95},
                'option-0-1': {'choice': 'incorrect', 'max_probability': .95},
            }}
        if 'correctness' in kwargs['questions']:
            return {'answers': {'correctness': {'probabilities': {
                'correct': self.correct, 'incorrect': 1 - self.correct},
                'max_probability': max(self.correct, 1 - self.correct)}}}
        return {'answers': {'decision': {'choice': self.choice, 'max_probability': self.confidence}}}


class DecisionsTest(unittest.TestCase):
    def test_new_word_is_scored_without_saved_references(self):
        engine = Engine(correct=.93)
        result = review(engine, dict(word='book', meaning='کتاب', wordLang='English', meaningLang='Persian'))
        self.assertEqual('scored', result['status'])
        self.assertEqual(.93, result['correctnessProbability'])
        self.assertEqual(1, len(engine.calls))
        self.assertIn('کتاب', engine.calls[0]['state'])
        self.assertIn('Persian', engine.calls[0]['state'])
        self.assertEqual({'correct', 'incorrect'}, set(engine.calls[0]['questions']['correctness']['criteria']))

    def test_returns_correct_probability_not_winning_incorrect_probability(self):
        result = review(Engine(correct=.08), dict(word='book', meaning='آب', wordLang='English', meaningLang='Persian'))
        self.assertEqual(.08, result['correctnessProbability'])

    def test_invalid_inputs_and_probabilities_are_rejected(self):
        data = dict(word='book', meaning='کتاب', wordLang='English', meaningLang='Persian')
        for probability in [float('nan'), float('inf'), -.1, 1.1]:
            with self.assertRaises(ValueError):
                review(Engine(correct=probability), data)
        with self.assertRaises(ValueError):
            review(Engine(), {**data, 'word': 'x' * 201})
        with self.assertRaises(ValueError):
            review(Engine(), {**data, 'meaningLang': 'Unknown'})

    def test_lesson_choices_use_progress_and_limit_reverse(self):
        engine = Engine('review')
        self.assertEqual({'modes': {'one': 'review'}}, lesson_plan(engine, {'words': [{'id': 'one', 'progress': 10}]}))
        self.assertNotIn('reverse', engine.calls[0]['questions']['decision']['criteria'])
        engine = Engine('reverse')
        self.assertEqual('reverse', lesson_plan(engine, {'words': [{'id': 'one', 'progress': 90}]})['modes']['one'])

    def test_bad_and_low_confidence_plans_fall_back(self):
        self.assertEqual({'modes': {}}, lesson_plan(Engine('review', .6), {'words': [{'id': 'one', 'progress': 10}]}))
        with self.assertRaises(ValueError):
            lesson_plan(Engine('reverse'), {'words': [{'id': 'one', 'progress': 10}]})
        with self.assertRaises(ValueError):
            lesson_plan(Engine('review'), {'words': [{'id': 'one', 'progress': float('nan')}]})

    def test_lesson_options_keep_only_confidently_incorrect_distractors(self):
        engine = Engine()
        result = lesson_options(engine, {'questions': [{
            'id': 'book', 'prompt': 'book', 'promptLang': 'English',
            'answerLang': 'Persian', 'correct': 'کتاب',
            'candidates': ['دفتر', 'آب'],
        }]})
        self.assertEqual({'options': {'book': ['آب']}}, result)
        self.assertEqual(1, len(engine.calls))
        self.assertIn('کتاب', engine.calls[0]['state'])
        self.assertIn('candidate 2', engine.calls[0]['questions']['option-0-1']['instructions'])

    def test_lesson_options_reject_invalid_input_and_uncertain_predictions(self):
        with self.assertRaises(ValueError):
            lesson_options(Engine(), {'questions': [{'id': 'x'}]})
        engine = Engine()
        engine.predict = lambda **kwargs: {'answers': {
            'option-0-0': {'choice': 'incorrect', 'max_probability': .6},
        }}
        data = {'questions': [{'id': 'x', 'prompt': 'book', 'promptLang': 'English',
                'answerLang': 'Persian', 'correct': 'کتاب', 'candidates': ['آب']}]}
        self.assertEqual({'options': {'x': []}}, lesson_options(engine, data))


if __name__ == '__main__':
    unittest.main()
