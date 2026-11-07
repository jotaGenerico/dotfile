# Checklist de segurança

Cada item: **o que verificar**, **como** (estático e, quando houver ambiente local/teste, dinâmico) e **critério de aceite**. Testes dinâmicos nunca em produção.

---

## Bloco A — Segredos e superfície de exposição

**SEC-01 Segredos no código e no histórico**
- `rg -n -i "api_key|apikey|secret|password|passwd|private_key|token|bearer|service_role|sk_live|sk_test" --glob '!node_modules' --glob '!*.lock' .`
- Histórico: `git log -p --all | rg -i "api_key|secret|password|private_key|service_role|sk_live"`
- Se `gitleaks` estiver instalado: `gitleaks detect --source .`
- Aceite: nenhuma credencial no repo nem no histórico; tudo via variável de ambiente em runtime. Segredo no histórico = Crítico (precisa rotacionar, não só apagar).

**SEC-02 Arquivos sensíveis versionados**
- `git ls-files | rg -i "\.env($|\.)|\.pem$|\.key$|id_rsa"` e conferir `.gitignore`.
- Aceite: `.gitignore` cobre `.env*`, `*.pem`, `*.key`; só `.env.example` sem valores reais pode estar versionado.

**SEC-03 Segredo exposto ao navegador**
- Buscar variáveis com prefixo público (`NEXT_PUBLIC_`, `VITE_`, `EXPO_PUBLIC_`, `REACT_APP_`, `PUBLIC_`) que carreguem chave privada, service role do Supabase, token de gateway ou chave de LLM.
- Aceite: prefixo público só para dados que podem ser vistos por qualquer visitante (ex.: anon key do Supabase com RLS correto).

**SEC-04 Superfície desnecessária**
- Rotas de debug/teste, endpoints de admin sem auth, scripts temporários, seeds e mocks incluídos no build de produção, portas/serviços expostos sem uso.
- Aceite: nada disso alcançável em produção.

**SEC-05 Dependências vulneráveis**
- `npm audit --omit=dev` / `pnpm audit` / `pip-audit` / equivalente da stack.
- Aceite: sem vulnerabilidade Crítica/Alta sem justificativa.

---

## Bloco B — Entradas, payload e mídia

**SEC-06 Limite de tamanho no back-end**
- Estático: todo campo de texto, parâmetro de query e corpo de API tem tamanho máximo validado no servidor (schema zod/yup/pydantic, limite do body parser, `varchar(n)`).
- Dinâmico: enviar string de 1–10 MB e query string inflada.
- Aceite: rejeição imediata (400/413). Inadequado: gravar no banco sem limite.

**SEC-07 Upload de arquivos**
- Validação no back-end de MIME **e** magic bytes, lista branca (PNG, JPEG, WebP ou o que o domínio exigir), tamanho máximo, nome de arquivo gerado pelo servidor.
- Aceite: arquivo renomeado (`.exe` → `.png`) é rejeitado.

**SEC-08 URLs externas de mídia**
- Campos como foto de perfil ou imagem em post aceitam URL arbitrária?
- Aceite: mídia sempre no storage da própria aplicação; URL externa recusada (evita tracker que captura IP dos usuários).

**SEC-09 Injeção e XSS**
- SQL/NoSQL montado por concatenação ou interpolação com entrada do usuário; `dangerouslySetInnerHTML`, `v-html`, `innerHTML` com conteúdo do usuário; execução de shell com entrada do usuário.
- Aceite: queries parametrizadas/ORM; HTML do usuário sanitizado ou escapado.

**SEC-10 Tratamento de erros**
- Dinâmico: provocar erro (JSON inválido, ID inexistente, tipo errado).
- Aceite: resposta genérica, sem stack trace, SQL, caminhos internos ou versões; detalhe só no log do servidor.

---

## Bloco C — Autenticação e autorização

**SEC-11 Mensagens que não enumeram usuários**
- Login, recuperação de senha e cadastro.
- Aceite: mesma resposta para e-mail existente e inexistente (ex.: "Credenciais inválidas").

**SEC-12 Mecanismo de autenticação**
- Preferência por provedor consolidado (Supabase Auth, Clerk, Auth0, OAuth 2.0/SAML). Se auth própria: senha com Argon2 (ou bcrypt/scrypt), sessão/JWT com expiração, limite de tentativas de login.
- Aceite: nenhuma senha em texto puro ou hash rápido (MD5/SHA-1/SHA-256 sem KDF); força bruta limitada.

**SEC-13 IDOR (acesso a recurso de outro usuário)**
- Estático: toda leitura/alteração/exclusão filtra pelo usuário autenticado (`WHERE user_id = <id da sessão>`), nunca por ID vindo só do cliente.
- Dinâmico: Conta A cria recurso → Conta B tenta ler/alterar/excluir pelo ID.
- Aceite: 403 ou 404 para B; recurso intacto.

**SEC-14 RLS e regras de BaaS — se Supabase/Postgres/Firebase**
- Toda tabela com dados de usuário tem RLS habilitado **e** policies de select/insert/update/delete corretas (`auth.uid() = user_id`); `service_role` usado só no servidor.
- Buckets de storage (Supabase Storage, Firebase Storage, S3) privados quando guardam arquivos de usuário; regras do Firebase sem `allow read, write: if true`.
- Aceite: com a anon key e token da Conta B não se lê nem altera linha ou arquivo da Conta A.

---

## Bloco D — Concorrência, idempotência e lógica de negócio

**SEC-15 Atomicidade e race condition**
- Estático: saldo, estoque, compra, reembolso, likes, agendamentos usam transação com trava de linha (`SELECT ... FOR UPDATE`), restrição única ou update atômico (`UPDATE ... SET saldo = saldo - :v WHERE id = :id AND saldo >= :v`). Ler-então-escrever sem trava = achado.
- Dinâmico: mesma ação disparada N vezes em paralelo:
  ```bash
  seq 20 | xargs -P 20 -I{} curl -s -o /dev/null -w "%{http_code}\n" \
    -X POST http://localhost:3000/api/reembolso \
    -H "Authorization: Bearer $TOKEN_TESTE" -H "Content-Type: application/json" \
    -d '{"pedido_id": 1}'
  ```
- Aceite: só uma execução tem efeito; saldo/contadores consistentes após o teste. Resolver no banco; fila ou Redis não são exigidos quando o banco resolve.

**SEC-16 Idempotência de webhooks e integrações**
- Webhook de pagamento valida a assinatura do provedor e registra o ID único do evento em tabela com restrição única (ex.: `eventos_processados`).
- Dinâmico: reenviar o mesmo evento duas vezes.
- Aceite: segundo envio responde 200/201 sem reprocessar (sem cobrança, e-mail ou liberação duplicada); evento sem assinatura válida é rejeitado.

**SEC-17 Nada de confiança no cliente**
- Preço, desconto, frete, total, permissões e papéis recalculados/decididos no back-end.
- Dinâmico: alterar `preco`, `total`, `role` ou `user_id` no corpo da requisição.
- Aceite: servidor ignora ou rejeita os valores do cliente.

**SEC-18 Afiliados e reembolso**
- Aceite: comissão fica pendente (sem saque) por prazo **maior** que a janela de reembolso do comprador; afiliado não lucra comprando o próprio produto e reembolsando.

**SEC-19 Casos limite de regra de negócio**
- Valores negativos, zero, quantidades enormes, cupom reutilizado ou combinado, datas no passado, troca de plano no meio do ciclo.
- Aceite: cada caso tratado explicitamente no back-end.

---

## Bloco E — Arquitetura e testes

**SEC-20 Princípios Security by Design/Default (PPSI 2.0)** — marcar ✅/❌/N/A com evidência:
1. Minimização da superfície de ataque (ver SEC-04).
2. Segurança por padrão: sem credenciais padrão; MFA disponível/ligado para contas administrativas.
3. Menor privilégio: usuário do banco e chaves de API com o mínimo necessário.
4. Defesa em profundidade: validação em camadas; logs centralizados com horário confiável.
5. Falha segura: erro faz rollback da transação; autorização nega por padrão (deny-all).
6. Não confiar em serviços externos: respostas de APIs de terceiros validadas.
7. Segregação de ambientes: dev, teste e produção separados (bancos e chaves distintos).
8. Projeto aberto: padrões consolidados (TLS, OAuth 2.0, JWT), nada de "segurança por obscuridade".
9. Simplicidade: bibliotecas mantidas, dependências controladas (lockfile versionado).
10. Correção adequada: falhas corrigidas com causa raiz e teste de regressão.

**SEC-21 Separação de responsabilidades**
- Três camadas: interface (componentes e eventos), regras de negócio (validações, cálculos, decisões) e dados/integrações (banco, APIs).
- Aceite: regra de negócio ou acesso a banco não fica dentro de componente de tela.

**SEC-22 Suíte de testes de integração**
- Existe, roda em banco isolado (nunca produção), cobre o fluxo completo (front → rotas → banco) e os cenários de SEC-06, SEC-13, SEC-15 e SEC-16, com `describe`/`it` descritivos.
- Rodar a suíte e anexar o resultado.
- Verificar no histórico se testes foram apagados ou afrouxados para passar: `git log -p --stat -- '*test*' '*spec*'`.
- Aceite: suíte passa e nenhum teste foi enfraquecido sem justificativa.

---

## Bloco F — Erros clássicos de configuração e código

**SEC-23 CORS**
- `Access-Control-Allow-Origin: *` (ou origem refletida sem checagem) junto com `credentials: true`.
- Aceite: lista explícita de origens confiáveis.

**SEC-24 Cookies, sessão e CSRF**
- Cookie de sessão com `HttpOnly`, `Secure` e `SameSite=Lax/Strict`; token de sessão longo guardado em `localStorage` é achado. Rotas que mudam estado e se autenticam por cookie têm proteção CSRF (token ou `SameSite`).
- Aceite: JavaScript da página não lê o cookie de sessão; requisição forjada de outro site não executa ação.

**SEC-25 JWT**
- Segredo vindo de variável de ambiente e forte (nada de `"secret"`, `"changeme"`); algoritmo fixado na verificação (rejeita `none`); expiração definida; o servidor **verifica** a assinatura (não só `decode`).
- Aceite: token alterado ou expirado é rejeitado.

**SEC-26 HTTPS e cabeçalhos de segurança**
- Redirecionamento HTTP → HTTPS, HSTS, `X-Content-Type-Options: nosniff`, CSP, proteção contra iframe (`frame-ancestors`/`X-Frame-Options`). Em Express, `helmet` resolve a maioria.
- Aceite: cabeçalhos presentes na resposta de produção.

**SEC-27 Modo debug em produção**
- `DEBUG=True`, `NODE_ENV` diferente de `production`, source maps públicos, Swagger/GraphiQL/painéis de admin do framework expostos sem auth, `console.log` de objetos inteiros de requisição.
- Aceite: nada disso ativo em produção.

**SEC-28 Mass assignment**
- Corpo da requisição passado inteiro para create/update (`...req.body`, `Model.update(req.body)`, `**request.data`).
- Dinâmico: enviar campos extras (`role: "admin"`, `saldo`, `verificado: true`).
- Aceite: só campos de uma lista branca são gravados.

**SEC-29 SSRF e open redirect**
- Servidor busca URL informada pelo usuário (preview de link, importar imagem, webhook configurável) sem lista branca e sem bloquear IPs internos (`127.0.0.1`, `10.x`, `192.168.x`, `169.254.169.254`).
- Redirecionamento para destino vindo de parâmetro (`?next=`, `?redirect=`) sem validar que é interno.
- Aceite: URL interna recusada; redirect só para caminhos da própria aplicação.

**SEC-30 Path traversal**
- Caminho de arquivo montado com entrada do usuário (`path.join(dir, req.query.file)`, `open(base + nome)`).
- Aceite: `../../etc/passwd` é rejeitado; arquivos referenciados por ID, não por caminho.

**SEC-31 Dados sensíveis em log**
- Senha, token, cookie, cartão, CPF ou corpo inteiro de requisições de login/pagamento indo para log, console ou ferramenta de monitoramento.
- Aceite: campos sensíveis mascarados ou omitidos.

**SEC-32 Abuso de custo e rate limit**
- Endpoints que gastam dinheiro ou recurso (chamada a LLM, envio de e-mail/SMS, geração de arquivo, upload) sem rate limit por usuário/IP e sem teto de uso; endpoint de LLM acessível sem login.
- Aceite: limite por usuário/IP e teto de gasto; sem auth, nada que gere custo.

**SEC-33 Recuperação de senha e verificação de e-mail**
- Token gerado com fonte criptográfica (não `Math.random`, não sequencial), de uso único, com expiração curta e invalidado após uso; link montado com domínio fixo, não com o cabeçalho `Host` da requisição.
- Aceite: token reutilizado, expirado ou adivinhado é rejeitado.

---

## Bloco G — Containers e desserialização

**SEC-34 Segurança de containers e imagens Docker — se usar Docker/containers**
- `Dockerfile` define usuário não-root (`USER`), não grava segredos em `ARG`/`ENV`/layers da imagem e tem `.dockerignore` bloqueando `.env*`, `*.pem`, `*.key` e `.git`.
- `docker-compose`/manifestos sem `privileged: true`, sem Docker socket montado sem necessidade estrita e sem portas internas de banco/cache/fila expostas publicamente (`0.0.0.0`).
- Aceite: container roda sem root, imagem limpa de credenciais e serviços internos acessíveis apenas na rede privada.

**SEC-35 Desserialização e avaliação dinâmica insegura**
- Buscar avaliação/desserialização de entrada não confiável (`eval`, `new Function`, `pickle.loads`, `yaml.load` sem `SafeLoader`, `unserialize`, desserialização polimórfica irrestrita).
- Aceite: zero execução dinâmica ou desserialização insegura sobre dados externos; uso exclusivo de parsers seguros (JSON + validação de schema).
