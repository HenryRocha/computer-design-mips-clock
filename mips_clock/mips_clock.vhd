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
        SW           : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        FPGA_RESET_N : IN STD_LOGIC;

        -- Output ports
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE main OF mips_clock IS
    -- Sinais intermediarios
    SIGNAL clk                           : STD_LOGIC;
    SIGNAL hexInput                      : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL palavraControle               : STD_LOGIC_VECTOR(PALAVRA_CONTROLE_WIDTH - 1 DOWNTO 0);
    SIGNAL opCode                        : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0);
    SIGNAL funct                         : STD_LOGIC_VECTOR(FUNCT_WIDTH - 1 DOWNTO 0);
    SIGNAL flagZero                      : STD_LOGIC;
    SIGNAL ULA_out_debug                 : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL PC_out_debug                  : STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
    SIGNAL mux_ULA_MEM_LUI_JAL_out_debug : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
BEGIN
    detectorSub0 : ENTITY work.edgeDetector(bordaSubida) PORT MAP (
        clk     => CLOCK_50,
        entrada => (NOT FPGA_RESET_N),
        saida   => clk
        );

    muxHexDisplay : ENTITY work.mux4x1
        GENERIC MAP(
            DATA_WIDTH => DATA_WIDTH
        )
        PORT MAP(
            entradaA => PC_out_debug,
            entradaB => ULA_out_debug,
            entradaC => mux_ULA_MEM_LUI_JAL_out_debug,
            entradaD => (OTHERS => '0'),
            seletor  => SW(1 DOWNTO 0),
            saida    => hexInput
        );

    conversorHEX0 : ENTITY work.conversorHex7Seg
        PORT MAP(
            dadoHex   => hexInput(3 DOWNTO 0),
            apaga     => '0',
            negativo  => '0',
            overFlow  => '0',
            saida7seg => HEX0
        );

    conversorHEX1 : ENTITY work.conversorHex7Seg
        PORT MAP(
            dadoHex   => hexInput(7 DOWNTO 4),
            apaga     => '0',
            negativo  => '0',
            overFlow  => '0',
            saida7seg => HEX1
        );

    conversorHEX2 : ENTITY work.conversorHex7Seg
        PORT MAP(
            dadoHex   => hexInput(11 DOWNTO 8),
            apaga     => '0',
            negativo  => '0',
            overFlow  => '0',
            saida7seg => HEX2
        );

    conversorHEX3 : ENTITY work.conversorHex7Seg
        PORT MAP(
            dadoHex   => hexInput(15 DOWNTO 12),
            apaga     => '0',
            negativo  => '0',
            overFlow  => '0',
            saida7seg => HEX3
        );

    conversorHEX4 : ENTITY work.conversorHex7Seg
        PORT MAP(
            dadoHex   => hexInput(19 DOWNTO 16),
            apaga     => '0',
            negativo  => '0',
            overFlow  => '0',
            saida7seg => HEX4
        );

    conversorHEX5 : ENTITY work.conversorHex7Seg
        PORT MAP(
            dadoHex   => hexInput(23 DOWNTO 20),
            apaga     => '0',
            negativo  => '0',
            overFlow  => '0',
            saida7seg => HEX5
        );

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
            clk             => clk,
            palavraControle => palavraControle,
            opCode          => opCode,
            flagZero        => flagZero,
            funct           => funct,
            -- Saida para simulacao
            bancoReg_outA_debug           => OPEN,
            bancoReg_outB_debug           => OPEN,
            ULA_out_debug                 => ULA_out_debug,
            PC_out_debug                  => PC_out_debug,
            selULA_debug                  => OPEN,
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
            clk             => clk,
            opCode          => opCode,
            funct           => funct,
            flagZero        => flagZero,
            palavraControle => palavraControle
        );
END ARCHITECTURE;