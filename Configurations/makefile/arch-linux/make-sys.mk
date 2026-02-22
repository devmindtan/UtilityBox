PYTHON_VENV = ~/Documents/venv/venv-py314/bin/python3
CAM_DIR = ~/Documents/code/UtilityBox/Apps/Camera

# ========================================
# 🎯 INSTALL ALL - Setup hệ thống từ đầu
# ========================================
install-all:
	@echo "🚀 --- BẮT ĐẦU CÀI ĐẶT TOÀN BỘ HỆ THỐNG ---"
	@make -f makefile/arch-linux/make-sys.mk install-zsh
	@make -f makefile/arch-linux/make-sys.mk install-unikey
	@make -f makefile/arch-linux/make-sys.mk install-chrome
	@make -f makefile/arch-linux/make-sys.mk install-onlyoffice
	@echo "✅ --- HOÀN TẤT CÀI ĐẶT! HÃY LOGOUT ĐỂ ÁP DỤNG ---"

# ========================================
# 📦 INDIVIDUAL INSTALLS
# ========================================
install-zsh:
	@echo "🐚 --- Đang cài đặt Zsh + Oh My Zsh + Powerlevel10k ---"
	@sudo pacman -S --needed --noconfirm zsh
	@if [ ! -d "$$HOME/.oh-my-zsh" ]; then \
		sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; \
	fi
	@if [ ! -d "$${ZSH_CUSTOM:-$$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then \
		git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $${ZSH_CUSTOM:-$$HOME/.oh-my-zsh/custom}/themes/powerlevel10k; \
	fi
	@yay -S --needed --noconfirm ttf-meslo-nerd-font-powerlevel10k
	@chsh -s $$(which zsh) > /dev/null 2>&1 || true
	@echo "✅ Đã cài xong Zsh + Powerlevel10k. Hãy logout và login lại."

install-onlyoffice:
	@echo "📄 --- Đang cài đặt OnlyOffice và Font ---"
	@yay -S --needed --noconfirm onlyoffice-bin ttf-ms-fonts

install-chrome:
	@echo "🌐 --- Đang cài đặt Google Chrome ---"
	@yay -S --needed --noconfirm google-chrome

install-unikey:
	@echo "⌨️  --- Đang cài đặt Unikey Input Method ---"
	@sudo pacman -S --needed --noconfirm fcitx5 fcitx5-unikey fcitx5-configtool fcitx5-qt fcitx5-gtk
	@echo "✅ Đã cài xong. Hãy logout để áp dụng biến môi trường."

# ========================================
# 🎮 SYSTEM CONTROLS
# ========================================
camera:
	@echo "📷 Starting camera..."
	@cd $(CAM_DIR) && \
	QT_LOGGING_RULES='*.debug=false;qt.qpa.fonts=false' \
	$(PYTHON_VENV) main.py 2>/dev/null

sound:
	@pavucontrol > /dev/null 2>&1 &

unikey-on:
	@echo "⌨️  --- Khởi động bộ gõ ---"
	@pgrep fcitx5 > /dev/null || fcitx5 -d > /dev/null 2>&1

unikey-off:
	@killall fcitx5 > /dev/null 2>&1 && echo "❌ --- Đã tắt bộ gõ ---" || echo "⚠️  Bộ gõ đang không chạy."

unikey-control:
	@fcitx5-configtool > /dev/null || fcitx5 -d > /dev/null 2>&1

# ========================================
# 💾 BACKUP & RESTORE
# ========================================
backup-configs:
	@echo "💾 --- Đang sao lưu configs ---"
	@cp ~/.config/i3/config ~/Documents/code/UtilityBox/Configurations/setups/Arch/i3/config
	@cp ~/.config/i3status/config ~/Documents/code/UtilityBox/Configurations/setups/Arch/i3status/config
	@cp ~/.zshrc ~/Documents/code/UtilityBox/Configurations/tools/zsh/.zshrc
	@cp ~/.p10k.zsh ~/Documents/code/UtilityBox/Configurations/tools/zsh/.p10k.zsh
	@cp -r ~/.config/nvim/* ~/Documents/code/UtilityBox/Configurations/tools/nvim/
	@pacman -Qqen > ~/Documents/code/UtilityBox/Configurations/setups/Arch/pkg_list.txt
	@pacman -Qqem > ~/Documents/code/UtilityBox/Configurations/setups/Arch/aur_list.txt
	@echo "✅ --- Đã sao lưu xong! ---"

restore-configs:
	@echo "📦 --- Đang khôi phục cấu hình ---"
	@cp ~/Documents/code/UtilityBox/Configurations/setups/Arch/i3/config ~/.config/i3/config
	@cp ~/Documents/code/UtilityBox/Configurations/setups/Arch/i3status/config ~/.config/i3status/config
	@cp ~/Documents/code/UtilityBox/Configurations/tools/zsh/.zshrc ~/.zshrc
	@cp ~/Documents/code/UtilityBox/Configurations/tools/zsh/.p10k.zsh ~/.p10k.zsh
	@mkdir -p ~/.config/nvim && cp -r ~/Documents/code/UtilityBox/Configurations/tools/nvim/* ~/.config/nvim/
	@echo "✅ --- Đã khôi phục xong. Nhấn Mod+Shift+R để reload i3 ---"

restore-packages:
	@echo "📦 --- Đang cài đặt packages từ repo chính ---"
	@sudo pacman -S --needed --noconfirm - < ~/Documents/code/UtilityBox/Configurations/setups/Arch/pkg_list.txt
	@echo "📦 --- Đang cài đặt packages từ AUR ---"
	@yay -S --needed --noconfirm - < ~/Documents/code/UtilityBox/Configurations/setups/Arch/aur_list.txt
	@echo "✅ --- Hoàn tất cài đặt toàn bộ phần mềm! ---"

# ========================================
# 🔄 GIT AUTOMATION
# ========================================
git-push:
	@echo "🚀 --- Đang đẩy dữ liệu lên GitHub ---"
	@cd ~/Documents/code/UtilityBox/ && \
	 git add . && \
	 git commit -m "Manual backup: $$(date +'%Y-%m-%d %H:%M:%S')" && \
	 git push origin main
	@echo "✅ --- Đã đẩy lên GitHub thành công! ---"

