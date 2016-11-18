#! /bin/bash

# -------------------------------------------------------------------
# USER SHELL ENVIRONMENT
# -------------------------------------------------------------------

# Source bash_environment
if [ -f ~/.bash_environment ]; then
  . ~/.bash_environment
fi

# Eventually load you private settings (not exposed here)
test -f ~/.bash_private &&
. ~/.bash_private

# MOTD
test -n "$INTERACTIVE" -a -n "$LOGIN" && (
  uname -npsr
  uptime
)

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export PATH=$PATH:/usr/local/packer:/usr/lib/git-core

# ----------------------------------------------------------------------
#  SHELL OPTIONS
# ----------------------------------------------------------------------

# bring in system bashrc
test -r /etc/bashrc &&
. /etc/bashrc

# bring in git prompt
#. ~/.git-prompt.sh

# shell opts. see bash(1) for details
shopt -s cdspell                 >/dev/null 2>&1  # correct minor errors in the spelling
                                                  # of a directory in a cd command
shopt -s extglob                 >/dev/null 2>&1  # extended pattern matching
shopt -s hostcomplete            >/dev/null 2>&1  # perform hostname completion
                                                  # on '@'
#shopt -s no_empty_cmd_completion >/dev/null 2>&1
shopt -u mailwarn                >/dev/null 2>&1

# default umask
umask 0022

# ----------------------------------------------------------------------
# BASH COMPLETION
# ----------------------------------------------------------------------

bash=${BASH_VERSION%.*}; bmajor=${bash%.*}; bminor=${bash#*.}
test -n "$PS1" && test $bmajor -gt 1 && (
  # search for a bash_completion file to source
  for f in /usr/local/etc/bash_completion \
    /opt/local/etc/bash_completion \
    /etc/bash_completion
  do
    test -f $f && (
      . $f
      break
    )
  done
)
unset bash bmajor bminor

# ----------------------------------------------------------------------
# BASH HISTORY
# ----------------------------------------------------------------------

# Increase the history size
HISTSIZE=10000
HISTFILESIZE=20000

# Add date and time to the history
HISTTIMEFORMAT="[%d/%m/%Y %H:%M:%S] "

# ----------------------------------------------------------------------
# VERSION CONTROL SYSTEM - SVN and GIT
# ----------------------------------------------------------------------

## display the current subversion revision (to be used later in the prompt)
__svn_ps1() {
  local svnversion=`svnversion | sed -e "s/[:M]//g"`
  # Continue if $svnversion is numerical
  if let $svnversion 2>/dev/null
  then
      printf " (svn:%s)" `svnversion`
  fi
}

# render __git_ps1 even better so as to show activity in a git repository
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1

# ----------------------------------------------------------------------
# PROMPT
# ----------------------------------------------------------------------

# Define some colors to use in the prompt
RESET_COLOR="\[\e[0m\]"
BOLD_COLOR="\[\e[1m\]"
# B&W
WHITE="\[\e[0;37m\]"
GRAY="\[\e[1;30m\]"
BLACK="\[\e[0;30m\]"
# RGB
RED="\[\e[0;31m\]"
GREEN="\[\e[0;32m\]"
BLUE="\[\e[34;1m\]"
# other
YELLOW="\[\e[0;33m\]"
LIGHT_CYAN="\[\e[36;1m\]"
CYAN_UNDERLINE="\[\e[4;36m\]"

# Configure user color and prompt type depending on whoami
if [ "$LOGNAME" = "root" ]; then
  COLOR_USER="${RED}"
  P="#"
else
  COLOR_USER="${LIGHT_CYAN}"
  P="$"
fi

# This function is called from a subshell in $PS1, to provide the colorized
# exit status of the last run command.
# Exit status 130 is also considered as good as it corresponds to a CTRL-D
__colorized_exit_status() {
  printf -- "\`status=\$? ; if [[ \$status = 0 || \$status = 130  ]]; then \
                              echo -e '\[\e[01;32m\]'\$status;             \
                            else                                           \
                              echo -e '\[\e[01;31m\]'\$status; fi\`"
}

###########
# my prompt; the format is as follows:
#
#    [hh:mm:ss]:$?:username@hostname workingdir(svn/git status) $>
#    `--------'  ^  `------' `------'                                            `--------'`--------------'
#       blue     |  root:red   cyan                                                light        green
#                |                                                                blue  (absent if not relevant)
#           exit code of
#        the previous command
#
# The git/svn status part is quite interesting: if you are in a directory under
# version control, you have the following information in the prompt:
#   - under GIT: current branch name, followed by a '*' if the repository has
#                uncommitted changes, followed by a '+' if some elements were
#                'git add'ed but not commited.
#   - under SVN: show (svn:XX[M]) where XX is the current revision number,
#                followed by 'M' if the repository has uncommitted changes
#
# `domain` reflect the current domain of the machine that run the prompt
# (guessed from hostname -f)
# `xentype` is DOM0 or domU depending if the machine is a Xen dom0 or domU
# Finally, is the environment variable PS1_EXTRA is set (or passed to the
# kernel), then its content is displayed here.
# 
# This prompt is perfect for terminal with black background, in my case the
# Vizor color set (see http://visor.binaryage.com/) or iTerm2
__set_my_prompt() {
  PS1="${BLUE}[\t]${RESET_COLOR}$(__colorized_exit_status) ${COLOR_USER}\u${RESET_COLOR}${LIGHT_CYAN}@\h${RESET_COLOR}${RESET_COLOR}:${BLUE}\w${GREEN}\$(__git_ps1 \" (%s)\")\$(__svn_ps1)${RESET_COLOR}${RESET_COLOR}${P} "
}

# Set the color prompt by default when interactive
if [ -n "$PS1" ]; then
    __set_my_prompt
    export PS1
fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -l'
