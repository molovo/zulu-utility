#
# Utility Functions and Options
#

#
# Colours
#

if (( ${terminfo[colors]} >= 8 )); then
  # ls Colors
  if ls --version 2>/dev/null | grep -q 'coreutils'; then
    # GNU
    if [[ -s ${HOME}/.dir_colors ]]; then
      eval "$(dircolors --sh ${HOME}/.dir_colors)"
    else
      eval "$(dircolors --sh)"
    fi

    alias ls='ls --group-directories-first --color=auto'

  else
    # BSD

    # colours for ls and completion
    export LSCOLORS='exfxcxdxbxGxDxabagacad'
    export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'

    # stock OpenBSD ls does not support colors at all, but colorls does.
    if [[ $OSTYPE == openbsd* ]]; then
      if (( ${+commands[colorls]} )); then
        alias ls='colorls -G'
      fi
    else
      alias ls='ls -G'
    fi
  fi

  # grep Colours
  export GREP_COLOR='37;45'             #BSD
  export GREP_COLORS="mt=${GREP_COLOR}" #GNU
  if [[ ${OSTYPE} == openbsd* ]]; then
    if (( ${+commands[ggrep]} )); then
      alias grep='ggrep --color=auto'
    fi
  else
   alias grep='grep --color=auto'
  fi

  # less Colours
  if [[ ${PAGER} == 'less' ]]; then
    export LESS_TERMCAP_mb=$'\E[1;31m'    # Begins blinking.
    export LESS_TERMCAP_md=$'\E[1;31m'    # Begins bold.
    export LESS_TERMCAP_me=$'\E[0m'       # Ends mode.
    export LESS_TERMCAP_se=$'\E[0m'       # Ends standout-mode.
    export LESS_TERMCAP_so=$'\E[7m'       # Begins standout-mode.
    export LESS_TERMCAP_ue=$'\E[0m'       # Ends underline.
    export LESS_TERMCAP_us=$'\E[1;32m'    # Begins underline.
  fi
fi


#
# ls Aliases
#

alias l='ls -lAh'         # all files, human-readable sizes
[[ -n ${PAGER} ]] && alias lm="l | ${PAGER}" # all files, human-readable sizes, use pager
alias ll='ls -lh'         # human-readable sizes
alias lr='ll -R'          # human-readable sizes, recursive
alias lx='ll -XB'         # human-readable sizes, sort by extension (GNU only)
alias lk='ll -Sr'         # human-readable sizes, largest last
alias lt='ll -tr'         # human-readable sizes, most recent last
alias la='ll -A'         # Lists human readable sizes, hidden files.
alias lm='la | "$PAGER"' # Lists human readable sizes, hidden files through pager.
alias lc='lt -c'         # Lists sorted by date, most recent last, shows change time.
alias lu='lt -u'         # Lists sorted by date, most recent last, shows access time.


#
# File Downloads
#

# order of preference: aria2c, axel, wget, curl. This order is derrived from speed based on personal tests.
if (( ${+commands[aria2c]} )); then
  alias get='aria2c --max-connection-per-server=5 --continue'
elif (( ${+commands[axel]} )); then
  alias get='axel --num-connections=5 --alternate'
elif (( ${+commands[wget]} )); then
  alias get='wget --continue --progress=bar --timestamping'
elif (( ${+commands[curl]} )); then
  alias get='curl --continue-at - --location --progress-bar --remote-name --remote-time'
fi

# Mac OS X Everywhere
if [[ "$OSTYPE" == darwin* ]]; then
  alias o='open'
elif [[ "$OSTYPE" == cygwin* ]]; then
  alias o='cygstart'
  alias pbcopy='tee > /dev/clipboard'
  alias pbpaste='cat /dev/clipboard'
else
  alias o='xdg-open'

  if (( $+commands[xclip] )); then
    alias pbcopy='xclip -selection clipboard -in'
    alias pbpaste='xclip -selection clipboard -out'
  elif (( $+commands[xsel] )); then
    alias pbcopy='xsel --clipboard --input'
    alias pbpaste='xsel --clipboard --output'
  fi
fi

alias pbc='pbcopy'
alias pbp='pbpaste'
#
# Resource Usage
#

alias df='df -kh'
alias du='du -kh'

if (( $+commands[htop] )); then
  alias top=htop
else
  if [[ "$OSTYPE" == (darwin*|*bsd*) ]]; then
    alias topc='top -o cpu'
    alias topm='top -o vsize'
  else
    alias topc='top -o %CPU'
    alias topm='top -o %MEM'
  fi
fi


#
# Always wear a condom
#

if [[ ${OSTYPE} == linux* ]]; then
  alias chmod='chmod --preserve-root -v'
  alias chown='chown --preserve-root -v'
fi

# not aliasing rm -i, but if safe-rm is available, use condom.
# if safe-rmdir is available, the OS is suse which has its own terrible 'safe-rm' which is not what we want
if (( ${+commands[safe-rm]} && ! ${+commands[safe-rmdir]} )); then
  alias rm='safe-rm'
fi


#
# Misc
#

# Makes a directory and changes to it.
mkdcd() {
  [[ -n ${1} ]] && mkdir -p ${1} && builtin cd ${1}
}

#
# Functions
#

# Changes to a directory and lists its contents.
function cdls {
  builtin cd "$argv[-1]" && ls "${(@)argv[1,-2]}"
}

# Pushes an entry onto the directory stack and lists its contents.
function pushdls {
  builtin pushd "$argv[-1]" && ls "${(@)argv[1,-2]}"
}

# Pops an entry off the directory stack and lists its contents.
function popdls {
  builtin popd "$argv[-1]" && ls "${(@)argv[1,-2]}"
}

# Prints columns 1 2 3 ... n.
function slit {
  awk "{ print ${(j:,:):-\$${^@}} }"
}

# Finds files and executes a command on them.
function find-exec {
  find . -type f -iname "*${1:-}*" -exec "${2:-file}" '{}' \;
}

# Displays user owned processes status.
function psu {
  ps -U "${1:-$LOGNAME}" -o 'pid,%cpu,%mem,command' "${(@)argv[2,-1]}"
}
