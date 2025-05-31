# Get host info using mullvad api
alias hinfo="curl -s https://am.i.mullvad.net/json | jq"

# Start a cloudflare tunnel with optional port
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
