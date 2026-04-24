# 1. Instant Prompt (Luôn ở đầu)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# 2. Định nghĩa đường dẫn
export ZSH="$HOME/.oh-my-zsh"

# 3. Giao diện (Theme)
ZSH_THEME="powerlevel10k/powerlevel10k"
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# 4. Plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# 5. KÍCH HOẠT OH MY ZSH (Dòng này sẽ tự load variables, alias, fzf, functions trong custom)
source $ZSH/oh-my-zsh.sh

# 6. Các lệnh chạy sau khi khởi động
fastfetch

# 7. Môi trường Node.js (NVM)
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"