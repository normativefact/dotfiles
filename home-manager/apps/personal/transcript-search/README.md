# Transcript Search

Launch **Transcript Search** from Fuzzel or Rofi's application menu. Type a ripgrep regular expression; matching transcript lines and nearby context appear as you type. Enter opens the selected video in MPV at the timestamp. Ctrl-O offers MPV (selected by default) and Zen Browser. Escape exits.

Search is case-insensitive unless the query contains uppercase letters. Invalid regular expressions and queries with no matches show an empty list. Transcripts must have a timestamp at the beginning of the matching line, in `[HH:MM:SS]` or `[HH:MM:SS.fraction]` format. Each transcript's relative path must match an `.mp4` file under `~/ics-video-original`. Zen receives a percent-encoded local file URL with a media fragment; seeking depends on its media support.

The Home Manager module packages the script and its dependencies, exposes `transcript-search` on PATH, and installs an XDG desktop entry that launches it in Kitty. It requires `inputs.zen-browser` in Home Manager's `extraSpecialArgs`, as in this configuration. To integrate it into the existing flake, copy `search` and `home-manager.nix` into `~/nix/home-manager/apps/transcript-search/` and add `./transcript-search/home-manager.nix` to the imports in `~/nix/home-manager/apps/default.nix`. Include the new files in the Git flake source, then rebuild Home Manager.

For direct execution, `search` requires Python 3, ripgrep, fzf, MPV, and Zen (`zen-beta`) on PATH. `TRANSCRIPT_ROOT`, `VIDEO_ROOT`, `MPV_BIN`, and `BROWSER_BIN` override their defaults.
