LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE work.sys_definition.all;
USE std.textio.all;
USE IEEE.std_logic_unsigned.all;


ENTITY dpmem IS -- Data/Program Memory
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
END dpmem;
 
ARCHITECTURE dpmem_arch OF dpmem IS

	TYPE DATA_ARRAY IS ARRAY (integer RANGE <>) OF std_logic_vector (DATA_WIDTH-1 downto 0); -- Memory Type
	SIGNAL M : DATA_ARRAY(0 to (2**10)-1) := (OTHERS => (OTHERS => '0'));  -- Memory model

	-- you can add more code for your application by increase the PM_Size
	CONSTANT PM_Size : Integer := 27; -- Size of program memory

	--type P_MEM is array (0 to PM_Size-1) of std_logic_vector(DATA_WIDTH -1 downto 0); -- Program Memory
	CONSTANT PM : DATA_ARRAY(0 to PM_Size-1) := (	
		-- Machine code for your application is initialized here 
		
		-- i = n; while(i-- > 0); sum += *(A++);	 --size = 27	--sum = 43E
		x"000D",	--0: 	    LD R0, 13
		x"010E",	--1: 	    LD R1, 14
		x"020F",	--2: 	    LD R2, 15	
		x"4300",	--3: 	    LI R3, #0
		x"4401",	--4:	    LI R4, #1
		x"910B",	--5:  cond: JPZ R1, end 
		x"6140",	--6: 	    SUB R1, R4
		x"2500",	--7: 	    LR R5, @R0
		x"5350",	--8: 	    ADD R3, R5
		x"5040",	--9: 	    ADD R0,R4
		x"A005",	--10:	    JMP cond
		x"3320",	--11: end:  SR R3, @R2
		x"B000",	--12:	    HALT
		x"0011",	--13:	    Address of A
		x"000A",	--14:	    Length of A
		x"0010",	--15:	    Address of sum
		x"0000",	--16:       Sum
		x"0048",	--17:       A[0]
		x"00A8",	--18:       A[1]
		x"0074",	--19:       A[2]
		x"001F",	--20:       A[3]
		x"006A",	--21:       A[4]
		x"001B",	--22:       A[5]
		x"0052",	--23:       A[6]
		x"00F5",	--24:       A[7]
		x"0005",	--25:       A[8]
		x"00EA"		--26:       A[9]
		
 		--x"000F", x"0110", x"0211", x"4300", x"4401", x"2500", --size = 29
		--x"6520", x"950D", x"5340", x"6140", x"910D", x"5040",	--index = 5
		--x"A005", x"1312", x"B000", x"0013", x"000A", x"001B",
		--x"FFFF", x"0048", x"00A8", x"0074", x"001F", x"006A",
		--x"001B", x"0052", x"00F5", x"0005", x"00EA"
		);
BEGIN  -- dpmem_arch

--  Read/Write process
RW_Proc : PROCESS (clk, nReset)
	BEGIN  
	IF nReset = '0' THEN
		Data_out <= (OTHERS => '0');
		M (0 to PM_Size-1) <= PM; -- initialize program memory
	ELSIF (clk'event and clk = '1') THEN
		IF Mwe = '1' THEN
			M(conv_integer(addr)) <= Data_in;
		ELSE
			IF Mre = '1' THEN
				Data_out <= M(conv_integer(addr));
			ELSE
				Data_out <= (OTHERS => 'Z');
			END IF;
		END IF;
	END IF;
	END PROCESS RW_Proc;
    
END dpmem_arch;