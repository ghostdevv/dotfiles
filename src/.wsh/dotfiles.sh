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
        return
    fi

    local OUTPUT="$HOME/$1"

    if _has_update_available "$1"; then
      local TEMP_FILE
      TEMP_FILE="$(mktemp)"

      # Download to temp file
      curl --progress-bar --http2 -L "https://raw.githubusercontent.com/ghostdevv/dotfiles/$LATEST_VERSION/src/$1" -o "$TEMP_FILE"

      # If local file exists and differs, confirm before overwriting
      if [[ -f "$OUTPUT" && "$FORCE" != true ]]; then
        if ! diff -q "$OUTPUT" "$TEMP_FILE" > /dev/null 2>&1; then
          echo -n "File '$1' differs from remote. Overwrite? (y/N): "
          read answer
          answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
          if [[ "$answer" != "y" ]]; then
            rm -f "$TEMP_FILE"
            echo -e "Skipping '$1'"
            return
          fi
        fi
      fi

      echo -e "Updating '$1'"
      mkdir -p "$(dirname $OUTPUT)"
      mv "$TEMP_FILE" "$OUTPUT"
      echo -e ""
    else
      echo "Skipping '$1'"
    fi
  }

  # todo add parallel

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
  _dotfiles_download ".wsh/rust.sh"
  _dotfiles_download ".wsh/audio.sh"
  _dotfiles_download ".wsh/entry.sh"
  _dotfiles_download ".wsh/images/framework-13-expansion-cards.png"
  _dotfiles_download ".wsh/packages/arch"
  _dotfiles_download ".wsh/packages/flatpak"
  _dotfiles_download ".wsh/packages/bode-arch"
  _dotfiles_download ".wsh/packages/whale-arch"
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
  # Tools
  _dotfiles_download ".config/fastfetch/config.jsonc"
  _dotfiles_download ".config/hyfetch.json"
  _dotfiles_download ".config/pop-shell/config.json" "linux"
  # GNOME Theme
  _dotfiles_download ".themes/GHOST/gnome-shell/gnome-shell.css" "linux"
  _dotfiles_download ".config/gtk-3.0/settings.ini"
  _dotfiles_download ".config/gtk-4.0/settings.ini"
  # ulauncher
  _dotfiles_download ".config/ulauncher/settings.json"
  _dotfiles_download ".config/ulauncher/shortcuts.json"
  _dotfiles_download ".config/ulauncher/user-themes/GHOST/dev.sh"
  _dotfiles_download ".config/ulauncher/user-themes/GHOST/manifest.json"
  _dotfiles_download ".config/ulauncher/user-themes/GHOST/reset.css"
  _dotfiles_download ".config/ulauncher/user-themes/GHOST/theme.css"
  _dotfiles_download ".config/ulauncher/user-themes/GHOST/theme-gtk-3.20.css"
  # Clipse
  _dotfiles_download ".config/clipse/config.json"
  # Niri
  _dotfiles_download ".config/niri/config.kdl"
  _dotfiles_download ".Xresources"
  _dotfiles_download ".config/hypr/hyprlock.conf"
  # Autostart
  _dotfiles_download ".config/autostart/1password.desktop" "linux"
  _dotfiles_download ".config/autostart/it.mijorus.smile.desktop" "linux"
  # Brave
  _dotfiles_download ".config/brave-flags.conf"
  # Mako
  _dotfiles_download ".config/mako/config"
  # App associations
  _dotfiles_download ".config/mimeapps.list"
  # Bat Additions
  _dotfiles_download ".config/bat/themes/serendipity-sunset-v1.tmtheme"
  # Presenterm
  _dotfiles_download ".config/presenterm/themes/ghost.yaml"
  # Opencode
  _dotfiles_download ".config/opencode/opencode.json"
  _dotfiles_download ".config/opencode/svelte.json"
  _dotfiles_download ".config/opencode/tui.json"
  _dotfiles_download ".config/opencode/themes/GHOST.json"
  _dotfiles_download ".config/opencode/commands/pr-comments.md"
  _dotfiles_download ".config/opencode/commands/pr-review.md"
  _dotfiles_download ".config/opencode/opencode-notifier.json"
  _dotfiles_download ".config/opencode/sounds/dingaling.opus"
  _dotfiles_download ".config/opencode/sounds/dingdong.opus"
  # Clank.pi
  _dotfiles_download ".pi/agent/models.json"
  _dotfiles_download ".pi/agent/settings.json"
  # llama-swap
  _dotfiles_download ".config/llama-swap/config.yaml"
  _dotfiles_download ".config/systemd/user/llama-swap.service"
  # Lazygit
  _dotfiles_download ".config/lazygit/config.yml"
  # Scripts
  _dotfiles_download ".wsh/scripts/update-crates.ts"
  _dotfiles_download ".wsh/scripts.sh"

  # Store new version
  echo "$LATEST_VERSION" > "$CURRENT_VERSION_FILE"

  # Updating ssh config
  if command -v op >/dev/null; then
    echo -n "\nDo you want to update your .gitconfig? (y/N): "
    read answer
    answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

    if [[ "$answer" == "y" ]]; then
      FORCE=true _dotfiles_download ".gitconfig"
      sed -i "s|__GIT_SIGNING_KEY__|$(op item get "Git Signing Key" --fields "public key")|g" "$HOME/.gitconfig"
    fi

    answer=""

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
          | jq -r '"\nHost \(.title | ascii_downcase | gsub(" "; "-"))\n  HostName \(.fields[] | select(.label == "ip") | .value)\n  User \(.fields[] | select(.label == "username") | .value)\n  Port \((.fields[] | select(.label == "port") | .value) // 22)"' \
          >>  ~/.ssh/config
      done
    fi
  fi

  # Cleanup internal functions
  unset -f _dotfiles_download
  unset -f _has_update_available

  printf "\nDone! Don't forget to restart your shell.\n"
}
