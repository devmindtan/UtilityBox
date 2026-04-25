# Cấu hình fzf
# Set up fzf key bindings and fuzzy completion
if fzf --version | grep -qE "0\.(4[8-9]|[5-9])"; then
  # Nếu bản fzf >= 0.48 (thường là trên Arch)
  eval "$(fzf --zsh)"
else
  # Nếu bản cũ (thường là Ubuntu), dùng cách load truyền thống
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi

fg="#CBE0F0"
bg="#011628"
bg_highlight="#143652"
purple="#B388FF"
blue="#06BCE4"
cyan="#2CF9ED"

export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git --exclude '*.zwc'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

source $ZSH_CUSTOM/fzf-git.sh

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview' --preview-window=wrap --preview-window=right:60%"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# Check port với fzf
fport() {
  local port
  # Lấy danh sách port, dùng sudo nhưng đã được cấp NOPASSWD nên sẽ không hỏi pass
  port=$(sudo ss -tunlp | grep LISTEN | fzf --header "Chọn Port để xem chi tiết" --layout=reverse | awk '{print $5}' | cut -d: -f2)
  
  # Chỉ chạy lsof nếu biến port không rỗng
  if [ -n "$port" ]; then
    sudo lsof -i :$port
  fi
}
# Check RAM và Kill với fzf
fmem() {
  local pid
  pid=$(smem -rt -n 20 --columns="pid user command pss" | \
    fzf --header-lines=1 --layout=reverse --header "Chọn Process để KILL (Tính theo PSS)" | \
    awk '{print $1}')
  
  if [ -n "$pid" ]; then
    echo "Đang kill PID: $pid"
    kill -9 $pid
  fi
}