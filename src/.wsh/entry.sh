for file in ~/.wsh/*.sh; do
  if [[ "$(basename "$file")" != "entry.sh" ]]; then
    source "$file"
  fi
done
