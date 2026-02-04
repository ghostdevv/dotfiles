# optionally configure volta
if [[ -d "$HOME/.volta" ]]; then
  export VOLTA_FEATURE_PNPM="1"
  export VOLTA_HOME="$HOME/.volta"
  export PATH="$VOLTA_HOME/bin:$PATH"
fi

# optionally configure deno
if [[ -d "$HOME/.deno" ]]; then
  export DENO_INSTALL="$HOME/.deno"
  export PATH="$DENO_INSTALL/bin:$PATH"
fi

# Svelte settings
export SVELTE_INSPECTOR_OPTIONS=true
export SVELTE_INSPECTOR_TOGGLE=ctrl+alt

# @antfu/ni settings
export NI_DEFAULT_AGENT="pnpm"
export NI_GLOBAL_AGENT="pnpm"

# install/command aliases
alias pi="ni"
alias pd="nr dev"
alias pp="nr preview"
alias pb="nr build"

if ! command -v pnpx &> /dev/null; then
    alias pnpx="pnpm dlx"
fi

# Update deps
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
  else
    echo "No lockfile found"
  fi;
}

# List package.json/deno scripts
scripts() {
    if [[ -f "package.json" ]]; then
        echo "Scripts in package.json"
        jq -r .scripts package.json
        return 0
    fi

    if [[ -f "deno.json" ]]; then
        echo "Tasks in deno.json"
        jq -r .tasks deno.json
        return 0
    fi

    echo "No package.json or deno.json found"
}

function yeet-node-modules() {
    # Find all node_modules directories and store them in an array
    NODE_MODULES_DIRS=()
    while IFS= read -r dir; do
        NODE_MODULES_DIRS+=("$dir")
    done < <(find . -name "node_modules" -type d -prune)

    # Check if any node_modules directories were found
    if [ ${#NODE_MODULES_DIRS[@]} -eq 0 ]; then
        echo "No node_modules directories found."
        return 0
    fi

    echo "The following node_modules directories will be deleted:"
    printf "  %s\n" "${NODE_MODULES_DIRS[@]}"

    echo -n "Do you want to delete these directories? (y/N): "
    read -r answer

    # Check the answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        echo "Deleting node_modules directories..."
        for dir in "${NODE_MODULES_DIRS[@]}"; do
            rm -rf "$dir"
            echo "  Deleted: $dir"
        done
        echo "Done!"
    else
        echo "No worries! I've not deleted anything"
    fi
}

function packument() {
    local name=$1;

    if [[ ! -n "$1" ]]; then
        echo -e "Usage: packument <name> [version]"
        return 1
    fi

    local pkg
    pkg=$(curl "https://registry.npmjs.org/$1" --silent --fail-with-body)

    if [[ $? -ne 0 ]]; then
        echo -e "Failed to fetch with data $pkg"
        return 1
    fi

    if [[ ! -n "$2" ]]; then
        jq --monochrome-output . <<< $pkg | bat \
            --file-name "Packument: $1" \
            --language json
        return 0
    fi

    local pkv=$(
        jq \
            --exit-status \
            --monochrome-output \
            ".versions[\"$2\"] // .versions[.\"dist-tags\"[\"$2\"]?]?" \
            <<< "$pkg"
    )

    if [[ $? -eq 0 && -n "$pkv" ]]; then
        echo $pkv | bat \
            --file-name "Packument Version: $1@$(jq --raw-output '.version' <<< $pkv)" \
            --language json
    else
        echo -e "Failed to get packument for \"$1\" (version: '$2')"
    fi
}
