## 🏠 Instalação e Configuração do MySQL

### Instalação
```bash
sudo apt update
sudo apt install -y mysql-server mysql-client

# iniciar/checar status
sudo systemctl enable --now mysql
sudo systemctl status mysql
```

Verifique a versão:
```bash
mysql --version
sudo mysql -e "SELECT VERSION();" 
```

### Ajustar bind-address — permitir conexões remotas
Edite o arquivo de configuração do servidor MySQL/MariaDB:

```bash
sudo sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql
```

### (Atenção) Desligar require_secure_transport — APENAS EM LAB

Desligar TLS permite conexões em texto claro. Nunca faça isso em produção. 

No arquivo de configuração (/etc/mysql/mysql.conf.d/mysqld.cnf ou /etc/my.cnf):
```bash
[mysqld]
require_secure_transport = OFF
```

Apos realizar a alteração reinicie o serviço:
```bash
sudo systemctl restart mysql 
```

##  Criar usuario remoto (sem exigir SSL) e conceder privilégios

Conecte no servidor localmente:
```bash
sudo mysql -u root
```

Dentro do prompt SQL:
```sql

-- cria usuário que pode conectar de qualquer host:
CREATE USER 'appuser'@'%' IDENTIFIED BY 'SenhaForte123';

-- conceder privilégios (ex.: só acesso ao schema `minhadb`)
GRANT SELECT, INSERT, UPDATE, DELETE ON minhadb.* TO 'appuser'@'%';

FLUSH PRIVILEGES;

```

## Ver permissões / permissionamento

```sql

-- ver privilégios do usuário atual:
SHOW GRANTS FOR CURRENT_USER();
-- ou para um usuário específico:
SHOW GRANTS FOR 'appuser'@'%';

-- ver usuários na tabela mysql.user (informações)
SELECT User, Host, plugin, authentication_string, ssl_type FROM mysql.user;

-- ver privilégios globais:
SHOW GRANTS FOR 'root'@'localhost';

-- consultar informações de privilégios por tabela
SELECT * FROM information_schema.SCHEMA_PRIVILEGES WHERE GRANTEE LIKE "%appuser%";
SELECT * FROM mysql.db WHERE User='appuser' AND Host='%';
```
## Conectando ao mysql remotamente para capturar os pacotes.

### Testes básicos de rede

```bash
# se tiver nc:
nc -vz IP_DO_SERVIDOR 3306
# ou telnet
telnet IP_DO_SERVIDOR 3306
```

### Conectar com o cliente mysql (exemplo):

```bash
# se tiver nc:
mysql -h <ip_do_servidor_mysql> -P 3306 -u appuser -p --ssl=0
```


```sql
SELECT USER(), CURRENT_USER();

-- USER() = string usada ao logar;
-- CURRENT_USER() = a conta efetivamente autenticada ('appuser'@'host') — útil para saber qual entrada alterar.


-- mostra os privilégios do usuário com o qual você está conectado
SHOW GRANTS FOR CURRENT_USER();

-- executar alguns show, capturar e validar no wireshark.
-- troca da senha do usuario, lembrar de sniffar neste momento.
ALTER USER CURRENT_USER() IDENTIFIED BY 'NovaSenhaForte!2025';

-- ver quais bancos o usuário "vê" (pode variar se SHOW DATABASES foi limitado por privilégios):
SHOW DATABASES;

-- para cada DB que aparecer:
USE nome_do_db;
SHOW TABLES;

```


<h5><center>
Observação: Este é um guia geral de apoio ao estudo, não um manual definitivo. As etapas devem ser adaptadas ao seu ambiente; não copie comandos sem revisão. Como o laboratório envolve captura e análise de pacotes, credenciais e comandos podem ficar expostos — execute apenas em ambiente controlado e isolado (VMs/laboratório) e com autorização por escrito. Nunca realize esses procedimentos em produção ou em redes de terceiros.
</h5></center>

:wq!

