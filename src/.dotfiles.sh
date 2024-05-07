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

  local LATEST_COMMIT="$(git ls-remote --head https://github.com/ghostdevv/dotfiles.git --ref main --type commit | head -n 1 | awk '{print $1}')"
  printf "\nUpdating Dotfiles ($(echo $LATEST_COMMIT | cut -c1-7)) [$FORCE]\n\n"

  function comment {
    case $1 in
      *.css)   echo "/* $2 */" ;;
      *.json)  exit 1          ;;
      *)       echo "# $2"     ;;
    esac
  }

  function dotfiles_download {
    local OUTPUT="$HOME/$1"

    if [[ -f "$OUTPUT" ]]; then
      local CURRENT_COMMIT="$(grep -m 1 -Eo 'DOTFILES_VERSION=(\w+)' $OUTPUT | sed 's/DOTFILES_VERSION=//')"
    fi

    if [[ "$LATEST_COMMIT" != "$CURRENT_COMMIT" || "$FORCE" = true ]]; then
      printf "\n\nUpdating '$1'\n"
      mkdir -p "$(dirname $OUTPUT)"
      curl -L "https://raw.githubusercontent.com/ghostdevv/dotfiles/$LATEST_COMMIT/src/$1" -o $OUTPUT
      
      local COMMENT="$(comment $OUTPUT "DOTFILES_VERSION=$LATEST_COMMIT")"
      if [[ "$(uname)" != "Darwin" && -n "$COMMENT" ]]; then
        # this isn't working correctly on mac and I can't fix it
        sed -i "1i$COMMENT\n" $OUTPUT
      fi
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

  # Linux Specific
  if [[ "$(uname)" != "Darwin" ]]; then
    dotfiles_download ".themes/GHOST/gnome-shell/gnome-shell.css"
    dotfiles_download ".config/presets/user/ghost.json"
  fi

  printf "\nDone! Don't forget to restart your shell.\n"
}

alias update-dotfiles="update_dotfiles"
