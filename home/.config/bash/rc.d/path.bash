export GOPATH="${HOME}/Developments/golang"
export PATH="${GOPATH}/bin:${PATH}"

if [ -e "/usr/local/Cellar/qt" ]; then
    export QT_HOMEBREW=true
fi

if [ -e "${HOME}/.phpenv/bin" ]; then
    export PATH="${HOME}/.phpenv/bin:${PATH}"
fi
