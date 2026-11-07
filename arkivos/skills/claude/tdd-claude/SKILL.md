---
name: tdd
description: >-
  Use quando o usuário pedir TDD, test-driven development, "escreve o teste primeiro" ou "ciclo red-green-refactor".
  Nunca ativar sozinho durante implementação.
---

# TDD — Test-Driven Development

Escreva o teste antes. Veja ele falhar. Escreva o mínimo de código para passar. Refatore.

**Lei de ferro:** nenhum código de produção sem um teste falhando primeiro. Se escreveu código antes do teste, apague e recomece.

## Quando usar

Só quando o usuário pedir TDD explicitamente. Em mudanças triviais de texto, estilo ou configuração sem lógica: não use, avise o usuário.

## Prioridade de tipo de teste

Em apps com banco, rotas ou integrações externas: **teste de integração primeiro** — fluxo completo (tela → rota → banco local descartável), cobrindo o caso feliz, IDOR, race condition e idempotência. Banco local idêntico ao de produção em schema; nunca produção.

Teste unitário puro só para lógica isolada sem I/O (funções de cálculo, validação, transformação). Se a lógica acessa banco ou serviço externo, integração é o caminho.

## Ciclo RED → GREEN → REFACTOR

**RED — escreva o teste falhando**
- Um comportamento por teste; nome descreve o que deve acontecer.
- Valor esperado derivado à mão, nunca pelo próprio código sob teste.
- Em linguagem compilada: stub vazio é permitido para o build não explodir — o teste precisa falhar na asserção, não em erro de compilação.
- Rode e confirme: falha pela razão certa (feature ausente, não erro de digitação).

**GREEN — código mínimo para passar**
- Escreva só o suficiente para o teste passar. Sem features extras.
- Rode a suíte inteira — não só o teste novo. Falha que você causou = corrija agora. Falha pré-existente que você não causou = reporte pelo nome no relatório; não corrija sem pedido do usuário.

**REFACTOR — limpe sem mudar comportamento**
- Remova duplicação, melhore nomes, extraia helpers. Suíte deve continuar verde.
- Não adicione comportamento nesta etapa.

Repita para o próximo comportamento.

## Regras de proteção

- Nunca apague, afrouxe ou altere teste existente para fazê-lo passar. Se parecer errado, pare e pergunte ao usuário.
- Nunca rode testes dinâmicos (curl, seed, migration) contra banco ou serviços de produção.
- Leia `boas-praticas-testes.md` antes de adicionar mocks, doubles ou helpers de limpeza, ou se tiver dúvida sobre teste tautológico.

## Subagentes

O ciclo RED → GREEN → REFACTOR roda direto sem subagente — vai-e-vem no terminal é mais rápido e barato.

Abra subagente apenas em dois casos:
- **Mapear fixtures e helpers** em repositório grande desconhecido: Agent tool, model=haiku. Nunca fork.
- **Paralelizar módulos independentes** (cada um tem seu ciclo TDD isolado): Agent tool, model=sonnet. Nunca fork.

## Checklist antes de marcar como pronto

- [ ] Cada novo comportamento tem um teste que falhou antes da implementação
- [ ] Assistiu cada teste falhar pela razão certa
- [ ] Código mínimo — sem features além do que o teste exige
- [ ] Suíte inteira passou (não só o arquivo novo)
- [ ] Saída limpa: sem erros, warnings ou console.log de debug
- [ ] Mocks usam a estrutura real completa (ver `boas-praticas-testes.md`)
- [ ] Nenhum teste existente foi apagado ou afrouxado
