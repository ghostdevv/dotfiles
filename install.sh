#!/bin/bash

# Vars
CURRENT_DIR="$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)";

# Logs
echo "Installing dotfiles"
printf "in: '$SHELL' at: '$CURRENT_DIR'\n\n"

# Install & Setup Deno
if ! command -v deno &> /dev/null; then
    curl -fsSL https://deno.land/install.sh | sh

    export DENO_INSTALL="/home/ghost/.deno"
    export PATH="$DENO_INSTALL/bin:$PATH"
fi

# Download & Update wsh
source "$CURRENT_DIR/src/.wsh/dotfiles.sh"
update-dotfiles

if [ "$(basename $SHELL)" = "bash" ]; then
    source ~/.bashrc
fi

printf "\n\n\nPlease include the following at the top of your shell config file:\n\n"
cat "$CURRENT_DIR/.zshrc.example"
