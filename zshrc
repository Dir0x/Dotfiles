if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to the oh-my-zsh installation.
export ZSH="~/.oh-my-zsh"

# Oh my zsh theme, plugins and load
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Manual configurations
PATH=/usr:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/usr/local/sbin:/sbin:/usr/sbin:/home/daniel/.local/bin:/snap/bin:/usr/local/go/bin:/home/daniel/go/bin:/home/daniel/Tools
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# Cat & ls aliases
alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias l='lsd --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'
alias cat='/usr/bin/bat'
alias catn='/usr/bin/cat'
alias catnl='/usr/bin/bat --paging=never'

# Utils
alias www='python3 -m http.server'
alias hosts='sudo nano /etc/hosts'
alias ffufdefault='ffuf -w /home/daniel/Diccionarios/directory_wordlist.txt -u '

# CTF platforms VPNs
alias htb='sudo openvpn ~/HackTheBox/D1r0x.ovpn'
alias thm='sudo openvpn ~/TryHackMe/Dirox.ovpn'

# Set 'man' colors
function man() {
    env \
    LESS_TERMCAP_mb=$'\e[01;31m' \
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;32m' \
    man "$@"
}

# Manual plugins
source /usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh
source /home/daniel/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# Keybindings
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Port scan with furious and nmap
scan(){
  puertos=$(/home/daniel/go/bin/furious -s connect -p 1-65535 $1 | grep "/tcp" | cut -d "/" -f1 | tr -d "\t" | sed -e 'H;${x;s/\n/,/g;s/^,//;p;};d')
  nmap -sC -A -sV -Pn -T4 -n -p$puertos $1 | tail -n+5 | head -n-3
}

# Delete initial warning
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

