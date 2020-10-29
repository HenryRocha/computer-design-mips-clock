-- Henry Rocha
-- Vitor Eller
-- Bruno Domingues
-- Top Level do projeto. Mapeia a CPU e as entradas e saídas da placa.

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY mips_clock IS
    GENERIC (
        DATA_WIDTH             : NATURAL := 8;
        INST_WIDTH             : NATURAL := 32;
        OPCODE_WIDTH           : NATURAL := 6;
        REG_END_WIDTH          : NATURAL := 5;
        FUNCT_WIDTH            : NATURAL := 6;
        PALAVRA_CONTROLE_WIDTH : NATURAL := 1;
        SHAMT_WIDTH            : NATURAL := 5;
        ADDR_WIDTH             : NATURAL := 9
    );
    PORT (
        -- Input ports
        CLOCK_50     : IN STD_LOGIC;
        SW           : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        KEY          : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        FPGA_RESET_N : IN STD_LOGIC;

        -- Output ports
        LEDR                               : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE main OF mips_clock IS
    -- Sinais intermediarios
    SIGNAL palavraControle : STD_LOGIC_VECTOR(PALAVRA_CONTROLE_WIDTH - 1 DOWNTO 0);
    SIGNAL opCode          : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0);
    SIGNAL flagZero        : STD_LOGIC;
BEGIN
    fluxoDados : ENTITY work.fluxoDados
        GENERIC MAP(
            DATA_WIDTH             => DATA_WIDTH,
            INST_WIDTH             => INST_WIDTH,
            OPCODE_WIDTH           => OPCODE_WIDTH,
            REG_END_WIDTH          => REG_END_WIDTH,
            FUNCT_WIDTH            => FUNCT_WIDTH,
            PALAVRA_CONTROLE_WIDTH => PALAVRA_CONTROLE_WIDTH,
            SHAMT_WIDTH            => SHAMT_WIDTH,
            ADDR_WIDTH             => ADDR_WIDTH
        )
        PORT MAP(
            clk             => CLOCK_50,
            palavraControle => palavraControle,
            opCode          => opCode,
            flagZero        => flagZero
        );

    -- Saidas de teste
    LEDR(0) <= SW(0);
    LEDR(1) <= NOT KEY(0);
    LEDR(2) <= NOT FPGA_RESET_N;
END ARCHITECTURE;