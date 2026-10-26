import subprocess
import unittest
from unittest.mock import Mock
from server import complete


class CompletionTests(unittest.TestCase):
    def test_uses_encoder_decoder_cli_with_literal_prompt_and_removes_end_marker(self):
        runner = Mock(return_value=subprocess.CompletedProcess([], 0, ' کتاب [end of text]\n', ''))
        result = complete({'prompt': '<2fa> book', 'max_tokens': 160}, runner)
        self.assertEqual({'choices': [{'text': 'کتاب', 'finish_reason': 'stop'}]}, result)
        args = runner.call_args.args[0]
        self.assertEqual('llama-completion', args[0])
        self.assertEqual('<2fa> book', args[args.index('-p') + 1])
        self.assertNotIn('shell', runner.call_args.kwargs)
        self.assertEqual(55, runner.call_args.kwargs['timeout'])

    def test_rejects_bad_language_tags_and_oversized_requests_before_inference(self):
        runner = Mock()
        for data in [{'prompt': '>>fas<< book'}, {'prompt': '<2fa> ' + 'x' * 201},
                     {'prompt': '<2fa> book', 'max_tokens': 1000}, {'prompt': '<2fa> book', 'stream': True}]:
            with self.assertRaises(ValueError):
                complete(data, runner)
        runner.assert_not_called()

    def test_partial_output_is_marked_as_truncated_and_empty_output_rejected(self):
        runner = Mock(return_value=subprocess.CompletedProcess([], 0, 'unfinished', ''))
        self.assertEqual('length', complete({'prompt': '<2en> کتاب'}, runner)['choices'][0]['finish_reason'])
        runner.return_value.stdout = ' [end of text]\n'
        with self.assertRaises(RuntimeError):
            complete({'prompt': '<2en> کتاب'}, runner)

    def test_timeout_and_process_errors_propagate_to_http_unavailable_handler(self):
        runner = Mock(side_effect=subprocess.TimeoutExpired('llama-completion', 55))
        with self.assertRaises(subprocess.TimeoutExpired):
            complete({'prompt': '<2en> کتاب'}, runner)


if __name__ == '__main__':
    unittest.main()
