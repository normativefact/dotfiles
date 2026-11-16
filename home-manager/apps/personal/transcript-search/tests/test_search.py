import contextlib
import importlib.machinery
import importlib.util
import io
from pathlib import Path
import tempfile
import unittest


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
        self.assertEqual(self.run_query('nonexistent'), ('No matches', []))
        self.assertEqual(self.run_query('//g')[1], [1, 2, 3, 4, 5, 6])


if __name__ == '__main__':
    unittest.main()
