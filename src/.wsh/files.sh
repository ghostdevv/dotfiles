# Convert an image to webp
webp() {
  local REGEX='\.(png|jpg|jpeg|pnm|pgn|ppm|pam|tiff)$'

  if [ -z "$(echo $1 | grep -E -i $REGEX)" ]; then
      echo 'Error: File must be one of: png, jpg, jpeg, pnm, pgn, ppm, pam, tiff'
      exit 1
  fi

  cwebp -q 90 "$1" -o "$(echo $1 | sed -E "s/$REGEX//").webp"
}

# Uncompress any file
# This function is based on code by Arcolinux under the GNU GPL v3.0 License
# https://github.com/arcolinux/arcolinux-zsh/blob/121b8ed0619ea041a2eed5483491336ec1edbcb8/etc/skel/.zshrc#L455
ex() {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1   ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *.deb)       ar x $1      ;;
      *.tar.xz)    tar xf $1    ;;
      *.tar.zst)   tar xf $1    ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Based on idea by @braebo
function quish_simple() {
  if [[ ! -n "$1" ]]; then
    echo "Usage: quish_simple <file>"
    exit 1
  fi

  local file="$1"
  local resolution="1920:1080"
  local fps="30"
  local bitrate="1500"
  local type="mp4"
  local output="quished-$1"

  ffmpeg -y -v quiet -stats -i "$file" -vf "scale=$resolution:force_original_aspect_ratio=decrease,pad=$resolution:(ow-iw)/2:(oh-ih)/2" -r "$fps" -b:v "$bitrate"k "${output}.${type}" </dev/null
}

alias fw="viu ~/.wsh/images/framework-16-expansion-cards.png --width 45"

function imagine() {
    local text="${1:-"imagine"}"
    local output="/tmp/imagine-$text.gif"

    if [[ ! -f "$output" ]]; then
        echo -e "Downloading & Caching ${text}.gif"
        curl -sLo "$output" "https://imagine.willow.sh/$text.gif"
    fi

    viu --width 45 --frame-rate 12 "$output"
}
