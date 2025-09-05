function __wsh_read_pkg_list() {
    local FILE="$HOME/.wsh/packages/$1"
    local LIST="$(grep -v '^#' "$FILE" | grep -v '^[[:space:]]*$')"

    if [[ "$2" == "true" ]]; then
        echo "Installing $(echo $LIST | wc -l) $1 packages" >&2
    fi

    echo $LIST | tr '\n' ' ' | sed 's/[[:space:]]*$//'
}

function update-system() {
  if ! grep -q -E '^ID=arch|ID_LIKE=.*arch' /etc/os-release; then
    echo "System is not Arch Linux or an Arch-based distribution, exiting..."
    return 1
  fi

  set -e

  echo -n "\nDo you want to install/update system packages? (Y/n): "
  read answer
  answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

  if [[ "$answer" != "n" ]]; then
    yay -Sy --needed $(__wsh_read_pkg_list "arch" true)
  fi

  echo -n "\nDo you want to start services? (Y/n): "
  read answer
  answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

  if [[ "$answer" != "n" ]]; then
    echo -e "\nStarting Tailscale"
    sudo systemctl enable tailscaled --now
    sudo tailscale up --accept-dns=false --operator="$USER"

    echo -e '\nStarting other services'
    sudo systemctl enable docker --now
    sudo systemctl enable sshd --now
    sudo systemctl enable reflector --now
    sudo systemctl enable reflector.timer --now
    sudo systemctl enable bluetooth --now
    sudo systemctl enable gdm
    sudo systemctl enable fw-fanctrl --now
    systemctl --user enable ulauncher --now
    sudo systemctl enable systemd-timesyncd --now
  fi

  if ! groups $USER | grep -q "\bdocker\b"; then
    echo -e "\nAdded you to the docker group"
    sudo usermod -aG docker $USER
  fi

  if ! groups $USER | grep -q "\bvboxusers\b"; then
    echo -e "\nAdded you to the vboxusers group"
    sudo usermod -aG vboxusers $USER
  fi

  if ! groups $USER | grep -q "\bvboxusers\b"; then
    echo -e "\nAdded you to the uucp group"
    sudo usermod -aG uucp $USER
  fi

  echo -n "\nDo you want to install/update flatpak packages? (Y/n): "
  read answer
  answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

  if [[ "$answer" != "n" ]]; then
    flatpak install --or-update flathub $(__wsh_read_pkg_list "flatpak" true)
  fi

  echo -e "\nSetting Gnome Settings"
  # theming
  echo " - theme settings"
  gsettings set org.gnome.desktop.interface monospace-font-name 'Comic Mono 12'
  gsettings set org.gnome.desktop.interface font-name 'Adwaita Sans 12'
  gsettings set org.gnome.desktop.interface cursor-theme 'Breeze_Light'
  gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'
  gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  gsettings set org.gnome.desktop.interface accent-color 'blue'
  gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'
  dconf write /org/gnome/shell/extensions/user-theme/name "'GHOST'"
  gsettings set org.gnome.desktop.interface show-battery-percentage true
  gsettings set org.gnome.shell favorite-apps "['brave-browser.desktop', 'com.discordapp.Discord.desktop', 'appimagekit_c6a7ecf86d9d84cd6069bf81dd900a87-karma.desktop', 'org.gnome.Nautilus.desktop', 'feishin.desktop', 'com.tutanota.Tutanota.desktop', 'md.obsidian.Obsidian.desktop', '1password.desktop']"
  gsettings set org.gnome.settings-daemon.plugins.power ambient-enabled false
  dconf write /org/gnome/desktop/lockdown/disable-lock-screen 'false'
  # gdm theming
  echo " - gdm theme settings"
  dconf write /org/gnome/login-screen/logo "''"
  dconf write /io/github/realmazharhussain/GdmSettings/appearance/cursor-theme "'Breeze_Light'"
  dconf write /io/github/realmazharhussain/GdmSettings/appearance/icon-theme "'Adwaita'"
  dconf write /io/github/realmazharhussain/GdmSettings/appearance/background-color "'rgb(18, 18, 20)'"
  dconf write /io/github/realmazharhussain/GdmSettings/appearance/background-type "'image'"
  dconf write /io/github/realmazharhussain/GdmSettings/appearance/background-image "'$HOME/Pictures/wallpaper.png'"
  dconf write /org/gnome/desktop/sound/allow-volume-above-100-percent 'true'
  # wm keybindings
  echo " - wm keybindings"
  dconf write /org/gnome/mutter/workspaces-only-on-primary true
  dconf write /org/gnome/desktop/wm/keybindings/show-desktop "['<Super>d']"
  dconf write /org/gnome/desktop/wm/keybindings/minimize "['<Super>h']"
  dconf write /org/gnome/desktop/wm/keybindings/maximize "@as []"
  dconf write /org/gnome/desktop/wm/keybindings/toggle-maximized "['<Super>m']"
  dconf write /org/gnome/settings-daemon/plugins/media-keys/home "['<Super>f']"
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
  dconf write /org/gnome/mutter/keybindings/toggle-tiled-left "@as []"
  dconf write /org/gnome/mutter/keybindings/toggle-tiled-right "@as []"
  dconf write /org/gnome/mutter/wayland/keybindings/restore-shortcuts "@as []"
  # pop shell
  echo " - pop shell"
  dconf write /org/gnome/shell/extensions/pop-shell/active-hint "true"
  dconf write /org/gnome/shell/extensions/pop-shell/hint-color-rgba "'rgba(33, 96, 236, 1)'"
  dconf write /org/gnome/shell/extensions/pop-shell/active-hint-border-radius "uint32 15"
  dconf write /org/gnome/shell/extensions/pop-shell/show-title "false"
  dconf write /org/gnome/shell/extensions/pop-shell/tile-by-default "true"
  # clipboard indicator
  echo " - clipboard indicator"
  dconf write /org/gnome/shell/extensions/clipboard-indicator/history-size "50"
  dconf write /org/gnome/shell/extensions/clipboard-indicator/preview-size "50"
  dconf write /org/gnome/shell/extensions/clipboard-indicator/paste-button "true"
  dconf write /org/gnome/shell/extensions/clipboard-indicator/move-item-first "true"
  dconf write /org/gnome/shell/extensions/clipboard-indicator/display-mode "0"
  dconf write /org/gnome/shell/extensions/clipboard-indicator/enable-keybindings "true"
  dconf write /org/gnome/shell/extensions/clipboard-indicator/private-mode-binding "@as []"
  dconf write /org/gnome/shell/extensions/clipboard-indicator/toggle-menu "['<Super>v']"
  dconf write /org/gnome/shell/extensions/clipboard-indicator/clear-history "@as []"
  dconf write /org/gnome/shell/extensions/clipboard-indicator/next-entry "@as []"
  dconf write /org/gnome/shell/extensions/clipboard-indicator/prev-entry "@as []"
  # vitals
  echo " - vitals"
  dconf write /org/gnome/shell/extensions/vitals/hot-sensors "['_memory_usage_', '_processor_usage_']"
  # custom keybindings
  echo " - custom keybindings"
  ## terminal
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal/name "'Terminal'"
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal/command "'ghostty +new-window'"
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal/binding "'<Super>T'"
  ## guake
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/guake-toggle/name "'Guake Toggle'"
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/guake-toggle/command "'guake-toggle'"
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/guake-toggle/binding "'<Alt>Return'"
  ## smile
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/emoji-toggle/name "'Emoji Picker (Smile) Toggle'"
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/emoji-toggle/command "'flatpak run it.mijorus.smile'"
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/emoji-toggle/binding "'<Super>period'"
  ## ulauncher
  dconf write /org/gnome/desktop/wm/keybindings/switch-input-source "@as []"
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/launcher-toggle/name "'Launcher Toggle'"
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/launcher-toggle/command "'ulauncher-toggle'"
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/launcher-toggle/binding "'<Super>space'"
  ## save keybindings
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/guake-toggle/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/emoji-toggle/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/launcher-toggle/']"
  # privacy
  echo " - privacy"
  dconf write /org/gnome/desktop/privacy/remember-app-usage "false"
  dconf write /org/gnome/desktop/privacy/remember-recent-files "false"
  dconf write /org/gnome/desktop/privacy/remove-old-temp-files "true"
  dconf write /org/gnome/desktop/privacy/remove-old-trash-files "true"
  # nautilus
  echo " - theme nautilus"
  gsettings set org.gnome.nautilus.preferences show-hidden-files true
  gsettings set org.gtk.gtk4.Settings.FileChooser show-hidden true
  gsettings set org.gtk.gtk4.Settings.FileChooser sort-directories-first true
  gsettings set org.gnome.nautilus.preferences date-time-format 'detailed'
  # guake
  echo " - guake"
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
  echo " - clocks"
  gsettings set org.gnome.clocks world-clocks "[{'location': <(uint32 2, <('New York', 'KNYC', true, [(0.71180344078725644, -1.2909618758762367)], [(0.71059804659265924, -1.2916478949920254)])>)>}]"
  gsettings set org.gnome.desktop.interface clock-show-seconds true
  gsettings set org.gnome.desktop.interface clock-show-date true
  gsettings set org.gnome.desktop.interface clock-show-weekday false
  gsettings set org.gnome.desktop.interface clock-format '24h'
  # file associations
  echo " - file associations"
  xdg-settings set default-web-browser brave-browser.desktop
  gio mime x-scheme-handler/http brave-browser.desktop
  gio mime x-scheme-handler/https brave-browser.desktop

  # Folders
  function _assure_bookmark() {
    local BOOKMARK_FOLDER="$HOME/.config/gtk-3.0"
    local BOOKMARK_FILE="$BOOKMARK_FOLDER/bookmarks"

    if [[ ! -e "$BOOKMARK_FILE" ]]; then
        mkdir -p "$(dirname $BOOKMARK_FILE)"
        touch "$BOOKMARK_FILE"
    fi

    local FOLDER="$HOME/$1"

    if ! grep -q "$FOLDER" "$BOOKMARK_FILE"; then
      echo "file://$FOLDER" >> $BOOKMARK_FILE
    fi
  }

  function _assure_bookmarked_folder() {
    local FOLDER="$HOME/$1"

    if [[ ! -e "$FOLDER" ]]; then
      echo -e "\nCreating $FOLDER and bookmarking in nautillus"
      mkdir -p "$FOLDER"
    fi

    _assure_bookmark "$1"
  }

  echo -e "\nAssuring home folders exist"
  xdg-user-dirs-update
  _assure_bookmark Desktop
  _assure_bookmark Documents
  _assure_bookmark Music
  _assure_bookmark Pictures
  _assure_bookmark Downloads
  _assure_bookmark Videos
  _assure_bookmarked_folder dev
  _assure_bookmarked_folder torrent
  _assure_bookmarked_folder to-archive

  # Set shell to zsh
  if [[ "$SHELL" != "/usr/bin/zsh" ]]; then
    echo -e "\nSetting ZSH"
    chsh -s /usr/bin/zsh
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

  if ! grep -q '^WIRELESS_REGDOM="GB"' "/etc/conf.d/wireless-regdom"; then
    echo "Please uncomment GB line in /etc/conf.d/wireless-regdom"
  fi

  set +e

  echo -e "\nDone! You may need to do the following steps:"
  echo "- Setup dns"
  echo "- Press apply in gdm-settings"
  echo "- Restart your computer"
}

function pkg-diff() {
    echo -e "\n# Arch"

    local ARCH_APPS_INSTALLED="$(yay -Qeq | tr '\n' ' ')"
    local ARCH_APPS_TARGET="$(__wsh_read_pkg_list "arch")"

    local ARCH_NOT_TRACKED=$(comm -23 <(echo $ARCH_APPS_INSTALLED | tr ' ' '\n' | sort) <(echo $ARCH_APPS_TARGET | tr ' ' '\n' | sort) | sed '/^$/d')
    local ARCH_NOT_INSTALLED=$(comm -13 <(echo $ARCH_APPS_INSTALLED | tr ' ' '\n' | sort) <(echo $ARCH_APPS_TARGET | tr ' ' '\n' | sort) | sed '/^$/d')

    if [[ -z "$ARCH_NOT_TRACKED" && -z "$ARCH_NOT_INSTALLED" ]]; then
        echo -e " => All good!"
    else
        if [[ -n "$ARCH_NOT_TRACKED" ]]; then
            echo -e " => Not tracked:"
            echo "$ARCH_NOT_TRACKED" | sed 's/^/    - /'
        fi

        if [[ -n "$ARCH_NOT_INSTALLED" ]]; then
            echo -e " => Not installed:"
            echo "$ARCH_NOT_INSTALLED" | sed 's/^/    - /'
        fi
    fi

    echo -e "\n# Flatpak"

    local FLATPAK_APPS_INSTALLED="$(flatpak list --app --columns application | tail -n +1 | tr '\n' ' ')"
    local FLATPAK_APPS_TARGET="$(__wsh_read_pkg_list "flatpak")"

    local FLATPAK_NOT_TRACKED=$(comm -23 <(echo $FLATPAK_APPS_INSTALLED | tr ' ' '\n' | sort) <(echo $FLATPAK_APPS_TARGET | tr ' ' '\n' | sort) | sed '/^$/d')
    local FLATPAK_NOT_INSTALLED=$(comm -13 <(echo $FLATPAK_APPS_INSTALLED | tr ' ' '\n' | sort) <(echo $FLATPAK_APPS_TARGET | tr ' ' '\n' | sort) | sed '/^$/d')

    if [[ -z "$FLATPAK_NOT_TRACKED" && -z "$FLATPAK_NOT_INSTALLED" ]]; then
        echo -e " => All good!"
    else
        if [[ -n "$FLATPAK_NOT_TRACKED" ]]; then
            echo -e " => Not tracked:"
            echo "$FLATPAK_NOT_TRACKED" | sed 's/^/    - /'
        fi

        if [[ -n "$FLATPAK_NOT_INSTALLED" ]]; then
            echo -e " => Not installed:"
            echo "$FLATPAK_NOT_INSTALLED" | sed 's/^/    - /'
        fi
    fi
}
