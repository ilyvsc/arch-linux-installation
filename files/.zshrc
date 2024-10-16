autoload -Uz promptinit
promptinit
prompt adam1

setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

eval "$(dircolors -b)"
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# FZF source
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Powerlevel10k settings
# (( ! ${+functions[p10k-instant-prompt-finalize]} )) || p10k-instant-prompt-finalize
# source ~/.powerlevel10k/powerlevel10k.zsh-theme
# [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# General aliases
alias full='sudo pacman -Syu'
alias add='sudo pacman -S'

# Poetry aliases
alias dshell='poetry run python manage.py shell'
alias runserver='poetry run start'
alias runbot='poetry run bot'
alias runtests='poetry run test'
alias migrate='poetry run migrate'
alias makemigrations='poetry run makemigrations'
alias migrateall='poetry run migrate_all'
alias makemessages='poetry run makemessages'
alias compilemessages='poetry run compilemessages'
alias format='poetry run pre-commit run --color=always --all-files'

# Helpful aliases
alias ls='lsd --group-dirs=first'
alias l='lsd --group-dirs=first'
alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias cat='bat'

alias zen="zeditor"

# Django aliases
alias django="poetry run django-admin"
alias dj="poetry run python manage.py"
alias djm="dj makemigrations && dj migrate"
alias djr="dj runserver"
alias djmr="djm && djr"

# Docker
alias depie="docker compose up"

# No more cd
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

# ZSH Plugins
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh

# Functions
function rmk(){
	scrub -p dod $1
	shred -zun 10 -v $1
}

# fzf improvement
function fzf-lovely(){
	fzf -m --reverse --preview-window down:20 --preview '[[ $(file --mime {}) =~ binary ]] &&
		echo {} is a binary file ||
		(bat --style=numbers --color=always {} ||
		highlight -O ansi -l {} ||
		coderay {} ||
		rougify {} ||
		cat {}) 2> /dev/null | head -500'
}

# Poetry configuration
PATH="$HOME/.local/bin:$PATH"
PATH=/root/.local/bin:/snap/bin:/usr/sandbox/:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/usr/share/games:/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
