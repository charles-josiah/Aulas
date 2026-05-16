# 📖 Wiki: Configuração do Servidor VNC no Kali Linux

> [!CAUTION]
> **AVISO DE ÉTICA E RESPONSABILIDADE**
> Este guia mostra como ativar e usar um servidor VNC no Kali Linux. Por padrão, VNC deve ser tratado como acesso remoto sensível e não deve ser exposto diretamente à internet.
>
> **Uso estritamente educacional:** aplique este procedimento apenas em laboratórios isolados, VMs dedicadas ou redes segregadas.
>
> **Não use em sistemas de terceiros ou produção sem autorização formal.** O uso deste material em qualquer contexto que viole normas legais ou políticas corporativas é de inteira responsabilidade do executor.
>
> **DISCLAIMER DE ESTABILIDADE E SUPORTE:** este ambiente foi preparado para fins pedagógicos, mas o comportamento pode variar conforme versão do Kali, do VNC e do software de virtualização.
>
> **Fique atento:**
> - conexões VNC expostas diretamente na rede podem não usar criptografia de transporte adequada.
> - senhas fracas ou padrão tornam a sessão vulnerável.
> - falhas podem ocorrer devido a drivers, virtualização desativada (BIOS/VT-x) ou conflitos de rede.
> - **ajustes manuais podem ser necessários** para adaptar o lab à sua máquina específica.
>
---

Este guia instrui como instalar, configurar e solucionar problemas do servidor VNC (**TigerVNC**) no Kali Linux, utilizando o ambiente gráfico padrão **XFCE**.

---

## 📋 Pré-requisitos
* Sistema Kali Linux atualizado.
* Acesso como `root` ou usuário com privilégios `sudo`.
* Conexão com a internet para download dos pacotes.
* Acesso SSH ao Kali, caso você use o método recomendado com túnel SSH.

---

## 🛠️ Passo a Passo de Instalação e Configuração

### Sequência validada em laboratório
Os comandos abaixo representam a sequência limpa baseada no procedimento executado e validado:
```bash
sudo apt update && sudo apt install kali-desktop-xfce -y
mkdir -p ~/.vnc
echo -e '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec startxfce4 &' > ~/.vnc/xstartup
chmod +x ~/.vnc/xstartup
vncserver :1
```

### 1. Atualizar o Sistema e Instalar o Ambiente Gráfico
Se o seu servidor opera apenas em modo texto (CLI), é obrigatório instalar a interface gráfica antes de prosseguir.
```bash
sudo apt update && sudo apt install kali-desktop-xfce -y
```

### 2. Instalar o Servidor VNC, se necessário
Em algumas instalações do Kali, o comando `vncserver` já pode estar disponível. Caso ele não exista, instale o TigerVNC:
```bash
sudo apt install tigervnc-standalone-server tigervnc-xorg-extension -y
```

### 3. Criar o Arquivo de Inicialização (xstartup)
Este arquivo indica ao VNC que o ambiente gráfico **XFCE** deve ser carregado quando o servidor iniciar.

Crie o diretório de configuração do VNC:
```bash
mkdir -p ~/.vnc
```

Crie o script em uma única linha, para facilitar copiar e colar:
```bash
echo -e '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec startxfce4 &' > ~/.vnc/xstartup
```

Atribua permissão de execução ao script:
```bash
chmod +x ~/.vnc/xstartup
```

### 4. Iniciar o Servidor VNC
Inicie o serviço definindo um identificador de display (ex: `:1` para a porta base 5901):
```bash
vncserver :1
```
O display `:1` usa a porta base `5901`.

Na primeira execução, o VNC pode solicitar a criação da senha de acesso. Caso apareça a pergunta `Would you like to enter a view-only password (y/n)?`, digite **`n`**.

> Se quiser definir ou trocar a senha manualmente antes de iniciar o servidor, execute:
> ```bash
> vncpasswd
> ```

---

## 🖥️ Como Conectar ao Servidor

### Opção recomendada: conexão via túnel SSH
Se quiser evitar expor a porta VNC diretamente na rede, inicie o servidor escutando apenas em `localhost`:
```bash
vncserver :1 -localhost yes -geometry 1280x720
```

No computador cliente, crie um túnel SSH para a porta VNC:
```bash
ssh -L 5901:localhost:5901 usuario@IP_DO_KALI
```

Depois, abra um cliente VNC, como RealVNC Viewer ou TigerVNC Viewer, e conecte em:
```text
localhost:5901
```

Insira a senha criada na primeira execução do `vncserver` ou definida manualmente com `vncpasswd`.

### Opção para laboratório isolado: conexão direta pela rede
Se você estiver em uma VM ou rede isolada e quiser permitir conexão direta ao IP do Kali, inicie o servidor com:
```bash
vncserver :1 -localhost no -geometry 1280x720
```

No cliente VNC, conecte usando:
```text
IP_DO_KALI:5901
```

Evite usar essa opção em redes compartilhadas, corporativas ou expostas à internet.

---

## 🔍 Gerenciamento e Solução de Problemas

### Como derrubar/parar a sessão atual
Caso precise reiniciar o servidor ou fechar a sessão ativa, execute:
```bash
vncserver -kill :1
```

### Erro: Session startup... cleanly exited too early
Se o serviço fechar em menos de 3 segundos após o comando de início:
1. Verifique se o arquivo `~/.vnc/xstartup` possui a permissão de execução (`chmod +x`).
2. Confirme se o ambiente gráfico `kali-desktop-xfce` foi completamente instalado.
3. Confira o log da sessão:
   ```bash
   ls -la ~/.vnc/
   ```
4. Delete arquivos temporários de travas caso o servidor tenha caído incorretamente:
   ```bash
   sudo rm -f /tmp/.X1-lock /tmp/.X11-unix/X1
   ```

### Verificar portas em execução
Para validar se o TigerVNC está escutando na porta correta:
```bash
ss -tulpn | grep 5901
```

### Listar sessões VNC ativas
Para ver as sessões em execução:
```bash
vncserver -list
```
