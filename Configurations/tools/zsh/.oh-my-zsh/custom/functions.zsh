devdoctor() {
  local reset='\033[0m'
  local bold='\033[1m'
  local green='\033[38;5;114m'   # xanh lá pastel
  local red='\033[38;5;210m'     # hồng pastel
  local blue='\033[38;5;117m'    # xanh dương pastel
  local yellow='\033[38;5;222m'  # vàng pastel
  local gray='\033[38;5;250m'    # xám nhạt

  local -A categories
  categories=(
    "Languages"   "python3 node rustc java javac"
    "Package Mgr" "uv nvm npm cargo"
    "DevOps"      "docker kubectl"
    "CLI Tools"   "fzf rg fd eza bat"
  )

  local order=("Languages" "Package Mgr" "DevOps" "CLI Tools")

  echo
  printf "${bold}${blue}  Dev Doctor${reset}\n"
  printf "${gray}─────────────────────────────────────────${reset}\n"

  for category in "${order[@]}"; do
    printf "\n${bold}${yellow}▸ %s${reset}\n" "$category"
    for tool in ${(z)categories[$category]}; do
      if command -v "$tool" >/dev/null 2>&1; then
        local version=$("$tool" --version 2>/dev/null | head -n1)
        printf "  ${green}✔${reset} ${bold}%-10s${reset} ${gray}%s${reset}\n" "$tool" "$version"
      else
        printf "  ${red}✘${reset} ${bold}%-10s${reset} ${gray}not found${reset}\n" "$tool"
      fi
    done
  done

  printf "\n${gray}─────────────────────────────────────────${reset}\n"
  echo
}
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