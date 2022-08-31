sync() {
  if [ -d ".git" ]; then;
    printf "\nSyncing with git:\n"

    git fetch
    git pull
  fi;

  if [ -f "package-lock.json" ]; then;
    printf "\nInstalling with npm:\n"

    npm install
  elif [ -f "pnpm-lock.yaml" ]; then;
    printf "\nInstalling with pnpm:\n"

    pnpm install
  fi;
}

update() {
  if [ -f "package-lock.json" ]; then;
    printf "\nUpdating with npm:\n"

    rm -rf node_modules
    pnpm up --config.strict-peer-dependencies=false --config.engine-strict=false --latest -r --no-lockfile
    rm -rf node_modules
    npm i
  elif [ -f "pnpm-lock.yaml" ]; then;
    printf "\nUpdating with pnpm:\n"

    pnpm up --config.strict-peer-dependencies=false --latest -r

    if [ -f "pnpm-workspace.yaml" ]; then;
      pnpm up --config.strict-peer-dependencies=false --latest
    fi;
  fi;
}

resolve_pm() {
  local PM="pnpm"

  if [ -f "package-lock.json" ]; then;
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

  if [ $# -eq 0 ]; then;
    echo "Please pass in a script to run";
    return 1;
  fi;

  echo Running $PM run $@;
  $PM run $@;
}

alias pd="pnpm dev"
alias pp="pnpm preview"
alias pb="pnpm build"
