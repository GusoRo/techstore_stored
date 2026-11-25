# Atividade - Stored Procedures no MySQL

## Descrição

Implementação dos dois exercícios práticos propostos no material da aula de Stored Procedures, utilizando o banco de dados `loja_tech`, da TechStore.

## Exercícios desenvolvidos

### 1. atualizar_preco_categoria

Procedure responsável por atualizar os preços dos produtos ativos de uma categoria.

- Recebe o ID da categoria e o percentual de ajuste.
- Percentual positivo aplica aumento.
- Percentual negativo aplica desconto.
- Permite desconto de até 50% e aumento de até 100%.
- Valida a existência da categoria.
- Retorna a quantidade de produtos alterados e uma mensagem por parâmetros `OUT`.
- Registra a operação na tabela `log_operacoes`.
- Utiliza transação para manter a consistência da operação.

Um percentual igual a zero é aceito e não altera os preços, mas registra a execução no log.

### 2. consultar_extrato_cliente

Procedure responsável por consultar as informações e o histórico de compras de um cliente.

Retorna três conjuntos de resultados:

1. Dados cadastrais do cliente.
2. Pedidos realizados, com data, status e valor total.
3. Resumo com quantidade de pedidos, valor total, ticket médio e data do último pedido.

Caso o cliente não exista, retorna uma mensagem informativa sem utilizar `SIGNAL`.

## Estrutura necessária

O script utiliza o banco `loja_tech` e as tabelas:

- `categorias`
- `produtos`
- `clientes`
- `pedidos`
- `log_operacoes`

Essas estruturas devem existir antes da execução. Elas fazem parte do script de criação apresentado no material da aula.

## Como executar

1. Abra o MySQL Workbench.
2. Execute primeiro o script de criação do banco e das tabelas da aula.
3. Se desejar, execute também os dados iniciais para realizar os testes.
4. Abra o arquivo `stored_procedures.sql`.
5. Execute o script completo.

## Exemplos de teste

### Atualizar preços de uma categoria em 10%

```sql
CALL atualizar_preco_categoria(3, 10.00, @quantidade, @mensagem);
SELECT @quantidade AS quantidade_alterada, @mensagem AS mensagem;
```

### Aplicar desconto de 20%

```sql
CALL atualizar_preco_categoria(3, -20.00, @quantidade, @mensagem);
SELECT @quantidade AS quantidade_alterada, @mensagem AS mensagem;
```

### Consultar o extrato de um cliente

```sql
CALL consultar_extrato_cliente(1);
```

### Consultar um cliente inexistente

```sql
CALL consultar_extrato_cliente(999);
```

## Tecnologias

- MySQL
- SQL
- Stored Procedures
- Parâmetros IN e OUT
- Estruturas condicionais
- Transações
- Funções de agregação
