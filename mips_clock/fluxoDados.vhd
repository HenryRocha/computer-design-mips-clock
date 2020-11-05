-- Henry Rocha
-- Vitor Eller
-- Bruno Domingues

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY fluxoDados IS
    GENERIC (
        DATA_WIDTH             : NATURAL := 8;
        INST_WIDTH             : NATURAL := 32;
        OPCODE_WIDTH           : NATURAL := 6;
        REG_END_WIDTH          : NATURAL := 6;
        FUNCT_WIDTH            : NATURAL := 6;
        PALAVRA_CONTROLE_WIDTH : NATURAL := 6;
        SHAMT_WIDTH            : NATURAL := 6;
        SELETOR_ULA            : NATURAL := 3;
        ADDR_WIDTH             : NATURAL := 32
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
        bancoReg_outA_debug : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        bancoReg_outB_debug : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        ULA_out_debug       : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        PC_out_debug        : OUT STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0)
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

    -- Partes da instrucao tipo R
    ALIAS instOpCode : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0) IS instrucao(31 DOWNTO 26);
    ALIAS rs         : STD_LOGIC_VECTOR(REG_END_WIDTH - 1 DOWNTO 0) IS instrucao(25 DOWNTO 21);
    ALIAS rt         : STD_LOGIC_VECTOR(REG_END_WIDTH - 1 DOWNTO 0) IS instrucao(20 DOWNTO 16);
    ALIAS rd         : STD_LOGIC_VECTOR(REG_END_WIDTH - 1 DOWNTO 0) IS instrucao(15 DOWNTO 11);
    ALIAS shamt      : STD_LOGIC_VECTOR(SHAMT_WIDTH - 1 DOWNTO 0) IS instrucao(10 DOWNTO 6);
    ALIAS instFunct  : STD_LOGIC_VECTOR(FUNCT_WIDTH - 1 DOWNTO 0) IS instrucao(5 DOWNTO 0);

    -- Partes da instrucao tipo I
    ALIAS imedTipoI : STD_LOGIC_VECTOR(15 DOWNTO 0) IS instrucao(15 DOWNTO 0);

    -- Partes da palavra de controle
    ALIAS habEscritaBancoRegs : STD_LOGIC IS palavraControle(0);
    ALIAS operacaoULA         : STD_LOGIC_VECTOR(SELETOR_ULA - 1 DOWNTO 0) IS palavraControle(SELETOR_ULA DOWNTO 1);
    ALIAS selMuxRtRd          : STD_LOGIC IS palavraControle(SELETOR_ULA + 1);
    ALIAS selMuxRtImed        : STD_LOGIC IS palavraControle(SELETOR_ULA + 2);
    ALIAS selMuxULAMem        : STD_LOGIC IS palavraControle(SELETOR_ULA + 3);
    ALIAS beq                 : STD_LOGIC IS palavraControle(SELETOR_ULA + 4);
    ALIAS habEscritaMEM       : STD_LOGIC IS palavraControle(SELETOR_ULA + 5);
    ALIAS habLeituraMEM       : STD_LOGIC IS palavraControle(SELETOR_ULA + 6);

    -- Constantes
    CONSTANT INCREMENTO : NATURAL := 4;
BEGIN
    PC : ENTITY work.registradorGenerico
        GENERIC MAP(
            larguraDados => ADDR_WIDTH
        )
        PORT MAP(
            DIN    => muxBeq_out,
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

    muxBeq : ENTITY work.muxGenerico2x1
        GENERIC MAP(
            larguraDados => ADDR_WIDTH
        )
        PORT MAP(
            entradaA_MUX => somaUm_out,
            entradaB_MUX => somaImedPc4_out,
            seletor_MUX  => beq,
            saida_MUX    => muxBeq_out
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

    estendeImedTipoI : ENTITY work.estendeSinalGenerico
        GENERIC MAP(
            larguraDadoEntrada => 16,
            larguraDadoSaida   => DATA_WIDTH
        )
        PORT MAP(
            estendeSinal_IN  => imedTipoI,
            estendeSinal_OUT => imedTipoI_ext
        );

    muxRtRd : ENTITY work.muxGenerico2x1
        GENERIC MAP(
            larguraDados => REG_END_WIDTH
        )
        PORT MAP(
            entradaA_MUX => rt,
            entradaB_MUX => rd,
            seletor_MUX  => selMuxRtRd,
            saida_MUX    => muxRtRd_out
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

    muxRtMem : ENTITY work.muxGenerico2x1
        GENERIC MAP(
            larguraDados => DATA_WIDTH
        )
        PORT MAP(
            entradaA_MUX => bancoReg_outB,
            entradaB_MUX => imedTipoI_ext,
            seletor_MUX  => selMuxRtImed,
            saida_MUX    => muxRtMem_out
        );

    ULA : ENTITY work.ULA
        GENERIC MAP(
            larguraDados => DATA_WIDTH,
            SEL_WIDTH    => SELETOR_ULA
        )
        PORT MAP(
            entradaA => bancoReg_outA,
            entradaB => muxRtMem_out,
            seletor  => operacaoULA,
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

    muxULAMem : ENTITY work.muxGenerico2x1
        GENERIC MAP(
            larguraDados => DATA_WIDTH
        )
        PORT MAP(
            entradaA_MUX => ULA_out,
            entradaB_MUX => RAM_out,
            seletor_MUX  => selMuxULAMem,
            saida_MUX    => muxULAMem_out
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
    bancoReg_outA_debug <= bancoReg_outA;
    bancoReg_outB_debug <= bancoReg_outB;
    ULA_out_debug       <= ULA_out;
    PC_out_debug        <= PC_out;
END ARCHITECTURE;