-- Autores:
--      Paulo Santos
-- Informacoes:
--      Nome do arquivo: 
--          somaConstante.vhd
--      Descricao:
--          Soma constante. Design inicial veio dos Modelos VHDL.

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY somaConstante IS
    GENERIC (
        larguraDados : NATURAL := 32;
        constante    : NATURAL := 4
    );
    PORT (
        entrada : IN STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
        saida   : OUT STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE comportamento OF somaConstante IS
BEGIN
    saida <= STD_LOGIC_VECTOR(unsigned(entrada) + constante);
END ARCHITECTURE;