update_dotfiles() {
  local LATEST_COMMIT="$(git ls-remote --head https://github.com/ghostdevv/dotfiles.git --ref main --type commit | head -n 1 | awk '{print $1}')"
  echo "Updating Dotfiles ($(echo $LATEST_COMMIT | cut -c1-7))"

  function dotfiles_download {
    local OUTPUT="$HOME/$1"

    if [[ -f $OUTPUT && "$LATEST_COMMIT" = "$(grep -m 1 -Eo 'DOTFILES_VERSION=(\w+)' $OUTPUT | sed 's/DOTFILES_VERSION=//')" ]]; then
      echo "Skipping '$1'"
    else
      printf "\n\nUpdating '$1'\n"
      mkdir -p "$(dirname $OUTPUT)"
      curl -L "https://raw.githubusercontent.com/ghostdevv/dotfiles/$LATEST_COMMIT/src/$1" -o $OUTPUT
      
      if [[ "$(uname)" != "Darwin" ]]; then
        # this isn't working correctly on mac and I can't fix it
        sed -i "1i# DOTFILES_VERSION=$LATEST_COMMIT\n" $OUTPUT
      fi
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
