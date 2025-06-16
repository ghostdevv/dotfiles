function imagine() {
    local text="${1:-"imagine"}"
    local output="/tmp/imagine-$text.gif"

    if [[ ! -f "$output" ]]; then
        echo -e "Downloading & Caching ${text}.gif"
        curl -sLo "$output" "https://imagine.willow.sh/$text.gif"
    fi

    viu --width 45 --frame-rate 12 "$output"
}

function ai-image() {
    local PROMPT="$@";

    if [[ -z "$PROMPT" ]]; then
        echo "Error: No prompt provided."
        return 1
    fi

    local ID="$(openssl rand -hex 16)"
    local OUTPUT="/tmp/ai-images/$ID"
    local SEED="$((1 + $RANDOM % 100))"

    echo -e "ai-image generator"
    echo -e "  prompt: \"$PROMPT\""
    echo -e "  seed:   $SEED"
    echo -e "  output: $OUTPUT.png"
    echo -e ""

    mkdir -p "$(dirname $OUTPUT)"

    printf "Generating image..."

    local CLOUDFLARE_ACCOUNT_ID="$(op item get 'ai-image command' --format json --fields 'username' | jq .value --raw-output)"
    local CLOUDFLARE_API_TOKEN="$(op item get 'ai-image command' --format json --fields 'credential' | jq .value --raw-output)"

    curl https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/ai/run/@cf/black-forest-labs/flux-1-schnell  \
        -X POST  \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN"  \
        -d "{ \"seed\": \"$SEED\", \"prompt\": \"$PROMPT\" }" \
        -o "$OUTPUT.json" \
        --progress-bar

    echo -e ""

    jq .result.image "$OUTPUT.json" --raw-output | base64 -d > "$OUTPUT.png"

    viu "$OUTPUT.png" --width 45
}
