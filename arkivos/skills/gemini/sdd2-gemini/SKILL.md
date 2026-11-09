---
name: sdd2
description: >-
  Ative SOMENTE quando o usuário pedir explicitamente SDD 2.0 (sdd2, sdd-2, EGM, Elephant Goldfish Model)
  ou uma de suas fases (bootstrap, brainstorm, draft, review, drift). Nunca ative por conta própria.
---

# SDD 2.0 — Elephant Goldfish Model (Antigravity)

Desenhe com contexto profundo, revise com contexto zero. O **Elefante** é você nesta sessão: conhece o projeto e a conversa, entrevista o usuário e escreve. Os **Peixinhos** são subagentes novos de contexto zero (`invoke_subagent`), sem o histórico da conversa, que atacam o que foi escrito para evitar autoconfirmação. O **usuário** resolve tradeoffs e aprova.

**Regras centrais:**
- Nunca ative este fluxo sem pedido explícito do usuário (se uma tarefa grande justificar, apenas sugira em uma linha e aguarde).
- Nenhum código de implementação antes de `spec.md` ter `STATUS: APPROVED`. Só o usuário aprova.

## Quando usar

Use em features grandes, refatorações amplas e decisões de arquitetura difíceis de reverter. Não use em bug pontual, ajuste de texto/estilo ou mudança localizada sem impacto em contrato ou dados: avise o usuário e siga sem o fluxo. Na dúvida, pergunte. Se pedirem para avaliar se um projeto se encaixa, responda com esses critérios e uma recomendação direta.

## Escolha da fase

- Com argumento (`bootstrap`, `brainstorm`, `draft`, `review`, `drift`): execute essa fase.
- Sem argumento, deduza pelo estado de `.spec/` e confirme com o usuário:
  - sem `invariants.md` → `bootstrap` (projeto sem código: pule para `brainstorm`)
  - feature sem `brief.md` aprovado → `brainstorm`
  - sem `spec.md` → `draft`
  - `spec.md` com `STATUS: DRAFT` → `review`
  - `STATUS: APPROVED` e implementação feita → `drift`

## Arquivos

```text
.spec/
  invariants.md
  <feature>/          # kebab-case
    brief.md
    spec.md
    review.md
    drift.md
```

Todos os arquivos em `.spec/` em Português do Brasil.

## Peixinhos (`invoke_subagent` com economia de tokens)

- No Antigravity, `invoke_subagent` já cria uma sessão limpa de contexto zero (não herda o chat do Elefante).
- **Tipo e modelo obrigatórios:**
  - Peixinhos de crítica (`brainstorm`, `review`, `drift`): use sempre `TypeName: "research"` (somente leitura por sandbox, menor custo de tools) e `Model: "flash"`.
  - Consolidador de grande volume ou varredura mecânica no `bootstrap`: `TypeName: "research"` e `Model: "flash_lite"`.
  - Nunca omita `Model` nem use `"inherit"`.
- **Execução:** dispare todos os peixinhos da rodada **em paralelo na mesma resposta** e encerre o turno sem polling (aguarde o wakeup automático do sistema).
- **Isolamento:** o `Prompt` leva apenas caminhos absolutos de arquivos, o ângulo e o formato de saída. Nunca resuma a conversa nem sugira a conclusão esperada.

Template de `Prompt` para cada peixinho:

```text
Você revisa uma proposta de software sem nenhum contexto prévio.
Leia apenas: <caminhos absolutos dos arquivos .spec> e o código relevante em <caminhos absolutos>.
Ângulo: <pergunta do ângulo>
Retorne no máximo 8 achados, do mais grave ao menos grave, cada um com:
- Gravidade: CRÍTICO | IMPORTANTE | MENOR
- Onde: seção da spec ou arquivo:linha
- Problema: uma frase
- Sugestão: uma frase
Sem achados reais, responda apenas "Sem achados". Não invente problemas.
```

Ângulos:

1. **Simplicidade e reuso:** existe solução mais simples, ou algo no código que já resolve?
2. **Clareza:** alguém sem contexto implementa isso sem adivinhar regras nem interpretar ambiguidades?
3. **Bordas e falhas:** entradas-limite, erros, estados inválidos, falhas de dependências.
4. **Invariantes:** viola algo em `.spec/invariants.md`?
5. **Domínio:** escolha o risco mais relevante para o projeto (concorrência/escala, segurança, migração de dados, performance, UX etc.).

Consolidação: junte os achados, remova duplicatas, confira no código antes de descartar qualquer um e apresente ao usuário agrupados por gravidade. Se o volume for grande, delegue a consolidação a um subagente (`TypeName: "research"`, `Model: "flash_lite"`).

## Fases

### bootstrap

1. Crie `.spec/` se não existir.
2. Mapeie estrutura, módulos, fluxo de dados, padrões e convenções (leitura direta em repo pequeno; subagente `research` + `"flash_lite"` se o repo for grande).
3. Escreva `.spec/invariants.md`: regras que nunca podem ser quebradas (negócio, segurança, dados, contratos de API), uma linha cada, com onde vivem no código. No fim, uma seção curta de convenções arquiteturais. Nada de documentação geral.
4. Valide com o usuário.

### brainstorm

1. Crie `.spec/<feature>/` se não existir.
2. Entreviste o usuário com poucas perguntas objetivas por vez (pode usar `ask_question` quando houver escolhas fechadas): objetivo, o que entra e o que fica fora, casos de uso, restrições.
3. Escreva `.spec/<feature>/brief.md` (até ~1 página): problema, objetivo, fora de escopo, casos de uso, restrições, perguntas abertas. Em projeto sem código, escreva também `.spec/invariants.md` a partir das decisões tomadas (stack, regras de dados, segurança, restrições); `onde vivem no código` fica para depois da implementação.
4. Dispare os 5 peixinhos em paralelo (`TypeName: "research"`, `Model: "flash"`) sobre `brief.md`, `invariants.md` e o código relevante.
5. Consolide, ajuste o brief com o usuário e obtenha aprovação.

### draft

Escreva `.spec/<feature>/spec.md` com `STATUS: DRAFT` na primeira linha. Uma seção por vez, parando para aprovação explícita do usuário a cada uma:

1. **Jornadas críticas:** interações passo a passo, estados de tela/API, comportamento em erro.
2. **Plano técnico:** mudanças de schema, endpoints, componentes, fluxo.
3. **Alternativas e tradeoffs:** o que foi descartado e por quê.
4. **Plano de implementação:** tarefas atômicas e ordenadas, cada uma dizendo como verificar (teste ou checagem).

### review

1. Dispare os 5 peixinhos em paralelo (`TypeName: "research"`, `Model: "flash"`) sobre `spec.md`, `brief.md`, `invariants.md` e o código relevante.
2. Consolide em `.spec/<feature>/review.md` e apresente ao usuário.
3. Aplique as correções que ele aprovar.
4. Se houve achado CRÍTICO, rode nova bateria de peixinhos **apenas sobre as seções alteradas**. Máximo de 3 rodadas; depois disso, leve o impasse ao usuário.
5. Com a aprovação do usuário, mude para `STATUS: APPROVED`.

### drift

1. Obtenha o diff da implementação (padrão: `git diff <branch-base>...HEAD`; pergunte a base se não for óbvia). Salve o diff em arquivo temporário de scratch se for grande, para não inflar prompts.
2. Delegue a comparação a um peixinho (`TypeName: "research"`, `Model: "flash"`) que lê apenas `spec.md`, `invariants.md` e o diff/arquivos alterados.
3. Escreva `.spec/<feature>/drift.md`: divergências da spec, violações de invariante, comportamento não especificado e tarefas do plano não implementadas. Cada item com `arquivo:linha` e seção da spec.
4. Para cada desvio, o usuário decide a direção:
   - **Atualizar a spec:** aplique agora, ainda dentro do `drift`.
   - **Corrigir o código:** registre como tarefa pós-aprovação; código só vem depois do fluxo SDD completo.
