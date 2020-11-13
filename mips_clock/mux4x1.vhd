-- Autores:
--      Henry Rocha
--      Vitor Eller
--      Bruno Domingues
-- Informacoes:
--      Nome do arquivo: 
--          mux4x1.vhd
--      Descricao:
--          Mux de 4 entradas.

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY mux4x1 IS
    GENERIC (
        DATA_WIDTH : NATURAL := 888
    );
    PORT (
        -- Inputs ports
        entradaA : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        entradaB : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        entradaC : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        entradaD : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        seletor  : IN STD_LOGIC_VECTOR(1 DOWNTO 0);

        -- Output ports
        saida : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE comportamento OF mux4x1 IS
BEGIN
    -- Selecionando a entrada de acordo com o seletor.
    saida <= entradaA WHEN (seletor = "00") ELSE
        entradaB WHEN (seletor = "01") ELSE
        entradaC WHEN (seletor = "10") ELSE
        entradaD;
END ARCHITECTURE;