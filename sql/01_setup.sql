-- =============================================================
-- 01_setup.sql
-- Projeto: Custo de Combustível de Frota (dados públicos da ANP)
-- Objetivo: criar o banco do projeto, um usuário com acesso
--           restrito e habilitar a importação de CSV.
-- Executar como: root
-- =============================================================

-- 1) Banco de dados do projeto
--    utf8mb4 = suporta todos os acentos do português
CREATE DATABASE IF NOT EXISTS diesel_anp
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

-- 2) Usuário do projeto (princípio do menor privilégio)
--    ATENÇÃO: a senha real é digitada só no terminal.
--    Este arquivo é público e mantém apenas o texto de exemplo.
CREATE USER IF NOT EXISTS 'analista_diesel'@'localhost'
  IDENTIFIED BY 'SUA_SENHA_AQUI';

--    Acesso total, mas SOMENTE ao banco diesel_anp
GRANT ALL PRIVILEGES ON diesel_anp.* TO 'analista_diesel'@'localhost';

-- 3) Habilita a importação de arquivos locais
--    (desativada por padrão no MySQL 8.4 por segurança).
--    Vale até o MySQL ser reiniciado.
SET GLOBAL local_infile = 1;

-- 4) Conferências
SHOW GRANTS FOR 'analista_diesel'@'localhost';
SHOW VARIABLES LIKE 'local_infile';