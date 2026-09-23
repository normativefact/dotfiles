{pkgs, ...}: {
  programs.yazi = {
    enable = true;
    # 1. System packages available to Yazi at runtime
    extraPackages = with pkgs; [
      mediainfo # Video/Audio metadata layouts
      duckdb # High-speed CSV/TSV table engine
      glow # Markdown CLI tool (used by Piper)
      wl-clipboard # System copy-paste engine for Wayland
    ];

    enableNushellIntegration = true;
    # 2. Only pull active, modern plugins
    plugins = {
      git = pkgs.yaziPlugins.git;
      mediainfo = pkgs.yaziPlugins.mediainfo;
      duckdb = pkgs.yaziPlugins.duckdb;
      piper = pkgs.yaziPlugins.piper;
    };

    # 3. yazi.toml assignments
    settings = {
      plugin = {
        prepend_previewers = [
        { url = "*.csv"; run = "duckdb"; }
        { url = "*.tsv"; run = "duckdb"; }
        { url = "*.md";  run = "piper -- glow --style=dark \"$1\""; }
        { mime = "{image,audio,video}/*"; run = "mediainfo"; }
        { mime = "application/x-subrip";   run = "mediainfo"; }
        ];
      };
    };

    # 4. Global Lua triggers
    initLua = ''
      require("git"):setup()
    '';
  };
}
