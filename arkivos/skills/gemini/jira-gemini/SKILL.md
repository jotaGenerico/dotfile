---
name: jira
description: >-
  Ative SOMENTE quando o usuário pedir explicitamente para verificar, criar ou dar baixa em tarefas no Jira
  (ex.: "vai lá no Jira", "vê se tem essa tarefa/subtarefa e cria", "dá baixa no Jira"). Nunca ative por conta própria.
---

# Jira — Verificação, Criação de Subtarefas e Baixa (Antigravity)

Gerencia tickets e subtarefas no Jira **exclusivamente quando o usuário pedir**, mantendo o vínculo claro entre o código/branch/PR atual e o cartão correto na sprint vigente.

## Escolha do modo (conforme o pedido do usuário)

- **Modo 1 — Iniciar / Verificar / Criar** (*"vai lá no Jira, vê se tem essa tarefa ou se é subtarefa de algo e cria"*):
  Executa os passos **1 → 2 → 3 → 4 → 5 (Em andamento)** e guarda a chave `<TICKET>` para usar na branch, nos commits e no PR quando o repositório exigir.
- **Modo 2 — Finalizar / Dar baixa** (*"vai lá no Jira, vê se tem alguma coisa e dá baixa"*):
  Confere o trabalho real feito na branch/sessão (`git status` + `git diff` / commits / PR), localiza o ticket correspondente nos passos **1 → 2** (ou cria nos passos **3 → 4** se ainda não existir) e aplica a baixa para `"Concluído"` no passo **5**.

## Economia de tokens

- Leia as regras do repositório (`read_file`) e chame as ferramentas do Jira **diretamente no agente principal**, sem abrir subagente.
- Só use `invoke_subagent` (`TypeName: "research"`, `Model: "flash_lite"`, nunca `"inherit"`) se precisar varrer dezenas de épicos/subtarefas antigas em um projeto muito extenso.

## Procedimento passo a passo

### 1. Contexto do trabalho atual e convenção do repositório
- Antes de mexer no Jira, identifique exatamente qual tarefa está em mãos (pedido atual na conversa, branch atual, `git status` + `git diff` para incluir arquivos novos não rastreados, ou commits recentes) para nunca atuar no ticket errado.
- Leia `CONTRIBUTING.md`, `AGENTS.md`, `GEMINI.md` ou `CLAUDE.md` na raiz do projeto para descobrir:
  - A chave do projeto Jira (ex.: `DEV`) e o épico/tarefa-pai onde subtarefas entram;
  - O padrão de nome de branch (`<tipo>/<ticket>-<slug>`), commit e título/corpo de PR (`[TICKET] Descrição`), se houver.
- **Não adivinhe:** se a chave do projeto ou o épico/tarefa-pai não estiverem documentados no repositório (ou se o conector Jira não estiver ativo na sessão), **pare e pergunte ao usuário**. Nunca chute códigos de projeto, épico ou ticket.

### 2. Localizar ticket existente (evitar duplicata e falso reuso)
Procure um ticket que cubra **exatamente o escopo da tarefa atual**, nesta ordem:
1. Ticket já mencionado pelo usuário na conversa ou presente no nome da branch atual (consulte no Jira e confirme que resumo/descrição batem com a tarefa).
2. Subtarefas abertas do épico/tarefa-pai ativo usando JQL direto:
   `parent = <EPIC> AND statusCategory != Done ORDER BY updated DESC`

**Regras na escolha do pai e do ticket:**
- **Múltiplas fases ou épicos:** compare resumo e descrição do pai com o escopo real e prefira a **fase funcional ativa na sprint vigente** (nunca reutilize ticket estrutural antigo nem fase homônima encerrada).
- **Subtarefas históricas encerradas:** se o épico trouxer aviso explícito de que subtarefas antigas estão *"encerradas / não devem receber novas funcionalidades"*, crie uma subtarefa nova em vez de reaproveitar uma antiga pelo nome parecido.
- **Ambiguidade real:** se houver dúvida genuína se um ticket existente já cobre a tarefa, **pergunte ao usuário** antes de criar outro ou dar baixa.

### 3. Validar a sprint ativa e o prazo (antes de criar ou vincular)
- Consulte a sprint ativa atual do projeto (ex.: via JQL `project = <KEY> AND sprint in openSprints()` ou ferramenta de sprints do board). Nunca confie em sprint/data lembrada de sessão anterior nem na última sprint gravada em ticket antigo.
- Se a leitura padrão do ticket omitir campos customizados, peça a **visão completa** do ticket conforme o conector e identifique no ticket-pai qual `customfield_*` armazena a sprint (geralmente `customfield_10020`, mas pode variar entre instâncias).
- **Checagem de vencimento:** converta `startDate` e `endDate` da sprint para o fuso atual e compare com a data/hora da execução. Se `endDate` já venceu, **não** a trate como sprint atual mesmo que o Jira retorne `state: active` — reporte a inconsistência ao usuário e peça orientação.
- **Associação à sprint:**
  - Para subtarefa nova, confirme **antes de criar** que o ticket-pai está na sprint vigente (no Jira, subtarefas normalmente herdam a sprint do pai e não permitem edição direta do campo Sprint).
  - Ao gravar o campo de sprint na escrita, envie o **ID numérico escalar** aceito pela ferramenta (ex.: `122`), nunca a lista retornada na leitura (`[{"id": 122}]`), e leia o ticket de volta para confirmar.
- **Bloqueio:** se a sprint ativa não puder ser consultada, estiver vencida, o pai estiver fora dela ou o Jira recusar a associação, **pare e peça orientação ao usuário** (nunca use sprint encerrada, nunca aceite sprint herdada de pai histórico e nunca mova tickets entre sprints por suposição).

### 4. Criar novo ticket ou subtarefa (quando não existir)
- Crie como **subtarefa do épico/tarefa-pai ativo** validado nos passos 1–3 (salvo convenção diferente do repositório ou instrução do usuário).
- **Tipo de item (`issuetype`):** confirme antes o nome exato do tipo de subtarefa aceito pelo projeto (ex.: `"Subtarefa"`, `"Sub-task"` ou `"Subtask"`, olhando uma subtarefa existente do épico ou os tipos do projeto) para não falhar na criação.
- **Resumo e descrição fiéis:**
  - Se o código já foi implementado, baseie o resumo e a descrição no que realmente mudou (`git status` + `git diff` e commits locais, incluindo arquivos novos).
  - Se estiver criando no início da tarefa, baseie-se no escopo pedido pelo usuário.
- **Atribuição ao usuário atual:** descubra a conta do usuário autenticado na integração (ex.: via `atlassianUserInfo` ou equivalente) e atribua o ticket a ele (`assignee` e/ou `reporter`). Nunca deixe ticket órfão.
- **Entrega multi-camada coesa:** se o projeto costuma separar backend/frontend/banco mas a tarefa resolve tudo numa única entrega coesa, crie **um único ticket** cobrindo as camadas afetadas (seguindo o padrão mais recente do épico).

### 5. Atualizar o status (apenas via transição oficial)
Consulte sempre o **status atual** e as **transições disponíveis** do ticket no Jira e execute apenas transições reais do workflow (nunca edite o campo de status diretamente, nunca invente nomes de transição e nunca reabra tickets encerrados automaticamente):

- **No Modo 1 (Iniciar / Criar):**
  - Se o ticket estiver aberto/backlog, faça a transição para `"Em andamento"` (ou equivalente do workflow) e consulte o ticket novamente para confirmar, preservando `assignee` e demais campos.
- **No Modo 2 (Finalizar / Dar baixa):**
  - Se houver Pull Request associado à entrega, confira antes no GitHub (`gh pr view <numero> --json state,mergedAt`):
    - Se o PR foi fechado sem merge (`state == "CLOSED"`), **não** dê baixa e avise o usuário.
    - Se o PR ainda estiver aberto (`state == "OPEN"`), avise o usuário que o PR ainda não foi mesclado e pergunte se mesmo assim deve marcar o ticket como concluído agora.
  - Execute a transição para `"Concluído"` / `"Resolvido"` (ou equivalente final do workflow) e consulte o ticket novamente para confirmar o novo status.
  - Se o workflow bloquear a transição direta (ex.: exigir passar primeiro por `"Em andamento"` ou `"Em revisão"`), execute as etapas permitidas pelo workflow ou reporte o bloqueio ao usuário.

### 6. Manter o rastro com o Git / PR
Sempre informe ao usuário no chat a chave e o status final do ticket (ex.: `DEV-123 → Em andamento` ou `DEV-123 → Concluído`). Quando a tarefa ainda for gerar branch, commit ou PR em repositório vinculado ao Jira, use essa mesma chave `<TICKET>` no nome da branch, nas mensagens de commit e no título/corpo do PR. Ao indicar o PR ao usuário, deixe explícito se é **Entrega de tarefa → `"Squash and merge"`** ou **Promoção para `main` → `"Create a merge commit"`** (promoção para `main` é exclusiva do usuário).
