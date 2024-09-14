update_dotfiles() {
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

  local STORAGE_DIR="$HOME/.dotfiles"

  local LATEST_VERSION="$(git ls-remote --head https://github.com/ghostdevv/dotfiles.git --ref main --type commit | head -n 1 | awk '{print $1}')"
  printf "\nUpdating Dotfiles ($(echo $LATEST_VERSION | cut -c1-7)) [$FORCE]\n\n"

  if [[ ! -d "$STORAGE_DIR" ]]; then
    mkdir -p "$STORAGE_DIR"
    touch "$STORAGE_DIR/version"
  fi

  local CURRENT_VERSION="$(cat "$STORAGE_DIR/version")"

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

  # General Dotfiles
  dotfiles_download ".dotfiles.sh"
  dotfiles_download ".bash_aliases"
  dotfiles_download ".zshrc-personal"
  dotfiles_download ".gitconfig"
  dotfiles_download ".nanorc"
  dotfiles_download ".config/alacritty/alacritty.toml"
  dotfiles_download ".config/fastfetch/config.jsonc"
  dotfiles_download ".config/guake/guake.conf"

  # Linux Specific
  if [[ "$(uname)" = "Linux" ]]; then
    dotfiles_download ".themes/GHOST/gnome-shell/gnome-shell.css"
    dotfiles_download ".config/presets/user/ghost.json"
    dotfiles_download ".config/autostart/1password.desktop"
    dotfiles_download ".config/autostart/guake.desktop"
  fi

  echo "$LATEST_VERSION" > "$STORAGE_DIR/version"

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
          | jq -r '"\nHost \(.title | ascii_downcase)\n  HostName \(.fields[] | select(.label == "ip") | .value)\n  User \(.fields[] | select(.label == "username") | .value)"' \
          >>  ~/.ssh/config
      done
    fi

  fi

  if [[ -f ~/.config/guake/guake.conf ]]; then
    guake --restore-preferences ~/.config/guake/guake.conf
  fi

  printf "\nDone! Don't forget to restart your shell.\n"
}

alias update-dotfiles="update_dotfiles"
