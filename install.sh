#!/bin/bash

# Vars
CURRENT_DIR="$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)";

# Logs
echo "Installing dotfiles"
printf "in: '$SHELL' at: '$CURRENT_DIR'\n\n"

# Install & Setup volta
if ! command -v volta &> /dev/null; then
    curl https://get.volta.sh | bash

    export VOLTA_FEATURE_PNPM="1"
    export VOLTA_HOME="$HOME/.volta"
    export PATH="$VOLTA_HOME/bin:$PATH"

    volta setup
    volta install node@20
    volta install pnpm@8 tsm nodemon @antfu/ni
fi

# Download & Update dotfiles
source "$CURRENT_DIR/src/.dotfiles.sh"
update_dotfiles

if [ "$(basename $SHELL)" = "bash" ]; then
    source ~/.bashrc
fi

printf "\n\n\nPlease include the following at the top of your shell config file:\n\n"
cat "$CURRENT_DIR/.zshrc.example"
