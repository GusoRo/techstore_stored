USE loja_tech;

DROP PROCEDURE IF EXISTS atualizar_preco_categoria;
DROP PROCEDURE IF EXISTS consultar_extrato_cliente;

DELIMITER //

CREATE PROCEDURE atualizar_preco_categoria(
    IN p_id_categoria INT,
    IN p_percentual DECIMAL(5,2),
    OUT p_quantidade_alterada INT,
    OUT p_mensagem VARCHAR(255)
)
BEGIN
    DECLARE v_categoria_existe INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_quantidade_alterada = 0;
        SET p_mensagem = 'Erro ao atualizar os preços. Operação cancelada.';
    END;

    SET p_quantidade_alterada = 0;
    SET p_mensagem = '';

    IF p_id_categoria IS NULL OR p_id_categoria <= 0 THEN
        SET p_mensagem = 'Erro: informe um ID de categoria válido.';

    ELSEIF p_percentual IS NULL THEN
        SET p_mensagem = 'Erro: o percentual de ajuste é obrigatório.';

    ELSEIF p_percentual < -50 THEN
        SET p_mensagem = 'Erro: o desconto máximo permitido é de 50%.';

    ELSEIF p_percentual > 100 THEN
        SET p_mensagem = 'Erro: o aumento máximo permitido é de 100%.';

    ELSE
        SELECT COUNT(*)
        INTO v_categoria_existe
        FROM categorias
        WHERE id_categoria = p_id_categoria;

        IF v_categoria_existe = 0 THEN
            SET p_mensagem = 'Erro: categoria não encontrada.';
        ELSE
            START TRANSACTION;

            UPDATE produtos
            SET preco = ROUND(preco * (1 + p_percentual / 100), 2)
            WHERE id_categoria = p_id_categoria
              AND ativo = TRUE;

            SET p_quantidade_alterada = ROW_COUNT();

            INSERT INTO log_operacoes (
                tabela_afetada,
                operacao,
                descricao
            )
            VALUES (
                'produtos',
                'UPDATE_PRECO_CATEGORIA',
                CONCAT(
                    'Categoria: ', p_id_categoria,
                    ' | Ajuste: ', p_percentual, '%',
                    ' | Produtos alterados: ', p_quantidade_alterada
                )
            );

            COMMIT;

            IF p_percentual = 0 THEN
                SET p_mensagem = CONCAT(
                    'Operação concluída sem alteração percentual. Produtos encontrados: ',
                    p_quantidade_alterada, '.'
                );
            ELSE
                SET p_mensagem = CONCAT(
                    'Preços atualizados com sucesso. Produtos alterados: ',
                    p_quantidade_alterada, '.'
                );
            END IF;
        END IF;
    END IF;
END //

CREATE PROCEDURE consultar_extrato_cliente(
    IN p_id_cliente INT
)
BEGIN
    DECLARE v_cliente_existe INT DEFAULT 0;

    SELECT COUNT(*)
    INTO v_cliente_existe
    FROM clientes
    WHERE id_cliente = p_id_cliente;

    IF p_id_cliente IS NULL OR v_cliente_existe = 0 THEN
        SELECT 'Erro: cliente não encontrado.' AS mensagem;
    ELSE
        SELECT
            nome,
            email,
            telefone,
            criado_em AS data_cadastro
        FROM clientes
        WHERE id_cliente = p_id_cliente;

        SELECT
            id_pedido AS numero_pedido,
            data_pedido,
            status,
            valor_total
        FROM pedidos
        WHERE id_cliente = p_id_cliente
        ORDER BY data_pedido DESC, id_pedido DESC;

        SELECT
            COUNT(id_pedido) AS total_pedidos,
            COALESCE(SUM(valor_total), 0.00) AS valor_total_gasto,
            COALESCE(AVG(valor_total), 0.00) AS ticket_medio,
            MAX(data_pedido) AS ultimo_pedido
        FROM pedidos
        WHERE id_cliente = p_id_cliente;
    END IF;
END //

DELIMITER ;

-- Teste do exercício 1:
-- CALL atualizar_preco_categoria(3, 10.00, @quantidade, @mensagem);
-- SELECT @quantidade AS quantidade_alterada, @mensagem AS mensagem;

-- Teste de validação do exercício 1:
-- CALL atualizar_preco_categoria(3, -60.00, @quantidade, @mensagem);
-- SELECT @quantidade AS quantidade_alterada, @mensagem AS mensagem;

-- Teste do exercício 2:
-- CALL consultar_extrato_cliente(1);

-- Teste de cliente inexistente:
-- CALL consultar_extrato_cliente(999);
