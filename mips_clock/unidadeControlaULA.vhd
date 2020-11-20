LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY unidadeControleULA IS
    GENERIC (
        FUNCT_WIDTH       : NATURAL := 888;
        ULAOP_WIDTH       : NATURAL := 888;
        SELETOR_ULA_WIDTH : NATURAL := 888
    );
    PORT (
        -- Input ports
        ULA_OP : IN STD_LOGIC_VECTOR(ULAOP_WIDTH - 1 DOWNTO 0);
        funct  : IN STD_LOGIC_VECTOR(FUNCT_WIDTH - 1 DOWNTO 0);

        -- Output ports
        UC_ULA_OUT : OUT STD_LOGIC_VECTOR(SELETOR_ULA_WIDTH - 1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE rtl OF unidadeControleULA IS
    -- Todos os tipos de funct possiveis.
    CONSTANT funct_add : STD_LOGIC_VECTOR(FUNCT_WIDTH - 1 DOWNTO 0) := "100000";
    CONSTANT funct_sub : STD_LOGIC_VECTOR(FUNCT_WIDTH - 1 DOWNTO 0) := "100010";
    CONSTANT funct_or  : STD_LOGIC_VECTOR(FUNCT_WIDTH - 1 DOWNTO 0) := "100101";
    CONSTANT funct_and : STD_LOGIC_VECTOR(FUNCT_WIDTH - 1 DOWNTO 0) := "100100";
    CONSTANT funct_slt : STD_LOGIC_VECTOR(FUNCT_WIDTH - 1 DOWNTO 0) := "101010";

    -- Todas as operacoes da ULA e seus seletores.
    CONSTANT ula_and : STD_LOGIC_VECTOR(SELETOR_ULA_WIDTH - 1 DOWNTO 0) := "000";
    CONSTANT ula_or  : STD_LOGIC_VECTOR(SELETOR_ULA_WIDTH - 1 DOWNTO 0) := "001";
    CONSTANT ula_add : STD_LOGIC_VECTOR(SELETOR_ULA_WIDTH - 1 DOWNTO 0) := "010";
    CONSTANT ula_sub : STD_LOGIC_VECTOR(SELETOR_ULA_WIDTH - 1 DOWNTO 0) := "110";
    CONSTANT ula_slt : STD_LOGIC_VECTOR(SELETOR_ULA_WIDTH - 1 DOWNTO 0) := "111";
BEGIN
    UC_ULA_OUT <=
        ula_add WHEN (ULA_OP = "010" AND funct = funct_add) OR (ULA_OP = "000") ELSE
        ula_sub WHEN (ULA_OP = "010" AND funct = funct_sub) OR (ULA_OP = "001") ELSE
        ula_or WHEN (ULA_OP = "010" AND funct = funct_or) OR (ULA_OP = "100") ELSE
        ula_and WHEN (ULA_OP = "010" AND funct = funct_and) OR (ULA_OP = "011") ELSE
        ula_slt WHEN (ULA_OP = "010" AND funct = funct_slt) OR (ULA_OP = "101")ELSE
        "000";
END ARCHITECTURE;