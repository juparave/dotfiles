# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

### Set vi mode
set -o vi

### history handling
#
# Erase duplicates
export HISTCONTROL=erasedups
# resize history size
export HISTSIZE=8000
export HISTFILESIZE=8000
# append to bash_history if Terminal.app quits
shopt -s histappend
# append to bash_history after each command is finished (multiple terminals)
export PROMPT_COMMAND='history -a'

### Basic aliases
alias ll="ls -lsa"
alias la='ls -A'
alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# telling tmux to support colors
export TERM=xterm-256color

###-tns-completion-start-###
if [ -f /Users/pablito/.tnsrc ]; then
    source /Users/pablito/.tnsrc
fi
###-tns-completion-end-###

### Search faster in vim
if type rg &> /dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files'
    export FZF_DEFAULT_OPTS='-m --height 50% --border'
fi

### Bash procedure to quickly change directory
workon() {
    if [[ -n $1 ]]; then
        selected=$(find ~/workspace/python ~/workspace/go ~/workspace/flutter ~/workspace/angular ~/workspace/svelte ~/workspace/elm -mindepth 1 -maxdepth 1 -type d | fzf --query $1)
    else
        selected=$(find ~/workspace/python ~/workspace/go ~/workspace/flutter ~/workspace/angular ~/workspace/svelte ~/workspace/elm -mindepth 1 -maxdepth 1 -type d | fzf)
    fi

    if [[ -z $selected ]]; then
        return 0
    fi

    cd $selected
    actvenv
}

### Bash procedure to load python venv if exists on current directory
actvenv() {
    # get the most recent venv directory if any
    # venv=$(find . -maxdepth 1 -type d -name "*env" -exec stat -lt "%Y-%m-%d" {} \+ | cut -d' ' -f7- | sort -n | tail -1)
    venv=$(find . -maxdepth 1 -type d -name "*env" -exec stat -lt "%Y-%m-%d" {} \+ | cut -d' ' -f7- | sort -nr | head -1)
    if [[ -n $venv ]]; then
        echo "Found python venv at $venv, activating it"
        source $venv/bin/activate
    fi
}

### Prompt
export PS1="\[$(tput setaf 5)\]\u\[$(tput sgr0)\] at \[$(tput setaf 3)\]\h\[$(tput sgr0)\] in \[$(tput bold)\]\[$(tput setaf 2)\]\w\n\[$(tput sgr0)\]↳ \\$ \[$(tput sgr0)\]"
## Shortening paths in the Bash prompt
export PROMPT_DIRTRIM=4

### Fortune and Cowsay
exec fortune | cowsay -n
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
