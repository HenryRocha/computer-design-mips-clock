-- Henry Rocha
-- Vitor Eller
-- Bruno Domingues

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL; -- Biblioteca IEEE para fun��es aritm�ticas

-- A ULA � respons�vel por realizar as opera��es entre as entradas da instru��o passada
-- Ela sempre realiza a opera��o entre a sa�da dos registradores e o valor em um endere�o de mem�ria ou do imediato passado pela instru��o
-- Sua sa�da sempre ser� enviada para o banco de registradores (esse mapeamento pode ser visto no Fluxo de Dados)

ENTITY ULA IS
    GENERIC (
        larguraDados : NATURAL := 8;
        SEL_WIDTH    : NATURAL := 3
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
    -- Declarando a constante "zero", usada para determinar se a sa?da ? zero ou n?o.
    CONSTANT zero : STD_LOGIC_VECTOR(larguraDados - 1 DOWNTO 0) := (OTHERS => '0');

    -- Todas as opera??es que a ULA consegue realizar.
    SIGNAL op_soma_zero   : STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
    SIGNAL op_soma        : STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
    SIGNAL op_soma_b_zero : STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
    SIGNAL op_soma_a_zero : STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
    SIGNAL op_sub         : STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
    SIGNAL op_or          : STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
    SIGNAL op_and         : STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);

    -- Sinal tempor?rio usado durante a compara??o com a constante "zero".
    SIGNAL saidaTemp : STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
BEGIN
    -- Realizando todas as opera??es.
    op_soma_zero   <= zero;
    op_soma        <= STD_LOGIC_VECTOR(unsigned(entradaA) + unsigned(entradaB));
    op_soma_b_zero <= STD_LOGIC_VECTOR(unsigned(entradaB));
    op_soma_a_zero <= STD_LOGIC_VECTOR(unsigned(entradaA));
    op_sub         <= STD_LOGIC_VECTOR(unsigned(entradaA) - unsigned(entradaB));
    op_and         <= entradaA AND entradaB;
    op_or          <= entradaA OR entradaB;

    -- Verificando qual opera??o deve ser atribu?da a "saidaTemp".
    saidaTemp <= op_soma_zero WHEN (seletor = "000") ELSE
    op_soma WHEN (seletor = "001") ELSE
    op_sub WHEN (seletor = "010") ELSE
    op_soma_b_zero WHEN (seletor = "011") ELSE
    op_soma_a_zero WHEN (seletor = "100") ELSE
    op_or WHEN (seletor = "101") ELSE
    op_and WHEN (seletor = "110") ELSE
    entradaA;

    -- Atribuindo "saida" a "saidaTemp" e realizando a compara??o para verificar se
    -- o resultado ? zero.
    saida    <= saidaTemp;
    flagZero <= '1' WHEN unsigned(saidaTemp) = unsigned(zero) ELSE
    '0';
END ARCHITECTURE;