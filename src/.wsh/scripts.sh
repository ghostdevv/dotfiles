function update-crates() {
    deno run \
        --allow-read=Cargo.toml --allow-write=Cargo.toml \
        --allow-env=TERM,CI --allow-net=crates.io \
        "$HOME/.wsh/scripts/update-crates.ts"
}
