function update-crates() {
    deno run \
        --allow-read=Cargo.toml --allow-write=Cargo.toml \
        --allow-env=NODE_DISABLE_COLORS,TMUX,TF_BUILD,TEAMCITY_VERSION,TERM_PROGRAM,COLORTERM,TERM,CI \
        --allow-net=crates.io \
        "$HOME/.wsh/scripts/update-crates.ts"
}
