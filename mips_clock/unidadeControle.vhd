-- Henry Rocha
-- Vitor Eller
-- Bruno Domingues

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- A unidade de controle � respons�vel por gerar os pontos de controle com base na instru��o sendo utilizada
-- A instru��o � interpretada baseada no OpCode passado
-- Com isso, geramos um vetor de 8 bits, onde cada um representa um ponto de controle

ENTITY unidadeControle IS
    GENERIC (
        DATA_WIDTH             : NATURAL := 8;
        INST_WIDTH             : NATURAL := 32;
        NUM_INST               : NATURAL := 2;
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
    ALIAS operacaoULA         : STD_LOGIC_VECTOR(SELETOR_ULA - 1 DOWNTO 0) IS palavraControle(SELETOR_ULA DOWNTO 1);
    ALIAS selMuxRtRd          : STD_LOGIC IS palavraControle(SELETOR_ULA + 1);
    ALIAS selMuxRtImed        : STD_LOGIC IS palavraControle(SELETOR_ULA + 2);
    ALIAS selMuxULAMem        : STD_LOGIC IS palavraControle(SELETOR_ULA + 3);
    ALIAS beq                 : STD_LOGIC IS palavraControle(SELETOR_ULA + 4);
    ALIAS habEscritaMEM       : STD_LOGIC IS palavraControle(SELETOR_ULA + 5);
    ALIAS habLeituraMEM       : STD_LOGIC IS palavraControle(SELETOR_ULA + 6);
    ALIAS selMuxJmp           : STD_LOGIC IS palavraControle(SELETOR_ULA + 7);

    -- Tipos de instrucoes.
    CONSTANT tipoR : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0) := "000000";
    SIGNAL isTipoR : STD_LOGIC;
    SIGNAL isTipoI : STD_LOGIC;
    SIGNAL isTipoJ : STD_LOGIC;

    -- Opcodes de instrucoes especificas.
    CONSTANT opcodeLoad  : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0) := "100011";
    CONSTANT opcodeStore : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0) := "101011";
    CONSTANT opcodeBeq   : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0) := "000100";
    CONSTANT opcodeJmp   : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0) := "000010";

    -- Todos os tipos de funct possiveis.
    CONSTANT funct_add : STD_LOGIC_VECTOR(5 DOWNTO 0) := "100000";
    CONSTANT funct_sub : STD_LOGIC_VECTOR(5 DOWNTO 0) := "100010";
    CONSTANT funct_or  : STD_LOGIC_VECTOR(5 DOWNTO 0) := "100101";
    CONSTANT funct_and : STD_LOGIC_VECTOR(5 DOWNTO 0) := "100100";
    CONSTANT funct_slt : STD_LOGIC_VECTOR(5 DOWNTO 0) := "101010";

    -- Sinais intermediarios.
    SIGNAL op_ula : STD_LOGIC_VECTOR(SELETOR_ULA - 1 DOWNTO 0);
BEGIN
    -- Verificando qual o tipo de instrucao a ser executada.
    isTipoR <= '1' WHEN (opcode = tipoR) ELSE
        '0';

    isTipoI <= '1' WHEN (opcode = opcodeLoad OR opcode = opcodeStore OR opcode = opcodeBeq) ELSE
        '0';

    -- Verificando qual o funct a ser executado.
    op_ula <= "000" WHEN (funct = funct_add) ELSE
        "001" WHEN (funct = funct_sub) ELSE
        "010" WHEN (funct = funct_or) ELSE
        "011" WHEN (funct = funct_and) ELSE
        "100" WHEN (funct = funct_slt) ELSE
        "000";

    -- Logica de quais pontos de controle devem ser habilitados de acordo com o tipo de
    -- instrucao e o opcode.
    habEscritaBancoRegs <= '1' WHEN (isTipoR = '1' OR (opcode = opcodeLoad)) ELSE
        '0';

    operacaoULA <= op_ula WHEN (isTipoR) ELSE
        "000" WHEN (opcode = opcodeLoad) ELSE
        "000" WHEN (opcode = opcodeStore) ELSE
        "001" WHEN (opcode = opcodeBeq) ELSE
        "000";

    selMuxRtRd <= NOT isTipoI;

    selMuxRtImed <= '1' WHEN (isTipoI = '1' AND opcode /= opcodeBeq) ELSE
        '0';

    selMuxULAMem <= '1' WHEN (opcode = opcodeLoad) ELSE
        '0';

    beq <= '1' WHEN (opcode = opcodeBeq) ELSE
        '0';

    habEscritaMEM <= '1' WHEN (opcode = opcodeStore) ELSE
        '0';

    selMuxJmp <= '1' WHEN (opcode = opcodeJmp) ELSE
        '0';
END ARCHITECTURE;