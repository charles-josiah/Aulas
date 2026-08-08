-- comandos-dba.sql
-- Comandos SQL executados pelo DBA durante o cenário "backup remoto via rede"
-- Este arquivo é executado manualmente no terminal 2 do kali enquanto
-- o tcpdump captura no terminal 1.
-- Cada comando abaixo gera tráfego que será capturado e, depois,
-- extraído do dump via tshark.

-- ============================================================
-- 1. Login como DBA (a senha aparece no payload do COM_QUERY? Não,
--    porque o handshake MySQL usa challenge-response com hash.
--    Mas outros comandos abaixo SIM vão em plaintext!)
-- ============================================================
-- (Executado manualmente: mysql -h IP_SERVIDOR -u dba_user -p)

-- ============================================================
-- 2. Comandos DDL (Data Definition Language)
-- ============================================================

-- Criar novo banco
CREATE DATABASE IF NOT EXISTS novo_sistema;

-- Usar o banco novo
USE novo_sistema;

-- Criar tabela de pedidos
CREATE TABLE pedidos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  cliente_id INT NOT NULL,
  produto VARCHAR(100) NOT NULL,
  valor DECIMAL(10,2) NOT NULL,
  data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (cliente_id) REFERENCES app_db.clientes(id)
);

-- ============================================================
-- 3. Comandos DCL (Data Control Language) - PERMISSIONAMENTO
-- ============================================================

-- Criar novo usuário para um sistema de relatórios
CREATE USER IF NOT EXISTS 'reports_user'@'%'
  IDENTIFIED WITH mysql_native_password BY 'reports_2024_secret';

-- Conceder acesso ao banco app_db
GRANT SELECT ON app_db.clientes TO 'reports_user'@'%';

-- Conceder acesso ao novo banco (acesso excessivo - didático!)
GRANT ALL PRIVILEGES ON novo_sistema.* TO 'reports_user'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;

-- ============================================================
-- 4. Comandos DML (Data Manipulation Language) - DADOS
-- ============================================================

-- Voltar para app_db
USE app_db;

-- Inserir novos clientes (dados sensíveis!)
INSERT INTO clientes (nome, cpf, email, senha_hash) VALUES
  ('Roberto Lima',     '111.222.333-44', 'roberto.lima@exemplo.com', SHA2('senha_roberto_2024', 256)),
  ('Fernanda Souza',   '555.666.777-88', 'fernanda.souza@exemplo.com', SHA2('senha_fernanda_2024', 256));

-- Consultar dados (SELECT)
SELECT id, nome, cpf, email FROM clientes;

-- Atualizar dados
UPDATE clientes SET email = 'maria.silva.novo@exemplo.com' WHERE cpf = '123.456.789-00';

-- ============================================================
-- 5. Comandos de ADMINISTRAÇÃO (visíveis no dump)
-- ============================================================

-- Ver permissões do reports_user
SHOW GRANTS FOR 'reports_user'@'%';

-- ============================================================
-- 6. Logout
-- ============================================================
EXIT;