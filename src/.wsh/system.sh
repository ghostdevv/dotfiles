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
  export BAT_THEME="serendipity-sunset-v1"
  export BAT_STYLE="full"
fi

# Search
alias s="search search"
sq() { search search "!$@"; }

alias sl="sl -d -e"

# Show the framework 16 expansion card support image
alias fw="viu ~/.wsh/images/framework-13-expansion-cards.png --width 45"

function __wsh_pkg_str() {
	if [[ $1 -eq 1 ]]; then
		echo "package"
	else
		echo "packages"
	fi
}

function pkgrep() {
	local flatpak="$(flatpak list --app --columns "name,application,versio" | grep --color=always -i "$@")"
	local flatpak_count="$(echo "$flatpak" | wc -l)"

	local arch="$(yay -Q | grep --color=always -i "$@")"
	local arch_count="$(echo "$arch" | wc -l)"

	if [[ -n "$arch" && -n "$flatpak" ]]; then
		echo -e "Found $arch_count Arch $(__wsh_pkg_str $arch_count) and $flatpak_count Flatpak $(__wsh_pkg_str $flatpak_count):"
		echo -e "$arch\n$flatpak"
	elif [[ -n "$arch" ]]; then
		echo -e "Found $arch_count Arch $(__wsh_pkg_str $arch_count):"
		echo -e "$arch"
	elif [[ -n "$flatpak" ]]; then
		echo -e "Found $flatpak_count Flatpak $(__wsh_pkg_str $flatpak_count):"
		echo -e "$flatpak"
	else
		echo -e "No Arch or Flatpak packages found"
	fi
}
