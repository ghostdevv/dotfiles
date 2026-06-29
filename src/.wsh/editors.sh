# Remap zeditor to zed
alias zed="zeditor"

# Open the ~/.zshrc in zed
alias hax="zed ~/.zshrc"

# Set nano as the editor
export EDITOR="nano"

# run pi
alias clank="$(volta which pi)"

function code-install-extensions() {
  local list="$HOME/.config/Code - OSS/extensions"

  if [[ ! -f "$list" ]]; then
    echo "Extensions list not found at '$list'"
    return
  fi

  while IFS= read -r extension; do
    echo "Installing extension: $extension"
    code --install-extension "$extension"
  done < "$list"
}
