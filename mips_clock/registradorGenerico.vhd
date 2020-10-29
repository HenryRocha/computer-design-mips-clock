
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY registradorGenerico IS
    GENERIC (
        larguraDados : NATURAL := 8
    );
    PORT (
        DIN      : IN STD_LOGIC_VECTOR(larguraDados - 1 DOWNTO 0);
        DOUT     : OUT STD_LOGIC_VECTOR(larguraDados - 1 DOWNTO 0);
        ENABLE   : IN STD_LOGIC;
        CLK, RST : IN STD_LOGIC
    );
END ENTITY;

ARCHITECTURE comportamento OF registradorGenerico IS
BEGIN
    -- In Altera devices, register signals have a set priority.
    -- The HDL design should reflect this priority.
    PROCESS (RST, CLK)
    BEGIN
        -- The asynchronous reset signal has the highest priority
        IF (RST = '1') THEN
            DOUT <= (OTHERS => '0'); -- Código reconfigurável.
            ELSE
            -- At a clock edge, if asynchronous signals have not taken priority,
            -- respond to the appropriate synchronous signal.
            -- Check for synchronous reset, then synchronous load.
            -- If none of these takes precedence, update the register output
            -- to be the register input.
            IF (rising_edge(CLK)) THEN
                IF (ENABLE = '1') THEN
                    DOUT <= DIN;
                END IF;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;