-- Henry Rocha
-- Vitor Eller
-- Bruno Domingues

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- A ULA eh responsavel por realizar as operacoes entre as entradas da instrucao passada
-- Ela sempre realiza a operacao entre dois registradores
-- Sua saida sempre sera enviada para o banco de registradores (esse mapeamento pode ser visto no Fluxo de Dados)

ENTITY ULA IS
    GENERIC (
        larguraDados : NATURAL := 888;
        SEL_WIDTH    : NATURAL := 888
    );
    PORT (
        -- Input ports 
        entradaA : IN STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
        entradaB : IN STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
        seletor  : IN STD_LOGIC_VECTOR(SEL_WIDTH - 1 DOWNTO 0);

        -- Output ports
        saida    : OUT STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
        flagZero : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE comportamento OF ULA IS
    -- Declarando a constante "zero", usada para determinar se a saida eh zero ou nao.
    CONSTANT zero : STD_LOGIC_VECTOR(larguraDados - 1 DOWNTO 0) := (OTHERS => '0');

    -- Todas as operacoes que a ULA consegue realizar.
    SIGNAL op_add : STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
    SIGNAL op_sub : STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
    SIGNAL op_or  : STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
    SIGNAL op_and : STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
    SIGNAL op_slt : STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);

    -- Sinal temporario usado durante a comparacao com a constante "zero".
    SIGNAL saidaTemp : STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
BEGIN
    -- Realizando todas as operacoes.
    op_add <= STD_LOGIC_VECTOR(unsigned(entradaA) + unsigned(entradaB));
    op_sub <= STD_LOGIC_VECTOR(unsigned(entradaA) - unsigned(entradaB));
    op_and <= entradaA AND entradaB;
    op_or  <= entradaA OR entradaB;
    op_slt <= STD_LOGIC_VECTOR(to_unsigned(1, larguraDados)) WHEN unsigned(entradaA) < unsigned(entradaB) ELSE
        (OTHERS => '0');

    -- Verificando qual operacaoo deve ser atribuida a "saidaTemp".
    saidaTemp <= op_and WHEN (seletor = "000") ELSE
        op_or WHEN (seletor = "001") ELSE
        op_add WHEN (seletor = "010") ELSE
        op_sub WHEN (seletor = "110") ELSE
        op_slt WHEN (seletor = "111") ELSE
        entradaA;

    -- Atribuindo "saida" a "saidaTemp" e realizando a comparacao para verificar se
    -- o resultado eh zero.
    saida    <= saidaTemp;
    flagZero <= '1' WHEN unsigned(saidaTemp) = unsigned(zero) ELSE
        '0';
END ARCHITECTURE;