-- Nguyen Kiem Hung
-- controller

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE work.sys_definition.all;
USE std.textio.all;
USE IEEE.std_logic_unsigned.all;

ENTITY controller IS             	
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
	RFwe, OPr1e, OPr2e : OUT std_logic ; -- Enable
	current_state : OUT state_type
	);
END controller;		 

ARCHITECTURE FSM OF controller IS
	--TYPE state_type IS (s_reset,s_fetch,s_IRload,s_decode,s_ld,s_ld2,s_sd,s_sd2,s_lr,s_lr2,s_lr3,s_sr,
	--s_sr2,s_li,s_add,s_add2,s_sub,s_sub2,s_or,s_or2,s_and,s_and2,s_jpz,s_jpz_comp,s_jmp,s_halt);

	SIGNAL state: state_type;

	SIGNAL opcode, rn, rm : std_logic_vector (3 downto 0);
BEGIN
	opcode <= Instr (15 downto 12); 
	rn <= Instr (11 downto 8);
	rm <= Instr (7 downto 4);

next_state_logic: PROCESS(nReset, clk, start)
	BEGIN
		IF start = '1' THEN
			IF(nReset = '0') THEN
				state <= s_reset;
			ELSIF(clk'event and clk = '1') THEN
				CASE state IS
				WHEN s_reset => state <= s_fetch;
				WHEN s_fetch => state <= s_IRload;
				WHEN s_IRload => state <= s_decode;
				WHEN s_decode =>
					CASE opcode IS
					WHEN "0000" => state <= s_ld;
					WHEN "0001" => state <= s_sd;
					WHEN "0010" => state <= s_lr;
					WHEN "0011" => state <= s_sr;
					WHEN "0100" => state <= s_li;
					WHEN "0101" => state <= s_add;
					WHEN "0110" => state <= s_sub;
					WHEN "0111" => state <= s_or;
					WHEN "1000" => state <= s_and;
					WHEN "1001" => state <= s_jpz;
					WHEN "1010" => state <= s_jmp;
					WHEN "1011" => state <= s_halt;
					WHEN OTHERS => state <= s_fetch;
					END CASE;
				WHEN s_ld => state <= s_ld2;
				WHEN s_ld2 => state <= s_fetch;
				WHEN s_sd => state <= s_sd2;
				WHEN s_sd2 => state <= s_fetch;
				WHEN s_lr => state <= s_lr2;
				WHEN s_lr2 => state <= s_lr3;
				WHEN s_lr3 => state <= s_fetch;
				WHEN s_sr => state <= s_sr2;
				WHEN s_sr2 => state <= s_fetch;
				WHEN s_li => state <= s_fetch;
				WHEN s_add => state <= s_add2;
				WHEN s_add2 => state <= s_fetch;
				WHEN s_sub => state <= s_sub2;
				WHEN s_sub2 => state <= s_fetch;
				WHEN s_or => state <= s_or2;
				WHEN s_or2 => state <= s_fetch;
				WHEN s_and => state <= s_and2;
				WHEN s_and2 => state <= s_fetch;
				WHEN s_jpz => state <= s_jpz_comp;
				WHEN s_jpz_comp => state <= s_fetch;
				WHEN s_jmp => state <= s_fetch;
				WHEN s_halt => state <= s_halt;
				WHEN OTHERS => state <= s_fetch;
				END CASE;
			END IF;
		END IF;
	END PROCESS;
-- State
	current_state <= state;
-- Combinational Circuit

-- PC
PCclr <= '1' WHEN state = s_reset ELSE '0';
PCinc <= '1' WHEN state = s_decode ELSE '0';
WITH state SELECT PCld <= ALUz WHEN s_jpz_comp, '1' WHEN s_jmp, '0' WHEN OTHERS;
-- IR
WITH state SELECT IRld <= '1' WHEN s_fetch|s_IRload, '0' WHEN OTHERS;
-- Memory
WITH state SELECT Ms <= "10" WHEN s_fetch, "01" WHEN s_ld|s_sd2, "00" WHEN s_sr2|s_lr2, "11" WHEN OTHERS;
WITH state SELECT Mre <= '1' WHEN s_fetch|s_ld|s_lr2, '0' WHEN OTHERS;
WITH state SELECT Mwe <= '1' WHEN s_sd2|s_sr2, '0' WHEN OTHERS;
-- RF
WITH state SELECT RFs <= "10" WHEN s_ld2|s_lr3, "01" WHEN s_li, "00" WHEN s_add2|s_sub2|s_or2|s_and2, "11" WHEN OTHERS;
WITH state SELECT RFwe <= '1' WHEN s_ld2|s_li|s_lr3|s_add2|s_sub2|s_or2|s_and2, '0' WHEN OTHERS;
WITH state SELECT RFwa <= rn WHEN s_ld2|s_li|s_lr3|s_add2|s_sub2|s_or2|s_and2, "ZZZZ" WHEN OTHERS;
WITH state SELECT OPr1e <= '1' WHEN s_sd|s_sr|s_add|s_sub|s_jpz|s_or|s_and,'0' WHEN OTHERS;
WITH state SELECT OPr1a <= rn WHEN s_sd|s_sr|s_add|s_sub|s_jpz|s_or|s_and,"ZZZZ" WHEN OTHERS;
WITH state SELECT OPr2e <= '1' WHEN s_sr|s_add|s_sub|s_or|s_and|s_lr, '0' WHEN OTHERS;
WITH state SELECT OPr2a <= rm WHEN s_sr|s_add|s_sub|s_or|s_and|s_lr, "ZZZZ" WHEN OTHERS;
-- ALU
WITH state SELECT ALUs <= "00" WHEN s_add2, "01" WHEN s_sub2, "10" WHEN s_or2, "11" WHEN s_and2, "ZZ" WHEN OTHERS;

END FSM;



