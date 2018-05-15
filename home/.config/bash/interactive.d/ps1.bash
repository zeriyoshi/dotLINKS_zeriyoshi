# Git show dirty state.
GIT_PS1_SHOWDIRTYSTATE=true

OS_NAME=''

if type dmidecode > /dev/null 2>&1 && [ "$(sudo dmidecode -s system-product-name)" = 'VirtualBox' ]; then
    OS_NAME="\[\e[37;44;1m\]VB\[\e[m\]"
fi

if [ $(uname) = 'Darwin' ]; then
    OS_NAME="${OS_NAME}\[\e[37;1m\]macOS\[\e[m\]"
elif type lsb_release > /dev/null 2>&1; then
    OS_NAME="${OS_NAME}\[\e[36;1m\]$(lsb_release -is)\[\e[m\]"
else
    OS_NAME="\[\e[33;1m]\Unknown\[\e[m\]"
fi

export PS1='['"$OS_NAME"':\W\[\e[31m\]$(__git_ps1 " (%s)")\[\e[m\]] \$ '