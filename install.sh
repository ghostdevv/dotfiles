#!/bin/bash

# Vars
CURRENT_DIR="$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)";

# Logs
echo "Installing dotfiles"
echo "B_S: ${BASH_SOURCE} S: $SHELL CD: $CURRENT_DIR"

# Install volta
curl https://get.volta.sh | bash

# Load volta executable
VOLTA_HOME="$HOME/.volta"
PATH="$VOLTA_HOME/bin:$PATH"

# Setup volta
volta setup
volta install node

# Install global tools
volta install pnpm yarn tsm nodemon

# Load aliases
cp "$CURRENT_DIR/.bash_aliases" ~/.bash_aliases

# Reload bash
. ~/.bashrc

# Done
echo "Done!"