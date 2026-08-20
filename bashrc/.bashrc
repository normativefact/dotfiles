# ==============================================================================
#  CUSTOM .bashrc TEMPLATE
# ==============================================================================

# --- 1. HISTORY CONFIGURATION ---
# Avoid duplicate lines and lines starting with a space in the history
HISTCONTROL=ignoreboth:erasedups
# Append to the history file rather than overwriting it
shopt -s histappend
# Set history length (number of lines in memory and on disk)
HISTSIZE=10000
HISTFILESIZE=20000
# Store timestamps in history (YYYY-MM-DD HH:MM:SS)
HISTTIMEFORMAT="%F %T "

# --- 2. COLOR & PROMPT (PS1) ---
# Enable color support for ls and grep
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# A clean, informative two-line colored prompt: [User@Host:Directory] [Time]
# Top line: Green user/host, Blue directory, Cyan time. Bottom line: Ready indicator.
PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\] \[\e[1;36m\][\t]\[\e[0m\]\n\$ '

# --- 3. QUALITY OF LIFE ALIASES ---
# Navigation shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# Better readability for file listing
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Prevent accidental overwrites/deletions (Safety nets)
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# System health and shortcuts
alias df='df -h' # Human-readable disk free space
alias du='du -h' # Human-readable disk usage
alias path='echo -e ${PATH//:/\\n}' # Display PATH variables cleanly line-by-line
alias mkdir='mkdir -pv' # Make parent directories and print message

# --- 4. USEFUL FUNCTIONS ---
# Create a directory and move into it immediately
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Smart archive extractor (handles almost any file format)
extract() {
    if [ -f "$1" ] ; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# --- 5. ENVIRONMENT VARIABLES ---
export EDITOR='nvim' # Change to 'vim' or 'code' if preferred
export VISUAL='nvim'

# Add custom binaries directory to PATH if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
export PATH


alias edit='~/config.sh'

# alias nvim="kitten @ set-background-opacity 1.0 && command nvim \"\$@\" && kitten @ set-background-opacity 0.8"

alias znix="zellij attach nixconf"
alias zhypr="zellij attach hyprland"
alias znvim="zellij attach neovim\ config"
