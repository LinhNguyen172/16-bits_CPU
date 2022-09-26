LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;
USE IEEE.numeric_std.all;
USE work.sys_definition.all;

ENTITY RF_tb IS

END RF_tb;
 
ARCHITECTURE RF_tb_bev OF RF_tb IS
	
COMPONENT RF IS -- Register File
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

CONSTANT clk_period : time := 20 ns;

SIGNAL clk : std_logic := '0';
SIGNAL nReset, RFwe, OPr1e, OPr2e : std_logic;
SIGNAL RFwa, OPr1a, OPr2a : std_logic_vector (3 downto 0);
SIGNAL RF_in, OPr1, OPr2 : std_logic_vector (15 downto 0);
SIGNAL RF_data : RF_ARRAY (15  downto 0);

BEGIN 

-- Clock generation
	clk <= not clk AFTER clk_period/2;

UUT : RF GENERIC MAP (16, 4)
	PORT MAP (clk, nReset, RF_in, RFwa, RFwe, OPr1a, OPr1e, OPr1, OPr2a, OPr2e, OPr2, RF_data);

--  Read/Write process
RW_Proc : PROCESS
	BEGIN  
	
	nReset <= '0'; 
	RF_in <= x"0000";
	RFwa <= "0000"; RFwe <= '0';
	OPr1a <= "0000"; OPr1e <= '0';
	OPr2a <= "0001"; OPr2e <= '0';
        WAIT FOR 5 ns;                                       
        
	nReset  <= '1';
        WAIT FOR 20 ns;
	
	OPr1e <= '1'; OPr2e <= '1';
	WAIT FOR 20 ns;
	OPr1e <= '0'; OPr2e <= '0';
	WAIT FOR 10 ns;
	
	RF_in <= x"0024";
	RFwa <= "1111"; RFwe <= '1';
	OPr1a <= "0000"; OPr1e <= '0';
	OPr2a <= "0001"; OPr2e <= '0';
        WAIT FOR 20 ns;
	RFwe <= '0';
	WAIT FOR 10 ns;

	OPr1a <= "1110"; OPr1e <= '1';
	OPr2a <= "1111"; OPr2e <= '1';
        WAIT FOR 20 ns;
	OPr1e <= '0'; OPr2e <= '0';
	WAIT FOR 10 ns;

	RF_in <= x"0025";
	RFwa <= "0010"; RFwe <= '1';
	OPr1a <= "0011"; OPr1e <= '1';
	OPr2a <= "0001"; OPr2e <= '1';
        WAIT FOR 20 ns;
	RFwe <= '0'; OPr1e <= '0'; OPr2e <= '0';
	WAIT FOR 10 ns;
	

	RF_in <= x"0027";
	RFwa <= "0101"; RFwe <= '1';
	OPr1a <= "0100"; OPr1e <= '1';
	OPr2a <= "1010"; OPr2e <= '1';
        WAIT FOR 20 ns;
	RFwe <= '0'; OPr1e <= '0'; OPr2e <= '0';
	WAIT FOR 10 ns;

	END PROCESS;
    
END RF_tb_bev;
