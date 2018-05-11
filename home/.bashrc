# Load system shared configures if exists.
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Load shared configures.
if [ -d "$HOME/.config/bash/rc.d" ]; then
    for SHARED_RC_FILE in $(find "$HOME/.config/bash/rc.d" -type f -o -type l); do
        . "$SHARED_RC_FILE"
    done
fi
