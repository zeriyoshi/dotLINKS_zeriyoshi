if [ -d "/usr/local/etc/bash_completion.d" ]; then
    for COMPLETION_FILE in $(find "/usr/local/etc/bash_completion.d" -type f -o -type l); do
        . "$COMPLETION_FILE"
    done
fi

if [ -r "/usr/share/git-core/contrib/completion/git-prompt.sh" ]; then
    . /usr/share/git-core/contrib/completion/git-prompt.sh
fi