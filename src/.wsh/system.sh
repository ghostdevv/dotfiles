# This alias is based on code by Arcolinux under the GNU GPL v3.0 License
# https://github.com/arcolinux/arcolinux-zsh/blob/121b8ed0619ea041a2eed5483491336ec1edbcb8/etc/skel/.zshrc#L225
alias update-grub="sudo grub-mkconfig -o /boot/grub/grub.cfg"

# List all processes
alias lsps="ps auxf"

# Grep through process list
# This alias is based on code by Arcolinux under the GNU GPL v3.0 License
# https://github.com/arcolinux/arcolinux-zsh/blob/121b8ed0619ea041a2eed5483491336ec1edbcb8/etc/skel/.zshrc#L222
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"

# Shortcuts or sensible defaults
# This block of aliases are based on code by Arcolinux under the GNU GPL v3.0 License
# https://github.com/arcolinux/arcolinux-zsh/blob/121b8ed0619ea041a2eed5483491336ec1edbcb8/etc/skel/.zshrc
alias pacman="sudo pacman --color auto"
alias free="free -mt"
alias wget="wget -c"
alias df="df -h"
alias grep="grep --color=auto"
alias egrep="grep -E --color=auto"
alias fgrep="grep -F --color=auto"
alias ls="ls --color=auto"
alias la="ls -a"
alias ll="ls -alFh"
alias l="ls"

alias update-mirrors="sudo reflector @/etc/xdg/reflector/reflector.conf"

# bat config
if command -v bat &> /dev/null; then
  export BAT_THEME="Catppuccin Mocha"
  export BAT_STYLE="full"
fi

# Search
alias s="search search"
sq() { search search "!$@"; }

# Show the framework 16 expansion card support image
alias fw="viu ~/.wsh/images/framework-16-expansion-cards.png --width 45"
