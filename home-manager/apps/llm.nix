{ pkgs, ... }:

{
  # 1. AI Tooling Packages
  home.packages = with pkgs; [
    codex
    bubblewrap
    mods
    wl-clipboard
    jq
  ];

  # 2. Nushell Aliases for AI
  programs.nushell.shellAliases = {
    # Quick piping via Mods
    ask            = "mods";
    ask-qwen       = "mods --api openrouter -m qwen/qwen-2.5-coder-32b-instruct";
    ask-free       = "mods --api groq -m llama-3.3-70b-versatile";
  };

  # 3. Declarative Mods Config (~/.config/mods/mods.yml)
  xdg.configFile."mods/mods.yml".text = ''
    default-api: openrouter
    default-model: qwen/qwen-2.5-coder-32b-instruct
    format-as: markdown
    apis:
      openrouter:
        base-url: https://openrouter.ai/api/v1
        api-key-env: OPENROUTER_API_KEY
        models:
          qwen/qwen-2.5-coder-32b-instruct:
            aliases: ["qwen", "default"]
            max-input-chars: 128000
      groq:
        base-url: https://api.groq.com/openai/v1
        api-key-env: GROQ_API_KEY
        models:
          llama-3.3-70b-versatile:
            aliases: ["groq", "free"]
            max-input-chars: 128000
      deepseek:
        base-url: https://api.deepseek.com
        api-key-env: DEEPSEEK_API_KEY
        models:
          deepseek-chat:
            aliases: ["deepseek"]
            max-input-chars: 64000
  '';

}
