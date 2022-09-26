LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;
USE IEEE.numeric_std.all;
USE work.sys_definition.all;

ENTITY RF IS -- Register File
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
END RF;
 
ARCHITECTURE RF_bev OF RF IS
	-- TYPE RF_ARRAY IS ARRAY (integer RANGE <>) OF std_logic_vector (DATA_WIDTH-1 downto 0); -- RF Type
	SIGNAL RF : RF_ARRAY(0 to (2**RF_ADDR_WIDTH)-1) := (OTHERS => (OTHERS => '0'));  -- RF model
	SIGNAL OPr1_tmp, OPr2_tmp : std_logic_vector (15 downto 0);
	
BEGIN 


--  Read/Write process
RW_Proc : PROCESS (clk)
	BEGIN  
	IF nReset = '0' THEN
		OPr1_tmp <= (OTHERS => 'Z');
		OPr2_tmp <= (OTHERS => 'Z');
	ELSIF (clk'event and clk = '1') THEN  -- rising clock edge
		IF RFwe = '1' THEN
			RF(conv_integer(RFwa)) <= RF_in;
		ELSE
			IF OPr1e = '1' THEN
				OPr1_tmp <= RF(conv_integer(OPr1a));
			ELSE
				OPr1_tmp <= (OTHERS => 'Z');
			END IF;

			IF OPr2e = '1' THEN
				OPr2_tmp <= RF(conv_integer(OPr2a));
			ELSE
				OPr2_tmp <= (OTHERS => 'Z');
			END IF;
		END IF;
	END IF;
	END PROCESS RW_Proc;

	OPr1 <= OPr1_tmp;
	OPr2 <= OPr2_tmp;
	RF_data <= RF;
    
END RF_bev;