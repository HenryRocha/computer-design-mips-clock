-- Henry Rocha
-- Vitor Eller
-- Bruno Domingues

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- A unidade de controle eh responsavel por gerar os pontos de controle com base na instrucao sendo utilizada
-- A instrucao eh interpretada baseada no OpCode passado
-- Com isso, geramos um vetor de 8 bits, onde cada um representa um ponto de controle

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
    ALIAS ulaOP               : STD_LOGIC_VECTOR(ULAOP_WIDTH - 1 DOWNTO 0) IS palavraControle(ULAOP_WIDTH DOWNTO 1);
    ALIAS selMuxRtRd          : STD_LOGIC IS palavraControle(ULAOP_WIDTH + 1);
    ALIAS selMuxRtImed        : STD_LOGIC IS palavraControle(ULAOP_WIDTH + 2);
    ALIAS selMuxULAMem        : STD_LOGIC IS palavraControle(ULAOP_WIDTH + 3);
    ALIAS branch              : STD_LOGIC IS palavraControle(ULAOP_WIDTH + 4);
    ALIAS habEscritaMEM       : STD_LOGIC IS palavraControle(ULAOP_WIDTH + 5);
    ALIAS habLeituraMEM       : STD_LOGIC IS palavraControle(ULAOP_WIDTH + 6);
    ALIAS selMuxJmp           : STD_LOGIC IS palavraControle(ULAOP_WIDTH + 7);

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

    -- Declarando todas as intrucoes da CPU e seus OpCodes.
    CONSTANT tipoR     : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0) := "000000";
    CONSTANT opcodeLW  : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0) := "100011";
    CONSTANT opcodeSW  : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0) := "101011";
    CONSTANT opcodeBEQ : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0) := "000100";
    CONSTANT opcodeJ   : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0) := "000010";
BEGIN
    -- Verificando qual a instrucao a ser executada.
    WITH opcode SELECT
        instrucao <= "00001" WHEN tipoR,
        "00010" WHEN opcodeLW,
        "00100" WHEN opcodeSW,
        "01000" WHEN opcodeBEQ,
        "10000" WHEN opcodeJ,
        "00000" WHEN OTHERS;

    -- Logica de quais pontos de controle devem ser habilitados de acordo com o tipo de
    -- instrucao e o opcode.
    habEscritaBancoRegs <= isTipoR;
    selMuxRtRd          <= isTipoR;
    selMuxRtImed        <= isLW OR isSW;
    selMuxULAMem        <= isLW;
    branch              <= isBEQ;
    habEscritaMEM       <= isSW;
    habLeituraMEM       <= isLW;
    selMuxJmp           <= isJ;

    ulaOP <= "00" WHEN (isLW OR isSW) ELSE
        "01" WHEN (isBEQ) ELSE
        "10" WHEN (isTipoR) ELSE
        "00";
END ARCHITECTURE;