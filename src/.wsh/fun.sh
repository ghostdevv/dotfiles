function imagine() {
    local text="${1:-"imagine"}"
    local output="/tmp/imagine-$text.gif"

    if [[ ! -f "$output" ]]; then
        echo -e "Downloading & Caching ${text}.gif"
        curl -sLo "$output" "https://imagine.willow.sh/$text.gif"
    fi

    viu --width 45 --frame-rate 12 "$output"
}
