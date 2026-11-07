# Boas Práticas para Testes Honestos e Mocks

Leia este guia apenas quando for introduzir mocks/doubles, criar helpers de teste ou revisar testes complexos.

## 1. Todo teste nomeia a quebra que captura

Antes de escrever o corpo do teste, responda: **qual mudança errada no código de produção deve fazer este teste falhar?**

- **Derive o valor esperado de forma independente:** use literais e fixtures conferidas na mão (testes orientados a tabela com `entrada → esperado` literal). Nunca calcule o `expected` chamando a própria função/helper sob teste:
  ```typescript
  // Errado (asserção espelho — passa mesmo se a lógica estiver invertida)
  const esperado = montarFiltro({ tag: 'urgente' });
  expect(montarFiltro({ tag: 'urgente' })).toBe(esperado);

  // Certo (literal derivado na mão)
  expect(montarFiltro({ tag: 'urgente' })).toBe('tag:"urgente"');
  ```
- **Sem referência compartilhada entre setup e asserção:** nunca reutilize a mesma instância de objeto/array mutável no input e no `expected` — se a função mutar o objeto *in-place*, os dois lados mudam juntos e o teste passa falso-positivo.
- **Proibido detector de mudança artificial:** não teste constantes internas (`expect(MAX_TENTATIVAS).toBe(5)`), estrutura privada ou texto exato irrelevante ao contrato. Teste o comportamento observável (*"falha 5 vezes e não executa a 6ª tentativa"*).
- **Comportamento, não texto-fonte:** nunca faça `grep` no código-fonte ou script para "testar" que uma linha existe; execute o artefato com entrada controlada e valide saída, banco/efeito colateral ou exit code.
- **Seu contrato, não o framework:** teste a fronteira do seu código (rota registrada, query/efeito no banco, payload retornado, validação), não se o Express/Prisma/React funciona por dentro. Getters/construtores triviais sem validação nem efeito colateral não ganham teste isolado.

## 2. Exercite o componente real (regras estritas para Mocks)

1. **Mock não ganha asserção própria:** verificar que um elemento `*-mock` renderizou ou que o seu próprio `vi.fn()` retornou o que você configurou não testa o sistema. Valide o efeito real resultante no componente/banco/resposta.
2. **Mock no nível mais baixo (lento/externo):** antes de mockar qualquer método, liste todos os efeitos colaterais dele. Mantenha reais os efeitos de que o teste depende (banco local, validação, gravação de estado) e mocke **apenas** a fronteira externa/paga/lenta (gateway de pagamento externo, envio de e-mail/SMS, API de LLM).
3. **Doubles específicos por cenário:** quando argumentos, ordem ou contagem de chamadas fazem parte do contrato (ex.: não cobrar duas vezes em webhook repetido), valide-os com fixtures separadas para sucesso, erro e entrada malformada. Um fake que aceita qualquer coisa não protege nada.
4. **Espelhe 100% da estrutura real nos mocks:** respostas mockadas devem conter todos os campos reais da API/entidade, não só o campo que o seu teste lê — mocks parciais escondem quebras silenciosas em código downstream.
5. **Código de produção só tem métodos de produção:** helpers de `reset()`, `seed()` ou `destroy()` usados apenas por testes ficam em arquivos de utilitários de teste, nunca na classe/serviço de produção.
6. **Setup de mock maior que o teste = sinal de design ruim ou teste errado:** se o mock ocupa mais da metade do teste ou quebra a cada refatoração interna, troque por **teste de integração** com componentes/banco local reais.

## 3. Checagem de Mutação (antes de encerrar)

Mude mentalmente o código de produção recém-escrito; **pelo menos um teste precisa falhar** para cada mutação realista:
- Constante, operador (`>` vs `>=`) ou argumento trocado
- Branch `if/else` invertida ou omitida
- Estado/registro no banco não gravado (efeito colateral omitido)
- Retorno vazio/default fixo
- Remoção da checagem de `0`, vazio, `null`, usuário não autorizado (`user_id` alheio) ou payload inválido

Se alguma dessas mutações deixaria todos os testes verdes, falta um caso de teste ou a asserção é fraca.
