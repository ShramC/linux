#
# ~/.bashrc
#

export PATH="/home/arch/.local/bin:$PATH"
export PATH="$HOME/.openport/bin:$PATH"
export PATH="$PATH:/home/arch/.spicetify"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

alias low='/home/arch/.local/bin/low'
alias balanced='/home/arch/.local/bin/balanced'
alias boost='/home/arch/.local/bin/boost'

# RAM cleaning command aliases
alias ram='Ram'
alias RAM='Ram'
