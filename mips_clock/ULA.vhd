-- Autores:
--      Henry Rocha
--      Vitor Eller
--      Bruno Domingues
-- Informacoes:
--      Nome do arquivo: 
--          ULA.vhd
--      Descricao:
--          A ULA eh responsavel por realizar as operacoes entre as entradas da instrucao passada.
--          ULA feita bit a bit. Usando de adders e full adders.

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ULA IS
    GENERIC (
        larguraDados : NATURAL := 32;
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
    -- Sinais intermediarios
    SIGNAL norTemp      : STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
    SIGNAL entradaB_inv : STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
    SIGNAL op_and       : STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
    SIGNAL op_or        : STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
    SIGNAL op_slt       : STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
    SIGNAL adder_out    : STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
    SIGNAL overflow     : STD_LOGIC;
BEGIN
    -- Invertendo a entradaB, de acordo com o seletor(2).
    muxinverteB : ENTITY work.mux2x1
        GENERIC MAP(
            DATA_WIDTH => larguraDados
        )
        PORT MAP(
            entradaA => entradaB,
            entradaB => NOT entradaB,
            seletor  => seletor(2),
            saida    => entradaB_inv
        );

    -- Realizando todas as operacoes.
    adderSubber : ENTITY work.adder
        GENERIC MAP(
            DATA_WIDTH => larguraDados
        )
        PORT MAP(
            entradaA => entradaA,
            entradaB => entradaB_inv,
            vem_um   => seletor(2),
            soma     => adder_out,
            overflow => overflow
        );

    op_and <= entradaA AND entradaB;
    op_or  <= entradaA OR entradaB;
    op_slt <= "0000000000000000000000000000000" & (adder_out(larguraDados - 1) XOR overflow);

    -- Selecionando a operacao de acordo com o seletor.
    mux : ENTITY work.mux4x1
        GENERIC MAP(
            DATA_WIDTH => larguraDados
        )
        PORT MAP(
            entradaA => op_and,
            entradaB => op_or,
            entradaC => adder_out,
            entradaD => op_slt,
            seletor  => seletor(1 DOWNTO 0),
            saida    => saida
        );

    -- Verificando se o resultado foi zero.
    flagZero <= '1' WHEN unsigned(saida) = 0 ELSE
        '0';
END ARCHITECTURE;