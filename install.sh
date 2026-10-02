#!/usr/bin/env bash
set -e

# Цвета для красивого вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${CYAN}${BOLD}"
echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║       Установщик окружения Hyprland + Serpantinum Desktop         ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Проверка, что скрипт НЕ запущен от root (он должен выполняться от обычного пользователя)
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}[ERROR] Не запускайте этот скрипт через sudo! Он сам запросит sudo, когда потребуется.${NC}"
    exit 1
fi

# 1. Проверка пакетного менеджера pacman
if ! command -v pacman &>/dev/null; then
    echo -e "${RED}[ERROR] Pacman не найден. Этот скрипт предназначен для Arch Linux / Arch-based дистрибутивов.${NC}"
    exit 1
fi

echo -e "${BLUE}[1/6] Проверка и установка пакетов...${NC}"

# Спросить пользователя об установке пакетов
read -rp "Установить официальные системные пакеты из packages-repo.txt? [Y/n]: " install_repo_pkgs
install_repo_pkgs=${install_repo_pkgs:-Y}

if [[ "$install_repo_pkgs" =~ ^[YyДд]$ ]]; then
    if [ -f "$SCRIPT_DIR/packages-repo.txt" ]; then
        echo -e "${YELLOW}Обновление базы пакетов и установка repo пакетов...${NC}"
        sudo pacman -Syu --needed --noconfirm - < "$SCRIPT_DIR/packages-repo.txt" || true
    fi
fi

# Проверка yay для AUR пакетов
if ! command -v yay &>/dev/null; then
    echo -e "${YELLOW}yay не обнаружен. Хотите собрать и установить yay-bin? [Y/n]: ${NC}"
    read -rp "" install_yay_choice
    install_yay_choice=${install_yay_choice:-Y}
    if [[ "$install_yay_choice" =~ ^[YyДд]$ ]]; then
        sudo pacman -S --needed --noconfirm git base-devel
        TMP_YAY=$(mktemp -d)
        git clone https://aur.archlinux.org/yay-bin.git "$TMP_YAY"
        (cd "$TMP_YAY" && makepkg -si --noconfirm)
        rm -rf "$TMP_YAY"
    fi
fi

if command -v yay &>/dev/null; then
    read -rp "Установить AUR-пакеты из packages-aur.txt? [Y/n]: " install_aur_pkgs
    install_aur_pkgs=${install_aur_pkgs:-Y}
    if [[ "$install_aur_pkgs" =~ ^[YyДд]$ ]]; then
        if [ -f "$SCRIPT_DIR/packages-aur.txt" ]; then
            echo -e "${YELLOW}Установка AUR пакетов через yay...${NC}"
            yay -S --needed --noconfirm - < "$SCRIPT_DIR/packages-aur.txt" || true
        fi
    fi
fi

# 2. Резервное копирование текущих конфигов пользователя
echo ""
echo -e "${BLUE}[2/6] Резервное копирование существующих конфигураций...${NC}"
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

CONFIGS_TO_BACKUP=("hypr" "serpantinum" "kitty" "environment.d" "gamemode.ini" "fastfetch" "cava" "gammastep" "gtk-3.0" "gtk-4.0" "xsettingsd")

for cfg in "${CONFIGS_TO_BACKUP[@]}"; do
    if [ -e "$HOME/.config/$cfg" ]; then
        cp -r "$HOME/.config/$cfg" "$BACKUP_DIR/"
    fi
done
echo -e "${GREEN}✓ Резервная копия сохранена в:${NC} $BACKUP_DIR"

# 3. Восстановление конфигураций
echo ""
echo -e "${BLUE}[3/6] Развертывание файлов конфигурации (~/.config)...${NC}"
mkdir -p "$HOME/.config"
cp -r "$SCRIPT_DIR/config/"* "$HOME/.config/"
echo -e "${GREEN}✓ Конфигурации успешно скопированы.${NC}"

# 4. Восстановление serpantinum и компонентов UI
echo ""
echo -e "${BLUE}[4/6] Установка компонентов Serpantinum Desktop (~/.local/share)...${NC}"
mkdir -p "$HOME/.local/share"
if [ -d "$SCRIPT_DIR/local_share/serpantinum" ]; then
    rm -rf "$HOME/.local/share/serpantinum"
    cp -r "$SCRIPT_DIR/local_share/serpantinum" "$HOME/.local/share/"
    echo -e "${GREEN}✓ Serpantinum скопирован в ~/.local/share/serpantinum${NC}"
fi

# 5. Установка пользовательских скриптов и симлинков (~/.local/bin)
echo ""
echo -e "${BLUE}[5/6] Настройка пользовательских скриптов и алиасов...${NC}"
mkdir -p "$HOME/.local/bin"
if [ -d "$SCRIPT_DIR/local_bin" ]; then
    cp -r "$SCRIPT_DIR/local_bin/"* "$HOME/.local/bin/"
    chmod +x "$HOME/.local/bin/"*
fi

# Создание симлинков
ln -sf "$HOME/.local/share/serpantinum/bin/serpantinum" "$HOME/.local/bin/serpantinum"
ln -sf "$HOME/.local/share/serpantinum/bin/serpantinumd" "$HOME/.local/bin/serpantinumd"
ln -sf "$HOME/.local/bin/fan" "$HOME/.local/bin/low"
ln -sf "$HOME/.local/bin/fan" "$HOME/.local/bin/balanced"
ln -sf "$HOME/.local/bin/fan" "$HOME/.local/bin/boost"
ln -sf "$HOME/.local/bin/quickshell-share-picker" "$HOME/.local/bin/hyprland-share-picker"

# Добавление в ~/.bashrc если нет
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc" 2>/dev/null; then
    cat << 'EOF' >> "$HOME/.bashrc"

export PATH="$HOME/.local/bin:$PATH"

alias low='$HOME/.local/bin/low'
alias balanced='$HOME/.local/bin/balanced'
alias boost='$HOME/.local/bin/boost'
alias ram='Ram'
alias RAM='Ram'
EOF
    echo -e "${GREEN}✓ Алиасы и PATH добавлены в ~/.bashrc${NC}"
fi

# 6. Оптимизация системы (CPU, GPU, NVMe, RAM)
echo ""
echo -e "${BLUE}[6/6] Системная оптимизация (CPU, GPU, NVMe, RAM)...${NC}"
if [ -f "$SCRIPT_DIR/optimize-system.sh" ]; then
    read -rp "Применить системную оптимизацию (требуются права sudo)? [Y/n]: " run_opt
    run_opt=${run_opt:-Y}
    if [[ "$run_opt" =~ ^[YyДд]$ ]]; then
        sudo bash "$SCRIPT_DIR/optimize-system.sh"
    fi
fi

# Включение необходимых служб
systemctl --user enable --now xsettingsd 2>/dev/null || true
systemctl --user enable --now easyeffects 2>/dev/null || true

echo ""
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}   ✓ Установка и восстановление окружения успешно завершены!       ${NC}"
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Для вступления всех настроек в силу перезапустите сессию или выполните перезагрузку.${NC}"
