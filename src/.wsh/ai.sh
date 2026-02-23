function serve-small-model() {
    llama-server \
        --port 7748 \
        --host '127.0.0.1' \
        --hf-repo unsloth/Llama-3.1-8B-Instruct-GGUF:Q5_K_M \
        --jinja \
        --n-gpu-layers 999 \
        --flash-attn on \
        --ctx-size 0 \
        --ubatch-size 2048 \
        --batch-size 2048
}
