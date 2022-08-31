# Install volta
curl https://get.volta.sh | bash

# Load volta executable
VOLTA_HOME="$HOME/.volta"
PATH="$VOLTA_HOME/bin:$PATH"

# Setup volta
volta setup
volta install node

# Install global tools
volta install pnpm
volta install tsm
volta install create-ghost
volta install astro
volta install nodemon

# Work around
# mkdir -p ~/scripts
# cp ./scripts/* ~/scripts
# cp -n ./.bash_aliases ~/.bash_aliases