# ⚙️ Linux Setup Configuration (Ubuntu Only)

> Bộ script hỗ trợ **cài đặt nhanh môi trường làm việc** trên Ubuntu.  
> Phù hợp cho máy mới hoặc khi cần setup lại toàn bộ hệ thống.

---
## 🖥️ Ubuntu Versions Tested

- Ubuntu 24.04 LTS
---

## 📌 Lưu ý quan trọng

- ⚠️ **Chỉ hỗ trợ Ubuntu** (không áp dụng cho các distro khác)
- 🌐 Quá trình tải yêu cầu **kết nối mạng ổn định**
- 🔄 Nếu bị gián đoạn do mạng → **chạy lại script**, tiến trình sẽ tự động tiếp tục
- 🧰 Yêu cầu **cài đặt `curl` trước**

---

## 🧰 Cài đặt `curl` (bắt buộc)

```bash
sudo apt update
sudo apt install -y curl
```

---

## 🚀 Cài đặt nhanh (Khuyến nghị)

Script tổng hợp – cài đặt các gói & cấu hình cần thiết **setup.sh**:

```bash
curl -fsSL https://raw.githubusercontent.com/devmindtan/UtilityBox/refs/heads/main/Configurations/setup-configuration/Linux/apps/setup.sh | bash
```

![Installed Packages](images/setup.png)

---

## 📦 Cài đặt từng ứng dụng (Tùy chọn)

### 🐳 Docker

```bash
curl -fsSL https://raw.githubusercontent.com/devmindtan/UtilityBox/refs/heads/main/Configurations/setup-configuration/Linux/apps/docker.sh | bash
```

![Installed Packages](images/docker.png)
- [Link gốc](https://docs.docker.com/engine/install/ubuntu/)
---

### 🌐 Google Chrome

```bash
curl -fsSL https://raw.githubusercontent.com/devmindtan/UtilityBox/refs/heads/main/Configurations/setup-configuration/Linux/apps/google.sh | bash
```

![Installed Packages](images/google.png)
- [Link gốc](https://www.google.com/chrome/)
---

### 🧠 JetBrains Toolbox

```bash
curl -fsSL https://raw.githubusercontent.com/devmindtan/UtilityBox/refs/heads/main/Configurations/setup-configuration/Linux/apps/jetbrains.sh | bash
```

![Installed Packages](images/jetbrains.png)
- [Link gốc](https://www.jetbrains.com/toolbox-app/)
---

### 🇻🇳 Unikey (Bộ gõ tiếng Việt)

```bash
curl -fsSL https://raw.githubusercontent.com/devmindtan/UtilityBox/refs/heads/main/Configurations/setup-configuration/Linux/apps/unikey.sh | bash
```

![Installed Packages](images/unikey.png)
- [Link gốc](https://github.com/BambooEngine/ibus-bamboo)
---

### 💬 Telegram

```bash
curl -fsSL https://raw.githubusercontent.com/devmindtan/UtilityBox/refs/heads/main/Configurations/setup-configuration/Linux/apps/telegram.sh | bash
```

![Installed Packages](images/telegram.png)
- [Link gốc](https://desktop.telegram.org)
---

## ✅ Gợi ý sử dụng

- 👉 Máy mới → dùng **setup.sh**
- 👉 Chỉ cần cài riêng từng app → dùng các script **Optionals**
- 👉 Có thể chạy lại script nhiều lần, **không gây lỗi**

---

***Sẽ còn cập nhật thêm nhiều ứng dụng mới trong tương lai***
---

## 🚧 Roadmap

- [ ] Thêm VS Code
- [ ] Thêm Zsh + Oh My Zsh
- [ ] Thêm Node.js / Python / Java
- [ ] Hỗ trợ Ubuntu bản mới
- [ ] Hỗ trợ thêm các bản phân phối khác của linux
