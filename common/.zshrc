# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

zstyle ':completion:*' auto-description 'arg: %d'
zstyle ':completion:*' completer _expand _complete _ignored _match _correct _approximate _prefix
zstyle ':completion:*' completions 1
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' file-sort name
zstyle ':completion:*' format 'completing %d'
zstyle ':completion:*' glob 1
zstyle ':completion:*' group-name ''
zstyle ':completion:*' ignore-parents parent pwd
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' list-suffixes true
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=** r:|=**'
zstyle ':completion:*' match-original both
zstyle ':completion:*' max-errors 2
zstyle ':completion:*' menu select=1
zstyle ':completion:*' original true
zstyle ':completion:*' preserve-prefix '//[^/]##/'
zstyle ':completion:*' prompt 'corrections(%e)'
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' substitute 0
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose false
zstyle :compinstall filename '/home/bodand/.zshrc'

autoload -Uz compinit
compinit

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd extendedglob
unsetopt beep nomatch notify
bindkey -v

setopt octalzeroes

source "${HOME}/.zgen/zgen.zsh"
if ! zgen saved
then
	# plugins
	zgen loadall <<EOF
		Tarrasch/zsh-bd
		zsh-vi-more/vi-increment
		nviennot/zsh-vim-plugin
EOF
	
	zgen oh-my-zsh
	zgen oh-my-zsh plugins/colored-man-pages
	zgen oh-my-zsh plugins/cpanm
	zgen oh-my-zsh plugins/dotenv
	zgen oh-my-zsh plugins/extract
	zgen oh-my-zsh plugins/git
	zgen oh-my-zsh plugins/gitignore
	zgen oh-my-zsh plugins/history
	zgen oh-my-zsh plugins/history-substring-search
	zgen oh-my-zsh plugins/man
	zgen oh-my-zsh plugins/mix-fast
	zgen oh-my-zsh plugins/perl
	zgen oh-my-zsh plugins/thefuck

	if which dnf 2>&1 > /dev/null
	then
		zgen oh-my-zsh plugins/dnf
	fi
	
	zgen load romkatv/powerlevel10k powerlevel10k
	
	zgen save
fi
ZSH_THEME="powerlevel10k/powerlevel10k"

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
eval $(thefuck --alias)

alias cls=clear

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
