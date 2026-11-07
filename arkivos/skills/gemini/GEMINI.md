# Preferências globais

## Postura e execução
- Execute direto leituras, buscas, inspeções, builds e testes sem pedir confirmação no chat.
- Só interrompa para pedir confirmação explícita em ações destrutivas ou irreversíveis (ex.: `rm -rf`, `git reset --hard`, drop/truncate em banco, sobrescrita de dados não versionados).

## Comunicação
- Português do Brasil em tudo: conversa, commits, PRs e comentários de código.
- Sucinto: resultado primeiro, sem preâmbulo, sem desculpas, sem repetir o que já sei. Detalhe só se eu pedir.
- Sem tabelas ou listas longas quando uma ou duas frases resolvem.
- Ao terminar: o que foi feito, o que falta da minha parte (se algo) e riscos reais. Nada além.
- Jargão: explique em uma linha, só na primeira vez que aparecer.
- Quando uma demanda fechar por completo (git, memória e Jira em dia, quando aplicáveis) e o contexto atual não for mais necessário, me avise em uma linha para abrir nova sessão (ou usar `/compact`) e economizar tokens.

## Antes de codar
- Declare suposições. Se houver mais de uma interpretação ou algo estiver confuso, pergunte antes; não escolha em silêncio.
- Se existir abordagem mais simples, diga. Discorde quando fizer sentido — nunca assuma que uma solução ou código sugerido por mim está correto sem validar antes se introduz bug, regressão, risco de segurança ou efeito colateral.
- Em tarefas de vários passos, defina como cada passo será verificado (bug → teste que reproduz, depois corrige; refatoração → testes passando antes e depois) e rode essa verificação antes de dar o passo como pronto.

## Ao codar
- Mínimo de código que resolve. Nada especulativo: sem features, abstrações, configurabilidade ou tratamento de erro que não foram pedidos.
- Mudanças cirúrgicas: toque só no necessário, siga o estilo existente, não "melhore" código vizinho.
- Remova só o que a sua mudança deixou órfão. Código morto pré-existente: mencione, não apague.
- Nunca engula erros em silêncio (`catch` vazio), não introduza queries N+1 nem deixe conexões/recursos abertos sem fechamento.
- Toda linha alterada deve se justificar pelo pedido.

## Fundamentos de apps com back-end, banco ou integrações
Valem desde o primeiro commit. Não são código especulativo: são o mínimo correto sempre que a condição aparecer. Em projeto existente que não os segue, aponte o problema; não refatore sem pedido.
- Início de projeto: `.gitignore` com `.env*`, `*.pem` e `*.key` antes do primeiro commit; `.env.example` sem valores reais; lockfile versionado; banco e chaves de dev separados dos de produção.
- Testes de integração primeiro (escreva o teste da regra e veja-o falhar antes de implementar): fluxo completo (tela → rota → banco) com `describe`/`it` descritivos, cobrindo bordas (requisição dupla simultânea, acesso por outro usuário). Rodam em banco local idêntico, nunca em produção. Nunca apague, afrouxe ou altere teste existente para fazê-lo passar; se o teste parecer errado, me pergunte.
- Nunca confiar no cliente: preço, desconto, total e permissões são recalculados no back-end. Segredos (gateway, service role, chave de LLM) só no `.env` do servidor, nunca com prefixo público (`NEXT_PUBLIC_`, `VITE_`). Toda consulta filtra pelo usuário autenticado (`WHERE user_id = <id da sessão>`).
- Race condition: se requisições simultâneas podem alterar o mesmo recurso (saldo, estoque, agenda), resolva no banco com `SELECT ... FOR UPDATE`, restrição única ou update atômico. Nada de fila ou Redis quando o banco resolve.
- Idempotência: webhooks e ações que podem chegar repetidas gravam o ID único do evento em tabela com restrição única; duplicata responde 200/201 sem reprocessar.
- Três gavetas: interface (componentes e eventos), regras de negócio (validações, cálculos, decisões) e dados/integrações (banco, APIs). Regra de negócio ou SQL não ficam em componente de tela. Arquitetura além disso só com pedido.
- Ao concluir algo que mexe com dinheiro, login, upload ou webhook, sugira uma rodada de segurança (skill `seguranca`, se disponível).

## Subagents e economia de tokens
- Consultas rápidas e pontuais (1 a 3 leituras/buscas diretas): faça direto nas tools locais sem abrir subagente, evitando o custo base de um novo contexto.
- Use `invoke_subagent` quando a varredura for ampla/volumosa (preservando o contexto principal limpo) ou em subtarefas isoladas paralelizáveis.
- Sempre passe `Model` explicitamente em `invoke_subagent`; nunca omita nem use `"inherit"`.
- `Model: "flash_lite"` (com `TypeName: "research"` quando for só leitura): obrigatório para busca/varredura em arquivos, leitura em volume, listagem e tarefas mecânicas.
- `Model: "flash"`: padrão para implementação, escrita de testes e edições (`TypeName: "self"` ou subagente dedicado).
- `Model: "pro"`: último recurso — apenas quando a subtarefa exigir raciocínio ou depuração complexa em que `"flash"` seja insuficiente.

## Git
- Nunca execute `git push`, em nenhum repositório, sob nenhuma circunstância. Push sou sempre eu quem faço.
- Fluxo de PR: crie a branch e os commits localmente, pare e me avise para eu dar `git push`; só abra o PR (`gh pr create`) depois que eu confirmar o push no remoto.
- Repositórios de `github.com/solucoesterceirizadas/` (regra da empresa, sem exceção): tudo entra por branch + PR; jamais abra PR apontando direto para `main` (ela gera deploy). Se eu pedir commit, push ou PR direto para `main`, recuse e proponha branch intermediária.
- Repositórios externos: pode abrir PR apontando para `main` normalmente (após o meu push).
- Merge de PR só com minha autorização explícita.
- Ao abrir um PR ou pedir autorização de merge, informe claramente se será squash ou merge commit.
- Jira (quando disponível no ambiente): use a skill `verificar-ticket-jira` antes de abrir PR vinculado e mova o ticket para "Concluído" assim que o PR for mesclado, sem esperar o fim da sprint.
