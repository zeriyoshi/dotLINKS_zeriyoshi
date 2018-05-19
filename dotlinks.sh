#!/bin/sh

__VERSION='0.0.4'
__UPSTREAM_URI_HTTP='https://github.com/zeriyoshi/dotLINKS'
__UPSTREAM_URI_SSH='git@github.com:zeriyoshi/dotLINKS.git'

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

__check_git()
{
    print_yellow "  Checking git installed status..."
    if ! type git > /dev/null 2>&1; then
        print_red "FAILED\n\nUpgrade process depends for git,\nPlease install and retry.\n\nAborted.\n"
        exit 1
    fi
    print_cyan "OK\n"
}

__check_git_upstream()
{
    print_yellow "  Checking remote upstream repository..."
    REMOTE_UPSTREAM_URI="$(cd "$__SCRIPT_DIR"; git remote get-url upstream 2>/dev/null &&:)"
    if [ ! "$REMOTE_UPSTREAM_URI" = "$__UPSTREAM_URI_SSH" ] && [ ! "$REMOTE_UPSTREAM_URI" = "$__UPSTREAM_URI_HTTP" ]; then
        print_yellow "INVALID\n"
        print_yellow "    Setting remote upstream repository..."
        $(cd "$__SCRIPT_DIR"; git remote add upstream "$__UPSTREAM_URI_SSH")
        REMOTE_UPSTREAM_URI="$(cd "$__SCRIPT_DIR"; git remote get-url upstream 2>/dev/null &&:)"
        if [ ! "$REMOTE_UPSTREAM_URI" = "$__UPSTREAM_URI_SSH" ] && [ ! "$REMOTE_UPSTREAM_URI" = "$__UPSTREAM_URI_HTTP" ]; then
            print_red "FAILED\n\nCannot add remote upstream repository.\nCheck upstream setting manually.\n\nAborted.\n"
            exit 1
        else
            print_cyan "OK\n"
        fi
    else
        print_cyan "OK\n"
    fi
}

export_init () ## Initialize dotLINKS.
{
    __check_git

    print_yellow "  Your dotLINKS remote repository :"
    read REMOTE_ORIGIN
    line_back
    if [ "$REMOTE_ORIGIN" = '' ]; then
        print_red "Initialize required remote repository.\n\nAborted.\n"
        exit 1
    fi

    print_yellow "  Setting remote origin repository..."
    $(cd "$__SCRIPT_DIR"; git remote set-url origin "$REMOTE_ORIGIN")
    REMOTE_ORIGIN_URI="$(cd "$__SCRIPT_DIR"; git remote get-url origin 2>/dev/null &&:)"
    if [ "$REMOTE_ORIGIN_URI" = "$REMOTE_ORIGIN" ]; then
        print_cyan "OK\n"
    else
        print_red "FAILED\n\nCannot add remote origin repository.\n\nAborted.\n"
        exit 1
    fi

    __check_git_upstream

    print_cyan "\nInitialize successfully.\n"
}

export_link () ## Link symbolic links.
{
    print_purple "Create symbolic link.\n"

    print_yellow "Cleanup unused files? (ex: .DS_Store) [Y/n]:"
    read CHOICE
    line_back
    if [ "$CHOICE" != 'n' ]; then
        print_cyan "\n  Removing unused files..."
        find "$__SCRIPT_DIR/home" \( -name '.DS_Store' -or -name '._*' -or -name 'Thumbs.db' -or -name 'Desktop.ini' \) -delete
        printf " done\n"
    fi

    printf "\n"

    print_cyan "  Target user home directory\n\n"
    printf "    $HOME\n\n"
    print_cyan "  Create symbolic link(s)\n\n"
    FILES=$(find $__SCRIPT_DIR/home -type f | sed 's/^.*home//')
    for FILE in $FILES; do
        echo "    $FILE"
    done

    print_yellow "Are you sure? [y/N]:"
    read CHOICE
    line_back
    if [ "$CHOICE" != 'y' ]; then
        print_red "Aborted.\n"
        exit 1
    fi

    printf "\n"

    for FILE in $FILES; do
        FILE_DIR="$(dirname "$HOME$FILE")"

        if [ ! -d "$FILE_DIR" ]; then
            mkdir -p "$FILE_DIR"
            print_purple "[CREATED]"
            printf " $FILE_DIR \n"
        fi

        if [ -f "$HOME$FILE" ]; then
            print_yellow "File already exists ($HOME$FILE) overwrite? [y/N]:"
            read CHOICE
            line_back
            if [ "$CHOICE" != 'y' ]; then
                print_yellow "[SKIPPED]"
                printf " $HOME$FILE\n"
                continue
            fi
        fi

        ln -sf "$__SCRIPT_DIR/home$FILE" "$HOME$FILE"
        print_cyan "[LINKED]"
        printf "  $HOME$FILE\n"
    done
}

export_unlink () ## Unlink symbolic links.
{
    print_purple "Removing symbolic link.\n"

    printf "\n"

    print_cyan "  Target user home directory\n\n"
    printf "    $HOME\n\n"
    print_cyan "  Removing symbolic link(s)\n\n"
    FILES=$(find "$__SCRIPT_DIR/home" -type f | sed 's/^.*home//')
    for FILE in $FILES; do
        echo "    $FILE"
    done

    print_yellow "Are you sure? [y/N]:"
    read CHOICE
    line_back
    if [ "$CHOICE" != 'y' ]; then
        print_red "Aborted.\n"
        exit 1
    fi

    printf "\n"

    for FILE in $FILES; do
        if [ -L "$HOME$FILE" ]; then
            unlink "$HOME$FILE"
            print_cyan "[UNLINKED]"
            printf " $HOME$FILE\n"
        else
            if [ -f "$HOME$FILE" ]; then
                print_yellow "This file is not symbolic link ($HOME$FILE) force delete? [y/N]:"
                read CHOICE
                line_back
                if [ "$CHOICE" = 'y' ]; then
                    rm "$HOME$FILE"
                    print_red "[DELETED]"
                    printf "  $HOME$FILE\n"
                else
                    print_yellow "[SKIPPED]"
                    printf " $HOME$FILE\n"
                fi
            fi
        fi
        UNLINK_DIR=$(dirname "$HOME$FILE")
        
        if [ -d "$UNLINK_DIR" ]; then
            UNLINK_DIR_ITEM_COUNT=$(find "$UNLINK_DIR" -maxdepth 1 -mindepth 1 | wc -l)
            if [ $UNLINK_DIR_ITEM_COUNT -eq 0 ]; then
                rmdir "$UNLINK_DIR"
                print_purple "[DELETED]"
                printf "  $UNLINK_DIR\n"
            fi
        fi
    done
}

export_upgrade () ## Upgrade dotLINKS.
{
    print_purple "Upgrade dotLINKS.\n\n"

    __check_git

    print_yellow "  Checking git repository..."
    if [ ! -d "$__SCRIPT_DIR/.git" ]; then
        print_red "FAILED\n\n"
        print_red "This directory is not git repository.\n\nAborted.\n"
        exit 1
    fi
    print_cyan "OK\n"

    __check_git_upstream

    print_yellow "  Fetching remote upstream repository..."
    if ! $(cd "$__SCRIPT_DIR"; git fetch upstream 2>/dev/null); then
        print_red "FAILED\n\nUpstream repository fetching failed.\n\nAborted.\n"
        exit 1
    else
        print_cyan "OK\n"
    fi

    print_yellow "  Merging upstream repository..."
    MERGE_STATE=$(cd "$__SCRIPT_DIR"; git merge upstream/master 2>&1)

    if [ "$(echo $MERGE_STATE | cut -c1-7)" = 'Already' ]; then
        print_cyan "OK\n\n"
        print_cyan "dotLINKS already up to date.\n"
    elif [ "$(echo $MERGE_STATE | cut -c1-5)" = 'error' ]; then
        print_red "FAILED\n\nUpstream repository merging failed.\nPlease check git status.\n\n"
        printf "$MERGE_STATE"
        print_red "\n\nAborted.\n"
        exit 1
    else
        print_cyan "OK\n\n"
        print_cyan "dotLINKS upgrade successfully.\n"
    fi
}

export_version () ## Show version.
{
    print_cyan "dotLINKS"
    printf " version "
    print_yellow "$__VERSION"
    printf " ($__UPSTREAM_URI_HTTP)\n"
}

# Self documentation.
# reference : https://qiita.com/suttang/items/d4b4474e93c8e74ae515
export_usage () ## Show usage.
{
    export_version
    
    printf "\n"

    print_yellow "Usage:\n"
    printf " $__SCRIPT_PATH [command]\n\n"

    print_yellow "Commands:\n"

    grep -E '^(function\s+)?\w+ \(\)\s+\{?\s*##' $__SCRIPT_PATH | sed -e 's/{//;s/ \{1,\}/ /g;s/function //;s/() ## /<>/' | cut -c8- | awk -F '<>' '{printf " \033[35m%-20s\033[0m %s\n", $1, $2}'
}

line_back ()
{
    printf "\033[1A\033[2K"
}

print_red ()
{
    print_opt '31m' "$1"
}

print_yellow ()
{
    print_opt '33m' "$1"
}

print_cyan ()
{
    print_opt '36m' "$1"
}

print_purple ()
{
    print_opt '35m' "$1"
}

print_opt ()
{
    printf "\033[$1$2\033[0m"
}

if [ -n "$(type -t export_$1)" ] && [ "$(type -t export_$1)" = function ] ; then
    "export_$1" $@
elif [ "$1" = '' ]; then
    export_usage
    exit 1
else
    print_red "[ERROR] Invalid command"
    printf " $1\n"
    export_usage
    exit 1
fi
