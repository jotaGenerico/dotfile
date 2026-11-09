---
name: seguranca
description: >-
  Ative SOMENTE quando o usuário pedir explicitamente rodada ou auditoria de segurança
  (seguranca, pentest, red team, modo hacker, checklist pré-deploy, go/no-go). Nunca ative sozinho ao concluir código.
---

# Segurança — rodadas e auditoria de aplicações (Antigravity)

Aja como atacante sobre o código do usuário: procure o que a IA costuma deixar passar (segredos no repo, confiança no front, IDOR, race condition, webhook reprocessado, payload sem limite, furo de regra de negócio). Todo achado precisa de evidência no código ou de um teste que reproduz. Sem evidência, não é achado.

Base: OWASP, PPSI 2.0 (Security by Design/Default do MGI) e as regras em `checklist.md` (nesta mesma pasta da skill).

## Regras do próprio teste

- **Ativação:** nunca rode esta skill sem pedido explícito do usuário.
- **Escopo:** só a aplicação do usuário, no repositório atual.
- **Testes dinâmicos** (requisições paralelas, payload gigante, acesso cruzado entre contas) apenas em ambiente local ou de teste, com banco descartável. Nunca em produção nem com dados reais. Se só houver produção disponível, faça apenas análise estática e registre isso no relatório.
- Nunca apague, afrouxe ou altere testes existentes para algo passar.
- Entregue o relatório primeiro. Corrija ou escreva testes só se o usuário pediu.

## Escolha do modo

- **Rodada** (*"roda uma rodada"*, feature recém-feita): só o que mudou (`git diff` não commitado + `git diff <branch-base>...HEAD`; sem branch-base, o não commitado; se vazio, `git show HEAD`). Aplique apenas os blocos e itens afetados pelo diff.
- **Auditoria completa** (*"audita a aplicação"*, *"pré-deploy"*, *"go/no-go"*): repositório inteiro, todos os blocos A–G aplicáveis e matriz Go/No-Go.

Na dúvida entre os dois, pergunte antes de rodar.

## Índice de blocos do `checklist.md` (economia de tokens)

Não leia o `checklist.md` inteiro no agente principal sem necessidade. Use este índice para selecionar os blocos afetados (na Rodada) e instrua cada subagente a ler com `read_file` **apenas a faixa de linhas do seu bloco**:

- **Bloco A (linhas 7–30, SEC-01..05):** Segredos no código/histórico, `.env`/chaves versionadas, prefixos públicos (`NEXT_PUBLIC_`/`VITE_`), superfície de debug, `audit` de dependências.
- **Bloco B (linhas 33–55, SEC-06..10):** Limite de payload/query, upload (MIME + magic bytes), URLs externas de mídia, SQLi/XSS/shell injection, vazamento em erros.
- **Bloco C (linhas 58–77, SEC-11..14):** Enumeração de usuários, força de auth/hash/rate-limit de login, IDOR (`WHERE user_id`), RLS/Storage policies (Supabase/Firebase/S3).
- **Bloco D (linhas 80–109, SEC-15..19):** Race condition/atomicidade no banco, idempotência + assinatura de webhooks, preço/permissão no cliente, janela de afiliados vs reembolso, bordas de negócio.
- **Bloco E (linhas 112–135, SEC-20..22):** PPSI 2.0 (10 princípios), separação em 3 camadas, existência/execução/histórico da suíte de testes de integração.
- **Bloco F (linhas 138–184, SEC-23..33):** CORS, cookies/CSRF, JWT, HTTPS/headers, debug em prod, mass assignment, SSRF/open redirect, path traversal, dados sensíveis em log, rate-limit de custo/LLM, reset de senha.
- **Bloco G (linhas 188–197, SEC-34..35):** Containers/Docker (root, segredos em layers/`ENV`, portas expostas, privilégios) e desserialização/`eval` inseguro.

## Fluxo com `invoke_subagent`

1. **Mapear a stack** (você, rápido, antes de despachar): linguagem/framework, banco/ORM, auth, pastas de rotas/handlers, presença de `Dockerfile`/`docker-compose*`, integrações (pagamento, webhooks, LLM), comando de testes e se há ambiente local descartável rodando.
2. **Despachar subagentes em paralelo na mesma resposta** (1 por bloco aplicável; na Rodada, só os blocos tocados pelo diff — se o diff for minúsculo e tocar 1 único bloco sem testes dinâmicos, faça direto sem subagente para economizar contexto):
   - **Nunca** omita `Model` nem use `"inherit"`.
   - **Bloco A:** `TypeName: "self"`, `Model: "flash_lite"` (precisa de `run_command` para `rg`, `git log`, `git ls-files` e `audit`; proíba qualquer escrita/edição no prompt).
   - **Blocos B–F (apenas análise estática):** `TypeName: "research"`, `Model: "flash"` (sandbox somente leitura nativo, menor gasto de tokens).
   - **Blocos B–F (com testes dinâmicos locais ou execução da suíte em SEC-22):** `TypeName: "self"`, `Model: "flash"` (precisa de `run_command`; proíba alterar arquivos do projeto ou rodar contra produção).
   - **Bloco G (condicional):** só despache subagente dedicado (`TypeName: "research"`, `Model: "flash"`) se houver `Dockerfile`/`docker-compose*`/manifesto de container no projeto; sem container, marque `SEC-34` como `N/A` direto e cheque `SEC-35` (`eval`/`pickle`/`yaml.load`) em busca rápida local sem abrir subagente.
   - **Brief de cada subagente:** caminho absoluto do `checklist.md` + `StartLine`/`EndLine` do seu bloco, mapa curto da stack, escopo (arquivos/diff ou repo), regras do teste e formato de achado abaixo. Encerre o turno sem polling e aguarde o wakeup automático.
3. **Verificar cada achado:** abra com `read_file` o `arquivo:linha` citado e confirme com o trecho exato. Descarte falso positivo; marque como `a confirmar` o que depende de infra externa ou teste dinâmico não executado.
4. **Consolidar** no relatório por severidade, deduplicando achados repetidos entre blocos (ver regra de ID abaixo).
5. **Testes de regressão** (somente se o usuário pedir): para cada achado Crítico/Alto, teste de integração que falha antes da correção e passa depois.

## Formato de cada achado

```text
[SEC-xx] <título> [(CWE-xxx)] — Severidade: Crítica | Alta | Média | Baixa — Status: confirmado | a confirmar (alta suspeita | baixa suspeita)
Onde: caminho/arquivo.ext:linha
Evidência: trecho ou comando + saída
Exploração: o que um atacante faz e o que ganha
Correção: mudança mínima sugerida
Prova: teste ou comando que demonstra o problema/correção
```

- **ID e CWE:** número do item do `checklist.md` (`SEC-13a`, `SEC-13b` se houver mais de um); inclua `(CWE-xxx)` ao lado do título quando houver CWE clássico aplicável (ex.: CWE-89 SQLi, CWE-22 Path Traversal, CWE-639 IDOR, CWE-362 Race Condition, CWE-798 segredo exposto). Se o mesmo defeito viola vários itens, descreva no principal e nos demais aponte `"ver SEC-xx"`.
- **Severidade:** **Crítica** = segredo exposto, dinheiro/saldo manipulável, acesso a dados de outro usuário. **Alta** = bypass de auth/autorização, injeção, DoS trivial. **Média** = defesa ausente com exploração condicionada. **Baixa** = higiene. Na dúvida entre duas, use a maior e justifique em uma linha.
- **Status:** **confirmado** quando o código prova a ausência da proteção; **a confirmar (alta suspeita | baixa suspeita)** quando depende de infra/proxy/`NODE_ENV` fora do repo ou de teste dinâmico não executado (gradue a suspeita para priorizar o bloqueio).

## Relatório

1. Veredito em uma linha: **GO** ou **NO-GO** (Auditoria) / **limpo** ou **N achados** (Rodada). Qualquer achado Crítico ou Alto (`confirmado` ou `a confirmar`) = **NO-GO**.
2. Achados no formato acima, mais severos primeiro.
3. Matriz Go/No-Go (só Auditoria — leia as linhas 1–197 do `checklist.md` se precisar conferir todos os títulos): cada `SEC-01`..`SEC-35` com ✅ / ❌ / ⚠️ não verificável (com motivo) / `N/A` (quando a premissa não existe na stack, ex.: sem upload ou sem Docker). Falta de proteção aplicável (ex.: sem suíte de testes) é ❌, nunca `N/A`.
4. O que não foi testado e por quê.
5. Fora do escopo (só Rodada): problemas Críticos/Altos vistos de passagem fora do diff, uma linha cada com `arquivo:linha`, sem análise profunda (recomende Auditoria completa).
6. Ao final de uma **Auditoria completa** (após exibir no chat), pergunte em uma linha se o usuário quer salvar o relatório em arquivo `.md`.

## Erros a evitar

- Rodar concorrência/payload contra produção → só local/teste; sem ambiente, apenas análise estática.
- Reportar suspeita sem `arquivo:linha` verificado → abrir o código e provar, ou marcar `a confirmar`.
- Assumir que RLS ligado basta → ler cada policy (`auth.uid() = user_id`) e buckets de storage.
- Contar validação de front-end como defesa → só vale validação/recálculo no back-end.
- Buscar segredos só no HEAD → checar histórico do git (`git log -p --all`).
- Corrigir código durante auditoria sem pedido → entregar relatório primeiro.
