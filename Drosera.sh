#!/bin/bash

set -e

echo ">>> Drosera Node Auto Installer"
echo ">>> Updating dependencies..."
apt update && apt install -y curl git sudo

echo ">>> Installing Bun..."
if ! command -v bun &> /dev/null; then
  curl -fsSL https://bun.sh/install | bash
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
  echo 'export BUN_INSTALL="$HOME/.bun"' >> ~/.bashrc
  echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> ~/.bashrc
fi

echo ">>> Cloning repo..."
cd ~
rm -rf drosera-nodes
git clone https://github.com/radenmaswijaya/drosera-nodes.git
cd drosera-nodes

echo ">>> Installing dependencies..."
export PATH="$HOME/.bun/bin:$PATH"
bun install

echo ">>> Creating systemd service..."
cat <<EOF > /etc/systemd/system/drosera.service
[Unit]
Description=Drosera Node Raden
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/drosera-nodes
ExecStart=/bin/bash -lc "bun deploy-trap.ts"
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

echo ">>> Starting service..."
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable drosera.service
systemctl restart drosera.service

echo ">>> Install complete!"
echo ">>> Cek status: systemctl status drosera.service"
echo ">>> Lihat log: journalctl -u drosera.service -f"
