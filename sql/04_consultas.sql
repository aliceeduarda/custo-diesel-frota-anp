-- =============================================================
-- 04_consultas.sql
-- Objetivo: responder às 4 perguntas de negócio do projeto.
-- Foco: diesel S10 (frota moderna). S500 entra como comparação.
-- Origem: precos_diesel (script 03) | Executar como: analista_diesel
-- =============================================================

USE diesel_anp;

-- =============================================================
-- 0) CHECAGEM DE VALORES EXTREMOS (antes de qualquer conclusão)
--    O máximo do S10 (R$ 9,99) está muito acima da média.
--    Onde estão os preços mais altos? Se forem casos isolados e
--    plausíveis (ex.: regiões remotas), mantemos.
-- =============================================================
SELECT estado_sigla, municipio, revenda, data_coleta, valor_venda
FROM precos_diesel
WHERE tipo_diesel = 'S10'
ORDER BY valor_venda DESC
LIMIT 10;

-- =============================================================
-- PERGUNTA 1: Em quais estados o diesel é mais barato e mais caro?
--    Preço médio do S10 por estado e diferença % em relação à
--    média nacional. Ordem: do mais barato ao mais caro.
-- =============================================================
WITH media_nacional AS (
  SELECT AVG(valor_venda) AS media
  FROM precos_diesel
  WHERE tipo_diesel = 'S10'
)
SELECT
  p.estado_sigla,
  ROUND(AVG(p.valor_venda), 3)                     AS preco_medio,
  ROUND((AVG(p.valor_venda) / m.media - 1) * 100, 1) AS dif_media_nacional_pct,
  COUNT(*)                                         AS coletas
FROM precos_diesel p
CROSS JOIN media_nacional m   -- "cola" a média nacional em cada linha
WHERE p.tipo_diesel = 'S10'
GROUP BY p.estado_sigla, m.media
ORDER BY preco_medio;

-- =============================================================
-- PERGUNTA 2: Como o preço variou mês a mês?
--    Preço médio mensal do S10 e variação % sobre o mês anterior.
-- =============================================================
WITH mensal AS (
  SELECT
    DATE_FORMAT(data_coleta, '%Y-%m') AS mes,   -- ex.: 2025-07
    AVG(valor_venda)                  AS preco_medio
  FROM precos_diesel
  WHERE tipo_diesel = 'S10'
  GROUP BY mes
)
SELECT
  mes,
  ROUND(preco_medio, 3) AS preco_medio,
  -- LAG() traz o preço do mês anterior para a mesma linha
  ROUND((preco_medio / LAG(preco_medio) OVER (ORDER BY mes) - 1) * 100, 2)
                        AS variacao_mes_anterior_pct
FROM mensal
ORDER BY mes;

-- =============================================================
-- PERGUNTA 3: Postos de marca vs. bandeira branca
--    3a) Brasil, por tipo de diesel
--    Positivo = marca mais cara que bandeira branca.
-- =============================================================
SELECT
  tipo_diesel,
  ROUND(AVG(CASE WHEN tipo_bandeira = 'MARCA' THEN valor_venda END), 3)
    AS media_marca,
  ROUND(AVG(CASE WHEN tipo_bandeira = 'BANDEIRA BRANCA' THEN valor_venda END), 3)
    AS media_bandeira_branca,
  ROUND((AVG(CASE WHEN tipo_bandeira = 'MARCA' THEN valor_venda END)
       / AVG(CASE WHEN tipo_bandeira = 'BANDEIRA BRANCA' THEN valor_venda END) - 1) * 100, 2)
    AS marca_vs_branca_pct
FROM precos_diesel
GROUP BY tipo_diesel;

--    3b) Mesma comparação só no RJ (controle: evita que a diferença
--        seja causada pela distribuição dos postos entre estados)
SELECT
  tipo_diesel,
  ROUND(AVG(CASE WHEN tipo_bandeira = 'MARCA' THEN valor_venda END), 3)
    AS media_marca,
  ROUND(AVG(CASE WHEN tipo_bandeira = 'BANDEIRA BRANCA' THEN valor_venda END), 3)
    AS media_bandeira_branca,
  ROUND((AVG(CASE WHEN tipo_bandeira = 'MARCA' THEN valor_venda END)
       / AVG(CASE WHEN tipo_bandeira = 'BANDEIRA BRANCA' THEN valor_venda END) - 1) * 100, 2)
    AS marca_vs_branca_pct
FROM precos_diesel
WHERE estado_sigla = 'RJ'
GROUP BY tipo_diesel;

-- =============================================================
-- PERGUNTA 4: No RJ, quais municípios têm o menor preço médio?
--    Top 10 do S10. Só entram municípios com pelo menos 30 coletas,
--    para evitar conclusões baseadas em poucas observações.
-- =============================================================
SELECT
  municipio,
  ROUND(AVG(valor_venda), 3)   AS preco_medio,
  COUNT(*)                     AS coletas,
  COUNT(DISTINCT cnpj_revenda) AS postos_pesquisados
FROM precos_diesel
WHERE tipo_diesel = 'S10'
  AND estado_sigla = 'RJ'
GROUP BY municipio
HAVING COUNT(*) >= 30
ORDER BY preco_medio
LIMIT 10;

