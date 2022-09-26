
-- Nguyen Kiem Hung
-- controller

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;
USE work.sys_definition.all;

ENTITY controller_tb IS             	

END controller_tb;

ARCHITECTURE behavior OF controller_tb IS
COMPONENT controller
GENERIC (
	DATA_WIDTH : integer := 16;  -- Data Width
	RF_ADDR_WIDTH : integer := 4   -- Address width
	);
PORT (
	clk : IN std_logic;    -- Clock
	nReset : IN std_logic; -- low active reset signal
	start : IN std_logic;    -- high active Start: enable cpu
	
	Instr : IN std_logic_vector (DATA_WIDTH-1 downto 0); -- RF Instruction 

         -- status signals from ALU
	ALUz : IN std_logic;

     	-- Control signals
	-- Memory Read/Write Enable
     	Mre, Mwe : OUT std_logic;

	-- Control PC
	PCclr, PCinc, PCld : OUT std_logic;
	
	-- Control IR
	IRld : OUT std_logic;
	
	-- Select Memory mux, RF mux and ALU
	Ms, RFs, ALUs : OUT std_logic_vector (1 downto 0);
	
	-- Control RF read/write
	RFwa, OPr1a, OPr2a : OUT std_logic_vector (RF_ADDR_WIDTH-1 downto 0); -- Address
	RFwe, OPr1e, OPr2e : OUT std_logic; -- Enable
	current_state : OUT state_type
	);
END COMPONENT;
	-- types and signals are declared here  
SIGNAL clk : std_logic := '0';
SIGNAL nReset, start : std_logic;
SIGNAL Instr : std_logic_vector (15 downto 0);
SIGNAL ALUz, Mre, Mwe, PCclr, PCinc, PCld, IRld : std_logic;
SIGNAL Ms, RFs, ALUs : std_logic_vector (1 downto 0);
SIGNAL RFwa, OPr1a, OPr2a : std_logic_vector (3 downto 0);
SIGNAL RFwe, OPr1e, OPr2e: std_logic;
SIGNAL state : state_type;
CONSTANT clk_period : time := 5 ns;
	 
BEGIN

--Controller;
UUT: controller GENERIC MAP (16, 4)
	PORT MAP (clk, nReset, start, Instr, ALUz, Mre, Mwe, PCclr, PCinc, PCld, IRld, Ms, RFs, ALUs,
	RFwa, OPr1a, OPr2a, RFwe, OPr1e, OPr2e, state);

-- Clock generation
	clk <= not clk after clk_period/2;

stim_proc : PROCESS
	BEGIN
        start <= '0'; nReset <= '0'; Instr <= x"0000"; ALUz <= '0';
	WAIT FOR 10 ns;
	start <= '1';
        WAIT FOR 10 ns;                                       
        nReset  <= '1'; -- working
        WAIT FOR 10 ns;
        Instr <= x"0120"; ALUz <= '1';
        WAIT FOR 20 ns;
        Instr <= x"1230";
        WAIT FOR 20 ns;
        Instr <= x"2340";
        WAIT FOR 20 ns;
        Instr <= x"3450";
	WAIT FOR 20 ns;
        Instr <= x"4560";
        WAIT FOR 20 ns;
        Instr <= x"5670";
        WAIT FOR 20 ns;
        Instr <= x"6780";
        WAIT FOR 20 ns;
        Instr <= x"7890";
        WAIT FOR 20 ns;
        Instr <= x"89A0";
        WAIT FOR 20 ns;
        Instr <= x"9AB0";
        WAIT FOR 20 ns;
        Instr <= x"A450";
        WAIT FOR 20 ns;
        Instr <= x"B340";
        WAIT FOR 20 ns;

	
	END PROCESS; 
END behavior;








