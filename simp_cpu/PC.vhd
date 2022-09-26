LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;

ENTITY PC IS
GENERIC (
	DATA_WIDTH : integer := 16
	); 
PORT (
	D : IN std_logic_vector (DATA_WIDTH-1 downto 0);
	clk, PCclr, PCinc, PCld: IN std_logic;
	PCout: OUT std_logic_vector (DATA_WIDTH-1 downto 0)
	);
END PC;

ARCHITECTURE PC_bev OF PC IS
SIGNAL Q : std_logic_vector (15 downto 0);
BEGIN
PC_stimulus: PROCESS(clk, PCclr, PCinc, PCld)
	BEGIN
		IF PCclr = '1' THEN 
			Q <= (OTHERS => '0');
		ELSIF clk'event and clk = '1' THEN
			IF PCinc = '1' THEN
 				Q <= Q + 1;
			ELSIF PCld = '1' THEN
				Q <= D;
			END IF;
		END IF;
	END PROCESS;
	PCout <= Q;
END PC_bev;
