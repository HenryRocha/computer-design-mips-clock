-- Henry Rocha
-- Vitor Eller
-- Bruno Domingues

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fluxoDados IS
    GENERIC (
        DATA_WIDTH             : NATURAL := 888;
        INST_WIDTH             : NATURAL := 888;
        OPCODE_WIDTH           : NATURAL := 888;
        REG_END_WIDTH          : NATURAL := 888;
        FUNCT_WIDTH            : NATURAL := 888;
        PALAVRA_CONTROLE_WIDTH : NATURAL := 888;
        SHAMT_WIDTH            : NATURAL := 888;
        ULAOP_WIDTH            : NATURAL := 888;
        ADDR_WIDTH             : NATURAL := 888;
        SELETOR_ULA_WIDTH      : NATURAL := 888
    );
    PORT (
        -- Input ports
        clk             : IN STD_LOGIC;
        palavraControle : IN STD_LOGIC_VECTOR(PALAVRA_CONTROLE_WIDTH - 1 DOWNTO 0);
        -- Output ports
        opCode   : OUT STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0);
        funct    : OUT STD_LOGIC_VECTOR(FUNCT_WIDTH - 1 DOWNTO 0);
        flagZero : OUT STD_LOGIC;
        -- Saidas para simulacao
        bancoReg_outA_debug           : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        bancoReg_outB_debug           : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        ULA_out_debug                 : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        PC_out_debug                  : OUT STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
        selULA_debug                  : OUT STD_LOGIC_VECTOR(SELETOR_ULA_WIDTH - 1 DOWNTO 0);
        mux_ULA_MEM_LUI_JAL_out_debug : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE main OF fluxoDados IS
    -- Sinais intermediarios
    SIGNAL somaUm_out       : STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
    SIGNAL PC_out           : STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
    SIGNAL instrucao        : STD_LOGIC_VECTOR(INST_WIDTH - 1 DOWNTO 0);
    SIGNAL ULA_out          : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL bancoReg_outA    : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL bancoReg_outB    : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL ULA_flagZero_out : STD_LOGIC;
    SIGNAL imedTipoI_ext    : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL muxRtMem_out     : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL muxRtRd_out      : STD_LOGIC_VECTOR(REG_END_WIDTH - 1 DOWNTO 0);
    SIGNAL RAM_out          : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL muxULAMem_out    : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL somaImedPc4_out  : STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
    SIGNAL muxBeq_out       : STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
    SIGNAL muxJmp_out       : STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
    SIGNAL selULA           : STD_LOGIC_VECTOR(SELETOR_ULA_WIDTH - 1 DOWNTO 0);

    -- Partes da instrucao tipo R
    ALIAS instOpCode : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0) IS instrucao(31 DOWNTO 26);
    ALIAS rs         : STD_LOGIC_VECTOR(REG_END_WIDTH - 1 DOWNTO 0) IS instrucao(25 DOWNTO 21);
    ALIAS rt         : STD_LOGIC_VECTOR(REG_END_WIDTH - 1 DOWNTO 0) IS instrucao(20 DOWNTO 16);
    ALIAS rd         : STD_LOGIC_VECTOR(REG_END_WIDTH - 1 DOWNTO 0) IS instrucao(15 DOWNTO 11);
    ALIAS shamt      : STD_LOGIC_VECTOR(SHAMT_WIDTH - 1 DOWNTO 0) IS instrucao(10 DOWNTO 6);
    ALIAS instFunct  : STD_LOGIC_VECTOR(FUNCT_WIDTH - 1 DOWNTO 0) IS instrucao(5 DOWNTO 0);

    -- Partes da instrucao tipo I
    ALIAS imedTipoI : STD_LOGIC_VECTOR(15 DOWNTO 0) IS instrucao(15 DOWNTO 0);

    -- Partes da instrucao tipo J
    ALIAS imedTipoJ : STD_LOGIC_VECTOR(25 DOWNTO 0) IS instrucao(25 DOWNTO 0);

    -- Partes da palavra de controle
    ALIAS habEscritaBancoRegs : STD_LOGIC IS palavraControle(0);
    ALIAS ula_op              : STD_LOGIC_VECTOR(ULAOP_WIDTH - 1 DOWNTO 0) IS palavraControle(3 DOWNTO 1);
    ALIAS selMuxRtRd31        : STD_LOGIC_VECTOR(1 DOWNTO 0) IS palavraControle(5 DOWNTO 4);
    ALIAS selMuxRtImed        : STD_LOGIC IS palavraControle(6);
    ALIAS selMuxUlaMemLuiJal  : STD_LOGIC_VECTOR(1 DOWNTO 0) IS palavraControle(8 DOWNTO 7);
    ALIAS branch              : STD_LOGIC IS palavraControle(9);
    ALIAS habEscritaMEM       : STD_LOGIC IS palavraControle(10);
    ALIAS habLeituraMEM       : STD_LOGIC IS palavraControle(11);
    ALIAS selMuxJmp           : STD_LOGIC_VECTOR(1 DOWNTO 0) IS palavraControle(13 DOWNTO 12);
    ALIAS selSignalExtender   : STD_LOGIC IS palavraControle(14);
    ALIAS selBNE              : STD_LOGIC IS palavraControle(15);

    -- Constantes
    CONSTANT INCREMENTO : NATURAL := 4;
BEGIN
    PC : ENTITY work.registradorGenerico
        GENERIC MAP(
            larguraDados => ADDR_WIDTH
        )
        PORT MAP(
            DIN    => muxJmp_out,
            DOUT   => PC_out,
            ENABLE => '1',
            CLK    => clk,
            RST    => '0'
        );

    somaUm : ENTITY work.somaConstante
        GENERIC MAP(
            larguraDados => ADDR_WIDTH,
            constante    => INCREMENTO
        )
        PORT MAP(
            entrada => PC_out,
            saida   => somaUm_out
        );

    somaImedPc4 : ENTITY work.somadorGenerico
        GENERIC MAP(
            larguraDados => ADDR_WIDTH
        )
        PORT MAP(
            entradaA => somaUm_out,
            entradaB => imedTipoI_ext(29 DOWNTO 0) & "00",
            saida    => somaImedPc4_out
        );

    muxBeq : ENTITY work.mux2x1
        GENERIC MAP(
            DATA_WIDTH => ADDR_WIDTH
        )
        PORT MAP(
            entradaA => somaUm_out,
            entradaB => somaImedPc4_out,
            seletor  => (branch AND ULA_flagZero_out) OR (selBNE AND (NOT ULA_flagZero_out)),
            saida    => muxBeq_out
        );

    muxJmp : ENTITY work.mux4x1
        GENERIC MAP(
            DATA_WIDTH => ADDR_WIDTH
        )
        PORT MAP(
            entradaA => muxBeq_out,
            entradaB => PC_out(31 DOWNTO 28) & imedTipoJ & "00",
            entradaC => bancoReg_outA,
            entradaD => (OTHERS => '0'),
            seletor  => selMuxJmp,
            saida    => muxJmp_out
        );

    ROM : ENTITY work.ROMMIPS
        GENERIC MAP(
            dataWidth       => INST_WIDTH,
            addrWidth       => ADDR_WIDTH,
            memoryAddrWidth => 6
        )
        PORT MAP(
            clk      => clk,
            Endereco => PC_out,
            Dado     => instrucao
        );

    estendeImedTipoI : ENTITY work.signalExtender
        GENERIC MAP(
            larguraDadoEntrada => 16,
            larguraDadoSaida   => DATA_WIDTH
        )
        PORT MAP(
            estendeSinal_IN  => imedTipoI,
            seletor          => selSignalExtender,
            estendeSinal_OUT => imedTipoI_ext
        );

    mux_RT_RD_31 : ENTITY work.mux4x1
        GENERIC MAP(
            DATA_WIDTH => REG_END_WIDTH
        )
        PORT MAP(
            entradaA => rt,
            entradaB => rd,
            entradaC => STD_LOGIC_VECTOR(to_unsigned(31, REG_END_WIDTH)),
            entradaD => (OTHERS => '0'),
            seletor  => selMuxRtRd31,
            saida    => muxRtRd_out
        );

    bancoRegs : ENTITY work.bancoRegistradores
        GENERIC MAP(
            larguraDados        => DATA_WIDTH,
            larguraEndBancoRegs => 5
        )
        PORT MAP(
            clk          => clk,
            enderecoA    => rs,
            enderecoB    => rt,
            enderecoC    => muxRtRd_out,
            dadoEscritaC => muxULAMem_out,
            escreveC     => habEscritaBancoRegs,
            saidaA       => bancoReg_outA,
            saidaB       => bancoReg_outB
        );

    muxRtMem : ENTITY work.mux2x1
        GENERIC MAP(
            DATA_WIDTH => DATA_WIDTH
        )
        PORT MAP(
            entradaA => bancoReg_outB,
            entradaB => imedTipoI_ext,
            seletor  => selMuxRtImed,
            saida    => muxRtMem_out
        );

    UC_ULA : ENTITY work.unidadeControleULA
        GENERIC MAP(
            FUNCT_WIDTH       => FUNCT_WIDTH,
            ULAOP_WIDTH       => ULAOP_WIDTH,
            SELETOR_ULA_WIDTH => SELETOR_ULA_WIDTH
        )
        PORT MAP(
            ULA_OP     => ula_op,
            funct      => instFunct,
            UC_ULA_OUT => selULA
        );

    ULA : ENTITY work.ULA
        GENERIC MAP(
            larguraDados => DATA_WIDTH,
            SEL_WIDTH    => SELETOR_ULA_WIDTH
        )
        PORT MAP(
            entradaA => bancoReg_outA,
            entradaB => muxRtMem_out,
            seletor  => selULA,
            saida    => ULA_out,
            flagZero => ULA_flagZero_out
        );

    RAM : ENTITY work.RAMMIPS
        GENERIC MAP(
            dataWidth       => DATA_WIDTH,
            addrWidth       => DATA_WIDTH,
            memoryAddrWidth => 6
        )
        PORT MAP(
            clk      => clk,
            Endereco => ULA_out,
            Dado_in  => bancoReg_outB,
            Dado_out => RAM_out,
            we       => habEscritaMEM
        );

    mux_ULA_MEM_LUI_JAL : ENTITY work.mux4x1
        GENERIC MAP(
            DATA_WIDTH => DATA_WIDTH
        )
        PORT MAP(
            entradaA => ULA_out,
            entradaB => RAM_out,
            entradaC => imedTipoI & STD_LOGIC_VECTOR(to_unsigned(0, 16)),
            entradaD => somaUm_out,
            seletor  => selMuxUlaMemLuiJal,
            saida    => muxULAMem_out
        );

    flipFlopFlagZero : ENTITY work.flipFlopGenerico
        PORT MAP(
            DIN    => ULA_flagZero_out,
            DOUT   => flagZero,
            ENABLE => '1',
            CLK    => clk,
            RST    => '0'
        );

    opCode <= instOpCode;
    funct  <= instFunct;

    -- Saidas de simulacao
    bancoReg_outA_debug           <= bancoReg_outA;
    bancoReg_outB_debug           <= bancoReg_outB;
    ULA_out_debug                 <= ULA_out;
    PC_out_debug                  <= PC_out;
    selULA_debug                  <= selULA;
    mux_ULA_MEM_LUI_JAL_out_debug <= muxULAMem_out;
END ARCHITECTURE;