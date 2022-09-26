LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;

ENTITY IR IS
GENERIC (
	DATA_WIDTH : integer := 16
	); 
PORT (
	D : IN std_logic_vector (DATA_WIDTH-1 downto 0);
	clk, IRld: IN std_logic;
	IRout: OUT std_logic_vector (DATA_WIDTH-1 downto 0)
	);
END IR;

ARCHITECTURE IR_bev OF IR IS
BEGIN
IR_stimulus: PROCESS(clk, IRld)
	BEGIN
		IF clk'event and clk = '1' and IRld = '1' THEN
			IRout <= D;
		END IF;
	END PROCESS;
END IR_bev;
