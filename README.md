# ⛽ Custo de Combustível de Frota — Onde e quando abastecer diesel mais barato?

> 🚧 **Status:** em desenvolvimento (previsão de conclusão: 28/10/2026)

## 📌 Problema de negócio

Para transportadoras rodoviárias, o diesel é um dos principais custos variáveis
da operação: cada centavo a mais por litro se multiplica pelo volume consumido
por toda a frota ao longo do mês.

Como o preço do diesel varia entre estados, municípios, tipos de posto e ao
longo do tempo, saber **onde e quando abastecer** pode gerar economia relevante
no planejamento de rotas e de paradas.

Este projeto usa dados públicos da ANP para responder: **em que lugar e em que
período o diesel é mais barato no Brasil?**


## ❓ Perguntas de negócio

1. Em quais estados o diesel é mais barato e mais caro?
2. Como o preço variou mês a mês?
3. Existe diferença relevante entre postos de bandeira (marca) e bandeira branca?
4. No estado do Rio de Janeiro, quais municípios têm o menor preço médio?

## 💡 Principais descobertas (diesel S10, jul/2025 a jun/2026)

> Comparações regionais feitas em relação à média **do mesmo mês**, para
> não distorcer os resultados com a forte alta de março/2026.

1. **Estados:** Pernambuco tem o diesel mais barato do país, **4,1% abaixo da
   média nacional**. O Acre é o mais caro, **22,0% acima** — cerca de 27% mais
   caro que Pernambuco. A região Norte concentra os preços mais altos
   (Acre, Roraima +9,7% e Amazonas +9,2%). O RJ fica na média (+0,4%).

2. **Evolução mensal:** o preço ficou estável entre jul/2025 e fev/2026
   (R$ 6,10 a R$ 6,16), saltou **15,1% em março/2026** e atingiu o pico em
   abril (R$ 7,47). No período completo, a alta foi de **16,7%**. O salto
   coincide com o reajuste da Petrobras de 14/03/2026, anunciado em meio
   à alta internacional do petróleo
   ([fonte](https://eixos.com.br/combustiveis-e-bioenergia/petrobras-anuncia-aumento-de-r-038-sobre-o-diesel-a-nas-refinarias-a-partir-de-sabado/)).

3. **Bandeiras:** postos de marca são mais caros em todos os recortes, mas a
   diferença é pequena: **+1,66% no Brasil** (R$ 0,11/L) e **+0,49% no RJ**.
   Em escala, porém, ela pesa: uma frota hipotética de 20.000 L/mês pagaria
   cerca de **R$ 2.140 a mais por mês** abastecendo só em postos de marca.

4. **Municípios do RJ:** **Belford Roxo (−3,5%)** e **Niterói (−3,4%)**
   estão tecnicamente empatados como os mais baratos do estado, seguidos de
   Três Rios (−3,1%). A capital aparece em 10º (−1,2%).

## 🧪 Decisões de análise e limitações

| Decisão | Justificativa |
|---|---|
| S10 e S500 analisados separadamente | São produtos com preços diferentes; misturá-los distorceria as médias |
| Foco no S10 | É o diesel da frota moderna de caminhões |
| Coluna "Valor de Compra" descartada | 0 de 231.537 registros de diesel estavam preenchidos |
| Comparações regionais pela média do mesmo mês | Evita que diferenças no período das coletas distorçam os rankings |
| Mínimo de 30 coletas por município | Evita conclusões baseadas em poucas observações |
| Preços de R$ 9,99 em Ourinhos (SP) mantidos | Investigados: 2 postos com preço alto e estável o ano todo (padrão real, não erro). São 15 registros, sem impacto nas médias |
| Carga validada | Os 806.626 registros dos CSVs foram conferidos com contagem no banco |

## 🗂️ Fonte dos dados

- **Série Histórica de Preços de Combustíveis — ANP**
  (Agência Nacional do Petróleo, Gás Natural e Biocombustíveis)
- Página oficial: https://www.gov.br/anp/pt-br/centrais-de-conteudo/dados-abertos/serie-historica-de-precos-de-combustiveis
- Dicionário de dados (metadados): https://www.gov.br/anp/pt-br/centrais-de-conteudo/dados-abertos/arquivos/shpc/metadados-serie-historica-precos-combustiveis-1.pdf
- Período analisado: 2º semestre de 2025 e 1º semestre de 2026
- Produto analisado: óleo diesel

### Visão geral dos arquivos brutos

| Arquivo | Registros | Colunas | Separador |
|---|---|---|---|
| `ca-2025-02.csv` | 384.208 | 16 | `;` |
| `ca-2026-01.csv` | 422.418 | 16 | `;` |
| **Total** | **806.626** | | |

> Os arquivos incluem todos os combustíveis automotivos. O filtro para diesel é
> aplicado na etapa de SQL.

## 🛠️ Ferramentas

| Etapa | Ferramenta |
|---|---|
| Armazenamento e consultas | MySQL 8.4 (via Laragon) |
| Tratamento e modelagem | Power BI — Power Query |
| Medidas e visualização | Power BI — DAX |
| Versionamento | Git e GitHub |

## 📁 Estrutura do repositório

| Pasta | Conteúdo |
|---|---|
| `dados/brutos/` | CSVs e metadados da ANP (não versionados — ver "Como reproduzir") |
| `sql/` | Consultas comentadas |
| `powerbi/` | Arquivo do dashboard |
| `imagens/` | Prints e GIF |

## ▶️ Como reproduzir

1. Baixe os arquivos do **2º semestre de 2025** e do **1º semestre de 2026**
   (Combustíveis automotivos) na página oficial da ANP, acima.
2. Extraia os CSVs em `dados/brutos/` e renomeie para `ca-2025-02.csv` e `ca-2026-01.csv`.
3. Inicie o MySQL e execute, nesta ordem:
   - `sql/01_setup.sql` como **root** (troque `SUA_SENHA_AQUI` pela senha desejada)
   - Conecte com `mysql --local-infile=1 -u analista_diesel -p diesel_anp`
   - `sql/02_staging_carga.sql` (carga e validação dos CSVs)
   - `sql/03_limpeza.sql` (tabela final do diesel)
   - `sql/04_consultas.sql` (respostas às perguntas de negócio)
4. *(etapa do Power BI será adicionada em seguida)*

## 👩‍💻 Autora

**Alice Eduarda** — Estudante de Análise e Desenvolvimento de Sistemas (UNISUAM)
[LinkedIn](https://www.linkedin.com/in/aliceeduarda-mth) · [GitHub](https://github.com/aliceeduarda)