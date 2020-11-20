-- Autores:
--      Henry Rocha
--      Vitor Eller
--      Bruno Domingues
-- Informacoes:
--      Nome do arquivo: 
--          signalExtender.vhd
--      Descricao:
--          Extende o sinal de entrada. Faz extensao com sinal e sem sinal, de acordo com
--          o seletor passado.

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY signalExtender IS
    GENERIC (
        larguraDadoEntrada : NATURAL := 888;
        larguraDadoSaida   : NATURAL := 888
    );
    PORT (
        -- Input ports
        estendeSinal_IN : IN STD_LOGIC_VECTOR(larguraDadoEntrada - 1 DOWNTO 0);
        seletor         : IN STD_LOGIC;

        -- Output ports
        estendeSinal_OUT : OUT STD_LOGIC_VECTOR(larguraDadoSaida - 1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE comportamento OF signalExtender IS
BEGIN
    -- O sinal de saida depende do sinal de entreda e do seletor.
    -- Quando o seletor eh '0', a extensao sera feita com sinal.
    -- Quando o seletor eh '1', a extensao sera feita sem sinal.
    estendeSinal_OUT <=
        (larguraDadoSaida - 1 DOWNTO larguraDadoEntrada => '1') & estendeSinal_IN WHEN (estendeSinal_IN(larguraDadoEntrada - 1) = '1' AND seletor = '0') ELSE
        (larguraDadoSaida - 1 DOWNTO larguraDadoEntrada => '0') & estendeSinal_IN WHEN (estendeSinal_IN(larguraDadoEntrada - 1) = '0' AND seletor = '0') ELSE
        (larguraDadoSaida - 1 DOWNTO larguraDadoEntrada => '0') & estendeSinal_IN WHEN (seletor = '1') ELSE
        (OTHERS                                         => '0');
END ARCHITECTURE;