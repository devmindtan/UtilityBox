if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

if [ -f $ZSH/custom/variables.zsh ]; then
    source $ZSH/custom/variables.zsh
fi
if [ -f $ZSH/custom/alias.zsh ]; then
    source $ZSH/custom/alias.zsh
fi
if [ -f $ZSH/custom/fzf.zsh ]; then
    source $ZSH/custom/fzf.zsh
fi

ZSH_THEME="powerlevel10k/powerlevel10k"
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh
fastfetch

if [ -f $ZSH/custom/functions.zsh ]; then
    source $ZSH/custom/functions.zsh
fi

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"


