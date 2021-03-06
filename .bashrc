HISTFILESIZE=10000

parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] \D{%F %T}\n\$ "
PROMPT_COMMAND='echo -en "\033]0; $( pwd|cut -d "/" -f 4-100 ) \a"'


# ignore case in less
LESS=-i

# CF CLI ALIASES:
# LAB personal
alias lpers='export CF_HOME="~/.cf_config/lab/personal" && echo -e "cf cli switched to \e[1m\e[32mLAB PERSONAL\e[39m\e[0m account"'
# LAB admin
alias ladm='export CF_HOME="~/.cf_config/lab/admin" && echo -e "cf cli switched to \e[1m\e[32mLAB ADMIN\e[39m\e[0m account"'
# PRO personal
alias ppers='export CF_HOME="~/.cf_config/pro/personal" && echo -e "cf cli switched to \e[1m\e[32mPRO PERSONAL\e[39m\e[0m account"'
# PRO admin
alias padm='export CF_HOME="~/.cf_config/pro/admin" && echo -e "cf cli switched to \e[1m\e[31mPRO ADMIN\e[39m\e[0m account"'
################

sssh() {
	printf '\ek%s\e\\' "$1";
	ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$1";
}

function cdt() {
	cd $(mktemp -d);
}

scut() {
	tr -s ' ' | cut -d' ' -f $1;
}
