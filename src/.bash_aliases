source ~/.dotfiles.sh

# Convert an image to webp
webp() {
  local REGEX='\.(png|jpg|jpeg|pnm|pgn|ppm|pam|tiff)$'

  if [ -z "$(echo $1 | grep -E -i $REGEX)" ]; then
      echo 'Error: File must be one of: png, jpg, jpeg, pnm, pgn, ppm, pam, tiff'
      exit 1
  fi

  cwebp -q 90 "$1" -o "$(echo $1 | sed -E "s/$REGEX//").webp"
}

# Start a cloudflare tunnel with optional port
tunnel() {
  if ! [[ $1 =~ ^-?[0-9]+$ ]]; then
      echo "Please pass a port as first argument to this command"
      return
  fi

  echo "Starting tunnel for http://localhost:$1"

  local ID="t$(date +%s)"
  
  screen -S "$ID" -L -Logfile "$ID" -dm bash -c "cloudflared tunnel --url http://localhost:$1"

  until grep -oqi 'https://.*trycloudflare.com' $ID; do
      echo '  Starting...'
      sleep 2
  done

  local URL="$(grep -oi 'https://.*trycloudflare.com' $ID 2>/dev/null)"

  echo "Tunnel running at $URL"

  if command -v pbcopy >/dev/null 2>&1; then
      echo "$URL" | pbcopy
      echo "  Copied to clipboard"
  elif command -v xsel >/dev/null 2>&1; then
      echo "$URL" | xsel --clipboard --input
      echo "  Copied to clipboard"
  else
      echo "  Unable to copy to clipboard"
  fi

  screen -S "$ID" -X logfile flush 0
  screen -S "$ID" -X log off
  rm -f "$ID"

  echo
  echo "Attaching to tunnel in 3 seconds..."

  sleep 3

  screen -r "$ID"
}

# Uncompress any file
# This function is based on code by Arcolinux under the GNU GPL v3.0 License
# https://github.com/arcolinux/arcolinux-zsh/blob/121b8ed0619ea041a2eed5483491336ec1edbcb8/etc/skel/.zshrc#L455
ex() {
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
      *.tar.zst)   tar xf $1    ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Open the ~/.zshrc in vscode
alias hax="code ~/.zshrc"

# Get host info using mullvad api
alias hinfo="curl -s https://am.i.mullvad.net/json | jq"

# Shortcut for journalctl
# This alias is based on code by Arcolinux under the GNU GPL v3.0 License
# https://github.com/arcolinux/arcolinux-zsh/blob/121b8ed0619ea041a2eed5483491336ec1edbcb8/etc/skel/.zshrc#L350
alias jctl="journalctl -p 3 -xb"

# Update grub config
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

# Set nano as the editor
export EDITOR="nano"

# @antfu/ni settings
export NI_DEFAULT_AGENT="pnpm"
export NI_GLOBAL_AGENT="pnpm"

# Update the git repo & deps 
sync() {
  if [[ -d ".git" ]]; then
    printf "\nSyncing with git:\n"

    git fetch
    git pull
  fi;

  ni
}

# Update deps 
update() {
  if [[ -f "package-lock.json" ]]; then
    printf "\nUpdating with npm:\n"

    rm -rf node_modules
    pnpm up --config.strict-peer-dependencies=false --config.engine-strict=false --latest -r --no-lockfile
    rm -rf node_modules
    npm i
  elif [[ -f "pnpm-lock.yaml" ]]; then
    printf "\nUpdating with pnpm:\n"

    pnpm up --config.strict-peer-dependencies=false --latest -r

    if [[ -f "pnpm-workspace.yaml" ]]; then
      pnpm up --config.strict-peer-dependencies=false --latest
    fi;
  else
    echo "No lockfile found"
  fi;
}

# node aliases
alias pi="ni"
alias pd="nr dev"
alias pp="nr preview"
alias pb="nr build"

# optionally configure volta
if [[ -d "$HOME/.volta" ]]; then
  export VOLTA_FEATURE_PNPM="1"
  export VOLTA_HOME="$HOME/.volta"
  export PATH="$VOLTA_HOME/bin:$PATH"
fi

# optionally configure deno
if [[ -d "$HOME/.deno" ]]; then
  export DENO_INSTALL="$HOME/.deno"
  export PATH="$DENO_INSTALL/bin:$PATH"
fi

# if bat exists alias cat for it
if command -v bat &> /dev/null; then
  export BAT_THEME="Visual Studio Dark+"
  export BAT_STYLE="full"
  alias cat="bat --style=header,header-filename,header-filesize,grid"
fi

# Based on idea by @fractalhq
peep() {
  if [[ ! -n "$1" ]]; then
    echo "Usage: peep <repo>"
    exit 1
  fi

  local REPO="https://github.com/$1.git"
  local LATEST_COMMIT_HASH="$(git ls-remote --head $REPO --ref main --type commit | head -n 1 | awk '{print $1}')"
  local OUTPUT="/tmp/peep-$LATEST_COMMIT_HASH"

  if [[ ! -d "$OUTPUT" ]]; then
    git clone --depth 1 $REPO $OUTPUT
    printf "\nCloned '$1' to '$OUTPUT'! Opening...\n"
  else
    echo "Repo '$1' found, opening..."
  fi

  code $OUTPUT
}

# Search
alias s="search search"
sq() { search search "!$@"; }
