-- Autores:
--      Paulo Santos
-- Modificado por:
--      Henry Rocha
--      Vitor Eller
--      Bruno Domingues
-- Informacoes:
--      Nome do arquivo: 
--          flipFlopGenerico.vhd
--      Descricao:
--          Flip Flop. Design inicial veio dos modelos VHDL da aula 2 e foi
--          alterado para usar das flags ENABLE e RST.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY flipFlopGenerico IS
    PORT (
        -- Input ports
        DIN    : IN STD_LOGIC;
        ENABLE : IN STD_LOGIC;
        RST    : IN STD_LOGIC;
        CLK    : IN STD_LOGIC;
        -- Output ports
        DOUT : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE main OF flipFlopGenerico IS
BEGIN
    PROCESS (RST, CLK)
    BEGIN
        -- Reset o valor de DOUT caso a flag RST seja ativada.
        IF (RST = '1') THEN
            DOUT <= '0';
        ELSE
            IF (rising_edge(CLK)) THEN
                IF (ENABLE = '1') THEN
                    DOUT <= DIN;
                END IF;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;