#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "Пожалуйста, запустите этот скрипт с sudo:"
  echo "sudo bash $0"
  exit 1
fi

echo "==> Применение системных оптимизаций CPU, GPU, RAM и NVMe..."

# 1. Сетевая оптимизация BBR + FQ
echo "==> Настройка BBR и FQ в sysctl..."
cat << 'EOF' > /etc/sysctl.d/99-performance.conf
# TCP BBR Congestion Control & FQ (минимизация задержки в играх и сети)
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# Увеличение сетевых буферов
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
EOF
sysctl -p /etc/sysctl.d/99-performance.conf || true

# 2. NVIDIA Persistence Daemon (предотвращает засыпание/сброс драйвера NVIDIA и микрофризы)
echo "==> Включение nvidia-persistenced..."
systemctl enable --now nvidia-persistenced.service || true

# 3. Настройка параметров драйвера NVIDIA для стабильности и сохранения VRAM
echo "==> Настройка modprobe для NVIDIA..."
cat << 'EOF' > /etc/modprobe.d/99-nvidia-power.conf
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia NVreg_TemporaryFilePath=/var/tmp
EOF

# 4. Оптимизация накопителя (NVMe ROM/SSD) - noatime вместо relatime
echo "==> Оптимизация опций монтирования в /etc/fstab (noatime)..."
if grep -q "relatime" /etc/fstab; then
    sed -i 's/relatime/noatime/g' /etc/fstab
    mount -o remount,noatime / || true
    echo "  -> noatime успешно установлен для диска."
fi

# 5. Проверка fstrim
systemctl enable --now fstrim.timer || true

echo ""
echo " Все оптимизации успешно применены!"
