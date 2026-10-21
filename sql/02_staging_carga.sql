-- =============================================================
-- 02_staging_carga.sql
-- Objetivo: carregar os CSVs brutos da ANP em uma tabela de
--           staging (tudo como texto) e validar a carga.
-- Executar como: analista_diesel
-- =============================================================

USE diesel_anp;

-- 1) Tabela de staging: espelho do CSV, todas as colunas como texto.
--    A conversão de tipos acontece depois, no script 03.
DROP TABLE IF EXISTS stg_precos;

CREATE TABLE stg_precos (
  regiao_sigla    VARCHAR(255),
  estado_sigla    VARCHAR(255),
  municipio       VARCHAR(255),
  revenda         VARCHAR(255),
  cnpj_revenda    VARCHAR(255),
  nome_rua        VARCHAR(255),
  numero_rua      VARCHAR(255),
  complemento     VARCHAR(255),
  bairro          VARCHAR(255),
  cep             VARCHAR(255),
  produto         VARCHAR(255),
  data_coleta     VARCHAR(255),
  valor_venda     VARCHAR(255),
  valor_compra    VARCHAR(255),
  unidade_medida  VARCHAR(255),
  bandeira        VARCHAR(255),
  arquivo_origem  VARCHAR(20)    -- rastreabilidade: de qual CSV veio a linha
);

-- 2) Carga do 2º semestre de 2025
LOAD DATA LOCAL INFILE 'C:/Users/alice/projetos/custo-diesel-frota-anp/dados/brutos/ca-2025-02.csv'
INTO TABLE stg_precos
CHARACTER SET utf8mb4                          
FIELDS TERMINATED BY ';' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'                     
IGNORE 1 LINES
(regiao_sigla, estado_sigla, municipio, revenda, cnpj_revenda,
 nome_rua, numero_rua, complemento, bairro, cep, produto,
 data_coleta, valor_venda, valor_compra, unidade_medida, bandeira)
SET arquivo_origem = 'ca-2025-02';

-- 3) Carga do 1º semestre de 2026 (mesmas opções)
LOAD DATA LOCAL INFILE 'C:/Users/alice/projetos/custo-diesel-frota-anp/dados/brutos/ca-2026-01.csv'
INTO TABLE stg_precos
CHARACTER SET utf8mb4                          
FIELDS TERMINATED BY ';' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'                     
IGNORE 1 LINES
(regiao_sigla, estado_sigla, municipio, revenda, cnpj_revenda,
 nome_rua, numero_rua, complemento, bairro, cep, produto,
 data_coleta, valor_venda, valor_compra, unidade_medida, bandeira)
SET arquivo_origem = 'ca-2026-01';

-- =============================================================
-- 4) VALIDAÇÃO DA CARGA
-- =============================================================

-- 4.1) Contagem por arquivo. Esperado (contado com wc -l):
--      ca-2025-02 = 384.208 | ca-2026-01 = 422.418 | total = 806.626
SELECT arquivo_origem, COUNT(*) AS registros
FROM stg_precos
GROUP BY arquivo_origem;

-- 4.2) Quais produtos existem? (identifica os tipos de diesel)
SELECT produto, COUNT(*) AS registros
FROM stg_precos
GROUP BY produto
ORDER BY registros DESC;

-- 4.3) Teste de acentuação: deve aparecer NITERÓI (com Ó correto)
SELECT DISTINCT municipio
FROM stg_precos
WHERE estado_sigla = 'RJ' AND municipio LIKE 'NIT%';

-- 4.4) Teste de fim de linha: a última coluna não pode ter
--      caracteres "invisíveis". Compare as duas medidas.
SELECT bandeira,
       LENGTH(bandeira)       AS tamanho,
       LENGTH(TRIM(bandeira)) AS tamanho_sem_espacos
FROM stg_precos
LIMIT 5;