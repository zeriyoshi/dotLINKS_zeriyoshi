#!/bin/sh

__VERSION='0.0.2'
__UPSTREAM_URI='https://github.com/zeriyoshi/dotLINKS'

# POSIX friendly path detection.
# reference : https://qiita.com/komeda-shinji/items/67081ef81e79281b2c7b
case "$0" in
    ./*)
        __SCRIPT_PATH="$(pwd)/${0#./}"
        ;;
    /*)
        __SCRIPT_PATH="$0"
        ;;
    *)  
        __SCRIPT_PATH="$(pwd)/$0"
        ;;
esac
__SCRIPT_DIR="${__SCRIPT_PATH%/*}"

export_link () ## Link symbolic links.
{
    __print_purple "Create symbolic link.\n"

    __print_yellow "Cleanup unused files? (ex: .DS_Store) [Y/n]:"
    read CHOICE
    __line_back
    if [ "$CHOICE" != 'n' ]; then
        __print_cyan "\n  Removing unused files..."
        find $__SCRIPT_DIR/home \( -name '.DS_Store' -or -name '._*' -or -name 'Thumbs.db' -or -name 'Desktop.ini' \) -delete
        printf " done\n"
    fi

    printf "\n"

    __print_cyan "  Target user home directory\n\n"
    printf "    $HOME\n\n"
    __print_cyan "  Create symbolic link(s)\n\n"
    FILES=$(find $__SCRIPT_DIR/home -type f | sed 's/^.*home//')
    for FILE in $FILES; do
        echo "    $FILE"
    done

    __print_yellow "Are you sure? [y/N]:"
    read CHOICE
    __line_back
    if [ "$CHOICE" != 'y' ]; then
        __print_red "Aborted.\n"
        exit 1
    fi

    printf "\n"

    for FILE in $FILES; do
        FILE_DIR=$(dirname "$HOME$FILE")

        if [ ! -d "$FILE_DIR" ]; then
            mkdir -p "$FILE_DIR"
            __print_purple "[CREATED]"
            printf " $FILE_DIR \n"
        fi

        if [ -f "$HOME$FILE" ]; then
            __print_yellow "File already exists ($HOME$FILE) overwrite? [y/N]:"
            read CHOICE
            __line_back
            if [ "$CHOICE" != 'y' ]; then
                __print_yellow "[SKIPPED]"
                printf " $HOME$FILE\n"
                continue
            fi
        fi

        ln -sf "$__SCRIPT_DIR/home$FILE" "$HOME$FILE"
        __print_cyan "[LINKED]"
        printf "  $HOME$FILE\n"
    done
}

export_unlink () ## Unlink symbolic links.
{
    __print_purple "Removing symbolic link.\n"

    printf "\n"

    __print_cyan "  Target user home directory\n\n"
    printf "    $HOME\n\n"
    __print_cyan "  Removing symbolic link(s)\n\n"
    FILES=$(find $__SCRIPT_DIR/home -type f | sed 's/^.*home//')
    for FILE in $FILES; do
        echo "    $FILE"
    done

    __print_yellow "Are you sure? [y/N]:"
    read CHOICE
    __line_back
    if [ "$CHOICE" != 'y' ]; then
        __print_red "Aborted.\n"
        exit 1
    fi

    printf "\n"

    for FILE in $FILES; do
        if [ -L "$HOME$FILE" ]; then
            unlink "$HOME$FILE"
            __print_cyan "[UNLINKED]"
            printf " $HOME$FILE\n"
        else
            if [ -f "$HOME$FILE" ]; then
                __print_yellow "This file is not symbolic link ($HOME$FILE) force delete? [y/N]:"
                read CHOICE
                __line_back
                if [ "$CHOICE" != 'y' ]; then
                    rm "$HOME$FILE"
                    __print_red "[DELETED]"
                    printf "  $HOME$FILE\n"
                else
                    __print_yellow "[SKIPPED]"
                    printf " $HOME$FILE\n"
                fi
            fi
        fi
        UNLINK_DIR=$(dirname "$HOME$FILE")
        
        if [ -d "$UNLINK_DIR" ]; then
            UNLINK_DIR_ITEM_COUNT=$(find "$UNLINK_DIR" -maxdepth 1 -mindepth 1 | wc -l)
            if [ $UNLINK_DIR_ITEM_COUNT -eq 0 ]; then
                rmdir "$UNLINK_DIR"
                __print_purple "[DELETED]"
                printf "  $UNLINK_DIR\n"
            fi
        fi
    done
}

export_version () ## Show version.
{
    __print_cyan "dotLINKS"
    printf " version "
    __print_yellow "$__VERSION"
    printf " ($__UPSTREAM_URI)\n"
}

# Self documentation.
# reference : https://qiita.com/suttang/items/d4b4474e93c8e74ae515
export_usage () ## Show usage.
{
    export_version
    
    printf "\n"

    __print_yellow "Usage:\n"
    printf " $__SCRIPT_PATH [command]\n\n"

    __print_yellow "Commands:\n"

    grep -E '^(function\s+)?\w+ \(\)\s+\{?\s*##' $__SCRIPT_PATH | sed -e 's/{//;s/ \{1,\}/ /g;s/function //;s/() ## /<>/' | cut -c8- | awk -F '<>' '{printf " \033[35m%-20s\033[0m %s\n", $1, $2}'
}

__line_back ()
{
    printf "\033[1A\033[2K"
}

__print_red ()
{
    __print_opt '31m' "$1"
}

__print_yellow ()
{
    __print_opt '33m' "$1"
}

__print_cyan ()
{
    __print_opt '36m' "$1"
}

__print_purple ()
{
    __print_opt '35m' "$1"
}

__print_opt ()
{
    printf "\033[$1$2\033[0m"
}

if [ '__' != "$(echo \"$1\" | cut -c1-2)" ] && [ -n "$(type -t export_$1)" ] && [ "$(type -t export_$1)" = function ]; then
    "export_$1" $@
elif [ "$1" = '' ]; then
    export_usage
    exit 1
else
    __print_red "[ERROR] Invalid command"
    printf " $1\n"
    export_usage
    exit 1
fi