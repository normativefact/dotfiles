# Transcript Search

Launch **Transcript Search** from Fuzzel or Rofi's application menu. It starts with fuzzy search over indexed concepts. **Ctrl-T** switches to live PCRE2 search over transcript text; **Ctrl-R** returns to concepts. Enter opens the selected video in MPV at the timestamp. Ctrl-O offers MPV (selected by default) and Zen Browser. Escape exits.

Regex search accepts bare PCRE2 patterns or `/pattern/flags` literals. Bare patterns use smart case (case-insensitive unless they contain uppercase letters) and line anchors. Slash literals are case-sensitive unless `i` is present; `^` and `$` anchor to the file unless `m` is present. Lookarounds, backreferences, named groups, Unicode properties, and inline modifiers are supported. This is PCRE2 syntax, rather than a JavaScript engine.

| Flag | Meaning |
| --- | --- |
| `g` | Accepted; search always returns all matching lines, once per line. |
| `i` | Case-insensitive matching. |
| `m` | `^` and `$` match line boundaries. |
| `s` | Dot also matches newlines. |
| `u` | Accepted; Unicode is always enabled. |
| `x` | Extended mode: ignore unescaped whitespace and allow `#` comments. |

Examples: `/\b(memory|attention)\b/gi`, `/(?<=working )memory/i`, `/\b(\w+)\s+\1\b/gi`, `/^\[00:12:/m`, `/first.*second/gis`. Escape delimiters as `\/`, or put a slash in a character class such as `[/]`. A query starting with `/` is treated as a slash literal; use `[/]path` for a bare pattern starting with a literal slash. Duplicate or unsupported flags and invalid expressions appear in the result header, with no selectable results. No matches has its own status.

Patterns can span lines using `\n`, `\s`, or dot with `s`; each line covered by a match keeps its original preview and seek location. Transcripts must have a timestamp at the beginning of the selected line, in `[HH:MM:SS]` or `[HH:MM:SS.fraction]` format. Each transcript's relative path must match an `.mp4`, `.mkv`, or `.webm` file under `~/ics-video-original` (checked in that order). Zen receives a percent-encoded local file URL with a media fragment; seeking depends on its media support.

The Home Manager module packages the script and its dependencies, exposes `transcript-search` on PATH, and installs an XDG desktop entry that launches it in Kitty. It requires `inputs.zen-browser` in Home Manager's `extraSpecialArgs`, as in this configuration. To integrate it into the existing flake, copy `search` and `home-manager.nix` into `~/nix/home-manager/apps/transcript-search/` and add `./transcript-search/home-manager.nix` to the imports in `~/nix/home-manager/apps/default.nix`. Include the new files in the Git flake source, then rebuild Home Manager.

For direct execution, `search` requires Python 3, ripgrep with PCRE2 support, fzf, MPV, and Zen (`zen-beta`) on PATH. `TRANSCRIPT_ROOT`, `VIDEO_ROOT`, `MPV_BIN`, and `BROWSER_BIN` override their defaults. Run regression tests with `python3 -m unittest discover -s tests`.
