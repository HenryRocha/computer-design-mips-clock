-- Autores:
--      Henry Rocha
--      Vitor Eller
--      Bruno Domingues
-- Informacoes:
--      Nome do arquivo: 
--          edgeDetector.vhd
--      Descricao:
--          Detector de borda. Design inicial veio dos Modelos VHDL.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY edgeDetector IS
    PORT (
        clk     : IN STD_LOGIC;
        entrada : IN STD_LOGIC;
        saida   : OUT STD_LOGIC);
END ENTITY;

ARCHITECTURE bordaSubida OF edgeDetector IS
    SIGNAL saidaQ : STD_LOGIC;
BEGIN
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            saidaQ <= entrada;
        END IF;
    END PROCESS;
    saida <= entrada AND (NOT saidaQ);
END ARCHITECTURE bordaSubida;

ARCHITECTURE bordaDescida OF edgeDetector IS
    SIGNAL saidaQ : STD_LOGIC;
BEGIN
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            saidaQ <= entrada;
        END IF;
    END PROCESS;
    saida <= (NOT entrada) AND saidaQ;
END ARCHITECTURE bordaDescida;