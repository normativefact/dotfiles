{ pkgs, ... }:

{
  # 1. AI Tooling Packages
  home.packages = with pkgs; [
    aider-chat
    mods
    wl-clipboard
    jq
  ];

  # 2. Nushell Aliases for AI
  programs.nushell.shellAliases = {
    # Interactive Aider sessions (Claude-Code workflow)
    aider-qwen     = "aider --model openrouter/qwen/qwen-2.5-coder-32b-instruct";
    aider-free     = "aider --model groq/llama-3.3-70b-versatile";
    aider-deepseek = "aider --model deepseek/deepseek-chat";

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

  # 4. Declarative Aider Config (~/.aider.conf.yml)
  home.file.".aider.conf.yml".text = ''
    model: openrouter/qwen/qwen-2.5-coder-32b-instruct
    dark-mode: true
    stream: true
    auto-commits: true
    attribute-commit-message-author: false
  '';
}
