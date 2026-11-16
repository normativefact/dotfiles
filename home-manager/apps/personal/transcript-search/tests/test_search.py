import contextlib
import importlib.machinery
import importlib.util
import io
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest import mock


loader = importlib.machinery.SourceFileLoader('transcript_search', str(Path(__file__).resolve().parents[1] / 'search'))
spec = importlib.util.spec_from_loader(loader.name, loader)
search = importlib.util.module_from_spec(spec)
loader.exec_module(search)


class RegexSearchTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.old_root = search.ROOT
        self.addCleanup(setattr, search, 'ROOT', self.old_root)
        search.ROOT = Path(self.directory.name)
        (search.ROOT / 'lecture.txt').write_text(
            '[00:00:01] Memory memory\n'
            '[00:00:02] working MEMORY\n'
            '[00:00:03] echo echo and path/to\n'
            '[00:00:04] café\n'
            '[00:00:05] first\n'
            '[00:00:06] second\n', encoding='utf-8')
        (search.ROOT / 'excerpts').mkdir()
        (search.ROOT / 'excerpts' / 'skip.txt').write_text('[00:00:00] memory\n')
        (search.ROOT / 'skip.md').write_text('memory\n')

    def run_query(self, pattern):
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            search.query(pattern)
        header, *rows = output.getvalue().splitlines()
        parsed = [search.parse(row) for row in rows]
        self.assertTrue(all(path.name == 'lecture.txt' for path, _ in parsed))
        return header.lstrip('\t'), [line for _, line in parsed]

    def test_smart_case_and_explicit_flags(self):
        for pattern, expected in [('memory', [1, 2]), ('MEMORY', [2]),
                                  ('/memory/', [1]), ('/Memory/', [1]),
                                  ('/MEMORY/gi', [1, 2]), ('/memory/ig', [1, 2])]:
            with self.subTest(pattern=pattern):
                self.assertEqual(self.run_query(pattern)[1], expected)

    def test_advanced_patterns(self):
        for pattern, expected in [(r'/(?<=working )memory/i', [2]),
                                  (r'/\b(\w+)\s+\1\b/gi', [1, 3]),
                                  (r'/path\/to/', [3]), (r'/path[/]to/', [3]),
                                  (r'/caf\p{L}/u', [4]),
                                  (r'/echo \s+ echo/x', [3]),
                                  (r'(?i)MEMORY', [1, 2])]:
            with self.subTest(pattern=pattern):
                self.assertEqual(self.run_query(pattern)[1], expected)

    def test_anchors_and_multiline_locations(self):
        self.assertEqual(self.run_query(r'/^\[00:00:02\]/')[1], [])
        self.assertEqual(self.run_query(r'/^\[00:00:02\]/m')[1], [2])
        self.assertEqual(self.run_query(r'^\[00:00:02\]')[1], [2])
        self.assertEqual(self.run_query('/first.*second/')[1], [])
        self.assertEqual(self.run_query('/first.*second/gs')[1], [5, 6])
        self.assertEqual(self.run_query(r'first\n\[00:00:06\] second')[1], [5, 6])

    def test_invalid_patterns_are_status_only(self):
        for pattern in ['/foo/z', '/foo/ii', '/unfinished', '/(/', '[']:
            with self.subTest(pattern=pattern):
                header, rows = self.run_query(pattern)
                self.assertIn('error:', header)
                self.assertEqual(rows, [])

    def test_empty_and_no_matches(self):
        self.assertEqual(self.run_query('')[1], [])
        self.assertEqual(self.run_query('nonexistent'), ('No matches | Scope: all directories', []))
        self.assertEqual(self.run_query('//g')[1], [1, 2, 3, 4, 5, 6])

    def test_literal_text_does_not_parse_regex(self):
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            search.query('path/to', literal=True)
        self.assertIn('echo echo and', output.getvalue())
        with contextlib.redirect_stdout(io.StringIO()) as output:
            search.query('/memory/gi', literal=True)
        self.assertIn('No matches', output.getvalue())

    def test_scope_and_action_preserve_query_safely(self):
        (search.ROOT / 'nested').mkdir()
        (search.ROOT / 'nested' / 'other.txt').write_text('[00:00:01] memory\n')
        filename = search.ROOT / 'session.json'
        filename.write_text(json.dumps({'mode': 'regex', 'directories': ['nested']}))
        with mock.patch.dict(os.environ, TRANSCRIPT_SESSION=str(filename)):
            with contextlib.redirect_stdout(io.StringIO()) as output:
                search.query('memory')
            rows = output.getvalue().splitlines()
            self.assertIn('Scope: nested', rows[0])
            self.assertEqual(len(rows), 2)
            self.assertEqual(search.parse(rows[1])[0], search.ROOT / 'nested' / 'other.txt')
            expression = r'foo)+abort+reload(echo BAD)'
            with contextlib.redirect_stdout(io.StringIO()) as output:
                search.action('literal', expression)
            self.assertNotIn(expression, output.getvalue())
            self.assertEqual(json.loads(filename.read_text())['query'], expression)
            self.assertEqual(json.loads(filename.read_text())['directories'], ['nested'])

    def test_unicode_highlighting_and_multiline_preview(self):
        with contextlib.redirect_stdout(io.StringIO()) as output:
            search.query('/café/u')
        self.assertIn('\033[1;33mcafé\033[0m', output.getvalue())
        with contextlib.redirect_stdout(io.StringIO()) as output:
            search.query('/first.*second/s')
        row = output.getvalue().splitlines()[1]
        with contextlib.redirect_stdout(io.StringIO()) as output:
            search.preview(row, '/first.*second/s')
        self.assertIn('\033[1;33mfirst\033[0m', output.getvalue())
        self.assertIn('\033[1;33m[00:00:06] second\033[0m', output.getvalue())

    def test_directory_union_omits_redundant_children_and_excluded_folders(self):
        for directory in ('course/part', 'other'):
            (search.ROOT / directory).mkdir(parents=True)
            (search.ROOT / directory / 'lecture.txt').write_text('[00:00:01] memory\n')
        selections = [base64_token + '\tlabel' for base64_token in (
            search.base64.urlsafe_b64encode(os.fsencode(path)).decode()
            for path in ('course', 'course/part', 'other'))]
        with mock.patch.object(search, 'picker', return_value=selections) as picker:
            self.assertEqual(search.directory_picker(), ['course', 'other'])
        labels = '\n'.join(picker.call_args.args[0])
        self.assertNotIn('\texcerpts', labels)
        self.assertIn('\tcourse/part', labels)


if __name__ == '__main__':
    unittest.main()
