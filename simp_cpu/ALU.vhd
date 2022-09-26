LIBRARY IEEE;USE IEEE.std_logic_1164.all;USE IEEE.std_logic_unsigned.all;
USE work.sys_definition.all;

ENTITY ALU IS
GENERIC (
	DATA_WIDTH : integer := 16
	);
PORT (
	ALUs : IN std_logic_vector (1 downto 0);
	OPr1, OPr2 : IN std_logic_vector (DATA_WIDTH-1 downto 0);
	ALUr : OUT std_logic_vector (DATA_WIDTH-1 downto 0);
	ALUz : OUT std_logic
	);	
END ALU;

ARCHITECTURE ALU_bev OF ALU IS
COMPONENT adder_n_bit IS
GENERIC (
	DATA_WIDTH : integer := 16
	);
PORT (
	a, b: IN std_logic_vector(DATA_WIDTH-1 downto 0);
	sum: OUT std_logic_vector(DATA_WIDTH-1 downto 0)
	);
END COMPONENT;

SIGNAL ADDout, OPr2_not, tmp, SUBout, ORout, ANDout : std_logic_vector (15 downto 0);

BEGIN 
	ALU_add: adder_n_bit GENERIC MAP (DATA_WIDTH => 16)
	PORT MAP (OPr1, OPr2, ADDout);
	
	OPr2_not <= NOT OPr2;
	ALU_sub_tmp: adder_n_bit GENERIC MAP (16)
	PORT MAP (OPr1, OPr2_not, tmp);
	ALU_sub: adder_n_bit GENERIC MAP (16)
	PORT MAP (tmp, x"0001", SUBout);

	ORout <= OPr1 OR OPr2;
	ANDout <= OPr1 AND OPr2;

	WITH ALUs SELECT ALUr <= ADDout WHEN "00",
				 SUBout WHEN "01",
				 ORout WHEN "10",
				 ANDout WHEN "11",
				 (OTHERS => 'Z') WHEN OTHERS;

	ALUz <= '1' when OPr1 = x"0000" else '0';

END ALU_bev;