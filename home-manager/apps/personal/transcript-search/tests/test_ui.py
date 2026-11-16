"""Exercise the actual fzf UI inside a terminal, without launching a player."""
import fcntl
import os
from pathlib import Path
import pty
import re
import select
import shutil
import signal
import struct
import sys
import tempfile
import termios
import time
import unittest


@unittest.skipUnless(shutil.which('fzf') and shutil.which('rg'), 'requires fzf and rg')
class TerminalTests(unittest.TestCase):
    def test_search_workflow(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for folder in ('a', 'b'):
                (root / folder).mkdir()
                (root / folder / 'lecture.txt').write_text(f'[00:00:01] memory {folder}\n')
                (root / folder / 'lecture.mp4').touch()
            player = root / 'player'
            log = root / 'opened'
            player.write_text(f'#!{sys.executable}\nimport sys\nfrom pathlib import Path\nPath({str(log)!r}).write_text(repr(sys.argv))\n')
            player.chmod(0o755)
            pid, fd = pty.fork()
            if pid == 0:
                fcntl.ioctl(0, termios.TIOCSWINSZ, struct.pack('HHHH', 40, 200, 0, 0))
                os.environ.update(TRANSCRIPT_ROOT=str(root), VIDEO_ROOT=str(root), MPV_BIN=str(player),
                                  TERM='xterm-256color', FZF_DEFAULT_OPTS='', FZF_DEFAULT_OPTS_FILE='/dev/null')
                script = str(Path(__file__).resolve().parents[1] / 'search')
                os.execv(sys.executable, [sys.executable, script])

            def exchange(keys=b'', wait=0.5):
                os.write(fd, keys)
                output = b''
                deadline = time.monotonic() + wait
                while time.monotonic() < deadline:
                    if select.select([fd], [], [], 0.03)[0]:
                        try:
                            data = os.read(fd, 65536)
                        except OSError:
                            break
                        output += data
                        if b'\x1b[6n' in data:
                            os.write(fd, b'\x1b[1;1R')
                        if b'\x1b[?2004$p' in data:
                            os.write(fd, b'\x1b[?2004;2$y')
                return re.sub(rb'\x1b\[[0-?]*[ -/]*[@-~]', b'', output).decode(errors='replace')

            try:
                self.assertIn('Regex>', exchange(wait=1.5))
                self.assertIn('memory a', exchange(b'/memory/gi'))
                exchange(b'\r')
                self.assertTrue(log.exists(), 'RET should launch the player')
                self.assertIn('lecture.mp4', log.read_text())
                self.assertIn('Literal>', exchange(b'\x0c'))
                self.assertIn('No matches', exchange(b'\x15nothing'))
                self.assertIn('memory a', exchange(b'\x15memory'))
                exchange(b'\x01\x0b')  # C-a C-k: kill query to the end.
                self.assertIn('memory a', exchange(b'\x19'))  # C-y restores it.
                self.assertIn('Directories>', exchange(b'\x1bs', wait=2))
                exchange(b'\t\t')  # Deselect all transcripts; select directory a.
                exchange(b'\r')
                exchange(b'\r')
                self.assertIn(str(root / 'a' / 'lecture.mp4'), log.read_text())
                self.assertIn('M-x', exchange(b'\x1bx', wait=1.5))
                exchange(b'all-directories')
                self.assertIn('memory b', exchange(b'\r'))
                self.assertIn('Concepts>', exchange(b'\x12'))
                self.assertIn('memory a', exchange(b'\x14'))
                self.assertIn('Keys>', exchange(b'\x08', wait=1.5))
                exchange(b'k')
                exchange(b'\x1b')
                self.assertIn('M-x', exchange(b'\x1bx', wait=1.5))
                exchange(b'literal')
                self.assertIn('Literal>', exchange(b'\r'))
            finally:
                exchange(b'\x07', wait=0.2)
                try:
                    os.kill(pid, signal.SIGTERM)
                except ProcessLookupError:
                    pass
                os.waitpid(pid, 0)
                os.close(fd)
