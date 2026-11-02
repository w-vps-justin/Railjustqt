#!/bin/bash
set -e

# Render က PORT variable ပေးတယ် (မရှိရင် default 10000 သုံးမည်)
PORT="${PORT:-10000}"

echo "=== Starting SSH Server on Port $PORT ==="

# SSH configuration ထဲမှာ Port ကို Render ပေးတဲ့ Port သို့ပြောင်းရန်
sed -i "s/^#\?Port .*/Port $PORT/" /etc/ssh/sshd_config || echo "Port $PORT" >> /etc/ssh/sshd_config

# Runtime directories
mkdir -p /var/run/sshd /run/sshd

# Host keys ဖန်တီး (container rebuild တိုင်း အသစ်)
ssh-keygen -A

# Config syntax စစ်
echo "=== sshd -t ==="
/usr/sbin/sshd -t

# Listening ports စစ်
echo "=== listening ports ==="
ss -tulnp || true

# SFTP subsystem ရှိမရှိ စစ်
echo "=== SFTP subsystem ==="
grep -i "subsystem" /etc/ssh/sshd_config || echo "no subsystem line!"

# sshd run (foreground, log to stderr)
exec /usr/sbin/sshd -D -e
