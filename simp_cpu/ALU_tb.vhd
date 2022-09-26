LIBRARY IEEE;USE IEEE.std_logic_1164.all;USE IEEE.std_logic_unsigned.all;
USE work.sys_definition.all;

ENTITY ALU_tb IS

END ALU_tb;

ARCHITECTURE ALU_tb_bev OF ALU_tb IS
COMPONENT ALU IS
GENERIC (
	DATA_WIDTH : integer := 16
	);
PORT (
	ALUs : IN std_logic_vector (1 downto 0);
	OPr1, OPr2 : IN std_logic_vector (DATA_WIDTH-1 downto 0);
	ALUr : OUT std_logic_vector (DATA_WIDTH-1 downto 0);
	ALUz : OUT std_logic
	);	
END COMPONENT;

SIGNAL ALUs : std_logic_vector (1 downto 0) := "00";
SIGNAL OPr1 : std_logic_vector (15 downto 0) := X"0009";
SIGNAL OPr2 : std_logic_vector (15 downto 0) := X"2102";
SIGNAL ALUr : std_logic_vector (15 downto 0);
SIGNAL ALUz : std_logic;
SIGNAL clk : std_logic := '0';

CONSTANT clk_period : time := 20 ns;
BEGIN 

	clk <= not clk AFTER clk_period/2;

DUT: ALU GENERIC MAP (16)
	PORT MAP (ALUs, OPr1, OPr2, ALUr, ALUz);
	
stim_pro: PROCESS
	BEGIN
	WAIT FOR 20 ns;
	ALUs <= ALUs + 1;
	OPr1 <= OPr1 - 1;
	OPr2 <= OPr2 - 9;
END PROCESS;
END ALU_tb_bev;