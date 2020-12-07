-- Autores:
--      Henry Rocha
--      Vitor Eller
--      Bruno Domingues
-- Informacoes:
--      Nome do arquivo: 
--          conversorHex7Seg.vhd
--      Descricao:
--          Usado para configurar os pinos dos displays HEX de acordo com a entraga. Design inicial veio dos Modelos VHDL.

LIBRARY IEEE;
USE ieee.std_logic_1164.ALL;

ENTITY conversorHex7Seg IS
    PORT (
        -- Input ports
        dadoHex  : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        apaga    : IN STD_LOGIC := '0';
        negativo : IN STD_LOGIC := '0';
        overFlow : IN STD_LOGIC := '0';

        -- Output ports
        saida7seg : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) -- := (others => '1')
    );
END ENTITY;

ARCHITECTURE comportamento OF conversorHex7Seg IS
    --
    --       0
    --      ---
    --     |   |
    --    5|   |1
    --     | 6 |
    --      ---
    --     |   |
    --    4|   |2
    --     |   |
    --      ---
    --       3
    --
    SIGNAL rascSaida7seg : STD_LOGIC_VECTOR(6 DOWNTO 0);
BEGIN
    rascSaida7seg <=
        "1000000" WHEN dadoHex = "0000" ELSE ---0
        "1111001" WHEN dadoHex = "0001" ELSE ---1
        "0100100" WHEN dadoHex = "0010" ELSE ---2
        "0110000" WHEN dadoHex = "0011" ELSE ---3
        "0011001" WHEN dadoHex = "0100" ELSE ---4
        "0010010" WHEN dadoHex = "0101" ELSE ---5
        "0000010" WHEN dadoHex = "0110" ELSE ---6
        "1111000" WHEN dadoHex = "0111" ELSE ---7
        "0000000" WHEN dadoHex = "1000" ELSE ---8
        "0010000" WHEN dadoHex = "1001" ELSE ---9
        "0001000" WHEN dadoHex = "1010" ELSE ---A
        "0000011" WHEN dadoHex = "1011" ELSE ---B
        "1000110" WHEN dadoHex = "1100" ELSE ---C
        "0100001" WHEN dadoHex = "1101" ELSE ---D
        "0000110" WHEN dadoHex = "1110" ELSE ---E
        "0001110" WHEN dadoHex = "1111" ELSE ---F
        "1111111";                           -- Apaga todos segmentos.

    saida7seg <=
        "1100010" WHEN (overFlow = '1') ELSE
        "1111111" WHEN (apaga = '1' AND negativo = '0') ELSE
        "0111111" WHEN (apaga = '0' AND negativo = '1') ELSE
        rascSaida7seg;
END ARCHITECTURE;