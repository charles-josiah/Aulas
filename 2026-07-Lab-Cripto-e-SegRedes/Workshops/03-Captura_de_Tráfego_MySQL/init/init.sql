-- init.sql
-- Script de inicializacao do MySQL para o Workshop 03
-- Cria banco app_db, tabela clientes, dados de exemplo e usuarios
-- Execute automaticamente na primeira inicializacao do container MySQL

-- ============================================================
-- 1. Banco de dados
-- ============================================================
CREATE DATABASE IF NOT EXISTS app_db
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE app_db;

-- ============================================================
-- 2. Tabela clientes (dados sensiveis - didatico!)
-- ============================================================
CREATE TABLE IF NOT EXISTS clientes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  cpf VARCHAR(14) NOT NULL UNIQUE,
  email VARCHAR(120) NOT NULL,
  senha_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 3. Dados de exemplo (CPFs e e-mails ficticios)
-- ============================================================
INSERT INTO clientes (nome, cpf, email, senha_hash) VALUES
  ('Maria Silva',      '123.456.789-00', 'maria.silva@exemplo.com',   SHA2('senha_maria_2024', 256)),
  ('Joao Santos',      '987.654.321-00', 'joao.santos@exemplo.com',   SHA2('senha_joao_2024', 256)),
  ('Ana Oliveira',     '456.789.123-00', 'ana.oliveira@exemplo.com',  SHA2('senha_ana_2024', 256)),
  ('Pedro Costa',      '789.123.456-00', 'pedro.costa@exemplo.com',   SHA2('senha_pedro_2024', 256)),
  ('Carla Rodrigues',  '321.654.987-00', 'carla.rodrigues@exemplo.com', SHA2('senha_carla_2024', 256));

-- ============================================================
-- 4. Usuarios e permissoes
-- ============================================================

-- Usuario administrador do banco (DBA) - super-usuario
CREATE USER IF NOT EXISTS 'dba_user'@'%' IDENTIFIED WITH mysql_native_password BY 'dba_secret_2024';
GRANT ALL PRIVILEGES ON *.* TO 'dba_user'@'%' WITH GRANT OPTION;

-- Usuario da aplicacao - GRANT limitado (sera capturado no dump)
CREATE USER IF NOT EXISTS 'app_user'@'%' IDENTIFIED WITH mysql_native_password BY 'app_secret_2024';
GRANT SELECT, INSERT, UPDATE ON app_db.clientes TO 'app_user'@'%';

-- Usuario de relatorios - GRANT apenas leitura
CREATE USER IF NOT EXISTS 'rel_user'@'%' IDENTIFIED WITH mysql_native_password BY 'rel_secret_2024';
GRANT SELECT ON app_db.clientes TO 'rel_user'@'%';

FLUSH PRIVILEGES;