LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL; -- Biblioteca IEEE para funções aritméticas

ENTITY somadorGenerico IS
    GENERIC (
        larguraDados : NATURAL := 32
    );
    PORT (
        entradaA, entradaB : IN STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
        saida              : OUT STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE comportamento OF somadorGenerico IS
BEGIN
    saida <= STD_LOGIC_VECTOR(unsigned(entradaA) + unsigned(entradaB));
END ARCHITECTURE;