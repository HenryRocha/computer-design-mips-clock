-- Autores:
--      Henry Rocha
--      Vitor Eller
--      Bruno Domingues
-- Informacoes:
--      Nome do arquivo: 
--          mips_clock.vhd
--      Descricao:
--          Top Level do projeto. Mapeia as conexoes entre a UC e o FD, alem das
--          conexoes com a placa.

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY mips_clock IS
    GENERIC (
        DATA_WIDTH             : NATURAL := 32;
        INST_WIDTH             : NATURAL := 32;
        NUM_INST               : NATURAL := 12;
        OPCODE_WIDTH           : NATURAL := 6;
        REG_END_WIDTH          : NATURAL := 5;
        FUNCT_WIDTH            : NATURAL := 6;
        PALAVRA_CONTROLE_WIDTH : NATURAL := 16;
        SHAMT_WIDTH            : NATURAL := 5;
        ULAOP_WIDTH            : NATURAL := 3;
        ADDR_WIDTH             : NATURAL := 32;
        SELETOR_ULA_WIDTH      : NATURAL := 3
    );
    PORT (
        -- Input ports
        CLOCK_50     : IN STD_LOGIC;
        SW           : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        KEY          : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        FPGA_RESET_N : IN STD_LOGIC;

        -- Output ports
        LEDR                               : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);

        -- Saidas para simulacao
        palavraControle_debug         : OUT STD_LOGIC_VECTOR(PALAVRA_CONTROLE_WIDTH - 1 DOWNTO 0);
        opCode_debug                  : OUT STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0);
        funct_debug                   : OUT STD_LOGIC_VECTOR(FUNCT_WIDTH - 1 DOWNTO 0);
        flagZero_debug                : OUT STD_LOGIC;
        bancoReg_outA_debug           : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        bancoReg_outB_debug           : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        ULA_out_debug                 : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        PC_out_debug                  : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        selULA_debug                  : OUT STD_LOGIC_VECTOR(SELETOR_ULA_WIDTH - 1 DOWNTO 0);
        mux_ULA_MEM_LUI_JAL_out_debug : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE main OF mips_clock IS
    -- Sinais intermediarios
    SIGNAL palavraControle : STD_LOGIC_VECTOR(PALAVRA_CONTROLE_WIDTH - 1 DOWNTO 0);
    SIGNAL opCode          : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0);
    SIGNAL funct           : STD_LOGIC_VECTOR(FUNCT_WIDTH - 1 DOWNTO 0);
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
            ULAOP_WIDTH            => ULAOP_WIDTH,
            ADDR_WIDTH             => ADDR_WIDTH,
            SELETOR_ULA_WIDTH      => SELETOR_ULA_WIDTH
        )
        PORT MAP(
            clk             => CLOCK_50,
            palavraControle => palavraControle,
            opCode          => opCode,
            flagZero        => flagZero,
            funct           => funct,
            -- Saida para simulacao
            bancoReg_outA_debug           => bancoReg_outA_debug,
            bancoReg_outB_debug           => bancoReg_outB_debug,
            ULA_out_debug                 => ULA_out_debug,
            PC_out_debug                  => PC_out_debug,
            selULA_debug                  => selULA_debug,
            mux_ULA_MEM_LUI_JAL_out_debug => mux_ULA_MEM_LUI_JAL_out_debug
        );

    UC : ENTITY work.unidadeControle
        GENERIC MAP(
            DATA_WIDTH             => DATA_WIDTH,
            INST_WIDTH             => INST_WIDTH,
            NUM_INST               => NUM_INST,
            OPCODE_WIDTH           => OPCODE_WIDTH,
            REG_END_WIDTH          => REG_END_WIDTH,
            FUNCT_WIDTH            => FUNCT_WIDTH,
            PALAVRA_CONTROLE_WIDTH => PALAVRA_CONTROLE_WIDTH,
            SHAMT_WIDTH            => SHAMT_WIDTH,
            ULAOP_WIDTH            => ULAOP_WIDTH,
            ADDR_WIDTH             => ADDR_WIDTH
        )
        PORT MAP(
            clk             => CLOCK_50,
            opCode          => opCode,
            funct           => funct,
            flagZero        => flagZero,
            palavraControle => palavraControle
        );

    -- Saidas de teste
    LEDR(0) <= SW(0);
    LEDR(1) <= NOT KEY(0);
    LEDR(2) <= NOT FPGA_RESET_N;

    -- Saidas para simulacao
    palavraControle_debug <= palavraControle;
    opCode_debug          <= opCode;
    funct_debug           <= funct;
    flagZero_debug        <= flagZero;
END ARCHITECTURE;