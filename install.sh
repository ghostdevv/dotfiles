# Logs
echo "Installing dotfiles"

# Install volta
curl https://get.volta.sh | bash

# Load volta executable
VOLTA_HOME="$HOME/.volta"
PATH="$VOLTA_HOME/bin:$PATH"

# Setup volta
volta setup
volta install node

# Install global tools
volta install pnpm tsm create-ghost nodemon

# Load aliases
curl https://raw.githubusercontent.com/ghostdevv/dotfiles/main/.bash_aliases > ~/.bash_aliases

# Reload bash
. ~/.bashrc

# Done
echo "Done!"