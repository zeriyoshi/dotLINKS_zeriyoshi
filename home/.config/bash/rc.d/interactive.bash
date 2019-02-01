# Real interactive environment only configures.
# reference : https://qiita.com/dark-space/items/cf25001f89c41341a9fd
if [[ $- =~ i ]]; then
    if [ -d "${HOME}/.config/bash/interactive.d" ]; then
        for INTERACTIVE_FILE in $(find "${HOME}/.config/bash/interactive.d" -type f -o -type l); do
            . "${INTERACTIVE_FILE}"
        done
    fi

    if [ ! "${TERM_PROGRAM}" = "" ] && [ -d "${HOME}/.config/bash/term.d/${TERM_PROGRAM}" ]; then
        for TERM_FILE in $(find "${HOME}/.config/bash/term.d/${TERM_PROGRAM}" -type f -o -type l); do
            . "${TERM_FILE}"
        done
    fi
fi