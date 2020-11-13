-- Autores:
--      Henry Rocha
--      Vitor Eller
--      Bruno Domingues
-- Informacoes:
--      Nome do arquivo: 
--          fullAdder.vhd
--      Descricao:
--          Implementacao de um Full Adder usando apenas portas logicas.
--          Realiza a soma de dois bits, levando em consideracao um vem_um.

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY fullAdder IS
    PORT (
        -- Input ports 
        entradaA : IN STD_LOGIC;
        entradaB : IN STD_LOGIC;
        vem_um   : IN STD_LOGIC;

        -- Output ports
        soma   : OUT STD_LOGIC;
        vai_um : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE rtl OF fullAdder IS
BEGIN
    -- Calcula a soma das entradas, levando em conta o vem_um.
    soma <= (entradaA XOR entradaB) XOR (vem_um);
    -- Calcula o vai_um.
    vai_um <= (entradaA AND entradaB) OR (vem_um AND entradaA) OR (vem_um AND entradaB);
END ARCHITECTURE;