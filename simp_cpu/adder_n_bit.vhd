LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY adder_n_bit IS
GENERIC (
	DATA_WIDTH : integer := 16
	);
PORT (
	a, b: IN std_logic_vector(DATA_WIDTH-1 downto 0);
	sum: OUT std_logic_vector(DATA_WIDTH-1 downto 0)
	);
END adder_n_bit;

ARCHITECTURE architecture_adder_n_bit OF adder_n_bit IS
	
COMPONENT full_adder IS
PORT (
	a, b: IN std_logic;
	cin: IN std_logic;
	cout: OUT std_logic;
	sum: OUT std_logic
	);
END COMPONENT;

SIGNAL c: std_logic_vector(DATA_WIDTH downto 0) := (OTHERS => '0');

BEGIN 
 
G: FOR i IN 0 TO DATA_WIDTH-1 GENERATE
	FA: full_adder PORT MAP (a(i),b(i),c(i),c(i+1),sum(i));
	END GENERATE;

END architecture_adder_n_bit;
