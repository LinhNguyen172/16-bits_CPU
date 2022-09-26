
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE work.sys_definition.all;

ENTITY datapath_tb IS

END datapath_tb;

ARCHITECTURE behavior OF datapath_tb IS
COMPONENT datapath IS
GENERIC (
	DATA_WIDTH : integer := 16; -- Data Width
	ADDR_WIDTH : integer := 16; -- Address width
	RF_ADDR_WIDTH : integer := 4  -- Address width
	);
PORT ( 

	--MUX
	RFs : IN std_logic_vector (1 downto 0);
	IRout_lower : IN std_logic_vector (DATA_WIDTH-1 downto 0);
	Data_from_memory: IN std_logic_vector (DATA_WIDTH-1 downto 0);

	-- ALU
	ALUs : IN std_logic_vector (1 downto 0);
	ALUr : OUT std_logic_vector (DATA_WIDTH-1 downto 0);
	ALUz : OUT std_logic;

	-- RF
	clk : IN std_logic;
	nReset : IN std_logic;
	RFwa : IN std_logic_vector (RF_ADDR_WIDTH-1 downto 0); -- Write address
	RFwe : IN std_logic; -- Write Enable
	OPr1a : IN std_logic_vector (RF_ADDR_WIDTH-1 downto 0); -- OPr1 address
	OPr1e : IN std_logic; -- Read Enable
	OPr2a : IN std_logic_vector (RF_ADDR_WIDTH-1 downto 0); -- OPr2 address
	OPr2e : IN std_logic;  -- Read Enable
	Data_to_memory: OUT std_logic_vector (DATA_WIDTH-1 downto 0); -- OPr1
	Addr_to_memory: OUT std_logic_vector (DATA_WIDTH-1 downto 0); -- OPr2
	RF_data : OUT RF_ARRAY (15  downto 0)
	);
END COMPONENT;

CONSTANT time_period : time := 20 ns;

SIGNAL 	clk : std_logic := '0';
SIGNAL	nReset : std_logic;

	--MUX
SIGNAL RFs : std_logic_vector (1 downto 0);
SIGNAL IRout_lower : std_logic_vector (15 downto 0);
SIGNAL Data_from_memory: std_logic_vector (15 downto 0);

	-- ALU
SIGNAL ALUs : std_logic_vector (1 downto 0);
SIGNAL ALUr : std_logic_vector (15 downto 0);
SIGNAL ALUz : std_logic;

	-- RF
SIGNAL RFwa, OPr1a, OPr2a : std_logic_vector (3 downto 0);
SIGNAL RFwe, OPr1e, OPr2e : std_logic;
SIGNAL Data_to_memory, Addr_to_memory: std_logic_vector (15 downto 0);
SIGNAL RF_data : RF_ARRAY (15  downto 0);

BEGIN
-- write your code here

-- Clock generation
	clk <= not clk AFTER time_period/2;

UUT: datapath GENERIC MAP (16, 16, 4)
	PORT MAP (RFs, IRout_lower, Data_from_memory, ALUs, ALUr, ALUz, clk, nReset,
	RFwa, RFwe, OPr1a, OPr1e, OPr2a, OPr2e, Data_to_memory, Addr_to_memory, RF_data);

stim_proc: PROCESS
	BEGIN
	-- Reset generation
        nReset <= '0';  
        WAIT FOR 20 ns;                                       
        nReset  <= '1';
        WAIT FOR 10 ns;

        IRout_lower <= x"0023"; Data_from_memory <= x"0210"; RFs <= "01";
	RFwa <= "0000"; RFwe <= '1'; OPr1a <= "0000"; OPr1e <= '0';
	OPr2a <= "0000"; OPr2e <= '0'; ALUs <= "XX";
        WAIT FOR 20 ns;
	
	IRout_lower <= x"0023"; Data_from_memory <= x"0210"; RFs <= "10";
	RFwa <= "0001"; RFwe <= '1'; OPr1a <= "0000"; OPr1e <= '0';
	OPr2a <= "0000"; OPr2e <= '0'; ALUs <= "XX";
        WAIT FOR 20 ns;

	IRout_lower <= x"0023"; Data_from_memory <= x"0210"; RFs <= "11"; -- s_add
	RFwa <= "0010"; RFwe <= '0'; OPr1a <= "0000"; OPr1e <= '1';
	OPr2a <= "0001"; OPr2e <= '1'; ALUs <= "XX";
        WAIT FOR 20 ns;

	IRout_lower <= x"0023"; Data_from_memory <= x"0210"; RFs <= "00"; -- s_load
	RFwa <= "0000"; RFwe <= '1'; OPr1a <= "0000"; OPr1e <= '0';
	OPr2a <= "0001"; OPr2e <= '0'; ALUs <= "00";
        WAIT FOR 20 ns;

	IRout_lower <= x"0000"; Data_from_memory <= x"0290"; RFs <= "10";
	RFwa <= "0010"; RFwe <= '1'; OPr1a <= "0000"; OPr1e <= '0';
	OPr2a <= "0001"; OPr2e <= '0'; ALUs <= "XX";
        WAIT FOR 20 ns;

	IRout_lower <= x"0023"; Data_from_memory <= x"0210"; RFs <= "11"; -- s_sub
	RFwa <= "0100"; RFwe <= '0'; OPr1a <= "0001"; OPr1e <= '1';
	OPr2a <= "0010"; OPr2e <= '1'; ALUs <= "XX";
        WAIT FOR 20 ns;

	IRout_lower <= x"0023"; Data_from_memory <= x"0210"; RFs <= "00"; -- s_load
	RFwa <= "0001"; RFwe <= '1'; OPr1a <= "0000"; OPr1e <= '0';
	OPr2a <= "0001"; OPr2e <= '0'; ALUs <= "01";
        WAIT FOR 20 ns;

	END PROCESS;
END behavior;