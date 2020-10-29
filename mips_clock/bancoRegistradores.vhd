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
        tmp(0)  := "00000000000000000000000000000000";
        tmp(1)  := "00000000000000000000000000000000";
        tmp(2)  := "00000000000000000000000000000000";
        tmp(3)  := "00000000000000000000000000000000";
        tmp(4)  := "00000000000000000000000000000000";
        tmp(5)  := "00000000000000000000000000000000";
        tmp(6)  := "00000000000000000000000000000000";
        tmp(7)  := "00000000000000000000000000000000";
        tmp(8)  := "00000000000000000000000000000001";
        tmp(9)  := "00000000000000000000000000000001";
        tmp(10) := "00000000000000000000000000000000";
        tmp(11) := "00000000000000000000000000000000";
        tmp(12) := "00000000000000000000000000000000";
        tmp(13) := "00000000000000000000000000000000";
        tmp(14) := "00000000000000000000000000000000";
        tmp(15) := "00000000000000000000000000000000";
        tmp(16) := "00000000000000000000000000000000";
        tmp(17) := "00000000000000000000000000000000";
        tmp(18) := "00000000000000000000000000000000";
        tmp(19) := "00000000000000000000000000000000";
        tmp(20) := "00000000000000000000000000000000";
        tmp(21) := "00000000000000000000000000000000";
        tmp(22) := "00000000000000000000000000000000";
        tmp(23) := "00000000000000000000000000000000";
        tmp(24) := "00000000000000000000000000000000";
        tmp(25) := "00000000000000000000000000000000";
        tmp(26) := "00000000000000000000000000000000";
        tmp(27) := "00000000000000000000000000000000";
        tmp(28) := "00000000000000000000000000000000";
        tmp(29) := "00000000000000000000000000000000";
        tmp(30) := "00000000000000000000000000000000";
        tmp(31) := "00000000000000000000000000000000";
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