# Vars
CURRENT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

# Logs
echo "Install dotfiles from $CURRENT_DIR"

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

# Copy aliases
mkdir -p ~/scripts
cp -r $CURRENT_DIR/scripts/* ~/scripts
cp $CURRENT_DIR/.bash_aliases ~/.bash_aliases

# Reload bash
. ~/.bashrc

# Done
echo "Done!"