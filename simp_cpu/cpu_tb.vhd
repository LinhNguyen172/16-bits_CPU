LIBRARY IEEE;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;
USE work.sys_definition.all;
USE std.textio.all;

ENTITY cpu_tb IS

END entity  cpu_tb;

ARCHITECTURE behavior OF cpu_tb IS
COMPONENT cpu IS
GENERIC (
	CONSTANT DATA_WIDTH: integer := 16;     -- Word Width
	CONSTANT ADDR_WIDTH: integer := 16;     -- Address width
	CONSTANT RF_ADDR_WIDTH: integer := 4   -- Register File address width
    );
PORT ( 
	clk : IN std_logic;    -- Clock
	nReset : IN std_logic; -- low active reset signal
	start : IN std_logic;    -- high active Start: enable cpu
	
	Addr_out : OUT std_logic_vector (ADDR_WIDTH-1 downto 0);
	IR_in_test : OUT std_logic_vector (DATA_WIDTH-1 downto 0);
	ALU_out : OUT std_logic_vector (DATA_WIDTH-1 downto 0);
	Ms : OUT std_logic_vector(1 downto 0);
	Mre, Mwe : OUT std_logic;
        RFs : OUT std_logic_vector(1 downto 0);
	RFwa : OUT std_logic_vector(RF_ADDR_WIDTH-1 downto 0);
	RFwe : OUT std_logic;
	OPr1a : OUT std_logic_vector(RF_ADDR_WIDTH-1 downto 0);
	OPr1e : OUT std_logic;
	OPr2a : OUT std_logic_vector(RF_ADDR_WIDTH-1 downto 0);
	OPr2e : OUT std_logic;
	ALUs : OUT std_logic_vector(1 downto 0);
	RF_data : OUT RF_ARRAY (15 downto 0);
	current_state : OUT state_type
        );
END COMPONENT;
CONSTANT clk_period : time := 10 ns;

SIGNAL clk : std_logic := '0';
SIGNAL nReset, start : std_logic;
SIGNAL Addr_out, IR_in_test, ALU_out : std_logic_vector (15 downto 0);
SIGNAL Mre, Mwe, RFwe, OPr1e, OPr2e : std_logic;
SIGNAL RFs, ALUs, Ms: std_logic_vector (1 downto 0);
SIGNAL RFwa, OPr1a, OPr2a : std_logic_vector (3 downto 0);
SIGNAL RF_data : RF_ARRAY (15 downto 0);
SIGNAL current_state : state_type;

BEGIN
	-- write your code here
-- Clock generation
	clk <= not clk after clk_period/2;

-- DUT component	
DUT: cpu GENERIC MAP (16, 16, 4)
	PORT MAP(clk, nReset, start, Addr_out, IR_in_test, ALU_out, Ms, Mre, Mwe, RFs, RFwa,
        RFwe, OPr1a, OPr1e, OPr2a, OPr2e, ALUs, RF_data, current_state);
 
	-- X"0003", -- Mov R0,3 => RF0 = M(3)
	-- X"1007" -- Mov 7,R0 => M(7) = RF0
	-- X"2230", -- M[ RF[2] ] = RF[3]
	-- X"3415", -- RF[4] = 21 -- mov4
	-- X"4450", -- add RF[4] = RF[4] + RF[5]
	-- X"5780", -- SUB RF[7] = RF[7] - RF[8]
	-- X"6812", -- jump 18 if RF[8] = 0
	-- X"7670", -- OR RF[6] = RF[6] OR RF[7] -- or
	-- X"8700", -- AND RF[7] = RF[7] AND RF[0] :AND
	-- X"9511" -- jum to 17
 	
	process begin
		start <= '1';
 		nReset <= '0';
 		wait for 22 ns;
 		nReset <= '1';
 		wait;
 	end process;

END behavior;