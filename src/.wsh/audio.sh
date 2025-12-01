function create-virtual-listener() {
    local name="$1"

    if [ -z "$name" ]; then
        echo "Error: Name is required"
        return 1
    fi

    local source="$name-listener-source"
    local sink="$name-listener-sink"

    pactl load-module module-null-sink sink_name="$sink" sink_properties=device.description="$sink"
    pactl load-module module-null-sink media.class=Audio/Source/Virtual sink_name="$source" channel_map=front-left,front-right
    pw-link "$sink":monitor_FL "$source":input_FL
    pw-link "$sink":monitor_FR "$source":input_FR

    echo -e "Virtual listener $name-listener-{source,sink} created"
    echo -e "Plug audio from an app into the sink"
    echo -e "Then you can bring it from the source to where you need it"
}
