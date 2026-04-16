# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
fastfetch
export PATH=$PATH:$HOME/.local/bin
export NVM_DIR="$HOME/.nvm"
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export SDL_IM_MODULE=fcitx

ms() {
    local mkfile="$HOME/Documents/code/UtilityBox/Configurations/makefile/arch-linux/make-sys.mk"
    local cmd="$1"

    if [[ ! -f "$mkfile" ]]; then
        echo "❌ Không tìm thấy makefile: $mkfile"
        return 1
    fi

    case "$cmd" in
        ""|help|-h|--help)
            echo "Usage: ms <target>"
            echo "       ms list"
            echo "       ms check"
            echo "       ms config <target>"
            echo ""
            echo "Ví dụ: ms install-zsh | ms sound | ms config unikey-on"
            ;;
        list)
            echo "📌 Danh sách target khả dụng:"
            grep -E '^[a-zA-Z0-9_.-]+:' "$mkfile" | sed 's/:.*//' | sort -u
            ;;
        check|doctor)
            local required_cmds=(make awk grep sed)
            local optional_cmds=(pacman yay fcitx5 pavucontrol)
            local missing=0

            echo "🔎 Kiểm tra lệnh bắt buộc:"
            for tool in "${required_cmds[@]}"; do
                if command -v "$tool" >/dev/null 2>&1; then
                    echo "  ✅ $tool"
                else
                    echo "  ❌ $tool"
                    missing=1
                fi
            done

            echo ""
            echo "🧩 Kiểm tra lệnh tuỳ chọn (tuỳ target):"
            for tool in "${optional_cmds[@]}"; do
                if command -v "$tool" >/dev/null 2>&1; then
                    echo "  ✅ $tool"
                else
                    echo "  ⚠️  $tool (chưa có)"
                fi
            done

            echo ""
            echo "📁 Kiểm tra đường dẫn quan trọng:"
            [[ -x "$HOME/Documents/venv/venv-py314/bin/python3" ]] && echo "  ✅ Python venv" || echo "  ⚠️  Thiếu venv python: $HOME/Documents/venv/venv-py314/bin/python3"
            [[ -f "$HOME/Documents/code/UtilityBox/Apps/Camera/main.py" ]] && echo "  ✅ Camera app" || echo "  ⚠️  Thiếu Camera app"

            if [[ $missing -eq 1 ]]; then
                echo ""
                echo "❌ Hệ thống chưa sẵn sàng hoàn toàn."
                return 1
            fi

            echo ""
            echo "✅ Kiểm tra cơ bản hoàn tất."
            ;;
        config)
            shift
            if [[ -z "$1" ]]; then
                echo "⚠️  Thiếu target cấu hình."
                echo "Gợi ý: ms config sound | ms config unikey-on | ms config unikey-control"
                return 1
            fi
            make -f "$mkfile" "$1"
            ;;
        *)
            make -f "$mkfile" "$@"
            ;;
    esac
}
venv() {
    local venv_name=$1
    local venv_path="$HOME/Documents/venv/$venv_name"

    if [[ -d "$venv_path" ]]; then
        # Kích hoạt venv
	source "$venv_path/bin/activate"

        # Thu thập thông tin
        local pkg_count=$(pip list --format=freeze | wc -l)
        local venv_size=$(du -sh "$venv_path" | cut -f1)
        local py_version=$(python --version)

        # Hiển thị thông tin
	echo "---------------------------------------"
        echo "Connected: $venv_name"
        echo "Packages:  $pkg_count"
        echo "Size:      $venv_size"
        echo "Version:   $py_version"
        echo "---------------------------------------"
    else
        echo "❌ Không tìm thấy: $venv_name tại $venv_path"
    fi
}
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
