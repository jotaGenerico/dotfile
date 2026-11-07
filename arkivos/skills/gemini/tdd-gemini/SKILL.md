---
name: tdd
description: >-
  Ative SOMENTE quando o usuário pedir explicitamente TDD (tdd, test-driven development, red-green-refactor, "escreve o teste primeiro").
  Nunca ative por conta própria em features ou bugfixes comuns.
---

# TDD — Red-Green-Refactor (Antigravity)

Escreva o teste primeiro. Veja-o falhar pelo motivo certo. Escreva o mínimo de código para passar. Refatore mantendo tudo verde.

**Princípio central:** se você não viu o teste falhar antes de codar, não provou que ele detecta o bug.

## Regras inegociáveis

1. **Ativação:** só execute este ritual completo quando o usuário pedir TDD explicitamente.
2. **Lei de Ferro:** nenhum código de produção antes de um teste falhando. Se escreveu código de produção antes do teste, apague-o por completo (não guarde como "referência" nem comente) e comece pelo teste. Exceções (protótipos descartáveis, código gerado, arquivos de config) exigem autorização explícita do usuário.
3. **Proteção da suíte existente:** nunca apague, afrouxe ou altere um teste pré-existente para fazê-lo passar. Se um teste existente parecer errado ou obsoleto, pare e pergunte ao usuário.
4. **Ambiente seguro:** testes de integração rodam exclusivamente em banco local/teste idêntico e descartável — **jamais** contra banco ou serviços de produção. Se não houver ambiente local disponível para rodar algum teste de integração, diferencie explicitamente no relatório o que foi **executado no terminal** do que ficou apenas **proposto**.

## Que tipo de teste escrever primeiro

- **Apps com back-end, banco ou integrações:** priorize **teste de integração do fluxo real** (tela/cliente → rota → regra → banco local), com `describe`/`it` descritivos em Português do Brasil (ou no idioma já adotado pela suíte do projeto), cobrindo caminho feliz e bordas críticas aplicáveis (acesso por outro usuário/IDOR, requisições simultâneas/race condition, idempotência/duplicata, limites de entrada).
- **Lógica pura / utilitário isolado sem I/O:** teste unitário direto sobre entradas e saídas reais.
- **Bugfix:** escreva primeiro o teste exato que reproduz o bug reportado.

## Ciclo obrigatório (passo a passo)

### 1. RED — Escrever um teste que falha
- Escreva **um** teste focado em **um** comportamento observável (se o nome precisa de "e", quebre em dois testes).
- Nomeie mentalmente qual defeito de produção faria esse teste quebrar.
- Derive o valor esperado na mão (literais/fixtures fixas) — nunca reutilize a própria função/helper testada para calcular o `expected`.
- Exercite código real; só use mock quando uma dependência externa/lenta tornar inevitável.

### 2. Verificar RED — Rodar e ver falhar (obrigatório)
Execute o arquivo de teste via `run_command` (sem pedir confirmação no chat):
- **Confirmar:** o teste **falha por asserção** (não por erro de sintaxe, import quebrado ou typo) exatamente porque o comportamento ainda não existe.
- **Passou de primeira?** O teste não testa nada novo ou é tautológico — corrija o teste antes de tocar no código.
- **Deu erro de execução/compilação de setup?** Corrija o setup até falhar pela asserção esperada (em linguagens compiladas, o mínimo aceitável no RED é um stub vazio que compila e falha na asserção).

### 3. GREEN — Mínimo de código para passar
- Implemente a solução mais simples e cirúrgica que faz o teste passar.
- Sem especulação (YAGNI): não adicione parâmetros extras, opções futuras, abstrações nem "melhore" código vizinho fora do pedido.

### 4. Verificar GREEN — Rodar o teste e a suíte inteira (obrigatório)
1. Rode o arquivo de teste recém-criado e confirme que passou sem warnings/erros sujos.
2. **Antes de concluir a entrega**, rode o comando da **suíte completa do projeto** (`npm test`, `pytest`, `cargo test`, etc.) — um arquivo verde não garante suíte verde.
   - Se o seu teste falhar: corrija o código de produção, não afrouxe o teste.
   - Se quebrou outro teste: corrija a regressão agora.
   - Se já havia falha pré-existente não causada por você: reporte o nome exato do teste falhando ao usuário (nunca omita falha vista no log).

### 5. REFACTOR — Limpar com a suíte verde
- Só depois do GREEN: remova duplicação óbvia introduzida por você, melhore nomes ou extraia helpers locais sem adicionar comportamento novo.
- Rode os testes novamente para provar que continuam verdes.
- Repita o ciclo (1 → 5) para o próximo comportamento/borda.

## Regras rápidas de testes honestos (e quando abrir a referência)

- Asserção sempre sobre comportamento/efeito real, **nunca** sobre existência ou chamada interna de mock sem contrato.
- Nenhum método exclusivo de teste dentro de classes/módulos de produção (limpeza de teste vive em utilitário de teste).
- Checagem mental de mutação ao fechar: se trocar um operador, constante, validação ou branch no código novo, pelo menos um teste **tem** que quebrar.

> **Progressive disclosure (economia de tokens):** NÃO leia `references/boas-praticas-testes.md` por padrão em testes simples sobre código real. Leia esse arquivo (nesta pasta da skill) **apenas** quando: (a) precisar criar mocks/doubles/spies, (b) o setup de teste estiver ficando grande/acoplado, ou (c) houver dúvida se uma asserção virou detector de mudança ou tautologia.

## Uso de `invoke_subagent` no TDD (economia de tokens)

- **Regra padrão (sem subagente):** execute o ciclo `RED → GREEN → REFACTOR` diretamente na conversa principal. O vai-e-vem rápido com o terminal gasta menos tokens direto nas tools locais do que abrir subagentes a cada passo.
- **Quando delegar:**
  - Mapear onde ficam helpers, factories, banco de teste e convenções em repositório grande desconhecido → `invoke_subagent` com `TypeName: "research"` e `Model: "flash_lite"`.
  - Múltiplos módulos independentes em paralelo → `TypeName: "self"` e `Model: "flash"`, exigindo que cada subagente siga o ciclo completo e devolva a saída real do `RED` e do `GREEN`.
  - Nunca omita `Model` nem use `"inherit"`.

## Sinais de alerta (pare na hora)

Se você se pegar pensando *"vou codar primeiro e já escrevo o teste"*, *"já testei manualmente"*, *"é simples demais para testar"* ou *"vou manter o código escrito antes só como referência"*: **pare, apague o código escrito antes do teste e recomece pelo passo 1 (RED).**

## Checklist antes de dar como pronto

- [ ] Cada comportamento/correção novo teve um teste escrito **antes** do código
- [ ] Você viu cada teste falhar no terminal pelo motivo esperado (`RED`)
- [ ] Escreveu apenas o código mínimo necessário (`GREEN`), sem especulação
- [ ] Suíte completa executada e saída limpa (sem warnings, erros ou `console.log`/prints de debug esquecidos; falhas pré-existentes explicitamente listadas)
- [ ] Nenhum teste existente foi apagado ou afrouxado
- [ ] Checagem de mutação mental aprovada (mudar a regra quebra o teste)
