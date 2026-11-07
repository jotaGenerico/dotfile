# Boas práticas de testes

Leia antes de adicionar mocks, doubles ou helpers de limpeza, ou se tiver dúvida sobre teste tautológico.

---

## Princípio 1 — Nomeie a quebra

Antes de escrever o corpo do teste, responda: **que mudança no código de produção faria este teste falhar?**

- Valor esperado derivado à mão ou por fixture literal — nunca pelo próprio código sob teste.
- Não teste estrutura interna (constantes, getters triviais, mensagens exatas de texto): teste o comportamento observável que depende delas.
- Não faça grep no código-fonte nem assert em texto de arquivo: rode o artefato e assert no efeito.

**Gate:** se não consegue nomear a quebra → redesenhe em torno de um comportamento observável.

```
// ❌ Espelho — sempre passa
const expected = buildQuery({ tag: 'urgente' });
expect(buildQuery({ tag: 'urgente' })).toBe(expected);

// ✅ Literal derivado à mão
expect(buildQuery({ tag: 'urgente' })).toBe('tag:"urgente"');
```

---

## Princípio 2 — Exercite o real

**Mock não ganha asserção.** Assertar que o mock existe diz nada sobre o componente — assertar no comportamento real.

**Mock no nível certo.** Aprenda os side effects reais do método antes de substituir; mantenha real o que o teste depende, mock só no que é lento ou externo.

**Double específico.** Se argumentos, contagem de chamadas ou ordem fazem parte do contrato, assert neles — fake que aceita qualquer coisa não verifica nada.

**Mock completo.** Espelhe a estrutura real inteira, não só os campos que o teste lê. Campo omitido quebra silenciosamente em integração.

**Limpeza pertence a utilitários de teste.** Método chamado só por testes não vai na classe de produção.

**Prefira integração a mock complexo.** Se o setup do mock cresceu mais que a lógica do teste, troque por teste de integração com componentes reais.

**Gate antes de mockar:**
```
1. Liste os side effects reais do método.
2. Mantenha real o que o teste depende; mock só o lento/externo abaixo disso.
3. Resposta do mock espelha a estrutura real completa.
4. Vai assertar no próprio mock? Desmocke ou apague a asserção.
5. Método só chamado por testes? Mova para utilitário de teste.
```

---

## Checagem de mutação

Antes de terminar, mute mentalmente o código de produção — ao menos um teste deve falhar para cada mutação realista:

- Constante ou argumento errado
- Handler de branch errado
- Side effect ou mudança de estado ausente
- Retorno vazio ou default
- Validação ausente para zero, vazio, nil, não-autorizado ou entrada malformada

Mutação que nada pega = comportamento desprotegido ou teste tautológico.

---

## Sinais de alerta

- Setup e asserção compartilham o mesmo objeto — igualdade garantida
- Teste só falha via panic, crash ou selector ausente
- Falha em toda mudança intencional, nunca em quebra acidental
- Valores esperados escondidos em loops, builders ou helpers
- Grep no código-fonte ou assert em símbolo removido
- Teste ainda faria sentido se só o framework existisse
- Asserção em `*-mock` test ID, ou falha ao remover o mock
- Método chamado só por arquivos de teste
- Setup do mock maior que a lógica do teste
- Mock "só por precaução"
