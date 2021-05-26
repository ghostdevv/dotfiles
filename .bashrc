export EDITOR="nano"

### CHANGE TITLE OF TERMINALS
case ${TERM} in
  xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|alacritty|st|konsole*)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
        ;;
  screen*)
    PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
    ;;
esac

### ARCHIVE EXTRACTION
# usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1   ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *.deb)       ar x $1      ;;
      *.tar.xz)    tar xf $1    ;;
      *.tar.zst)   unzstd $1    ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

### Aliases

# Better commands
alias \
	yay="yay --noconfirm --color always" \
	pacman="sudo pacman --color always" \
	grep="grep --color=auto" \
	mkdir="mkdir -pv"

# ls
alias \
	ls="ls -A --color=always --group-directories-first" \
	la='exa -a --color=always --group-directories-first' \
	ll='exa -l --color=always --group-directories-first' \
	lt='exa -aT --color=always --group-directories-first' 

# Confirm before overwriting
alias \
	cp="cp -i" \
	mv="mv -i" \
	rm="rm -i" 
	
# Human readable sizes
alias \
	df="df -h" \
	free="free -m" 

# Pacman & Yay 
alias \
	update-mirrors="sudo pacman-mirrors -f 0" \
	update="pacman -Syu && yay -Syu"

# Git
alias \
	commit="git commit -m" \
	push="git push" \
	upush="git push -u origin" \
	gstat="git status"

# Misc
alias \
	myip="curl ipinfo.io/ip" \
	ports="netstat -tulanp" \
	cls="clear" \
	untar="tar -zxvf" \
	jctl="journalctl -p 3 -xb"

# Fun
alias \
	rr="curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash" \
	cmatrix="cmatrix -a"

# Bare git repo alias for dotfiles
alias \
	dotfiles="/usr/bin/git --git-dir=$HOME/dotfiles --work-tree=$HOME" \
	dotfiles-setup="git init --bare $HOME/dotfiles && dotfiles config --local status.showUntrackedFiles no && git checkout -b main"