# --- Cấu hình Project ---
PKG_NAME      := com.mycompany.app
# Lấy phần cha (com.mycompany) để tạo package song song
PKG_PARENT    := com.mycompany
PKG_DIR       := $(subst .,/,$(PKG_PARENT))
MAIN_CLASS    := $(PKG_NAME).App
SRC_BASE      := src/main/java
# Trỏ đến thư mục cha để p=model sẽ tạo com/mycompany/model
FULL_PKG_PATH := $(SRC_BASE)/$(PKG_DIR)
p = app
n = App
# --- Màu sắc ---
BLUE   := \033[1;34m
GREEN  := \033[1;32m
CYAN   := \033[1;36m
YELLOW := \033[1;33m
RED    := \033[1;31m
RESET  := \033[0m

# --- Lệnh thực thi ---
run:
	@echo "$(CYAN)🚀 Đang khởi chạy ứng dụng...$(RESET)"
	@mvn -q compile exec:java -Dexec.mainClass="$(PKG_PARENT).$(p).$(n)"

debug:
	@echo "$(CYAN)🛠  Đang chạy chế độ Debug...$(RESET)"
	@mvn -q compile
	@java -cp target/classes $(PKG_PARENT).$(p).$(n)

# Tạo package song song: make create-pkg p=model -> com.mycompany.model
create-pkg:
	@mkdir -p $(FULL_PKG_PATH)/$(p)
	@echo "$(GREEN)✔$(RESET) Đã tạo package: $(YELLOW)$(PKG_PARENT).$(p)$(RESET)"

# Tạo class: make create-class n=User p=model
create-class:
	@$(eval FINAL_PATH := $(if $(p),$(FULL_PKG_PATH)/$(p),$(FULL_PKG_PATH)/app))
	@$(eval FINAL_PKG := $(if $(p),$(PKG_PARENT).$(p),$(PKG_NAME)))
	@mkdir -p $(FINAL_PATH)
	@printf "package $(FINAL_PKG);\n\npublic class $(n) {\n    public $(n)() {\n        System.out.println(\"Khởi tạo $(n) thành công!\");\n    }\n}\n" > $(FINAL_PATH)/$(n).java
	@echo "$(GREEN)✔$(RESET) Đã tạo class $(YELLOW)$(n)$(RESET) tại $(CYAN)$(FINAL_PKG)$(RESET)"

clean:
	@mvn clean
	@echo "$(YELLOW)✔ Đã dọn dẹp thư mục target$(RESET)"

compress:
	@mvn package -DskipTests
	@echo "$(GREEN)✔ Đã tạo file JAR tại target/$(RESET)"

status:
	@echo "$(BLUE)==========================================$(RESET)"
	@echo "$(CYAN)          PROJECT STATUS REPORT          $(RESET)"
	@echo "$(BLUE)==========================================$(RESET)"
	@echo "$(GREEN)▶ Maven Version:$(RESET)  $$(mvn --version | head -n 1)"
	@echo "$(GREEN)▶ Entry Point:$(RESET)    $(YELLOW)$(PKG_PARENT)$(RESET)"
	@echo "$(GREEN)▶ Artifact Size:$(RESET)  $(YELLOW)$$(du -sh target/ 2>/dev/null | cut -f1 || echo "Empty")$(RESET)"
	@echo "$(GREEN)▶ Source Files:$(RESET)   $(YELLOW)$$(find src/main/java -name "*.java" | wc -l)$(RESET) files"
	@echo "$(GREEN)▶ Current Time:$(RESET)   $$(date '+%Y-%m-%d %H:%M:%S')"
	@echo "$(BLUE)==========================================$(RESET)"

help:
	@echo "$(CYAN)Các lệnh hỗ trợ:$(RESET)"
	@echo "  $(GREEN)make run$(RESET)             : Biên dịch và chạy"
	@echo "  $(GREEN)make create-pkg p=$(RESET)   : Tạo package mới (vd: p=model)"
	@echo "  $(GREEN)make create-class n= p=$(RESET): Tạo class mới (vd: n=User p=model)"
	@echo "  $(GREEN)make status$(RESET)          : Xem tổng quan dự án"
	@echo "  $(GREEN)make clean$(RESET)           : Xóa rác biên dịch"

.PHONY: all run debug create-pkg create-class clean compress status help
