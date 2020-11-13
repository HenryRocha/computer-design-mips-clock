-- Autores:
--      Henry Rocha
--      Vitor Eller
--      Bruno Domingues
-- Informacoes:
--      Nome do arquivo: 
--          adder.vhd
--      Descricao:
--          Soma dois vetores de N bits, ignorando o vai_um do bit mais significativo.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY adder IS
	GENERIC (
		DATA_WIDTH : NATURAL := 32
	);
	PORT (
		-- Input ports
		entradaA : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
		entradaB : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
		vem_um   : IN STD_LOGIC;

		-- Output ports
		soma     : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
		overflow : OUT STD_LOGIC
	);
END ENTITY;

ARCHITECTURE rtl OF adder IS
	SIGNAL vai_um : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
BEGIN
	-- Calcula a soma dos primeiros bits.
	somaBit0 : ENTITY work.fullAdder
		PORT MAP(
			entradaA => entradaA(0),
			entradaB => entradaB(0),
			vem_um   => vem_um,
			soma     => soma(0),
			vai_um   => vai_um(0)
		);

	-- Calcula o restante dos bits, usando de um for para economizar linhas
	-- de codigo.
	somaResto : FOR i IN 1 TO DATA_WIDTH - 1 GENERATE
		somaBitX : ENTITY work.fullAdder
			PORT MAP(
				entradaA => entradaA(i),
				entradaB => entradaB(i),
				vem_um   => vai_um(i - 1),
				soma     => soma(i),
				vai_um   => vai_um(i)
			);
	END GENERATE;

	-- Calculando o overflow.
	overflow <= vai_um(DATA_WIDTH - 1) XOR vai_um(DATA_WIDTH - 2);
END ARCHITECTURE;