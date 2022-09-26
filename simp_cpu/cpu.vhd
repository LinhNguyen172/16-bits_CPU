-- Nguyen Kiem Hung
-- cpu : the top level entity

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE work.sys_definition.all;
USE std.textio.all;
USE IEEE.std_logic_unsigned.all;

-- 
ENTITY cpu IS
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
	Ms: OUT std_logic_vector(1 downto 0);
	Mre, Mwe : OUT std_logic;
        RFs : OUT std_logic_vector(1 downto 0);
	RFwa : OUT std_logic_vector(RF_ADDR_WIDTH-1 downto 0);
	RFwe : OUT std_logic;
	OPr1a : OUT std_logic_vector(RF_ADDR_WIDTH-1 downto 0);
	OPr1e : OUT std_logic;
	OPr2a : OUT std_logic_vector(RF_ADDR_WIDTH-1 downto 0);
	OPr2e : OUT std_logic;
	ALUs : OUT std_logic_vector(1 downto 0);
	RF_data : OUT RF_ARRAY (15  downto 0);
	current_state : OUT state_type
        );
END cpu;


ARCHITECTURE struct OF cpu IS
COMPONENT control_unit
GENERIC (
	CONSTANT DATA_WIDTH: integer := 16;     -- Word Width
	CONSTANT ADDR_WIDTH: integer := 16;     -- Address width
	CONSTANT RF_ADDR_WIDTH: integer := 4   -- Register File address width
	);
PORT (
	clk : IN std_logic;
	nReset : IN std_logic;
	start : IN std_logic;

	--MUX
	Addr_from_RF_to_memory : IN std_logic_vector (DATA_WIDTH-1 downto 0); -- OPr2
	Ms : OUT std_logic_vector(1 downto 0);
	Addr_to_memory : OUT std_logic_vector (ADDR_WIDTH-1 downto 0); -- memory address

	-- IR
	Data_from_memory : IN std_logic_vector (DATA_WIDTH-1 downto 0); -- memory data
	IRout_lower : OUT std_logic_vector (DATA_WIDTH-1 downto 0); --IRout[7-0] to datapath
	
	-- Controller
	RFs : OUT std_logic_vector (1 downto 0);
	RFwa : OUT std_logic_vector (RF_ADDR_WIDTH-1 downto 0); -- Write address
	RFwe : OUT std_logic; -- Write Enable

	OPr1a : OUT std_logic_vector (RF_ADDR_WIDTH-1 downto 0); -- Read address
	OPr1e : OUT std_logic; -- Read Enable
	OPr2a : OUT std_logic_vector (RF_ADDR_WIDTH-1 downto 0); -- Read address
	OPr2e : OUT std_logic;  -- Read Enable

	ALUs : OUT std_logic_vector (1 downto 0); 
	ALUz : IN std_logic;

	Mre, Mwe : OUT std_logic;
	current_state : OUT state_type
	);
END COMPONENT;	

COMPONENT datapath
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

COMPONENT dpmem  -- Data/Program Memory
GENERIC (
	DATA_WIDTH : integer := 16; -- Word Width
	ADDR_WIDTH : integer := 16  -- Address width
	);
PORT (
	-- Writing
	clk : IN std_logic; -- clock
	nReset : IN std_logic; -- Reset input
	addr : IN std_logic_vector (ADDR_WIDTH-1 downto 0); -- Address
	-- Writing Port
	Mwe : IN std_logic; -- Write Enable
	Data_in : IN std_logic_vector (DATA_WIDTH-1 downto 0) := (OTHERS => '0'); -- Input Data
	-- Reading Port
	Mre : IN std_logic; -- Read Enable
	Data_out : OUT std_logic_vector (DATA_WIDTH-1 downto 0)  -- Output data
	);
END COMPONENT;


-- declare internal signals here
SIGNAL ALUz_s, Mre_s, Mwe_s, RFwe_s, OPr1e_s, OPr2e_s: std_logic;
SIGNAL RFs_s, ALUs_s, Ms_s: std_logic_vector (1 downto 0);
SIGNAL RFwa_s, OPr1a_s, OPr2a_s : std_logic_vector (3 downto 0);
SIGNAL addr_mem, Data_out_mem, Data_in_mem, ALUr_s, OPr2_s, IRout_lower: std_logic_vector (15 downto 0);

BEGIN

-- write your code here

	-- Controller;
control_U: control_unit GENERIC MAP (16, 16, 4)
	PORT MAP (clk, nReset, start, OPr2_s, Ms_s, addr_mem, Data_out_mem, IRout_lower, RFs_s, RFwa_s, RFwe_s,
	OPr1a_s, OPr1e_s, OPr2a_s, OPr2e_s, ALUs_s, ALUz_s, Mre_s, Mwe_s, current_state);
 
  	-- datapath;
datapath_U: datapath GENERIC MAP (16, 16, 4)
	PORT MAP (RFs_s, IRout_lower, Data_out_mem, ALUs_s, ALUr_s, ALUz_s, clk, nReset,
	RFwa_s, RFwe_s, OPr1a_s, OPr1e_s, OPr2a_s, OPr2e_s, Data_in_mem, OPr2_s, RF_data);

	-- dpmem;
Mem_U: dpmem GENERIC MAP (16, 16)
	PORT MAP (clk, nReset, addr_mem, Mwe_s, Data_in_mem, Mre_s, Data_out_mem);

	Addr_out <= addr_mem;
	IR_in_test <= Data_out_mem;
	ALU_out <= ALUr_s;	
	Ms <= Ms_s;
	Mre <= Mre_s;
	Mwe <= Mwe_s;
	RFs <= RFs_s;
	RFwa <= RFwa_s;
	RFwe <= RFwe_s;
	OPr1a <= OPr1a_s;
	OPr1e <= OPr1e_s;
	OPr2a <= OPr2a_s;
	OPr2e <= OPr2e_s;
	ALUs <= ALUs_s;
END struct;
