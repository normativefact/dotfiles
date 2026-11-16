# Transcript Search

Launch **Transcript Search** from Fuzzel or Rofi's application menu. It starts in live PCRE2 transcript search. `C-t` selects regex mode, `C-l` selects literal text search, and `C-r` selects fuzzy search over indexed concepts. Switching modes retains the query. `RET` opens the selected timestamp in MPV; `C-o` offers MPV (selected by default) and Zen Browser. Opening a video keeps the current query, mode, directory scope, and selection. `C-g` or `Esc` exits. Key names use Emacs notation: `C-t` means Ctrl+t, `M-x` means Alt+x, and `M-<` means Alt+<.

`M-x` opens a searchable command palette with command names, descriptions, and bindings. It includes query editing and navigation commands. `C-h` opens a searchable key reference. Auxiliary pickers return to the existing search when dismissed; `RET` runs the selected command in the palette.

`M-s` opens a directory picker built from directories containing searchable transcripts, including their ancestors. Use `Tab` to toggle folders, then `RET` to search their union recursively. Deselect **All transcripts** before narrowing to particular directories. Parent selections include their children. `M-a` in the picker resets the scope to all transcripts; `Esc` cancels. The active scope appears beside the search status and applies to regex, literal, and concept searches. You can also run `all-directories` through `M-x`.

| Keys | Action |
| --- | --- |
| `C-n` / `C-p` | Next / previous result. |
| `M-<` / `M->` | First / last result. |
| `C-a` / `C-e` | Beginning / end of query. |
| `C-b` / `C-f` | Backward / forward character. |
| `M-b` / `M-f` | Backward / forward word. |
| `C-k` / `C-y` | Kill to end / yank. |
| `C-u` | Kill to beginning. |
| `C-w` / `M-DEL` | Kill preceding word (whitespace-delimited with `C-w`). |
| `M-d` | Kill following word. |
| `M-v` | Toggle transcript preview. |
| `M-p` / `M-n` | Scroll preview by a page. |
| `S-Up` / `S-Down` | Scroll preview by a line. |

Regex and literal matches are highlighted in the result list and full transcript preview. The preview opens around the selected line and can scroll through the rest of the transcript. Search state lasts for the current session; no query history is saved across sessions.

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

The Home Manager module (`transcript-search.nix`) packages the script and its dependencies, exposes `transcript-search` on PATH, and installs an XDG desktop entry that launches it in Kitty. It requires `inputs.zen-browser` in Home Manager's `extraSpecialArgs`, as in this configuration. Import the module into Home Manager, include its files in the Git flake source, and rebuild Home Manager to update the installed launcher.

For direct execution, `search` requires Python 3, ripgrep with PCRE2 support, fzf, MPV, and Zen (`zen-beta`) on PATH. `TRANSCRIPT_ROOT`, `VIDEO_ROOT`, `MPV_BIN`, and `BROWSER_BIN` override their defaults. Run regression tests with `python3 -m unittest discover -s tests`.
