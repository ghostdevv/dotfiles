# Install volta
curl https://get.volta.sh | bash

# Reload shell
. ~/.bashrc

# Install global tools
volta install pnpm
volta install tsc
volta install create-ghost
volta install astro
volta install nodemon

# Work around
cp -n ./.bash_aliases ~/.bash_aliases