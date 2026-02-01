install-onlyoffice:
	@echo "--- Đang cài đặt OnlyOffice và Font ---"
	@yay -S --needed --noconfirm onlyoffice-bin ttf-ms-fonts

install-chrome:
	@yay -S --needed --noconfirm google-chrome

unikey-on:
	@echo "--- Khởi động bộ gõ ---"
	@pgrep fcitx5 > /dev/null || fcitx5 -d > /dev/null 2>&1

unikey-off:
	@killall fcitx5 > /dev/null 2>&1 && echo "--- Đã tắt bộ gõ ---" || echo "Bộ gõ đang không chạy."

unikey-control:
	@fcitx5-configtool > /dev/null || fcitx5 -d > /dev/null 2>&1

install-unikey:
	@sudo pacman -S --needed fcitx5 fcitx5-unikey fcitx5-configtool fcitx5-qt fcitx5-gtk
	@echo "Đã cài xong. Hãy Log out để áp dụng biến môi trường."
sound:
	@easyeffects > /dev/null 2>&1 &
install-sound:
	@sudo pacman -S --needed --noconfirm easyeffects lsp-plugins mdsp-plugins

backup-configs:
	@cp ~/.config/i3/config ~/Documents/code/UtilityBox/Configurations/setups/Arch/i3/config
	@cp ~/.zshrc ~/Documents/code/UtilityBox/Configurations/tools/zsh/.zshrc
	@cp ~/.p10k.zsh ~/Documents/code/UtilityBox/Configurations/tools/zsh/.p10k.zsh
	@cp -r ~/.config/nvim/* ~/Documents/code/UtilityBox/Configurations/tools/nvim/
	@pacman -Qqen > ~/Documents/code/UtilityBox/Configurations/setups/Arch/pkg_list.txt  # Gói từ repo chính
	@pacman -Qqem > ~/Documents/code/UtilityBox/Configurations/setups/Arch/aur_list.txt  # Gói từ AUR
	@echo "--- Đã sao lưu các file cấu hình quan trọng ---"

git-push:
	@echo "--- Đang đẩy dữ liệu lên GitHub ---"
	@cd ~/Documents/code/UtilityBox/ && \
	 git add . && \
	 git commit -m "Manual backup: $$(date +'%Y-%m-%d %H:%M:%S')" && \
	 git push origin main
	@echo "--- Đã đẩy lên GitHub thành công! ---"
