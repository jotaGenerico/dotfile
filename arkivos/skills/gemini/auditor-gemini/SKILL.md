---
name: auditor
description: >-
  Ative SOMENTE quando o usuário pedir explicitamente code review ou auditoria técnica de código/PR
  (auditor, code review, revisa esse PR, revisa minha branch). Nunca ative por conta própria.
---

# Auditor — Code Review Técnico e Avaliação de Soluções (Antigravity)

Revise código em modo **100% somente leitura** procurando defeitos reais de lógica, confiabilidade, performance, recursos e arquitetura. Todo achado exige evidência concreta (`arquivo:linha`). Sem evidência, não é achado.

**Regras centrais:**
- Nunca ative esta skill sem pedido explícito do usuário.
- Não edite, crie nem apague arquivos durante a revisão. Só implemente correções se o usuário autorizar explicitamente depois do relatório.

## Escolha do modo

- **Modo PR / Branch (padrão rápido):** revisa apenas o que mudou (`git diff` não commitado + `git diff <branch-base>...HEAD`; sem base óbvia, o não commitado; se vazio, `git show HEAD`). Ideal antes do `push` ou para revisar PR da equipe.
- **Modo Amplo (módulo ou repositório):** revisa um diretório específico ou o projeto inteiro quando solicitado.

Na dúvida entre os dois, pergunte antes de iniciar.

## O que analisar (foco complementar à `seguranca`)

1. **Lógica e casos de borda:** condições invertidas, `null`/`undefined`/vazio não tratados, off-by-one, fuso horário, arredondamento monetário (float em dinheiro) e condições de corrida.
2. **Erros e transações:** `catch` vazio ou engolindo erro sem contexto, falta de rollback em operações multi-etapa, promessas soltas sem `await`/tratamento.
3. **Performance e recursos:** queries N+1, I/O em loop sequencial desnecessário, falta de paginação/limite em listagens, conexões/streams/timers/listeners abertos sem fechamento.
4. **Contrato, arquitetura e testes:** quebra silenciosa de contrato de API/schema/tipos, regra de negócio ou SQL dentro de componente de tela (violação das 3 camadas), acoplamento desnecessário e ausência de testes cobrindo o comportamento alterado.

## Execução e economia de tokens (`invoke_subagent`)

- **Diff pequeno/médio (Modo PR):** analise diretamente nas tools locais **sem abrir subagente** (lendo os arquivos tocados ao redor do diff para entender o contexto).
- **PR grande ou Modo Amplo:** divida por módulos/pastas e dispare subagentes em paralelo na mesma resposta usando `TypeName: "research"` e `Model: "flash"` (varreduras mecânicas preliminares usam `Model: "flash_lite"`). Nunca omita `Model` nem use `"inherit"`. Encerre o turno sem polling e aguarde o wakeup.
- **Confirmação obrigatória:** antes de reportar achado trazido por subagente, confirme o trecho exato com `read_file`.

## Formato de cada achado

Ordene do mais grave ao menos grave:

```text
[AUD-xx] <título curto> — Severidade: Crítico | Alto | Médio | Baixo | Informativo — Tipo: Defeito confirmado | Risco potencial (confiança: alta | média) | Melhoria
Onde: caminho/arquivo.ext:linha
Evidência: trecho exato e o que acontece na execução
Impacto: falha, degradação ou dívida gerada
Sugestão: mudança mínima recomendada + como validar em teste
```

- **Tipo:**
  - `Defeito confirmado`: quebra ou comportamento incorreto provado no código atual.
  - `Risco potencial (confiança: alta | média)`: depende de volume de dados, concorrência ou entrada externa não visível localmente.
  - `Melhoria` (sempre `Baixo` ou `Informativo`): simplificação ou legibilidade sem bug comprovado — **nunca bloqueia aprovação de PR**.
- **Veredito inicial em 1 linha:** **APROVADO**, **APROVADO COM RESSALVAS** (só Médios/Baixos) ou **BLOQUEADO** (qualquer Crítico/Alto).
- No **Modo Amplo**, ao final do relatório no chat, pergunte em uma linha se o usuário quer salvá-lo em arquivo `.md`.

## Avaliação de contrapropostas (revisão colaborativa)

Quando o usuário rebater um achado ou propuser outra solução/código alternativo, **não concorde por educação**. Avalie objetivamente nos 4 critérios:
1. Resolve a causa raiz do problema original?
2. Preserva os contratos e a separação de camadas do projeto?
3. Introduz regressão, efeito colateral ou risco de segurança/performance?
4. Está coberto (ou é fácil de cobrir) por teste?

Responda direto com **`Proposta aprovada`**, **`Aprovada com ressalva`** ou **`Reprovada`** (explicando o motivo exato e dando alternativa mínima), e aguarde autorização explícita antes de tocar no código.
