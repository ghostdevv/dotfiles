function update-dotfiles() {
  local FORCE=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -f|--force)
        local FORCE=true
        shift 1
        ;;
      *)
        echo "Unknown option: $1"
        return 1
        ;;
    esac
  done

  local LATEST_VERSION="$(git ls-remote --head https://github.com/ghostdevv/dotfiles.git --ref main --type commit | head -n 1 | awk '{print $1}')"
  printf "\nUpdating Dotfiles ($(echo $LATEST_VERSION | cut -c1-7)) [$FORCE]\n\n"

  local CURRENT_VERSION_FILE="$HOME/.dotfiles-version"
  local CURRENT_VERSION="$(cat "$CURRENT_VERSION_FILE" 2>/dev/null)"

  function dotfiles_download {
    local OUTPUT="$HOME/$1"

    if [[ "$LATEST_VERSION" != "$CURRENT_VERSION" || "$FORCE" = true || ! -f "$OUTPUT" ]]; then
      printf "\n\nUpdating '$1'\n"
      mkdir -p "$(dirname $OUTPUT)"
      curl -L "https://raw.githubusercontent.com/ghostdevv/dotfiles/$LATEST_VERSION/src/$1" -o "$OUTPUT"
      echo
    else
      echo "Skipping '$1'"
    fi
  }

  # wsh
  if [[ -d "$HOME/.wsh" ]]; then rm -r "$HOME/.wsh"; fi
  dotfiles_download ".wsh/dotfiles.sh"
  dotfiles_download ".wsh/system.sh"
  dotfiles_download ".wsh/dotfiles.sh"
  dotfiles_download ".wsh/git.sh"
  dotfiles_download ".wsh/deno-node.sh"
  dotfiles_download ".wsh/editors.sh"
  dotfiles_download ".wsh/network.sh"
  dotfiles_download ".wsh/files.sh"
  dotfiles_download ".wsh/update-system.sh"
  dotfiles_download ".wsh/entry.sh"
  # bash & zsh config
  dotfiles_download ".bash_aliases"
  dotfiles_download ".zshrc-personal"
  # Editors
  dotfiles_download ".config/zed/settings.json"
  dotfiles_download ".config/zed/keymap.json"
  dotfiles_download ".config/zed/tasks.json"
  dotfiles_download ".config/zed/themes/serendipity-sunset-v1-zed.json"
  dotfiles_download ".nanorc"
  # Terminals
  dotfiles_download ".config/alacritty/alacritty.toml"
  dotfiles_download ".config/ghostty/config"
  # Git
  dotfiles_download ".gitconfig"
  # Tools
  dotfiles_download ".config/fastfetch/config.jsonc"

  # Linux Specific
  if [[ "$(uname)" = "Linux" ]]; then
    dotfiles_download ".themes/GHOST/gnome-shell/gnome-shell.css"
    dotfiles_download ".config/autostart/1password.desktop"
  fi

  echo "$LATEST_VERSION" > "$CURRENT_VERSION_FILE"

  if command -v op >/dev/null; then
    echo -n "\nDo you want to update your SSH config? (y/N): "
    read answer
    answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

    if [[ "$answer" == "y" ]]; then
      printf "\nSetting ~/.ssh/config hosts with 1password"

      FORCE=true dotfiles_download ".ssh/config"

      for ID in $(op item ls --categories server --format=json | jq -r '.[].id'); do
        SERVER=$(op item get $ID --format=json)
        printf "Found Server: $(echo $SERVER | jq '.title')\n"

        echo $SERVER \
          | jq -r '"\nHost \(.title | ascii_downcase)\n  HostName \(.fields[] | select(.label == "ip") | .value)\n  User \(.fields[] | select(.label == "username") | .value)\n  SetEnv TERM=xterm-256color"' \
          >>  ~/.ssh/config
      done
    fi

  fi

  printf "\nDone! Don't forget to restart your shell.\n"
}
