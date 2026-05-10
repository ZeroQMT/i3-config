# zoomer shell config

autoload -Uz colors && colors # load colors
#PROMPT="%F{green}%n@%m %F{blue}%~ %F{magenta}$ %f" 
#PROMPT="%F%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "
#PROMPT="%F%{$fg[cyan]%}[%{$fg[white]%}%n%{$fg[white]%}@%{$fg[cyan]%}%M %{$fg[white]%}%~%{$fg[cyan]%}]%{$reset_color%}$%b "
#PROMPT='%F{magenta}%n@%m%f %F{red}%~%f $ '
#PROMPT='%F{magenta}%~%f $ '
#PROMPT='%F{blue}%n%f@%F{magenta}%m%f %F{white}[%F{cyan}%~%F{white}]%f ❯ '
PROMPT='%F{cyan}%~%f %F{green}❯%f '

stty -ixon # disable C-s and C-q

setopt autocd # any directory typed is automatically cd-ed into.
setopt interactive_comments # i can do stuff like THIS

alias ls='ls --color=auto'
alias ll='exa -l' || ls -l
alias vim='nvim'
alias nvim='nvim'
alias bat='bat --theme="Solarized (dark)"'
alias tmux='tmux -u'
alias cl='clear'
alias toc='touch'
alias py='python3'
alias serve='python -m http.server'

se(){
	choice=$(find "$HOME/scripts" -type f | fzf --preview "bat -l sh {}")
	[ -z "$choice" ] || nvim "$choice"
}

# basic bindings
# bindkey -v # press ESC and see what happens
# bindkey "^[[1;5D" backward-word   # Ctrl+Left
# bindkey "^[[1;5C" forward-word    # Ctrl+Right
# bindkey "^H" backward-word        # Ctrl+H
# bindkey "^K" forward-word         # Ctrl+K
# bindkey '^A' beginning-of-line    # Ctrl+A
# bindkey '^E' end-of-line          # Ctrl+E
# bindkey '^U' kill-whole-line      # Ctrl+U
# bindkey '^K' kill-line            # Ctrl+K
# bindkey '^W' backward-kill-word   # Ctrl+W
# bindkey '^?' backward-delete-char # Backspace
# bindkey '^D' delete-char          # Ctrl+D
# bindkey '^L' clear-screen         # Ctrl+L
# bindkey '^P' up-line-or-history   # Ctrl+P
# bindkey '^N' down-line-or-history # Ctrl+N
bindkey '^R' history-incremental-search-backward # Ctrl+R
#bindkey '^T' transpose-chars      # Ctrl+T

# source other programs 
# source ~/.config/shell/aliasrc
# source ~/.config/shell/bin/startup
# source ~/.config/shell/bin/archive-helper
# source ~/.config/shell/shortcutsrc
eval "$(zoxide init zsh)"
eval "$(fzf --zsh)"

ZDOTDIR=${ZDOTDIR:-$HOME}
# zsh smart completion
autoload -Uz compinit
zstyle ':completion:*' menu select        
zstyle ':completion:*' matcher-list 'r:|=*' 'l:|=*' 'm:{a-z}={A-Za-z}'  
zstyle ':completion:*' rehash true        
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$ZDOTDIR/.zcompcache"
compinit -d "$ZDOTDIR/.zcompdump"
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Created by `pipx` on 2026-05-09 14:32:03
export PATH="$PATH:/home/qmt/.local/bin"
