install-onlyoffice:
	@yay -S --needed onlyoffice-bin ttf-ms-fonts
	@sudo pacman -S libnotify
camera:
	@source ~/Documents/venv/venv-py314/bin/activate
	@python3 ~/Documents/apps/Camera/main.py > /dev/null 2>&1 &
unikey:
	@echo "--- Success ---"
	@export GTK_IM_MODULE=fcitx && \
	 export QT_IM_MODULE=fcitx && \
	 export XMODIFIERS=@im=fcitx
	@pgrep fcitx5 > /dev/null || fcitx5 -d > /dev/null 2>&1
unikey-off:
	@killall fcitx5 && echo "--- Đã tắt bộ gõ ---" || echo "Bộ gõ đang không chạy."
install-unikey:
	@sudo pacman -S --needed fcitx5 fcitx5-bamboo fcitx5-configtool fcitx5-qt fcitx5-gtk
	@echo "Đã cài xong. Hãy Log out."
sound:
	@alsamixer
