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

        # Check for stashes
        local stash_count=$(git stash list | wc -l)
        if [ "$stash_count" -gt 0 ]; then
          echo "  📦 Has $stash_count stash(es)"
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

function co-authored-by() {
    local username="$1"

    if [[ -z "$username" ]]; then
        echo "Usage: co-authored-by <username>"
        return 1
    fi

    local data
    # Thanks to Seth Larson for the fetch idea!
    # https://sethmlarson.dev/easy-github-co-authored-by
    data=$(curl "https://api.github.com/users/$username" --silent --fail-with-body)

    if [[ $? -ne 0 ]]; then
        echo -e "Failed to fetch with $data"
        return 1
    fi

    echo $data | jq \
        --raw-output \
        '"Co-Authored-By: \(.name) <\(.id)+\(.login)@users.noreply.github.com>"'
}

function pr-comments() {
    local pr_number="" owner="" repo="" author="" show_all=false
    local positional=()

    # Parse flags and positional args
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --author) author="$2"; shift 2 ;;
            --all)    show_all=true; shift ;;
            --help|-h)
                echo "Usage: pr-comments <pr-number|url> [owner/repo] [--author LOGIN] [--all]"
                echo ""
                echo "Fetches PR comments and review threads using the GitHub GraphQL API (via gh)."
                echo ""
                echo "  <pr-number>     PR number in the current repo"
                echo "  <url>           Full GitHub PR URL"
                echo "  [owner/repo]    Repository (optional, detected from git remote)"
                echo "  --author LOGIN  Only show threads started by LOGIN"
                echo "  --all           Include resolved and outdated threads"
                return 0
                ;;
            *) positional+=("$1"); shift ;;
        esac
    done

    local arg="${positional[1]:-}"
    local repo_arg="${positional[2]:-}"

    if [[ -z "$arg" ]]; then
        pr-comments --help
        return 1
    fi

    # Parse input: URL or bare number
    if [[ "$arg" =~ ^https?://github\.com/([^/]+)/([^/]+)/pull/([0-9]+) ]]; then
        owner="${match[1]}"
        repo="${match[2]}"
        pr_number="${match[3]}"
    elif [[ "$arg" =~ ^[0-9]+$ ]]; then
        pr_number="$arg"
    else
        echo "Error: expected a PR number or GitHub PR URL."
        return 1
    fi

    # Resolve owner/repo if not parsed from URL
    if [[ -z "$owner" || -z "$repo" ]]; then
        if [[ -n "$repo_arg" && "$repo_arg" =~ ^([^/]+)/([^/]+)$ ]]; then
            owner="${match[1]}"
            repo="${match[2]}"
        else
            local remote_url
            remote_url=$(git remote get-url origin 2>/dev/null)

            if [[ -z "$remote_url" ]]; then
                echo "Error: no git remote found. Provide owner/repo as second argument."
                return 1
            fi

            if [[ "$remote_url" =~ github\.com[:/]([^/]+)/([^/.]+) ]]; then
                owner="${match[1]}"
                repo="${match[2]}"
            else
                echo "Error: could not parse owner/repo from remote: $remote_url"
                return 1
            fi
        fi
    fi

    # Build jq filters
    local jq_thread_select='.isResolved == false and .isOutdated == false'
    if $show_all; then
        jq_thread_select='true'
    fi

    local jq_author_select='true'
    if [[ -n "$author" ]]; then
        jq_author_select="\$c.author.login == \"$author\""
    fi

    local jq_comment_author='true'
    if [[ -n "$author" ]]; then
        jq_comment_author=".author.login == \"$author\""
    fi

    # jq filter for review threads
    local jq_threads
    jq_threads="$(cat <<'JQEOF'
[
  .data.repository.pullRequest.reviewThreads.nodes[]
  | select(__THREAD_SELECT__)
  | .comments.nodes[0] as $c
  | select(__AUTHOR_SELECT__)
  | {
      id: .id,
      author: $c.author.login,
      path: $c.path,
      line: $c.line,
      url: $c.url
    } + (
      if ($c.body | test("DESCRIPTION START"))
      then {
        title:       ($c.body | split("\n")[0]),
        severity:    ($c.body | split("\n")[2]),
        description: ($c.body | capture("DESCRIPTION START -->\\s*(?<d>[\\s\\S]*?)\\s*<!-- DESCRIPTION END").d // ""),
        locations:   ($c.body | capture("LOCATIONS START\\n(?<l>[\\s\\S]*?)\\nLOCATIONS END").l // "")
      }
      else { body: $c.body }
      end
    )
]
JQEOF
)"
    jq_threads="${jq_threads//__THREAD_SELECT__/$jq_thread_select}"
    jq_threads="${jq_threads//__AUTHOR_SELECT__/$jq_author_select}"

    # jq filter for conversation comments
    local jq_comments
    jq_comments="$(cat <<JQEOF
[
  .data.repository.pullRequest.comments.nodes[]
  | select($jq_comment_author)
  | {
      author: .author.login,
      date:   .createdAt[0:10],
      url:    .url,
      body:   .body
    }
]
JQEOF
)"

    # Execute GraphQL query — fetches both conversation comments and review threads
    local raw_response
    raw_response=$(gh api graphql -f query="
{
  repository(owner: \"$owner\", name: \"$repo\") {
    pullRequest(number: $pr_number) {
      comments(last: 100) {
        nodes {
          author { login }
          body
          createdAt
          url
        }
      }
      reviewThreads(last: 100) {
        nodes {
          id
          isResolved
          isOutdated
          comments(first: 1) {
            nodes {
              author { login }
              body
              path
              line
              url
            }
          }
        }
      }
    }
  }
}" 2>&1)

    if [[ $? -ne 0 ]]; then
        echo "Error fetching PR data:"
        echo "$raw_response"
        return 1
    fi

    # Process conversation comments
    local comments
    comments=$(printf '%s\n' "$raw_response" | jq "$jq_comments" 2>&1)
    if [[ $? -ne 0 ]]; then
        echo "Error processing comments with jq:"
        echo "$comments"
        return 1
    fi

    # Process review threads
    local threads
    threads=$(printf '%s\n' "$raw_response" | jq "$jq_threads" 2>&1)
    if [[ $? -ne 0 ]]; then
        echo "Error processing review threads with jq:"
        echo "$threads"
        return 1
    fi

    local comment_count thread_count
    comment_count=$(printf '%s\n' "$comments" | jq 'length')
    thread_count=$(printf '%s\n' "$threads" | jq 'length')

    local label="unresolved"
    $show_all && label="all"

    if [[ "$comment_count" -eq 0 && "$thread_count" -eq 0 ]]; then
        echo "No comments or ${label} review threads on PR #$pr_number ($owner/$repo)"
        [[ -n "$author" ]] && echo "  (filtered to author: $author)"
        return 0
    fi

    echo "PR #$pr_number - $owner/$repo"
    [[ -n "$author" ]] && echo "  filtered to author: $author"
    echo ""

    # Print conversation comments
    if [[ "$comment_count" -gt 0 ]]; then
        echo "=== Comments ($comment_count) ==="
        echo ""
        printf '%s\n' "$comments" | jq -r '.[] |
            "--- " + .author + " (" + .date + ") ---\n" +
            .body + "\n" +
            .url + "\n"
        '
    fi

    # Print review threads
    if [[ "$thread_count" -gt 0 ]]; then
        echo "=== Review Threads ($thread_count ${label}) ==="
        echo ""
        printf '%s\n' "$threads" | jq -r '.[] |
            "--- " + .author + " @ " + .path + ":" + (.line // 0 | tostring) + " ---\n" +
            (if .title then
                "Title: "       + .title + "\n" +
                "Severity: "    + .severity + "\n" +
                "Description: " + .description + "\n" +
                (if .locations != "" then "Locations:\n" + .locations + "\n" else "" end)
            else
                .body + "\n"
            end) +
            .url + "\n"
        '
    fi
}
