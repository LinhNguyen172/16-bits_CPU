-- Nguyen Kiem Hung
-- datapath for microprocessor
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE work.sys_definition.all;

ENTITY datapath IS -- RF, MUX, ALU
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
END datapath;

ARCHITECTURE struct OF datapath IS
COMPONENT RF
GENERIC (
	DATA_WIDTH : integer := 16; -- Word Width
	RF_ADDR_WIDTH : integer := 4  -- Address width
	);
PORT (
	clk : IN std_logic; -- clock
	nReset : IN std_logic; -- Reset input

	-- Writing Port
	RF_in : IN std_logic_vector (DATA_WIDTH-1 downto 0) := (OTHERS => '0'); -- Input Data
	RFwa : IN std_logic_vector (RF_ADDR_WIDTH-1 downto 0); -- Write address
	RFwe : IN std_logic; -- Write Enable
	-- Reading Port 1
	OPr1a : IN std_logic_vector (RF_ADDR_WIDTH-1 downto 0); -- Read address
	OPr1e : IN std_logic; -- Read Enable
	OPr1 : OUT std_logic_vector (DATA_WIDTH-1 downto 0); -- Output data 1
	-- Reading Port
	OPr2a : IN std_logic_vector (RF_ADDR_WIDTH-1 downto 0); -- Read address
	OPr2e : IN std_logic; -- Read Enable
	OPr2 : OUT std_logic_vector (DATA_WIDTH-1 downto 0);  -- Output data 2
	RF_data : OUT RF_ARRAY (15  downto 0)
	);
END COMPONENT;

COMPONENT ALU 
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

COMPONENT mux4to1 
GENERIC ( 
	DATA_WIDTH : integer := 8
	);
PORT (
	A, B, C, D : IN std_logic_vector (DATA_WIDTH-1 downto 0);
	SEL : IN std_logic_vector (1 downto 0);
	Z : OUT std_logic_vector (DATA_WIDTH-1 downto 0)
	);
END COMPONENT;

SIGNAL OPr1_tmp, OPr2_tmp, ALUr_tmp, RFin : std_logic_vector (15 downto 0);
SIGNAL D : std_logic_vector (15 downto 0) := (OTHERS => 'Z');

BEGIN
	-- write your code here

	--ALU;
ALU_U: ALU GENERIC MAP (16)
	PORT MAP (ALUs, OPr1_tmp, OPr2_tmp, ALUr_tmp, ALUz);

	--RF: REG_FILE;
RF_U: RF GENERIC MAP (16, 4)
	PORT MAP (clk, nReset, RFin, RFwa, RFwe, OPr1a, OPr1e, OPr1_tmp, OPr2a, OPr2e, OPr2_tmp, RF_data);

	-- MUX;
MUX0_U: mux4to1 GENERIC MAP (16)
	PORT MAP (ALUr_tmp, IRout_lower, Data_from_memory, D, RFs, RFin);
	
	Addr_to_memory <= OPr2_tmp;
	Data_to_memory <= OPr1_tmp;
	ALUr <= ALUr_tmp;

END struct;
