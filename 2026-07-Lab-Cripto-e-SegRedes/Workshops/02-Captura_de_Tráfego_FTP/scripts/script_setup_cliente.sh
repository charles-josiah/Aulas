#!/bin/bash
# script_setup_cliente.sh - Script de setup do cliente (kali)
# Execute na MÁQUINA CLIENTE (Kali Linux)

echo "╔═══════════════════════════════════════════════════╗"
echo "║  🧪 Setup Cliente - Laboratório de Segurança      ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""

# Verificar tcpdump
if ! command -v tcpdump &> /dev/null; then
    echo "❌ tcpdump não encontrado! Instalando..."
    sudo apt update && sudo apt install -y tcpdump ftp lftp
else
    echo "✅ tcpdump: $(tcpdump --version | head -1)"
fi

# Criar diretório de capturas
echo "📁 Criando ~/laboratorio-capturas..."
mkdir -p ~/laboratorio-capturas
cd ~/laboratorio-capturas || exit 1

# Liberar tcpdump sem senha (opcional, para o laboratório)
echo "🔓 Liberando tcpdump sem senha (sudoers.d)..."
echo "kali ALL=(ALL) NOPASSWD: /usr/bin/tcpdump" | sudo tee /etc/sudoers.d/tcpdump
sudo chmod 440 /etc/sudoers.d/tcpdump

echo ""
echo "✅ Setup do cliente concluído!"
echo "   Comandos úteis:"
echo "   • ftp IP_SERVIDOR        (conectar no servidor FTP)"
echo "   • sudo tcpdump -i any -s 0 -w ftp.pcap \"host IP_SERVIDOR and (port 21 or portrange 30000-30100)\""
