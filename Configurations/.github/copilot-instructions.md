# Copilot Instructions - UtilityBox/Configurations

## Tổng quan

Repository tự động hóa cấu hình và quản lý môi trường phát triển Linux (Arch/Ubuntu). Gồm 3 nhóm chính:

### 1. **Makefiles** (`/makefile/`)

- Automation scripts cho system management, app installation, backup/restore
- Java project scaffolding và build automation

### 2. **Setups** (`/setups/`)

- Package lists và configs cho Arch Linux (i3wm, i3status)
- Shell scripts cho Ubuntu/Debian setup

### 3. **Tools** (`/tools/`)

- Dev tool configs: Neovim, Zsh, Zed
- Dotfiles được track và sync

## Workflow Patterns

**Backup/Restore**: Sử dụng make targets để sync configs giữa system và repo
**Package Management**: Maintain plain text lists (pkg_list.txt, aur_list.txt) cho reproducibility  
**Git Automation**: Auto-commit với timestamp khi backup

## Coding Standards

1. **IGNORE** thư mục `backend-express` hoàn toàn
2. **Makefile style**:
   - Colored output với `@echo` + emoji
   - Suppress unnecessary logs với `> /dev/null 2>&1`
   - Non-interactive flags (`--noconfirm`, `DEBIAN_FRONTEND=noninteractive`)
3. **Shell scripts**:
   - Error handling + status logging
   - Summary tables với colored SUCCESS/ERROR
4. **Java automation**: Biến `p` (package), `n` (name) cho dynamic scaffolding

## Tech Stack

**OS**: Arch Linux, Ubuntu/Debian | **WM**: i3 | **Shell**: Zsh + Oh My Zsh + Powerlevel10k  
**Editors**: Neovim (LazyVim), Zed | **Build**: Make, Maven | **Pkg**: pacman, yay, apt, apt-fast
