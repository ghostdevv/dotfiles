#!/bin/zsh
pnpm dlx chokidar-cli '**.css' --ignore 'generated.css' --command 'pkill -9 ulauncher'
