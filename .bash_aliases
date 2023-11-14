sync() {
  if [[ -d ".git" ]]; then
    printf "\nSyncing with git:\n"

    git fetch
    git pull
  fi;

  if [[ -f "package-lock.json" ]]; then
    printf "\nInstalling with npm:\n"

    npm install
  elif [[ -f "pnpm-lock.yaml" ]]; then
    printf "\nInstalling with pnpm:\n"

    pnpm install
  fi;
}

update() {
  if [[ -f "package-lock.json" ]]; then
    printf "\nUpdating with npm:\n"

    rm -rf node_modules
    pnpm up --config.strict-peer-dependencies=false --config.engine-strict=false --latest -r --no-lockfile
    rm -rf node_modules
    npm i
  elif [[ -f "pnpm-lock.yaml" ]]; then
    printf "\nUpdating with pnpm:\n"

    pnpm up --config.strict-peer-dependencies=false --latest -r

    if [[ -f "pnpm-workspace.yaml" ]]; then
      pnpm up --config.strict-peer-dependencies=false --latest
    fi;
  fi;
}

resolve_pm() {
  local PM="pnpm"

  if [[ -f "package-lock.json" ]]; then
    PM="npm";
  fi;

  echo $PM;
}

pm() {
  local PM=$(resolve_pm);

  echo $PM $@;
  $PM $@;
}

pi() {
  local PM=$(resolve_pm);

  echo Running $PM install $1;
  $PM install $1;
}

pr() {
  local PM=$(resolve_pm);

  if [[ $# -eq 0 ]]; then
    echo "Please pass in a script to run";
    return 1;
  fi;

  echo Running $PM run $@;
  $PM run $@;
}

alias pd="pnpm dev"
alias pp="pnpm preview"
alias pb="pnpm build"

webp() {
    local REGEX='\.(png|jpg|jpeg|pnm|pgn|ppm|pam|tiff)$'

    if [ -z "$(echo $1 | grep -E -i $REGEX)" ]; then
        echo 'Error: File must be one of: png, jpg, jpeg, pnm, pgn, ppm, pam, tiff'
        exit 1
    fi

    cwebp -q 90 "$1" -o "$(echo $1 | sed -E "s/$REGEX//").webp"
}

alias hax="~/.zshrc -w"

tunnel() {
    if ! [[ $1 =~ ^-?[0-9]+$ ]]; then
        echo "Please pass a port as first argument to this command"
        return
    fi

    echo "Starting tunnel for http://localhost:$1"

    local ID="t$(date +%s)"
    
    screen -S "$ID" -L -Logfile "$ID" -dm bash -c "cloudflared tunnel --url http://localhost:$1"

    until grep -oqi 'https://.*trycloudflare.com' $ID; do
        echo '  Starting...'
        sleep 2
    done

    local URL="$(grep -oi 'https://.*trycloudflare.com' $ID 2>/dev/null)"

    echo "Tunnel running at $URL"

    if command -v pbcopy >/dev/null 2>&1; then
        echo "$URL" | pbcopy
        echo "  Copied to clipboard"
    elif command -v xsel >/dev/null 2>&1; then
        echo "$URL" | xsel --clipboard --input
        echo "  Copied to clipboard"
    else
        echo "  Unable to copy to clipboard"
    fi

    screen -S "$ID" -X logfile flush 0
    screen -S "$ID" -X log off
    rm -f "$ID"

    echo
    echo "Attaching to tunnel in 3 seconds..."

    sleep 3

    screen -r "$ID"
}
