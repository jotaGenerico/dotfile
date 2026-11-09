---
name: auditor
description: >-
  Use quando o usuário pedir code review, revisão de PR, revisão de branch antes do push ou revisão de código de colega.
  Não use para auditoria de segurança (use seguranca) nem para spec/planejamento (use sdd2).
---

# Auditor — Code Review técnico

Review focado em bugs que escapam ao compilador e ao linter: lógica errada, borda não tratada, N+1 de queries, `catch` vazio engolindo erro, vazamento de conexão/memória e quebra silenciosa de contrato.

**Regra:** relatório primeiro. Só corrige com autorização explícita do usuário.

## Escopo

Analisa o diff (padrão: `git diff <branch-base>...HEAD`; pergunte a base se não for óbvia) ou os arquivos indicados. Não substitui:
- **seguranca**: vulnerabilidades de segurança
- **sdd2**: planejamento e spec
- **tdd**: escrita de testes

## Fluxo

1. Obtenha o diff ou os arquivos a revisar.
2. Analise em busca de:
   - **Bug de lógica**: condição errada, cálculo incorreto, estado inválido possível.
   - **Borda não tratada**: zero, nil/null, lista vazia, string vazia, valor negativo, concorrência.
   - **N+1 de queries**: loop que dispara query por iteração sem batch.
   - **Catch/except vazio ou genérico**: erro engolido sem log nem re-throw que mascara falha real.
   - **Vazamento de recurso**: conexão, file handle ou stream aberto sem fechar em todos os caminhos, inclusive em erro.
   - **Quebra de contrato**: retorno, tipo ou comportamento que viola o que chamadores esperam (interface, schema, evento).
3. Avalie contrapropostas do usuário: verifique se resolve o problema original, se introduz regressão ou furo de segurança e se tem efeitos colaterais — não aceite só porque veio do usuário.
4. Para cada achado, confirme no arquivo:linha antes de reportar. Sem evidência, não é achado.
5. Apresente o relatório. Aguarde autorização para qualquer correção.

## Formato de cada achado

```
[REV-xx] <título> — Severidade: Alta | Média | Baixa — Tipo: confirmado | potencial | melhoria
Onde: caminho/arquivo.ext:linha
Evidência: trecho relevante
Problema: o que pode dar errado e em que cenário
Sugestão: mudança mínima
```

Severidade: **Alta** = bug que causa dado errado, perda ou falha silenciosa em produção. **Média** = comportamento incorreto em borda ou degradação real. **Baixa** = fragilidade ou dívida sem impacto imediato.

Tipo: **confirmado** = código prova o problema. **potencial** = depende de contexto externo não visível no diff. **melhoria** = não é defeito mas reduz risco futuro.

## Relatório

1. Resumo em uma linha: **limpo** ou **N achados (X altos, Y médios, Z baixos)**.
2. Achados no formato acima, mais severos primeiro.
3. O que ficou fora do escopo e por quê.

Sem achados reais, responda "Limpo". Não invente problemas.
