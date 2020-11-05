LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- Baseado no apendice C (Register Files) do COD (Patterson & Hennessy).

ENTITY bancoRegistradores IS
    GENERIC (
        larguraDados        : NATURAL := 32;
        larguraEndBancoRegs : NATURAL := 5 --Resulta em 2^5=32 posicoes
    );
    -- Leitura de 2 registradores e escrita em 1 registrador simultaneamente.
    PORT (
        clk : IN STD_LOGIC;
        --
        enderecoA : IN STD_LOGIC_VECTOR((larguraEndBancoRegs - 1) DOWNTO 0);
        enderecoB : IN STD_LOGIC_VECTOR((larguraEndBancoRegs - 1) DOWNTO 0);
        enderecoC : IN STD_LOGIC_VECTOR((larguraEndBancoRegs - 1) DOWNTO 0);
        --
        dadoEscritaC : IN STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
        escreveC     : IN STD_LOGIC := '0';
        --
        saidaA : OUT STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
        saidaB : OUT STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE comportamento OF bancoRegistradores IS
    SUBTYPE palavra_t IS STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
    TYPE memoria_t IS ARRAY(2 ** larguraEndBancoRegs - 1 DOWNTO 0) OF palavra_t;

    FUNCTION initMemory
        RETURN memoria_t IS VARIABLE tmp : memoria_t := (OTHERS => (OTHERS => '0'));
    BEGIN
        tmp(0)  := x"00000000";
        tmp(1)  := x"00000000";
        tmp(2)  := x"00000000";
        tmp(3)  := x"00000000";
        tmp(4)  := x"00000000";
        tmp(5)  := x"00000000";
        tmp(6)  := x"00000000";
        tmp(7)  := x"00000000";
        tmp(8)  := x"00000000";
        tmp(9)  := x"0000000A";
        tmp(10) := x"0000000B";
        tmp(11) := x"0000000C";
        tmp(12) := x"0000000D";
        tmp(13) := x"00000016";
        tmp(14) := x"00000000";
        tmp(15) := x"00000000";
        tmp(16) := x"00000000";
        tmp(17) := x"00000000";
        tmp(18) := x"00000000";
        tmp(19) := x"00000000";
        tmp(20) := x"00000000";
        tmp(21) := x"00000000";
        tmp(22) := x"00000000";
        tmp(23) := x"00000000";
        tmp(24) := x"00000000";
        tmp(25) := x"00000000";
        tmp(26) := x"00000000";
        tmp(27) := x"00000000";
        tmp(28) := x"00000000";
        tmp(29) := x"00000000";
        tmp(30) := x"00000000";
        tmp(31) := x"00000000";
        RETURN tmp;
    END initMemory;

    -- Declaracao dos registradores:
    SHARED VARIABLE registrador : memoria_t := initMemory;
BEGIN
    PROCESS (clk) IS
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (escreveC = '1') THEN
                registrador(to_integer(unsigned(enderecoC))) := dadoEscritaC;
            END IF;
        END IF;
    END PROCESS;

    -- IF endereco = 0 : retorna ZERO
    PROCESS (ALL) IS
    BEGIN
        IF (unsigned(enderecoA) = 0) THEN
            saidaA <= (OTHERS => '0');
        ELSE
            saidaA <= registrador(to_integer(unsigned(enderecoA)));
        END IF;
        IF (unsigned(enderecoB) = 0) THEN
            saidaB <= (OTHERS => '0');
        ELSE
            saidaB <= registrador(to_integer(unsigned(enderecoB)));
        END IF;
    END PROCESS;
END ARCHITECTURE;