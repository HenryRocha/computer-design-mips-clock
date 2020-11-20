-- Autores:
--      Henry Rocha
--      Vitor Eller
--      Bruno Domingues
-- Informacoes:
--      Nome do arquivo: 
--          mux2x1.vhd
--      Descricao:
--          Mux de 2 entradas.

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY mux2x1 IS
    GENERIC (
        DATA_WIDTH : NATURAL := 8
    );
    PORT (
        -- Inputs ports
        entradaA : IN STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0);
        entradaB : IN STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0);
        seletor  : IN STD_LOGIC;

        -- Output ports
        saida : OUT STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE comportamento OF mux2x1 IS
BEGIN
    -- Selecionando a entrada de acordo com o seletor.
    saida <= entradaB WHEN (seletor = '1') ELSE
        entradaA;
END ARCHITECTURE;