# Composer
if [ -d "$HOME/.composer/vendor/bin" ]; then
    PATH="$HOME/.composer/vendor/bin:$PATH"
elif [ -d "$HOME/.config/composer/vendor/bin" ]; then
    PATH="$HOME/.config/composer/vendor/bin"
fi

# Homebrew
if [ -d /usr/local/sbin ]; then
    PATH="/usr/local/sbin:$PATH"
fi

export PATH
