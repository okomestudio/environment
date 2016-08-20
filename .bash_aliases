#!/bin/bash

# ~/.bash_aliases

# Enable color support of ls and also add handy aliases.
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto --classify'

  alias grep='grep --color=auto'
  # alias fgrep='fgrep --color=auto'
  # alias egrep='egrep --color=auto'
fi

alias ds9='ds9 -zscale'

alias less='less -S'

alias l='ls -CF'
alias la='ls -A'
alias ll='ls -lh'

alias open='xdg-open'
