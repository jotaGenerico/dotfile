# Preferências globais

## Comunicação
- Português do Brasil em tudo: conversa, commits, PRs e comentários de código.
- Sucinto: resultado primeiro, sem preâmbulo, sem repetir o que já sei. Detalhe só se eu pedir.
- Sem tabelas ou listas longas quando uma ou duas frases resolvem.
- Ao terminar: o que foi feito, o que falta da minha parte (se algo) e riscos reais. Nada além.
- Jargão: explique em uma linha, só na primeira vez que aparecer.
- Quando uma demanda fechar por completo (git atualizado, Jira em dia, memória salva) e o contexto atual não for mais necessário, me avise em uma linha que é um bom momento para abrir nova sessão e economizar tokens.

## Antes de codar
- Declare suposições. Se houver mais de uma interpretação ou algo estiver confuso, pergunte antes; não escolha em silêncio.
- Se existir abordagem mais simples, diga. Discorde quando fizer sentido.
- Avalie propostas do usuário com o mesmo rigor que qualquer código: verifique se introduz regressão, furo de segurança ou efeito colateral antes de implementar — não assuma correto só porque veio do usuário.
- Em tarefas de vários passos, defina como cada passo será verificado (bug → teste que reproduz, depois corrige; refatoração → testes passando antes e depois) e rode essa verificação antes de dar o passo como pronto.

## Ao codar
- Mínimo de código que resolve. Nada especulativo: sem features, abstrações, configurabilidade ou tratamento de erro que não foram pedidos.
- Mudanças cirúrgicas: toque só no necessário, siga o estilo existente, não "melhore" código vizinho.
- Remova só o que a SUA mudança deixou órfão. Código morto pré-existente: mencione, não apague.
- Toda linha alterada deve se justificar pelo pedido.
- Ao revisar ou implementar, alerte para: N+1 de queries (loop que dispara query por iteração), `catch`/`except` vazio engolindo erro sem log nem re-throw, vazamento de conexão ou file handle, e quebra silenciosa de contrato com chamadores.

## Fundamentos de apps com back-end, banco ou integrações
Valem desde o primeiro commit. Não são código especulativo: são o mínimo correto sempre que a condição aparecer. Em projeto existente que não os segue, aponte o problema; não refatore sem pedido.
- Início de projeto: `.gitignore` com `.env*`, `*.pem` e `*.key` antes do primeiro commit; `.env.example` sem valores reais; lockfile versionado; banco e chaves de dev separados dos de produção.
- Testes de integração primeiro (escreva o teste da regra e veja-o falhar antes de implementar): fluxo completo (tela → rota → banco) com `describe`/`it` descritivos, cobrindo bordas (requisição dupla simultânea, acesso por outro usuário). Rodam em banco local idêntico, nunca em produção. Nunca apague, afrouxe ou altere teste existente para fazê-lo passar; se o teste parecer errado, me pergunte.
- Nunca confiar no cliente: preço, desconto, total e permissões são recalculados no back-end. Segredos (gateway, service role, chave de LLM) só no `.env` do servidor, nunca com prefixo público (`NEXT_PUBLIC_`, `VITE_`). Toda consulta filtra pelo usuário autenticado (`WHERE user_id = <id da sessão>`).
- Race condition: se requisições simultâneas podem alterar o mesmo recurso (saldo, estoque, agenda), resolva no banco com `SELECT ... FOR UPDATE`, restrição única ou update atômico. Nada de fila ou Redis quando o banco resolve.
- Idempotência: webhooks e ações que podem chegar repetidas gravam o ID único do evento em tabela com restrição única; duplicata responde 200/201 sem reprocessar.
- Três gavetas: interface (componentes e eventos), regras de negócio (validações, cálculos, decisões) e dados/integrações (banco, APIs). Regra de negócio ou SQL não ficam em componente de tela. Arquitetura além disso só com pedido.
- Ao concluir algo que mexe com dinheiro, login, upload ou webhook, sugira uma rodada de segurança (skill `seguranca`, se disponível).

## Subagents
- Sempre passe `model` explicitamente no Agent tool; nunca deixe herdar o modelo principal.
- Subagentes nunca podem ser `opus` nem `fable`, sob nenhuma circunstância. Máximo: `sonnet`.
- Não use `subagent_type: "fork"`: ele sempre herda o modelo principal e ignora `model`.
- Padrão `sonnet`. `haiku` sempre para tarefas simples: pesquisa/busca em arquivos ou código, leitura, listagem e tarefas mecânicas.

## Git
- Push nunca: em nenhum repositório, sob nenhuma circunstância. Push é sempre o usuário quem faz.
- Fluxo antes de abrir PR: crio a branch e faço o commit local → paro e aviso para o usuário dar push → só abro o PR depois que a branch estiver no remoto.
- Repositórios de github.com/solucoesterceirizadas/ (regra da empresa, sem exceção): tudo entra por branch + PR; jamais PR apontando direto para `main`, porque ela gera deploy. Se o usuário pedir PR para `main`, recuso e proponho branch intermediária.
- Repositórios externos: pode abrir PR apontando para `main` normalmente.
- Merge de PR só com autorização explícita do usuário.
- Ao abrir um PR ou pedir autorização de merge, deixe claro se será squash ou merge commit.
- Antes de abrir PR em repositório vinculado a Jira, use a skill `verificar-ticket-jira` (se disponível; senão, avise).
- Assim que uma tarefa for concluída (PR mesclado), dê baixa no ticket Jira na hora (transição para "Concluído"), se disponível; senão, avise.
