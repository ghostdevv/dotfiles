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
    echo "Installing System Packages"
    yay -Sy --needed \
      noto-fonts noto-fonts-extra noto-fonts-cjk ttf-twemoji ttf-comic-mono-git ttf-liberation ttf-dejavu adobe-source-code-pro-fonts \
      adobe-source-sans-fonts adobe-source-serif-fonts adobe-source-han-sans-otc-fonts adobe-source-han-serif-otc-fonts ttf-hanazono \
      ttf-opensans cantarell-fonts \
      breeze-gtk breeze-icons xcursor-breeze archlinux-tweak-tool-git \
      gnome-browser-connector gnome-tweaks power-profiles-daemon \
      mullvad-vpn-bin tailscale dog 7zip unzip trash-cli viu rustup fw-fanctrl-git tree ripgrep ladybird-git \
      appimagelauncher flatpak reflector balena-etcher-bin chromium librewolf-bin \
      bat fastfetch cmatrix ddgr jq 1password 1password-cli scrcpy yt-dlp cloudflared-bin screen aws-cli-bin perl-image-exiftool \
      spotify gparted vlc blender brave-bin filelight signal-desktop htop imagemagick audacity \
      visual-studio-code-bin lazydocker lazygit ghostty guake github-cli docker docker-compose hyperfine zed nano man-db \
      jdk17-openjdk jdk21-openjdk cmake bluez bluez-utils gsmartcontrol smartmontools ollama \
      zsh pnpm-shell-completion zsh-syntax-highlighting \
      pipewire wireplumber pipewire-audio pipewire-alsa pipewire-pulse lib32-pipewire \
      wireless-regdb acpi iio-sensor-proxy fprint less usbutils dosfstools wget python-black \
      nmap gnu-netcat traceroute whois go just pop-icon-theme-git fd hexyl ulauncher tlrc-bin

      # amd-ucode base base-devel btrfs-progs efibootmgr gnome grub linux-headers linux-firmare
      # linux-zen mesa lib32-mesa mesa-utils networkmanager openssh plymouth vulkan-radeon git
      # steam wine wine-gecko wine-mono vulkan-headers
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
  fi

  if ! groups $USER | grep -q "\bdocker\b"; then
    echo -e "\nAdded you to the docker group"
    sudo usermod -aG docker $USER
  fi

  echo -n "\nDo you want to install/update flatpak packages? (Y/n): "
  read answer
  answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

  if [[ "$answer" != "n" ]]; then
    echo -e "\nInstalling Flatpak Packages"
    flatpak install --or-update flathub \
        io.missioncenter.MissionCenter org.qbittorrent.qBittorrent it.mijorus.smile \
        org.raspberrypi.rpi-imager ca.desrt.dconf-editor md.obsidian.Obsidian com.discordapp.Discord com.modrinth.ModrinthApp \
        org.gimp.GIMP org.dbgate.DbGate com.github.tchx84.Flatseal com.obsproject.Studio org.libreoffice.LibreOffice \
        io.github.flattool.Warehouse org.gnome.Papers com.github.jeromerobert.pdfarranger org.kde.kdenlive \
        org.nickvision.tagger org.gnome.Boxes com.tutanota.Tutanota page.tesk.Refine org.bluesabre.MenuLibre \
        com.mongodb.Compass io.github.realmazharhussain.GdmSettings org.gnome.meld app.zen_browser.zen \
        it.mijorus.whisper net.mkiol.SpeechNote
  fi

  echo -e "\nSetting Gnome Settings"
  # theming
  echo " - theme settings"
  gsettings set org.gnome.desktop.interface monospace-font-name 'Comic Mono 10'
  gsettings set org.gnome.desktop.interface cursor-theme 'Breeze_Light'
  gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'
  dconf write /org/gnome/shell/extensions/user-theme/name "'GHOST'"
  dconf write /org/gnome/desktop/interface/accent-color "'blue'"
  gsettings set org.gnome.desktop.interface show-battery-percentage true
  gsettings set org.gnome.shell favorite-apps "['brave-browser.desktop', 'com.discordapp.Discord.desktop', 'appimagekit_c6a7ecf86d9d84cd6069bf81dd900a87-karma.desktop', 'org.gnome.Nautilus.desktop', 'spotify.desktop', 'com.tutanota.Tutanota.desktop', 'md.obsidian.Obsidian.desktop', '1password.desktop']"
  gsettings set org.gnome.settings-daemon.plugins.power ambient-enabled false
  # gdm theming
  echo " - gdm theme settings"
  dconf write /org/gnome/login-screen/logo "''"
  dconf write /io/github/realmazharhussain/GdmSettings/appearance/cursor-theme "'Breeze_Light'"
  dconf write /io/github/realmazharhussain/GdmSettings/appearance/icon-theme "'Adwaita'"
  dconf write /io/github/realmazharhussain/GdmSettings/appearance/background-color "'rgb(18, 18, 20)'"
  dconf write /io/github/realmazharhussain/GdmSettings/appearance/background-type "'image'"
  dconf write /io/github/realmazharhussain/GdmSettings/appearance/background-image "'$HOME/Pictures/background.png'"
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
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal/command "'ghostty'"
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal/binding "'<Super>T'"
  ## guake
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/guake-toggle/name "'Guake Toggle'"
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/guake-toggle/command "'guake-toggle'"
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/guake-toggle/binding "'<Alt>Return'"
  ## smile
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/emoji-toggle/name "'Emoji Picker (Smile) Toggle'"
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/emoji-toggle/command "'flatpak run it.mijorus.smile'"
  dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/emoji-toggle/binding "'<Super>period'"
  ## rofi
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
