PYTHON_VENV = ~/Documents/venv/venv-py314/bin/python3
CAM_DIR = ~/Documents/code/UtilityBox/Apps/Camera
SELF_MK = $(abspath $(lastword $(MAKEFILE_LIST)))
AUDIO_HDMI_SINK ?= alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__HDMI1__sink

# ========================================
# 🎯 INSTALL ALL - Setup hệ thống từ đầu
# ========================================
install-all:
	@echo "🚀 --- BẮT ĐẦU CÀI ĐẶT TOÀN BỘ HỆ THỐNG ---"
	@$(MAKE) -f $(SELF_MK) install-zsh
	@$(MAKE) -f $(SELF_MK) install-unikey
	@$(MAKE) -f $(SELF_MK) install-chrome
	@$(MAKE) -f $(SELF_MK) install-onlyoffice
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

# ========================================
# 📷 CAMERA QUICK TOOLS (Meet/Messenger)
# ========================================
cam-help:
	@echo "📷 Camera quick commands:"
	@echo "  make -f ... cam-install-deps # Tự cài dependency camera/web call"
	@echo "  make -f ... cam-check      # Kiểm tra camera + portal + pipewire"
	@echo "  make -f ... cam-test       # Mở camera local test (OpenCV app)"
	@echo "  make -f ... cam-release    # Giải phóng camera nếu app khác đang chiếm"
	@echo "  make -f ... cam-restart    # Restart service camera/portal"
	@echo "  make -f ... cam-fix        # Chuỗi sửa nhanh camera web call"
	@echo "  make -f ... cam-meet       # Mở Google Meet"
	@echo "  make -f ... cam-messenger  # Mở Facebook Messenger"

cam-install-deps:
	@echo "📦 --- CÀI DEPENDENCY CHO CAMERA WEB CALL ---"
	@sudo pacman -S --needed --noconfirm \
		pipewire wireplumber \
		xdg-desktop-portal xdg-desktop-portal-gtk \
		v4l-utils
	@echo "✅ Đã cài dependency camera/portal"

cam-check:
	@echo "🔎 --- CAMERA CHECK (WEB CALL) ---"
	@echo "🖥 Session type: $$XDG_SESSION_TYPE"
	@echo ""
	@echo "🎥 Video devices:"
	@if ls /dev/video* >/dev/null 2>&1; then ls -l /dev/video*; else echo "❌ Không có /dev/video*"; fi
	@echo ""
	@echo "📦 v4l2 devices:"
	@if command -v v4l2-ctl >/dev/null 2>&1; then v4l2-ctl --list-devices; else echo "⚠️  Thiếu v4l2-ctl (cài gói v4l-utils)"; fi
	@echo ""
	@echo "🔧 User services (camera stack):"
	@printf "  pipewire: "; systemctl --user is-active pipewire 2>/dev/null || true
	@printf "  wireplumber: "; systemctl --user is-active wireplumber 2>/dev/null || true
	@printf "  xdg-desktop-portal: "; systemctl --user is-active xdg-desktop-portal 2>/dev/null || true
	@printf "  xdg-desktop-portal-gtk: "; systemctl --user is-active xdg-desktop-portal-gtk 2>/dev/null || true
	@echo ""
	@echo "🔒 Tiến trình đang dùng camera (/dev/video*):"
	@FOUND=0; \
	for dev in /dev/video*; do \
		[ -e "$$dev" ] || continue; \
		OUT=$$(fuser "$$dev" 2>/dev/null); \
		if [ -n "$$OUT" ]; then \
			FOUND=1; \
			echo "  $$dev <- PID: $$OUT"; \
		fi; \
	done; \
	if [ $$FOUND -eq 0 ]; then \
		echo "  (không có tiến trình nào chiếm camera)"; \
	fi
	@echo ""
	@echo "✅ Gợi ý: nếu Meet/Messenger vẫn đen màn hình -> chạy cam-release rồi cam-restart"

cam-test:
	@echo "🧪 --- TEST CAMERA LOCAL ---"
	@$(MAKE) -f $(SELF_MK) camera

cam-release:
	@echo "🧹 --- GIẢI PHÓNG CAMERA ---"
	@PIDS=$$(for dev in /dev/video*; do [ -e "$$dev" ] || continue; fuser "$$dev" 2>/dev/null; done | tr ' ' '\n' | sort -u | tr '\n' ' '); \
	if [ -z "$$PIDS" ]; then \
		echo "✅ Không có tiến trình nào đang chiếm camera"; \
	else \
		echo "⚠️  Đang dừng PID: $$PIDS"; \
		kill $$PIDS >/dev/null 2>&1 || true; \
		sleep 1; \
		echo "✅ Đã giải phóng camera"; \
	fi

cam-restart:
	@echo "♻️  --- RESTART CAMERA/PORTAL SERVICES ---"
	@systemctl --user restart pipewire wireplumber 2>/dev/null || true
	@systemctl --user restart xdg-desktop-portal xdg-desktop-portal-gtk 2>/dev/null || true
	@systemctl --user start xdg-desktop-portal xdg-desktop-portal-gtk 2>/dev/null || true
	@echo "📌 Trạng thái portal:"
	@printf "  xdg-desktop-portal: "; systemctl --user is-active xdg-desktop-portal 2>/dev/null || true
	@printf "  xdg-desktop-portal-gtk: "; systemctl --user is-active xdg-desktop-portal-gtk 2>/dev/null || true
	@echo "✅ Đã restart xong. Hãy reload tab Meet/Messenger (Ctrl+Shift+R)."

cam-fix:
	@echo "🛠️  --- CAMERA QUICK FIX ---"
	@$(MAKE) -f $(SELF_MK) cam-install-deps
	@$(MAKE) -f $(SELF_MK) cam-release
	@$(MAKE) -f $(SELF_MK) cam-restart
	@$(MAKE) -f $(SELF_MK) cam-check

cam-meet:
	@xdg-open "https://meet.google.com" > /dev/null 2>&1 &
	@echo "🌐 Đã mở Google Meet"

cam-messenger:
	@xdg-open "https://www.messenger.com" > /dev/null 2>&1 &
	@echo "🌐 Đã mở Messenger"

# ========================================
# 🔊 AUDIO QUICK TOOLS
# ========================================
audio-help:
	@echo "🔊 Audio quick commands:"
	@echo "  make -f ... audio-check        # Kiểm tra trạng thái âm thanh"
	@echo "  make -f ... audio-use-speaker  # Chuyển sang loa laptop"
	@echo "  make -f ... audio-use-hdmi     # Chuyển sang âm thanh HDMI (ưu tiên HDMI1)"
	@echo "  make -f ... audio-use-hdmi1    # Ép sang HDMI1"
	@echo "  make -f ... audio-use-bt       # Chuyển sang tai nghe Bluetooth"
	@echo "  make -f ... audio-move-streams # Chuyển app đang phát sang default sink"
	@echo "  make -f ... audio-restart      # Restart PipeWire + WirePlumber"
	@echo "  make -f ... audio-test         # Phát âm test"

audio-check:
	@echo "🔎 --- AUDIO CHECK ---"
	@echo "🎧 Bluetooth connected devices:"
	@bluetoothctl devices Connected 2>/dev/null || true
	@echo ""
	@echo "🎚 Default sink:"
	@pactl get-default-sink 2>/dev/null || echo "(không lấy được default sink)"
	@echo ""
	@echo "📤 Sinks:"
	@pactl list sinks short 2>/dev/null || echo "(không lấy được danh sách sinks)"
	@echo ""
	@echo "🪪 Active profiles:"
	@pactl list cards 2>/dev/null | grep -E "Name:|Active Profile:" || true

audio-use-speaker:
	@echo "🔊 --- CHUYỂN SANG LOA LAPTOP ---"
	@CARD=$$(pactl list cards short | awk '/alsa_card\.pci-/{print $$2; exit}'); \
	if [ -z "$$CARD" ]; then \
		echo "❌ Không tìm thấy ALSA card"; \
		exit 1; \
	fi; \
	PROFILE='HiFi (HDMI1, HDMI2, HDMI3, Mic1, Mic2, Speaker)'; \
	pactl set-card-profile "$$CARD" "$$PROFILE" 2>/dev/null || true; \
	SINK=$$(pactl list sinks short | awk '/HiFi__Speaker__sink/{print $$2; exit}'); \
	if [ -z "$$SINK" ]; then \
		echo "❌ Không tìm thấy Speaker sink"; \
		exit 1; \
	fi; \
	pactl set-default-sink "$$SINK"; \
	pactl set-sink-mute "$$SINK" 0; \
	pactl set-sink-volume "$$SINK" 80%; \
	echo "✅ Default sink -> $$SINK"

audio-use-hdmi:
	@$(MAKE) --no-print-directory -f $(SELF_MK) audio-use-hdmi1

audio-use-hdmi1:
	@echo "🖥️ --- CHUYỂN SANG HDMI AUDIO ---"
	@CARD=$$(pactl list cards short | awk '/alsa_card\.pci-/{print $$2; exit}'); \
	if [ -z "$$CARD" ]; then \
		echo "❌ Không tìm thấy ALSA card"; \
		exit 1; \
	fi; \
	PROFILE='HiFi (HDMI1, HDMI2, HDMI3, Mic1, Mic2, Speaker)'; \
	pactl set-card-profile "$$CARD" "$$PROFILE" 2>/dev/null || true; \
	SINK=$$(pactl list sinks short | awk -v s="$(AUDIO_HDMI_SINK)" '$$2==s{print $$2; exit}'); \
	if [ -z "$$SINK" ]; then \
		SINK=$$(pactl list sinks short | awk '/HiFi__HDMI1__sink/{print $$2; exit}'); \
	fi; \
	if [ -z "$$SINK" ]; then \
		SINK=$$(pactl list sinks short | awk '/HiFi__HDMI[0-9]+__sink/{print $$2; exit}'); \
	fi; \
	if [ -z "$$SINK" ]; then \
		SINK=$$(pactl list sinks short | awk '/hdmi|HDMI/{print $$2; exit}'); \
	fi; \
	if [ -z "$$SINK" ]; then \
		echo "❌ Không tìm thấy HDMI sink"; \
		echo "⚠️  Hãy kiểm tra cáp/màn hình và chạy: make -f ... audio-check"; \
		exit 1; \
	fi; \
	pactl set-default-sink "$$SINK"; \
	if command -v wpctl >/dev/null 2>&1; then \
		SID=$$(pactl list sinks short | awk -v s="$$SINK" '$$2==s{print $$1; exit}'); \
		[ -n "$$SID" ] && wpctl set-default "$$SID" >/dev/null 2>&1 || true; \
	fi; \
	for i in $$(pactl list sink-inputs short | awk '{print $$1}'); do \
		pactl move-sink-input $$i "$$SINK"; \
	done; \
	pactl set-sink-mute "$$SINK" 0; \
	pactl set-sink-volume "$$SINK" 80%; \
	echo "✅ Default sink -> $$SINK"

audio-use-bt:
	@echo "🎧 --- CHUYỂN SANG BLUETOOTH ---"
	@BT_CARD=$$(pactl list cards short | awk '/bluez_card\./{print $$2; exit}'); \
	if [ -z "$$BT_CARD" ]; then \
		echo "❌ Không tìm thấy Bluetooth card trong PipeWire"; \
		exit 1; \
	fi; \
	pactl set-card-profile "$$BT_CARD" a2dp-sink 2>/dev/null || true; \
	SINK=$$(pactl list sinks short | awk '/bluez_output\./{print $$2; exit}'); \
	if [ -z "$$SINK" ]; then \
		echo "❌ Không tìm thấy Bluetooth sink (hãy đảm bảo tai nghe đã kết nối)"; \
		exit 1; \
	fi; \
	pactl set-default-sink "$$SINK"; \
	pactl set-sink-mute "$$SINK" 0; \
	pactl set-sink-volume "$$SINK" 80%; \
	echo "✅ Default sink -> $$SINK"

audio-move-streams:
	@echo "🔁 --- CHUYỂN APP ĐANG PHÁT SANG DEFAULT SINK ---"
	@DEFAULT=$$(pactl get-default-sink); \
	COUNT=0; \
	for i in $$(pactl list sink-inputs short | awk '{print $$1}'); do \
		pactl move-sink-input $$i "$$DEFAULT"; \
		COUNT=$$((COUNT + 1)); \
	done; \
	echo "✅ Đã chuyển $$COUNT stream(s) sang $$DEFAULT"

audio-restart:
	@echo "♻️  --- RESTART AUDIO SERVICES ---"
	@systemctl --user restart pipewire pipewire-pulse wireplumber
	@echo "✅ Đã restart PipeWire + WirePlumber"

audio-test:
	@echo "🧪 --- PHÁT ÂM THANH TEST ---"
	@if [ -f /usr/share/sounds/alsa/Front_Center.wav ]; then \
		paplay /usr/share/sounds/alsa/Front_Center.wav; \
	else \
		speaker-test -D default -c 2 -t wav -l 1; \
	fi

# ========================================
# 🎙️ MICROPHONE QUICK TOOLS
# ========================================
mic-help:
	@echo "🎙️ Mic quick commands:"
	@echo "  make -f ... mic-check         # Kiểm tra trạng thái microphone"
	@echo "  make -f ... mic-use-laptop    # Chuyển sang mic laptop"
	@echo "  make -f ... mic-use-wired     # Chuyển sang mic nối dây (jack 3.5mm)"
	@echo "  make -f ... mic-use-bt        # Chuyển sang mic Bluetooth (HFP/HSP)"
	@echo "  make -f ... mic-unmute        # Bỏ mute mic default"
	@echo "  make -f ... mic-move-streams  # Chuyển app đang thu sang default source"
	@echo "  make -f ... mic-test          # Thu thử 3 giây vào /tmp"

mic-check:
	@echo "🔎 --- MIC CHECK ---"
	@echo "🎧 Bluetooth connected devices:"
	@bluetoothctl devices Connected 2>/dev/null || true
	@echo ""
	@echo "🎚 Default source:"
	@pactl get-default-source 2>/dev/null || echo "(không lấy được default source)"
	@echo ""
	@echo "🎙 Sources:"
	@pactl list sources short 2>/dev/null || echo "(không lấy được danh sách sources)"
	@echo ""
	@echo "🪪 Active profiles:"
	@pactl list cards 2>/dev/null | grep -E "Name:|Active Profile:" || true

mic-use-laptop:
	@echo "💻 --- CHUYỂN SANG MIC LAPTOP ---"
	@SRC=$$(pactl list sources short | awk '/alsa_input\..*HiFi__Mic/{print $$2; exit}'); \
	if [ -z "$$SRC" ]; then \
		SRC=$$(pactl list sources short | awk '/alsa_input\./{print $$2; exit}'); \
	fi; \
	if [ -z "$$SRC" ]; then \
		echo "❌ Không tìm thấy laptop microphone source"; \
		exit 1; \
	fi; \
	pactl set-default-source "$$SRC"; \
	pactl set-source-mute "$$SRC" 0; \
	pactl set-source-volume "$$SRC" 80%; \
	echo "✅ Default source -> $$SRC"

mic-use-wired:
	@echo "🎧 --- CHUYỂN SANG MIC NỐI DÂY ---"
	@SRC=$$(pactl list sources | awk 'BEGIN{RS="Source #"; FS="\n"} /Name: alsa_input\./ && /Active Port: analog-input-headset-mic/ {for(i=1;i<=NF;i++) if($$i ~ /Name: /){sub(/^.*Name: /, "", $$i); print $$i; exit}}'); \
	if [ -z "$$SRC" ]; then \
		SRC=$$(pactl list sources short | awk '/alsa_input\..*(headset|Headset|Mic2|mic2)/{print $$2; exit}'); \
	fi; \
	if [ -z "$$SRC" ]; then \
		echo "❌ Không tìm thấy mic nối dây (headset jack)"; \
		echo "⚠️  Hãy cắm mic 3.5mm và kiểm tra lại bằng: make -f ... mic-check"; \
		exit 1; \
	fi; \
	pactl set-default-source "$$SRC"; \
	pactl set-source-mute "$$SRC" 0; \
	pactl set-source-volume "$$SRC" 80%; \
	echo "✅ Default source -> $$SRC"

mic-use-bt:
	@echo "🎧 --- CHUYỂN SANG MIC BLUETOOTH ---"
	@BT_CARD=$$(pactl list cards short | awk '/bluez_card\./{print $$2; exit}'); \
	if [ -z "$$BT_CARD" ]; then \
		echo "❌ Không tìm thấy Bluetooth card trong PipeWire"; \
		exit 1; \
	fi; \
	pactl set-card-profile "$$BT_CARD" headset-head-unit 2>/dev/null || pactl set-card-profile "$$BT_CARD" headset-head-unit-cvsd 2>/dev/null || true; \
	SRC=$$(pactl list sources short | awk '/bluez_input\./{print $$2; exit}'); \
	if [ -z "$$SRC" ]; then \
		echo "❌ Không tìm thấy Bluetooth microphone source"; \
		echo "⚠️  Hãy đảm bảo tai nghe hỗ trợ mic và đang dùng profile HFP/HSP"; \
		exit 1; \
	fi; \
	pactl set-default-source "$$SRC"; \
	pactl set-source-mute "$$SRC" 0; \
	pactl set-source-volume "$$SRC" 100%; \
	echo "✅ Default source -> $$SRC"

mic-unmute:
	@echo "🔓 --- UNMUTE DEFAULT MIC ---"
	@SRC=$$(pactl get-default-source); \
	pactl set-source-mute "$$SRC" 0; \
	pactl set-source-volume "$$SRC" 80%; \
	echo "✅ Mic đã unmute: $$SRC"

mic-move-streams:
	@echo "🔁 --- CHUYỂN APP ĐANG THU SANG DEFAULT SOURCE ---"
	@DEFAULT=$$(pactl get-default-source); \
	COUNT=0; \
	for i in $$(pactl list source-outputs short | awk '{print $$1}'); do \
		pactl move-source-output $$i "$$DEFAULT"; \
		COUNT=$$((COUNT + 1)); \
	done; \
	echo "✅ Đã chuyển $$COUNT stream(s) sang $$DEFAULT"

mic-test:
	@echo "🧪 --- TEST MIC (3 GIÂY) ---"
	@SRC=$$(pactl get-default-source 2>/dev/null); \
	if [ -z "$$SRC" ]; then \
		echo "❌ Không lấy được default source"; \
		exit 1; \
	fi; \
	echo "Recording from: $$SRC"; \
	parecord --device="$$SRC" --rate=48000 --channels=1 --format=s16le /tmp/mic-test.wav & \
	PID=$$!; \
	sleep 5; \
	kill $$PID >/dev/null 2>&1 || true; \
	if [ -s /tmp/mic-test.wav ]; then \
		echo "✅ Đã thu xong: /tmp/mic-test.wav"; \
	else \
		echo "❌ Thu thất bại hoặc không có dữ liệu"; \
		exit 1; \
	fi

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
	@rsync -av --delete ~/.config/kitty/ ~/Documents/code/UtilityBox/Configurations/tools/kitty/
	@rm -rf ~/Documents/code/UtilityBox/Configurations/tools/zsh/.oh-my-zsh
	@mkdir -p ~/Documents/code/UtilityBox/Configurations/tools/zsh/.oh-my-zsh/custom
	@rsync -av --exclude='.git' ~/.oh-my-zsh/custom/ ~/Documents/code/UtilityBox/Configurations/tools/zsh/.oh-my-zsh/custom/
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
	@mkdir -p ~/.oh-my-zsh/custom && cp -r ~/Documents/code/UtilityBox/Configurations/tools/zsh/custom/* ~/.oh-my-zsh/custom/
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

