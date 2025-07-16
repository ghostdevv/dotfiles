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

function yt-dlp-abv() {
    mkdir -p "video"
    yt-dlp -f "bestvideo[height<=1080]+bestaudio" \
        --write-thumbnail --embed-thumbnail --add-metadata \
        --embed-subs --sub-langs "en" --write-auto-subs \
        --merge-output-format mkv \
        -o "video/%(uploader)s/%(title,id)S-%(id)s.%(ext)s" \
        "$1"
}

function v2a() {
    local SOURCE="video"
    local DEST="audio"

    if [[ ! -d "$SOURCE" ]]; then
        echo "Error: Source directory '$SOURCE' does not exist"
        return 1
    fi

    mkdir -p "$DEST"

    # Find all video files recursively
    find "$SOURCE" -type f \( -name "*.mkv" -o -name "*.mp4" -o -name "*.webm" \) | while read -r VIDEO_FILE; do
        # Get relative path from source directory
        local REL_PATH="${VIDEO_FILE#$SOURCE/}"
        local DIR_PATH=$(dirname "$REL_PATH")
        local FILENAME=$(basename "$REL_PATH")
        local FILENAME_NO_EXT="${FILENAME%.*}"

        # Create destination directory structure
        local DEST_DIR="$DEST/$DIR_PATH"
        mkdir -p "$DEST_DIR"

        # Full path to output FLAC file
        local OUTPUT_FILE="$DEST_DIR/$FILENAME_NO_EXT.flac"

        # Skip if FLAC already exists
        if [[ -f "$OUTPUT_FILE" ]]; then
            echo "Skipping '$VIDEO_FILE' - FLAC already exists"
            continue
        fi

        # Look for thumbnail image with same name
        local THUMBNAIL=""
        local VIDEO_DIR=$(dirname "$VIDEO_FILE")
        for ext in webp jpg jpeg png; do
            local THUMB_PATH="$VIDEO_DIR/$FILENAME_NO_EXT.$ext"
            if [[ -f "$THUMB_PATH" ]]; then
                THUMBNAIL="$THUMB_PATH"
                break
            fi
        done

        echo "Converting '$VIDEO_FILE' to '$OUTPUT_FILE'"

        if [[ -n "$THUMBNAIL" ]]; then
            echo "Adding cropped square thumbnail: $THUMBNAIL"
            # Extract audio with cropped square thumbnail
            ffmpeg -y -v quiet -stats \
                -i "$VIDEO_FILE" \
                -i "$THUMBNAIL" \
                -map 0:a:0 \
                -map 1:0 \
                -c:a flac \
                -vf "crop=min(iw\,ih):min(iw\,ih)" \
                -c:v:0 png \
                -disposition:v:0 attached_pic \
                -metadata:s:v title="Album cover" \
                -metadata:s:v comment="Cover (front)" \
                -map_metadata 0 \
                "$OUTPUT_FILE" </dev/null
        else
            echo "No thumbnail found, extracting audio only"
            # Extract audio without thumbnail
            ffmpeg -y -v quiet -stats -i "$VIDEO_FILE" \
                -vn -c:a flac -map_metadata 0 \
                "$OUTPUT_FILE" </dev/null
        fi

        if [[ $? -eq 0 ]]; then
            echo "Successfully converted '$VIDEO_FILE'"
        else
            echo "Error converting '$VIDEO_FILE'"
        fi
    done
}
