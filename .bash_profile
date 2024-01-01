#!/usr/bin/env bash

# This file is loaded if we are in an interactive shell ($PS1 exists.)

# Load the shell dotfiles, and then some:
#
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.

for _file in ~/.{functions}; do
  [ -r "$_file" ] && [ -f "$_file" ] && source "$_file";
done
unset _file

# for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
#         [ -r "$file"  ] && [ -f "$file"  ] && source "$file";
#         done;
#         unset file;

### options
HISTCONTROL=ignoreboth
shopt -s globstar histappend nullglob

### set up homebrew vars and PATH
if [[ -z $HOMEBREW_PREFIX ]]; then
  case $(uname) in
  Darwin)
    if [[ $(uname -m) == 'arm64' ]]; then
      HOMEBREW_PREFIX='/opt/homebrew'
    elif [[ $(uname -m) == 'x86_64' ]]; then
      HOMEBREW_PREFIX='/usr/local'
    fi
    ;;
  Linux)
    if [[ -d '/home/linuxbrew/.linuxbrew' ]]; then
      HOMEBREW_PREFIX='/home/linuxbrew/.linuxbrew'
    elif [[ -d $HOME/.linuxbrew ]]; then
      HOMEBREW_PREFIX=$HOME/.linuxbrew
    fi
    if [[ -d $HOMEBREW_PREFIX ]]; then
      PATH=$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH
    fi
    ;;
  esac
fi
if [[ -d $HOMEBREW_PREFIX ]]; then
  eval $($HOMEBREW_PREFIX/bin/brew shellenv)
fi

### aliases
alias python='python3'

#################################
# history_logger() side effects:
#################################
# sets or updates these global variables:
# -> '_last_history_number_logged'
# -> '_last_history_number_had_new_command'
#
#  $HISTCMD special bash variable normally provides the last history command number
#  But it unavailable at PROMPT_COMMAND eval time.
#  'history 1' or 'fc -l 0' both provide a working alternative, after massaging.
#
function history_logger() {
  local last_exit_code=$?   # must be the first command we run in this function
  local last_history_line=$(fc -l 0)   # was 'history 1'
  local _match_me="^([0-9]+)[ 	]+([^	 ]+)"
  export _last_history_number_had_new_command=""

  # TODO(tamsky): can we save a fork and use $UID instead of $(id- u)?
  #
  # Only log if we are not root:
  if [ "$(id -u)" -ne 0 ]; then
    # only log if history number changes:
    if [[ ${last_history_line} =~ ${_match_me} ]] && [[ ${BASH_REMATCH[1]} != $_last_history_number_logged ]] ; then
      _last_history_number_logged=${BASH_REMATCH[1]} ;
      _last_history_number_had_new_command=${BASH_REMATCH[2]} ;
      echo "$(date)] ${HOSTNAME%%.*}[$$:S${WINDOW}:${last_exit_code}] ${PWD/~/\~} ${last_history_line}" >> ~/.shell.log;
    fi ;
  fi
}

export PROMPT_COMMAND=history_logger

### prompt: https://starship.rs
eval "$(starship init bash)"

### Sonoma-ism?
stty erase 

### instruct UNIX programs that our terminal is UTF-8
export LC_ALL=en_US.UTF-8

# because we run after exports, we need to cleanup PATH again here:
# Cleanup
if [ $(type -t dedup_input) ] ; then
  export PATH=$( printf "$PATH" | tr : '\n' | dedup_input | tr '\n' : )
fi
