#!/bin/bash
# script_setup_cliente.sh - Setup do cliente (kali)
# Execute na MAQUINA CLIENTE (Kali Linux)

echo "╔═══════════════════════════════════════════════════╗"
echo "║  🧪 Setup Cliente MySQL - Laboratorio de Seguranca ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""

# Verificar/instalar tcpdump
if ! command -v tcpdump &> /dev/null; then
    echo "📦 Instalando tcpdump..."
    sudo apt update && sudo apt install -y tcpdump
else
    echo "✅ tcpdump: $(tcpdump --version | head -1)"
fi

# Verificar/instalar tshark (ESSENCIAL para extrair queries MySQL)
if ! command -v tshark &> /dev/null; then
    echo "📦 Instalando tshark (para analise de queries)..."
    sudo apt update && sudo apt install -y tshark
    echo "⚠️  Durante a instalacao, escolha 'Sim' para permitir captura por nao-root"
else
    echo "✅ tshark: $(tshark --version | head -1)"
fi

# Verificar/instalar mysql client
if ! command -v mysql &> /dev/null; then
    echo "📦 Instalando mysql-client..."
    sudo apt install -y default-mysql-client
else
    echo "✅ mysql client: $(mysql --version)"
fi

# Criar diretorio de capturas
echo "📁 Criando ~/laboratorio-capturas..."
mkdir -p ~/laboratorio-capturas
cd ~/laboratorio-capturas || exit 1

# Liberar tcpdump sem senha
echo "🔓 Liberando tcpdump sem senha (sudoers.d)..."
echo "kali ALL=(ALL) NOPASSWD: /usr/bin/tcpdump" | sudo tee /etc/sudoers.d/tcpdump
sudo chmod 440 /etc/sudoers.d/tcpdump

echo ""
echo "✅ Setup do cliente concluido!"
echo ""
echo "   Comandos uteis:"
echo "   • sudo tcpdump -i any -s 0 -w mysql.pcap \"host IP_SERVIDOR and port 3306\""
echo "   • mysql -h IP_SERVIDOR -u dba_user -p    (senha: dba_secret_2024)"
echo "   • tshark -r mysql.pcap -Y \"mysql.query\" -T fields -e mysql.query"