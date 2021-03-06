-- Autores:
--      Henry Rocha
--      Vitor Eller
--      Bruno Domingues
-- Informacoes:
--      Nome do arquivo: 
--          unidadeControle.vhd
--      Descricao:
--          UC. Responsavel por decodificar o opcode e funct de cada instrucao.
--          Decide quais pontos de controle devem ser acionados.

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY unidadeControle IS
    GENERIC (
        DATA_WIDTH             : NATURAL := 888;
        INST_WIDTH             : NATURAL := 888;
        NUM_INST               : NATURAL := 888;
        OPCODE_WIDTH           : NATURAL := 888;
        REG_END_WIDTH          : NATURAL := 888;
        FUNCT_WIDTH            : NATURAL := 888;
        PALAVRA_CONTROLE_WIDTH : NATURAL := 888;
        SHAMT_WIDTH            : NATURAL := 888;
        ULAOP_WIDTH            : NATURAL := 888;
        ADDR_WIDTH             : NATURAL := 888
    );
    PORT (
        -- Input ports
        clk      : IN STD_LOGIC;
        opcode   : IN STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0);
        funct    : IN STD_LOGIC_VECTOR(FUNCT_WIDTH - 1 DOWNTO 0);
        flagZero : IN STD_LOGIC;

        -- Output ports
        palavraControle : OUT STD_LOGIC_VECTOR(PALAVRA_CONTROLE_WIDTH - 1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE main OF unidadeControle IS
    -- Declarando onde cada ponto de controle sera localizado na palavra de controle.
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

    -- O sinal "instrucao" eh responsavel por dizer qual instrucao esta sendo executada.
    -- Desse modo, ele eh um vetor onde o tamanho eh o numero de instrucoes que o
    -- processador tem.
    SIGNAL instrucao : STD_LOGIC_VECTOR(NUM_INST - 1 DOWNTO 0);
    -- Declarando qual bit do vetor eh cada instrucao.
    ALIAS isTipoR : STD_LOGIC IS instrucao(0);
    ALIAS isLW    : STD_LOGIC IS instrucao(1);
    ALIAS isSW    : STD_LOGIC IS instrucao(2);
    ALIAS isBEQ   : STD_LOGIC IS instrucao(3);
    ALIAS isJ     : STD_LOGIC IS instrucao(4);
    ALIAS isADDI  : STD_LOGIC IS instrucao(5);
    ALIAS isANDI  : STD_LOGIC IS instrucao(6);
    ALIAS isORI   : STD_LOGIC IS instrucao(7);
    ALIAS isSLTI  : STD_LOGIC IS instrucao(8);
    ALIAS isJAL   : STD_LOGIC IS instrucao(9);
    ALIAS isLUI   : STD_LOGIC IS instrucao(10);
    ALIAS isBNE   : STD_LOGIC IS instrucao(11);

    -- Declarando todas as intrucoes da CPU e seus OpCodes.
    CONSTANT tipoR      : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0) := "000000";
    CONSTANT opcodeLW   : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0) := "100011";
    CONSTANT opcodeSW   : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0) := "101011";
    CONSTANT opcodeBEQ  : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0) := "000100";
    CONSTANT opcodeJ    : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0) := "000010";
    CONSTANT opcodeADDI : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0) := "001000";
    CONSTANT opcodeANDI : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0) := "001100";
    CONSTANT opcodeORI  : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0) := "001101";
    CONSTANT opcodeSLTI : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0) := "001010";
    CONSTANT opcodeJAL  : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0) := "000011";
    CONSTANT opcodeLUI  : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0) := "001111";
    CONSTANT opcodeBNE  : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0) := "000101";

    -- Declarando o funct do JR, usado para diferenciar ele
    -- das outras instrucoes tipo R.
    CONSTANT functJR : STD_LOGIC_VECTOR(FUNCT_WIDTH - 1 DOWNTO 0) := "001000";
BEGIN
    -- Verificando qual a instrucao a ser executada.
    WITH opcode SELECT
        instrucao <=
        "000000000001" WHEN tipoR,
        "000000000010" WHEN opcodeLW,
        "000000000100" WHEN opcodeSW,
        "000000001000" WHEN opcodeBEQ,
        "000000010000" WHEN opcodeJ,
        "000000100000" WHEN opcodeADDI,
        "000001000000" WHEN opcodeANDI,
        "000010000000" WHEN opcodeORI,
        "000100000000" WHEN opcodeSLTI,
        "001000000000" WHEN opcodeJAL,
        "010000000000" WHEN opcodeLUI,
        "100000000000" WHEN opcodeBNE,
        "000000000000" WHEN OTHERS;

    -- Logica de quais pontos de controle devem ser habilitados de acordo com o tipo de
    -- instrucao e o opcode.
    habEscritaBancoRegs <= isTipoR OR isADDI OR isANDI OR isORI OR isSLTI OR isJAL OR isLUI;
    selMuxRtRd31        <=
        "01" WHEN isTipoR ELSE
        "10" WHEN isJAL ELSE
        "10" WHEN (isTipoR = '1' AND funct = functJR) ELSE
        "00";
    selMuxRtImed       <= isLW OR isSW OR isADDI OR isANDI OR isORI OR isSLTI;
    selMuxUlaMemLuiJal <=
        "01" WHEN isLW ELSE
        "10" WHEN isLUI ELSE
        "11" WHEN isJAL ELSE
        "00";
    branch        <= isBEQ;
    selBNE        <= isBNE;
    habEscritaMEM <= isSW;
    habLeituraMEM <= isLW;
    selMuxJmp     <=
        "01" WHEN (isJ OR isJAL) ELSE
        "10" WHEN (isTipoR = '1' AND funct = functJR) ELSE
        "00";
    selSignalExtender <= isORI;

    ula_op <= "000" WHEN (isLW OR isSW) ELSE
        "001" WHEN (isBEQ OR isBNE) ELSE
        "010" WHEN (isTipoR) ELSE
        "000" WHEN (isADDI) ELSE
        "011" WHEN (isANDI) ELSE
        "100" WHEN (isORI) ELSE
        "101" WHEN (isSLTI) ELSE
        "000";
END ARCHITECTURE;