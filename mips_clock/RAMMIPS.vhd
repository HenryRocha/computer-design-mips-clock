LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY RAMMIPS IS
    GENERIC (
        dataWidth       : NATURAL := 32;
        addrWidth       : NATURAL := 32;
        memoryAddrWidth : NATURAL := 6); -- 64 posicoes de 32 bits cada
    PORT (
        clk      : IN STD_LOGIC;
        Endereco : IN STD_LOGIC_VECTOR (addrWidth - 1 DOWNTO 0);
        Dado_in  : IN STD_LOGIC_VECTOR(dataWidth - 1 DOWNTO 0);
        Dado_out : OUT STD_LOGIC_VECTOR(dataWidth - 1 DOWNTO 0);
        we       : IN STD_LOGIC := '0'
    );
END ENTITY;

ARCHITECTURE assincrona OF RAMMIPS IS
    TYPE blocoMemoria IS ARRAY(0 TO 2 ** memoryAddrWidth - 1) OF STD_LOGIC_VECTOR(dataWidth - 1 DOWNTO 0);

    SIGNAL memRAM : blocoMemoria;
    --  Caso queira inicializar a RAM (para testes):
    --  attribute ram_init_file : string;
    --  attribute ram_init_file of memRAM:
    --  signal is "RAMcontent.mif";

    -- Utiliza uma quantidade menor de endereços locais:
    SIGNAL EnderecoLocal : STD_LOGIC_VECTOR(memoryAddrWidth - 1 DOWNTO 0);
BEGIN
    -- Ajusta o enderecamento para o acesso de 32 bits.
    EnderecoLocal <= Endereco(memoryAddrWidth + 1 DOWNTO 2);

    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (we = '1') THEN
                memRAM(to_integer(unsigned(EnderecoLocal))) <= Dado_in;
            END IF;
        END IF;
    END PROCESS;

    -- A leitura deve ser sempre assincrona:
    Dado_out <= memRAM(to_integer(unsigned(EnderecoLocal)));
END ARCHITECTURE;