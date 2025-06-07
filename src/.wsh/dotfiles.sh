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

  # get the current kernel to deduce the OS
  local PLATFORM="$(uname --kernel-name | tr '[:upper:]' '[:lower:]')"

  # find the current version
  local CURRENT_VERSION_FILE="$HOME/.dotfiles-version"
  local CURRENT_VERSION="$(cat "$CURRENT_VERSION_FILE" 2>/dev/null)"

  # fetch the latest version from github
  local LATEST_VERSION="$(git ls-remote --head https://github.com/ghostdevv/dotfiles.git --ref main --type commit | head -n 1 | awk '{print $1}')"

  # welcomer
  printf "\nupdate-dotfiles --current-version=\"$(echo $CURRENT_VERSION | cut -c1-7)\" --latest-version=\"$(echo $LATEST_VERSION | cut -c1-7)\" --force=$FORCE --platform=$PLATFORM\n\n"

  # Checks if the path has an update (normalised to $HOME):
  # - Is the current version different from the latest version?
  # - Is the force flag set to true?
  # - Does the path exist?
  function _has_update_available() {
    local OUTPUT="$HOME/$1"
    [[ "$LATEST_VERSION" != "$CURRENT_VERSION" || "$FORCE" = true || ! -e "$OUTPUT" ]]
  }

  # Download a file from GitHub if an update is available. Given
  # path is normalised to $HOME. If a platform lock argument is provided,
  # it'll only install if the platform matches the current platform.
  function _dotfiles_download() {
    local PLATFORM_LOCK="$2"
    if [[ -n $PLATFORM_LOCK && $PLATFORM_LOCK != $PLATFORM ]]; then
        echo "Skipping '$1' (platform mismatch)"
    fi

    local OUTPUT="$HOME/$1"

    if _has_update_available "$1"; then
      printf "\n\nUpdating '$1'\n"
      mkdir -p "$(dirname $OUTPUT)"
      curl -L "https://raw.githubusercontent.com/ghostdevv/dotfiles/$LATEST_VERSION/src/$1" -o "$OUTPUT"
      echo
    else
      echo "Skipping '$1'"
    fi
  }

  # wsh - if an update is needed, we remove the whole
  # directory to make removing orphaned files easier
  if _has_update_available ".wsh"; then rm -r "$HOME/.wsh"; fi
  _dotfiles_download ".wsh/dotfiles.sh"
  _dotfiles_download ".wsh/system.sh"
  _dotfiles_download ".wsh/dotfiles.sh"
  _dotfiles_download ".wsh/git.sh"
  _dotfiles_download ".wsh/deno-node.sh"
  _dotfiles_download ".wsh/editors.sh"
  _dotfiles_download ".wsh/network.sh"
  _dotfiles_download ".wsh/files.sh"
  _dotfiles_download ".wsh/update-system.sh"
  _dotfiles_download ".wsh/fun.sh"
  _dotfiles_download ".wsh/entry.sh"
  _dotfiles_download ".wsh/images/framework-16-expansion-cards.png"
  # bash & zsh config
  _dotfiles_download ".bash_aliases"
  _dotfiles_download ".zshrc-personal"
  # Editors
  _dotfiles_download ".config/zed/settings.json"
  _dotfiles_download ".config/zed/keymap.json"
  _dotfiles_download ".config/zed/tasks.json"
  _dotfiles_download ".config/zed/themes/serendipity-sunset-v1-zed.json"
  _dotfiles_download ".nanorc"
  # Terminals
  _dotfiles_download ".config/alacritty/alacritty.toml"
  _dotfiles_download ".config/ghostty/config"
  # Git
  _dotfiles_download ".gitconfig"
  # Tools
  _dotfiles_download ".config/fastfetch/config.jsonc"
  # Theme
  _dotfiles_download ".themes/GHOST/gnome-shell/gnome-shell.css" "linux"
  # Autostart
  _dotfiles_download ".config/autostart/1password.desktop" "linux"
  _dotfiles_download ".config/autostart/it.mijorus.smile.desktop" "linux"

  # Store new version
  echo "$LATEST_VERSION" > "$CURRENT_VERSION_FILE"

  # Updating ssh config
  if command -v op >/dev/null; then
    echo -n "\nDo you want to update your SSH config? (y/N): "
    read answer
    answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

    if [[ "$answer" == "y" ]]; then
      printf "\nSetting ~/.ssh/config hosts with 1password"

      FORCE=true _dotfiles_download ".ssh/config"

      for ID in $(op item ls --categories server --format=json | jq -r '.[].id'); do
        SERVER=$(op item get $ID --format=json)
        printf "Found Server: $(echo $SERVER | jq '.title')\n"

        echo $SERVER \
          | jq -r '"\nHost \(.title | ascii_downcase)\n  HostName \(.fields[] | select(.label == "ip") | .value)\n  User \(.fields[] | select(.label == "username") | .value)\n  SetEnv TERM=xterm-256color"' \
          >>  ~/.ssh/config
      done
    fi
  fi

  # Cleanup internal functions
  unset -f _dotfiles_download
  unset -f _has_update_available

  printf "\nDone! Don't forget to restart your shell.\n"
}
