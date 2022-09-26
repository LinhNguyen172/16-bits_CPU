LIBRARY IEEE;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;
USE work.sys_definition.all;
USE std.textio.all;
 
ENTITY dpmem_tb IS

END dpmem_tb;

ARCHITECTURE behavior OF dpmem_tb IS
COMPONENT dpmem
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

CONSTANT CLKTIME : time := 20 ns;
   
SIGNAL clk : std_logic := '0';
SIGNAL nReset : std_logic := '0';
SIGNAL addr : std_logic_vector(15 downto 0);
SIGNAL Mwe : std_logic;
SIGNAL data_in : std_logic_vector(15 downto 0);
SIGNAL Mre : std_logic;
SIGNAL data_out : std_logic_vector(15 downto 0);

BEGIN

-- Clock generation
	clk <= not clk after CLKTIME/2;
   
-- DUT component
DUT: dpmem GENERIC MAP (16, 16)
	PORT MAP (clk, nReset, addr, Mwe, data_in, Mre, data_out);
   
-- Read process
stimuli_proc : PROCESS
	BEGIN
	-- Reset generation
        nReset <= '0'; Mre <= '0'; Mwe <= '0'; addr <= (OTHERS => '0');
        WAIT FOR 50 ns;                                       
        nReset  <= '1';
        WAIT FOR 10 ns;
        Mre <= '1'; -- read enable at address 0
        WAIT FOR 20 ns;
	Mre <= '0';
	WAIT FOR 10 ns;
        addr <= X"0001";  Mre <= '1'; -- read enable at address 1
        WAIT FOR 20 ns;
	Mre <= '0';
	WAIT FOR 10 ns;       
        addr <= X"0000"; data_in <= X"000E"; Mwe <= '1'; -- write enable at address 10
        WAIT FOR 20 ns;
	Mwe <= '0';
	WAIT FOR 10 ns;
        addr <= X"0001"; data_in <= X"000F"; Mwe <= '1'; -- write enable at address 11
        WAIT FOR 20 ns;
	Mwe <= '0';
	WAIT FOR 10 ns;
        addr <= X"0000"; Mre <= '1'; -- read enable at address 0
        WAIT FOR 20 ns;
	Mre <= '0';
	WAIT FOR 10 ns;
        addr <= X"0001"; Mre <= '1'; -- read enable at address 1
        WAIT FOR 20 ns;
	Mre <= '0';
	WAIT FOR 10 ns;  
        addr <= X"0002"; Mre <= '1'; -- read enable at address 2
        WAIT FOR 20 ns;
	Mre <= '0';
	WAIT FOR 10 ns;
        addr <= X"0003"; Mre <= '1'; -- read enable at address 3
        WAIT FOR 20 ns;
	Mre <= '0';
        addr <= X"0004"; Mre <= '1'; -- read enable at address 4
        WAIT FOR 20 ns;
	Mre <= '0';
        addr <= X"0005"; Mre <= '1'; -- read enable at address 5
        WAIT FOR 20 ns;
	Mre <= '0';
        addr <= X"0006"; Mre <= '1'; -- read enable at address 6
        WAIT FOR 20 ns;
	Mre <= '0';
        addr <= X"0007"; Mre <= '1'; -- read enable at address 7
        WAIT FOR 20 ns;
	Mre <= '0';
        addr <= X"0008"; Mre <= '1'; -- read enable at address 8
        WAIT FOR 20 ns;
	Mre <= '0';
        addr <= X"0009"; Mre <= '1'; -- read enable at address 9
        WAIT FOR 20 ns;
	Mre <= '0';
        addr <= X"000A"; Mre <= '1'; -- read enable at address 10
        WAIT FOR 20 ns;
	Mre <= '0';
	addr <= X"000B"; Mre <= '1'; -- read enable at address 11
        WAIT FOR 20 ns;
	Mre <= '0';
	WAIT FOR 10 ns;
	WAIT; 
	END PROCESS;
END behavior;