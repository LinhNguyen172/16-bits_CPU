-- control unit for microprocessor
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE work.sys_definition.all;

ENTITY control_unit IS
GENERIC (
	DATA_WIDTH: integer := 16;     -- Word Width
	ADDR_WIDTH: integer := 16;     -- Address width
	RF_ADDR_WIDTH: integer := 4   -- Register File address width
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
END control_unit;

ARCHITECTURE struct OF control_unit IS
COMPONENT controller
GENERIC (
	DATA_WIDTH : integer := 16;  -- Data Width
	RF_ADDR_WIDTH : integer := 4   -- Address width
	);
PORT (
	clk : IN std_logic;    -- Clock
	nReset : IN std_logic; -- low active reset signal
	start : IN std_logic;    -- high active Start: enable cpu
	
	Instr : IN std_logic_vector (DATA_WIDTH-1 downto 0); -- IRout

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
	RFwe, OPr1e, OPr2e : OUT std_logic;  -- Enable
	current_state : OUT state_type
	);
END COMPONENT;
COMPONENT PC
GENERIC (
	DATA_WIDTH : integer := 16
	); 
PORT (
	D : IN std_logic_vector (DATA_WIDTH-1 downto 0);
	clk, PCclr, PCinc, PCld: IN std_logic;
	PCout: OUT std_logic_vector (DATA_WIDTH-1 downto 0)
	);
END COMPONENT;
COMPONENT IR
GENERIC (
	DATA_WIDTH : integer := 16
	); 
PORT (
	D : IN std_logic_vector (DATA_WIDTH-1 downto 0);
	clk, IRld: IN std_logic;
	IRout: OUT std_logic_vector (DATA_WIDTH-1 downto 0)
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

SIGNAL tmp_16bit, IRout, PCout : std_logic_vector (15 downto 0);
SIGNAL Ms_s : std_logic_vector (1 downto 0);
SIGNAL PCclr, PCinc, PCld, IRld : std_logic;
SIGNAL D : std_logic_vector (15 downto 0) := (OTHERS => 'Z');

BEGIN
	-- write your code here
	
	--Controller;
Controller_U: Controller GENERIC MAP (16, 4)
	PORT MAP (clk, nReset, start, IRout, ALUz, Mre, Mwe, PCclr, PCinc, PCld,
	IRld, Ms_s, RFs, ALUs, RFwa, OPr1a, OPr2a, RFwe, OPr1e, OPr2e, current_state);
	
	--IR;
IR_U: IR GENERIC MAP (16)
	PORT MAP (Data_from_memory, clk, IRld, IRout);

	tmp_16bit <= x"00ff" and IRout; -- direct data to mux or address data to PC
	IRout_lower <= tmp_16bit;
	--PC;
PC_U: PC GENERIC MAP (16)
	PORT MAP (tmp_16bit, clk, PCclr, PCinc, PCld, PCout);
	
	-- MUX4to1;
MUX_U: mux4to1 GENERIC MAP (16)
	PORT MAP (Addr_from_RF_to_memory, tmp_16bit, PCout, D, Ms_s, Addr_to_memory);
	Ms <= Ms_s;
END struct;


