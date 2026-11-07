---
name: seguranca
description: >-
  Use quando o usuário pedir para verificar, auditar ou testar a segurança de uma aplicação (rodada de segurança,
  pentest, red team, "modo hacker", checklist pré-deploy, go/no-go), ou para revisar código gerado por IA (vibe coding)
  em busca de segredos expostos, IDOR, RLS, race condition, falta de idempotência ou limite de payload.
---

# Segurança — rodadas e auditoria de aplicações

Aja como atacante sobre o código do usuário: procure o que a IA costuma deixar passar (segredos no repo, confiança no front, IDOR, race condition, webhook reprocessado, payload sem limite, furo de regra de negócio). Todo achado precisa de evidência no código ou de um teste que reproduz. Sem evidência, não é achado.

Base: OWASP, PPSI 2.0 (Security by Design/Default do MGI) e as regras de construção em `checklist.md`.

## Mapa de linhas do checklist.md

Use para passar o intervalo exato ao subagente — ele lê só as linhas do seu bloco, não o arquivo inteiro.

- Bloco A — Segredos e superfície de exposição: linhas 7–30
- Bloco B — Entradas, payload e mídia: linhas 33–55
- Bloco C — Autenticação e autorização: linhas 58–77
- Bloco D — Concorrência, idempotência e lógica de negócio: linhas 80–109
- Bloco E — Arquitetura e testes: linhas 112–135
- Bloco F — Erros clássicos de configuração e código: linhas 138–184
- Bloco G — Containers e desserialização: linhas 191–203 (só se existir Dockerfile/docker-compose)

## Regras do próprio teste

- Escopo: só a aplicação do usuário, no repositório atual.
- Testes dinâmicos (requisições paralelas, payload gigante, acesso cruzado entre contas) apenas em ambiente local ou de teste, com banco descartável. Nunca em produção nem com dados reais. Se só houver produção disponível, faça apenas a análise estática e diga isso no relatório.
- Nunca apague, afrouxe ou altere testes existentes para algo passar.
- Entregue o relatório primeiro. Corrija ou escreva testes só se o usuário pediu.

## Escolha do modo

| Pedido | Modo | Escopo |
|---|---|---|
| "roda uma rodada", durante o desenvolvimento, feature recém-feita | **Rodada** | Só o que mudou: `git diff` não commitado + `git diff <branch-base>...HEAD`. Sem branch-base, só o não commitado; se estiver vazio, o último commit (`git show HEAD`). Aplique apenas os itens do checklist que tocam o código alterado. |
| "audita a aplicação", "pré-deploy", "go/no-go", projeto finalizado | **Auditoria completa** | Repositório inteiro, todos os blocos A–G e matriz Go/No-Go. |

Na dúvida entre os dois, pergunte.

## Fluxo

**Atalho — Rodada curta:** se o diff for pequeno e afetar somente 1 bloco do checklist, sem teste dinâmico necessário, audite você mesmo sem abrir subagente.

1. **Mapear a stack** (você, antes de despachar): linguagem/framework, banco e ORM, provedor de auth (Supabase, Clerk, Auth0, próprio), onde ficam rotas/handlers, integrações (pagamento, webhooks, LLM), existência e comando da suíte de testes, ambiente local disponível. Esse mapa vai no brief de cada subagente.
2. **Despachar subagentes em paralelo**, um por bloco do `checklist.md` (na Rodada, só os blocos afetados pelo diff). Modelos: model=haiku para o bloco A (busca mecânica: rg, git log, npm audit); model=sonnet para os blocos B–F (análise estática e lógica de negócio); model=haiku para o Bloco G (Dockerfile/docker-compose) — só despache se existir `Dockerfile` ou `docker-compose.yml` no repositório; senão, marque N/A sem abrir subagente. Nunca use `subagent_type: "fork"` (herda o modelo principal e ignora `model`). Cada brief contém: caminho absoluto deste `checklist.md`, o intervalo de linhas do bloco (ver mapa acima), o mapa da stack, o escopo (diff ou repo), as regras do próprio teste acima e o formato de achado abaixo. O subagente lê o código; não corrige nada. Sem ferramenta de subagentes: execute os blocos você mesmo, um por vez.
3. **Verificar cada achado**: abra o arquivo:linha citado e confirme com o trecho exato. Descarte o que não se sustenta; marque como "a confirmar" o que depende de teste dinâmico não executado.
4. **Consolidar** no relatório, ordenado por severidade. Como cada subagente vê só o seu bloco, a deduplicação é sua: o mesmo trecho achado em blocos diferentes vira um achado só (ver regra de ID abaixo).
5. **Testes de regressão** (se o usuário pedir): para cada achado Crítico/Alto, um teste de integração que falha antes da correção e passa depois (IDOR entre contas, payload acima do limite, requisições concorrentes, webhook duplicado).

## Formato de cada achado

```
[SEC-xx] <título> — Severidade: Crítica | Alta | Média | Baixa — Status: confirmado | a confirmar
Onde: caminho/arquivo.ext:linha
Evidência: trecho ou comando + saída
Exploração: o que um atacante faz e o que ganha
Correção: mudança mínima sugerida
Prova: teste ou comando que demonstra o problema/correção
```

ID: o número do item do `checklist.md`; dois achados no mesmo item recebem sufixo (`SEC-13a`, `SEC-13b`). Se o mesmo defeito viola vários itens, descreva-o por completo no item principal e, nos outros, só aponte "ver SEC-xx".

Severidade: **Crítica** = vazamento de segredo, dinheiro/saldo manipulável, acesso a dados de outro usuário. **Alta** = bypass de auth/autorização, injeção, DoS trivial. **Média** = defesa ausente com exploração condicionada. **Baixa** = higiene. Classifique pelo impacto no código como está hoje; se a exploração depende de outro defeito, cite-o ("ver SEC-xx"). Na dúvida entre duas, use a maior e justifique em uma linha.

Status: **confirmado** quando o código do repositório prova que a proteção falta; **a confirmar** quando a prova está fora do repo (comportamento de biblioteca, proxy/infra, `NODE_ENV`, handler ausente) ou depende de teste dinâmico não executado.

## Relatório

1. Veredito em uma linha: **GO** ou **NO-GO** (Auditoria) / **limpo** ou **N achados** (Rodada).
2. Achados no formato acima, mais severos primeiro.
3. Matriz Go/No-Go (só Auditoria): cada SEC do `checklist.md` com ✅ / ❌ / ⚠️ não verificável (com motivo) / N/A. Use N/A quando a premissa do item não existe na stack (sem upload, sem Supabase, sem front). Use ❌ quando o item se aplica e a proteção exigida está ausente (ex.: não há suíte de testes).
4. O que não foi testado e por quê (ex.: sem ambiente local para testes dinâmicos).
5. Fora do escopo (só Rodada): problemas Críticos/Altos vistos de passagem fora do diff, uma linha cada com arquivo:linha, sem análise. Se houver, recomende Auditoria completa.
6. **Salvar (só Auditoria Completa):** pergunte em uma linha se o usuário quer gravar o relatório em arquivo `.md`; aguarde resposta antes de criar qualquer arquivo.

Qualquer achado Crítico ou Alto, confirmado ou a confirmar, = NO-GO até ser corrigido ou descartado.

## Erros comuns

| Erro | Correção |
|---|---|
| Rodar teste de concorrência ou payload contra produção | Só local/teste. Sem ambiente, só análise estática. |
| Reportar suspeita sem arquivo:linha | Abrir o código e confirmar, ou marcar "a confirmar". |
| "RLS está habilitado, então está seguro" | Ler cada policy; RLS ligado sem policy correta ainda vaza ou bloqueia tudo. |
| Validação no front contada como proteção | Só conta o que o back-end valida/recalcula. |
| Buscar segredos só no código atual | Buscar também no histórico do git. |
| Corrigir durante a auditoria sem pedido | Relatório primeiro. |
