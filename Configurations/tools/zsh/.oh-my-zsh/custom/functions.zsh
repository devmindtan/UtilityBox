devdoctor() {
    local tools=(python3 uv node npm rustc cargo java javac docker kubectl fzf rg fd)
    echo "=== Dev Doctor ==="
    for t in "${tools[@]}"; do
        if command -v "$t" >/dev/null 2>&1; then
            printf "%-10s ✅ %s\n" "$t" "$("$t" --version 2>/dev/null | head -n 1)"
        else
            printf "%-10s ❌\n" "$t"
        fi
    done
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