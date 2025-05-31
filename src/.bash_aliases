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

# Remap zeditor to zed
alias zed="zeditor"

# Open the ~/.zshrc in vscode
alias hax="code ~/.zshrc"

# Get host info using mullvad api
alias hinfo="curl -s https://am.i.mullvad.net/json | jq"

# Shortcut for journalctl
# This alias is based on code by Arcolinux under the GNU GPL v3.0 License
# https://github.com/arcolinux/arcolinux-zsh/blob/121b8ed0619ea041a2eed5483491336ec1edbcb8/etc/skel/.zshrc#L350
alias jctl="journalctl -p 3 -xb"

# Update grub config

# Check git status of child directories
git_status_check() {
  local current_dir=$(pwd)

  echo "Checking git repositories in child directories..."
  echo

  for dir in */; do
    if [ -d "$dir" ]; then
      cd "$dir" || continue

      # Check if it's a git repository
      if [ -d ".git" ] || git rev-parse --git-dir > /dev/null 2>&1; then
        echo "📁 ${dir%/}"

        # Get current branch
        local branch=$(git branch --show-current)
        echo "  Branch: $branch"

        # Check for uncommitted changes
        if ! git diff --quiet || ! git diff --cached --quiet; then
          echo "  📝 Has uncommitted changes"
        fi

        # Check for unpushed commits and if behind remote
        local ahead=0
        local behind=0

        # Only check if there's a tracking branch
        if git rev-parse @{u} >/dev/null 2>&1; then
          ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
          behind=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo "0")

          if [ "$ahead" -gt 0 ]; then
            echo "  ⬆️  Has $ahead commit(s) not pushed"
          fi

          if [ "$behind" -gt 0 ]; then
            echo "  ⬇️  Is $behind commit(s) behind remote"
          fi

          # If no differences with remote and no local changes
          if [ "$ahead" -eq 0 ] && [ "$behind" -eq 0 ] && git diff --quiet && git diff --cached --quiet; then
            echo "  ✅ Repository is up to date"
          fi
        else
          echo "  ⚠️  No tracking branch"
        fi

        echo
      fi

      cd "$current_dir" || return
    fi
  done
}

alias gsc="git_status_check"

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

scripts() {
    if [[ -f "package.json" ]]; then
        echo "Scripts in package.json"
        jq -r .scripts package.json
        return 0
    fi

    if [[ -f "deno.json" ]]; then
        echo "Tasks in deno.json"
        jq -r .tasks deno.json
        return 0
    fi

    echo "No package.json or deno.json found"
}

function yeet-node-modules() {
    # Find all node_modules directories and store them in an array
    NODE_MODULES_DIRS=()
    while IFS= read -r dir; do
        NODE_MODULES_DIRS+=("$dir")
    done < <(find . -name "node_modules" -type d -prune)

    # Check if any node_modules directories were found
    if [ ${#NODE_MODULES_DIRS[@]} -eq 0 ]; then
        echo "No node_modules directories found."
        return 0
    fi

    echo "The following node_modules directories will be deleted:"
    printf "  %s\n" "${NODE_MODULES_DIRS[@]}"

    echo -n "Do you want to delete these directories? (y/N): "
    read -r answer

    # Check the answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        echo "Deleting node_modules directories..."
        for dir in "${NODE_MODULES_DIRS[@]}"; do
            rm -rf "$dir"
            echo "  Deleted: $dir"
        done
        echo "Done!"
    else
        echo "No worries! I've not deleted anything"
    fi
}

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
  alias cat="bat --paging=never --style=header,header-filename,header-filesize,grid"
fi

# Based on idea by @fractalhq
peep() {
  if [[ ! -n "$1" ]]; then
    echo "Usage: peep <repo>"
    return 1
  fi

  local REPO
  if [[ "$1" =~ ^https?:// ]]; then
    REPO="$1"
  elif [[ "$1" =~ ^[^/]+/[^/]+$ ]]; then
    REPO="https://github.com/$1.git"
  else
    echo "Please provide a repo path or url"
    return 1
  fi

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

function quish_simple() {
  if [[ ! -n "$1" ]]; then
    echo "Usage: quish_simple <file>"
    exit 1
  fi

  local file="$1"
  local resolution="1920:1080"
  local fps="30"
  local bitrate="1500"
  local type="mp4"
  local output="quished-$1"

  ffmpeg -y -v quiet -stats -i "$file" -vf "scale=$resolution:force_original_aspect_ratio=decrease,pad=$resolution:(ow-iw)/2:(oh-ih)/2" -r "$fps" -b:v "$bitrate"k "${output}.${type}" </dev/null
}

update_system() {
  if ! grep -q '^ID_LIKE=.*arch' /etc/os-release; then
    echo "System is not Arch Linux or an Arch-based distribution, exiting..."
    return 1
  fi

  set -e

  echo -n "\nDo you want to install/update system packages? (Y/n): "
  read answer
  answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

  if [[ "$answer" != "n" ]]; then
    echo "Installing System Packages"
    yay -Sy --needed \
      breeze-gtk breeze-icons ttf-comic-mono-git xcursor-breeze gdm-settings archlinux-tweak-tool-git \
      gnome-browser-connector gnome-shell-extension-pop-shell-git \
      mullvad-vpn-bin tailscale dnsproxy dog 7zip trash-cli \
      appimagelauncher flatpak \
      bat fastfetch-git cmatrix ddgr btop-git jq 1password-cli scrcpy yt-dlp cloudflared-bin screen aws-cli-bin \
      spotify 1password kate gparted vlc blender brave-bin filelight signal-desktop \
      visual-studio-code-bin lazydocker lazygit alacritty gfhostty guake github-cli docker docker-compose hyperfine zed \
      jdk17-openjdk jdk21-openjdk cmake bluez bluez-utils \
      oh-my-zsh-git pnpm-shell-completion zsh-syntax-highlighting
  fi

  echo -e "\nStarting Tailscale"
  sudo systemctl enable tailscaled --now
  sudo tailscale up --accept-dns=false --operator=ghost

  echo -e "\nStarting Docker"
  sudo systemctl enable docker --now

  if ! groups $USER | grep -q "\bdocker\b"; then
    echo -e "\nAdded you to the docker group"
    sudo usermod -aG docker $USER
  fi

  echo -e "\nInstalling Flatpak Packages"
  flatpak install flathub \
    io.missioncenter.MissionCenter org.qbittorrent.qBittorrent org.gnome.Characters it.mijorus.smile \
    org.raspberrypi.rpi-imager ca.desrt.dconf-editor md.obsidian.Obsidian com.discordapp.Discord \
    org.gimp.GIMP org.dbgate.DbGate com.github.tchx84.Flatseal com.obsproject.Studio \
    io.github.flattool.Warehouse org.gnome.Papers com.github.jeromerobert.pdfarranger \
    fr.romainvigier.MetadataCleaner org.gnome.Boxes

  echo -e "\nSetting Gnome Settings"
  # theming
  gsettings set org.gnome.desktop.interface monospace-font-name 'Comic Mono 10'
  gsettings set org.gnome.desktop.interface cursor-theme 'Breeze_Light'
  gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'
  dconf write /org/gnome/shell/extensions/user-theme/name "'GHOST'"
  dconf write /org/gnome/desktop/interface/accent-color "'blue'"
  gsettings set org.gnome.desktop.interface show-battery-percentage true
  gsettings set org.gnome.shell favorite-apps "['brave-browser.desktop', 'com.discordapp.Discord.desktop', 'org.gnome.Nautilus.desktop', 'spotify.desktop', 'com.tutanota.Tutanota.desktop']"
  # gdm theming
  dconf write /org/gnome/login-screen/logo "''"
  dconf write /io/github/realmazharhussain/GdmSettings/appearance/cursor-theme "'Breeze_Light'"
  dconf write /io/github/realmazharhussain/GdmSettings/appearance/icon-theme "'Adwaita'"
  dconf write /io/github/realmazharhussain/GdmSettings/appearance/background-color "'rgb(18, 18, 20)'"
  dconf write /io/github/realmazharhussain/GdmSettings/appearance/background-type "'image'"
  dconf write /io/github/realmazharhussain/GdmSettings/appearance/background-image "'$HOME/Pictures/background.png'"
  # wm keybindings
  dconf write /org/gnome/mutter/workspaces-only-on-primary true
  dconf write /org/gnome/desktop/wm/keybindings/show-desktop "['<Super>d']"
  dconf write /org/gnome/desktop/wm/keybindings/minimize "['<Super>h']"
  dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-down "@as []"
  dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-up "@as []"
  dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-left "@as ['<Super>Page_Up']"
  dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-right "@as ['<Super>Page_Down']"
  dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-left "@as ['<Super><Shift>Page_Up']"
  dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-right "@as ['<Super><Shift>Page_Down']"
  dconf write /org/gnome/settings-daemon/plugins/media-keys/screensaver "['<Super>Escape']"
  dconf write /org/gnome/desktop/wm/keybindings/close "['<Super>q', '<Alt>F4']"
  dconf write /org/gnome/shell/keybindings/focus-active-notification "@as []"
  dconf write /org/gnome/shell/keybindings/toggle-message-tray "@as ['<Super>n']"
  dconf write /org/gnome/shell/keybindings/toggle-quick-settings "@as ['<Super>x']"
  # pop shell
  dconf write /org/gnome/shell/extensions/pop-shell/active-hint "true"
  dconf write /org/gnome/shell/extensions/pop-shell/hint-color-rgba "'rgba(33, 96, 236, 1)'"
  dconf write /org/gnome/shell/extensions/pop-shell/active-hint-border-radius "uint32 15"
  dconf write /org/gnome/shell/extensions/pop-shell/show-title "false"
  dconf write /org/gnome/shell/extensions/pop-shell/tile-by-default "true"
  # clipboard indicator
  dconf write /org/gnome/shell/extensions/clipboard-indicator/toggle-menu "['<Super>v']"
  dconf write /org/gnome/shell/extensions/clipboard-indicator/history-size "50"
  dconf write /org/gnome/shell/keybindings/toggle-message-tray "@as []"
  # vitals
  dconf write /org/gnome/shell/extensions/vitals/hot-sensors "['_memory_usage_', '_processor_usage_']"
  # custom keybindings
  ## terminal
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal/name "'Terminal'"
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal/command "'ghostty'"
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal/binding "'<Super>T'"
  ## guake
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/guake-toggle/name "'Guake Toggle'"
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/guake-toggle/command "'guake-toggle'"
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/guake-toggle/binding "'<Alt>Return'"
  ## smilet
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/emoji-toggle/name "'Emoji Picker (Smile) Toggle'"
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/emoji-toggle/command "'flatpak run it.mijorus.smile'"
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/emoji-toggle/binding "'<Super>period'"
  ## save keybindings
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/guake-toggle/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/emoji-toggle/']"
  # privacy
  dconf write /org/gnome/desktop/privacy/remember-app-usage "false"
  dconf write /org/gnome/desktop/privacy/remember-recent-files "false"
  dconf write /org/gnome/desktop/privacy/remove-old-temp-files "true"
  dconf write /org/gnome/desktop/privacy/remove-old-trash-files "true"
  # nautilus
  dconf write /org/gnome/nautilus/preferences/show-hidden-files "true"
  # guake
  dconf write /org/guake/style/font/palette "'#151517171c1c:#ecec5f5f6767:#8080a7a76363:#fdfdc2c25353:#54548585c0c0:#bfbf8383c0c0:#5757c2c2c0c0:#eeeeecece7e7:#555555555555:#ffff69697373:#9393d3d39393:#ffffd1d15656:#4d4d8383d0d0:#ffff5555ffff:#8383e8e8e4e4:#ffffffffffff:#eeeeeeeeeeee:#121212121414'"
  dconf write /org/guake/style/font/palette-name "'Custom'"
  dconf write /org/guake/style/font/style "'Comic Mono 12'"
  dconf write /org/guake/style/font/allow-bold "true"
  dconf write /org/guake/style/background/transparency "65"
  dconf write /org/guake/keybindings/global/show-hide "''"
  dconf write /org/guake/general/use-trayicon "false"
  dconf write /org/guake/general/window-width "80"
  dconf write /org/guake/general/window-height "35"
  dconf write /org/guake/general/window-losefocus "true"
  dconf write /org/guake/general/gtk-use-system-default-theme "false"
  dconf write /org/guake/general/gtk-prefer-dark-theme "true"
  dconf write /org/guake/general/gtk-theme-name "'Adwaita'"
  dconf write /org/guake/general/use-default-font "false"
  dconf write /org/guake/style/cursor-blink-mode "1"
  dconf write /org/guake/style/cursor-shape "1"
  dconf write /org/guake/general/use-scrollbar "false"
  dconf write /org/guake/general/hide-tabs-if-one-tab "true"
  dconf write /org/guake/general/start-at-login "true"
  # clocks
  gsettings set org.gnome.clocks world-clocks "[{'location': <(uint32 2, <('New York', 'KNYC', true, [(0.71180344078725644, -1.2909618758762367)], [(0.71059804659265924, -1.2916478949920254)])>)>}]"
  gsettings set org.gnome.desktop.interface clock-show-seconds true
  gsettings set org.gnome.desktop.interface clock-show-date true
  gsettings set org.gnome.desktop.interface clock-show-weekday false
  gsettings set org.gnome.desktop.interface clock-format '24h'

  # Folders
  create_bookmarked_folder() {
    FOLDER="$HOME/$1"
    BOOKMARK_FILE="$HOME/.config/gtk-3.0/bookmarks"

    if [[  ! -e "$FOLDER" ]]; then
      echo -e "\nCreating $FOLDER and bookmarking in nautillus"
      mkdir -p "$FOLDER"
    fi

    if ! grep -q "$FOLDER" "$BOOKMARK_FILE"; then
      echo "file://$FOLDER" >> $BOOKMARK_FILE
    fi
  }

  create_bookmarked_folder dev
  create_bookmarked_folder torrent
  create_bookmarked_folder to-archive

  # Set shell to zsh
  if [[ "$SHELL" != "/bin/zsh" ]]; then
    echo -e "\nSetting ZSH"
    chsh -s /bin/zsh
  fi

  # Install my search tool
  install_search() {
    curl -L -o search https://github.com/ghostdevv/search/releases/latest/download/search-linux-amd64 \
      && chmod +x search \
      && sudo mv -f search /usr/local/bin \
      && sudo chown root:root /usr/local/bin/search

    if [[ ! -e "/lib/systemd/system/search.service" ]]; then
      echo "\nAdding Search Service"
      sudo curl -sL -o /lib/systemd/system/search.service https://raw.githubusercontent.com/ghostdevv/search/main/search.service \
        && sudo systemctl daemon-reload \
        && sudo systemctl enable search --now
    fi

    sudo systemctl restart search
  }

  if command -v search &> /dev/null; then
    echo -n "\nDo you want to update search? (Y/n): "
    read answer
    answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

    if [[ "$answer" != "n" ]]; then
      echo -e "\nUpdating Search"
      install_search
      echo "Search is now v$(search --version)"
    fi
  else
    echo -e "\nInstalling Search"
    install_search
  fi

  set +e

  echo -e "\nDone! You may need to do the following steps:"
  echo "- Setup dns"
  echo "- Press apply in gdm-settings"
  echo "- Restart your computer"
}

alias update-system="update_system"

# Svelte
export SVELTE_INSPECTOR_OPTIONS=true
export SVELTE_INSPECTOR_TOGGLE=ctrl+alt
