# Update the git repo & deps
sync() {
  if [[ -d ".git" ]]; then
    printf "\nSyncing with git:\n"

    git fetch
    git pull
  fi;

  ni
}

# Check git status of child directories
function gsc() {
  local current_dir=$(pwd)

  echo "Checking git repositories in child directories..."
  echo

  for dir in */; do
    if [ -d "$dir" ]; then
      cd "$dir" || continue

      # Check if it's a git repository
      if [ -d ".git" ] || git rev-parse --git-dir > /dev/null 2>&1; then
        echo "📁 ${dir%/}"

        # Get current branch
        local branch=$(git branch --show-current)
        echo "  Branch: $branch"

        # Check for uncommitted changes
        if ! git diff --quiet || ! git diff --cached --quiet; then
          echo "  📝 Has uncommitted changes"
        fi

        # Check for unpushed commits and if behind remote
        local ahead=0
        local behind=0

        # Only check if there's a tracking branch
        if git rev-parse @{u} >/dev/null 2>&1; then
          ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
          behind=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo "0")

          if [ "$ahead" -gt 0 ]; then
            echo "  ⬆️  Has $ahead commit(s) not pushed"
          fi

          if [ "$behind" -gt 0 ]; then
            echo "  ⬇️  Is $behind commit(s) behind remote"
          fi

          # If no differences with remote and no local changes
          if [ "$ahead" -eq 0 ] && [ "$behind" -eq 0 ] && git diff --quiet && git diff --cached --quiet; then
            echo "  ✅ Repository is up to date"
          fi
        else
          echo "  ⚠️  No tracking branch"
        fi

        echo
      fi

      cd "$current_dir" || return
    fi
  done
}

function __wsh_parse_git_repo_arg() {
    local REPO
    if [[ "$1" =~ ^https?:// ]]; then
      REPO="$1"
    elif [[ "$1" =~ ^git@ ]]; then
      REPO="$1"
    elif [[ "$1" =~ ^[^/]+/[^/]+$ ]]; then
      REPO="git@github.com:$1.git"
    else
      return 1
    fi

    echo "$REPO"
}

# Based on idea by @braebo
function peep() {
  if [[ ! -n "$1" ]]; then
    echo "Usage: peep <repo>"
    return 1
  fi

  local REPO
  REPO=$(__wsh_parse_git_repo_arg "$1")

  if [[ $? -ne 0 ]]; then
    echo "Please provide a username/repo or full url"
    return 1
  fi

  local DEFAULT_BRANCH="$(git ls-remote --symref $REPO HEAD | grep '^ref:' | awk '{print $2}' | sed 's|refs/heads/||')"

  if [[ -z "$DEFAULT_BRANCH" ]]; then
    echo "No default branch found"
    return 1
  fi

  local LATEST_COMMIT_HASH="$(git ls-remote --head $REPO --ref $DEFAULT_BRANCH --type commit | head -n 1 | awk '{print $1}')"

  if [[ -z "$LATEST_COMMIT_HASH" ]]; then
    echo "No commit found"
    return 1
  fi

  local OUTPUT="/tmp/peep/$LATEST_COMMIT_HASH"
  mkdir -p "/tmp/peep"

  echo -e "peep v2.0.0"
  echo -e "  repo           : $REPO"
  echo -e "  destination    : $OUTPUT"
  echo -e "  latest-commit  : $LATEST_COMMIT_HASH"
  echo -e "  default-branch : $DEFAULT_BRANCH"

  if [[ ! -d "$OUTPUT" ]]; then
    echo -e "\nCloning..."
    git clone --depth 1 $REPO $OUTPUT
  fi

  echo -e "\nOpening in zed..."
  zeditor $OUTPUT
}

function clone() {
    if [[ ! -n "$1" ]]; then
      echo "Usage: clone <repo>"
      return 1
    fi

    local REPO
    REPO=$(__wsh_parse_git_repo_arg "$1")

    if [[ $? -ne 0 ]]; then
      echo "Please provide a username/repo or full url"
      return 1
    fi

    REPO="$(echo "$REPO" | sed 's|https://\([^/]*\)/\(.*\)|git@\1:\2|')"

    echo "Cloning $REPO"
    git clone $REPO ${@:2}
}
