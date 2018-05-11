if [ -d "/usr/local/etc/bash_completion.d" ]; then
    for COMPLETION_FILE in $(find "/usr/local/etc/bash_completion.d" -type f -o -type l); do
        . "$COMPLETION_FILE"
    done
fi