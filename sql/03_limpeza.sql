-- =============================================================
-- 03_limpeza.sql
-- Objetivo: criar a tabela final com apenas o diesel, tipos de
--           dados corretos e colunas derivadas para a análise.
-- Origem: stg_precos (script 02) | Executar como: analista_diesel
-- =============================================================

USE diesel_anp;

-- 1) Tabela final, com os tipos corretos
DROP TABLE IF EXISTS precos_diesel;

CREATE TABLE precos_diesel (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  regiao_sigla    VARCHAR(2)    NOT NULL,
  estado_sigla    CHAR(2)       NOT NULL,
  municipio       VARCHAR(100)  NOT NULL,
  revenda         VARCHAR(255),
  cnpj_revenda    VARCHAR(20),
  bandeira        VARCHAR(100),
  tipo_bandeira   VARCHAR(20)   NOT NULL,  -- BANDEIRA BRANCA ou MARCA
  tipo_diesel     VARCHAR(4)    NOT NULL,  -- S10 ou S500
  data_coleta     DATE          NOT NULL,
  valor_venda     DECIMAL(6,3)  NOT NULL,  -- R$ por litro
  arquivo_origem  VARCHAR(20)   NOT NULL
);

-- 2) Cópia da staging para a tabela final, já convertendo e filtrando
INSERT INTO precos_diesel (
  regiao_sigla, estado_sigla, municipio, revenda, cnpj_revenda,
  bandeira, tipo_bandeira, tipo_diesel, data_coleta, valor_venda,
  arquivo_origem
)
SELECT
  TRIM(regiao_sigla),
  TRIM(estado_sigla),
  TRIM(municipio),
  TRIM(revenda),
  TRIM(cnpj_revenda),
  TRIM(bandeira),
  -- Classificação para a pergunta 3
  CASE WHEN TRIM(bandeira) = 'BRANCA' THEN 'BANDEIRA BRANCA'
       ELSE 'MARCA'
  END,
  -- Os dois tipos de diesel são analisados separadamente
  CASE TRIM(produto)
       WHEN 'DIESEL S10' THEN 'S10'
       WHEN 'DIESEL'     THEN 'S500'
  END,
  -- Texto dd/mm/aaaa -> DATE
  STR_TO_DATE(TRIM(data_coleta), '%d/%m/%Y'),
  -- Texto '6,29' -> número 6.290
  CAST(REPLACE(TRIM(valor_venda), ',', '.') AS DECIMAL(6,3)),
  arquivo_origem
FROM stg_precos
WHERE TRIM(produto) IN ('DIESEL', 'DIESEL S10');

-- =============================================================
-- 3) VALIDAÇÃO DA LIMPEZA
-- =============================================================

-- 3.1) Contagem por tipo. Esperado: S10 = 145.525 | S500 = 86.012
SELECT tipo_diesel, COUNT(*) AS registros
FROM precos_diesel
GROUP BY tipo_diesel;

-- 3.2) Período coberto. Esperado: julho/2025 a junho/2026
SELECT MIN(data_coleta) AS primeira_coleta,
       MAX(data_coleta) AS ultima_coleta
FROM precos_diesel;

-- 3.3) Faixa de preço por tipo (procura valores absurdos, como 0 ou 60)
SELECT tipo_diesel,
       MIN(valor_venda) AS menor_preco,
       MAX(valor_venda) AS maior_preco,
       ROUND(AVG(valor_venda), 3) AS preco_medio
FROM precos_diesel
GROUP BY tipo_diesel;

-- 3.4) Distribuição por tipo de bandeira
SELECT tipo_bandeira, COUNT(*) AS registros
FROM precos_diesel
GROUP BY tipo_bandeira;