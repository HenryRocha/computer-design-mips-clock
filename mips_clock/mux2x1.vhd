LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY mux2x1 IS
    -- Total de bits das entradas e saidas
    GENERIC (
        larguraDados : NATURAL := 8
    );
    PORT (
        entradaA_MUX, entradaB_MUX : IN STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
        seletor_MUX                : IN STD_LOGIC;
        saida_MUX                  : OUT STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE comportamento OF mux2x1 IS
BEGIN
    saida_MUX <= entradaB_MUX WHEN (seletor_MUX = '1') ELSE
        entradaA_MUX;
END ARCHITECTURE;