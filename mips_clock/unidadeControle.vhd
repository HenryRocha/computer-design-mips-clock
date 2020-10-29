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

    -- Tipos de instrucoes.
    -- TODO: implementar tipo I e tipo J.
    CONSTANT tipoR : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0) := "000000";
    SIGNAL isTipoR : STD_LOGIC;
    CONSTANT tipoI : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0) := "001100";
    SIGNAL isTipoI : STD_LOGIC;
    CONSTANT tipoJ : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 DOWNTO 0) := "001100";
    SIGNAL isTipoJ : STD_LOGIC;
BEGIN
    -- Verificando qual o tipo de instrucao a ser executada.
    isTipoR <= '1' WHEN (opcode = tipoR) ELSE
        '0';

    -- Logica de quais pontos de controle devem ser habilitados de acordo com o tipo de
    -- instrucao e o opcode.
    habEscritaBancoRegs <= isTipoR;

    operacaoULA <= funct WHEN (isTipoR) ELSE
        "000000";
END ARCHITECTURE;