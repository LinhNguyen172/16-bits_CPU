--This confidential and proprietary software may be used
--only as authorized by a licensing agreement from
--Laboratory for Smart Integrated Systems (SIS), VNU University of Engineering and Technology (VNU-UET).
-- (C) COPYRIGHT 2015
-- ALL RIGHTS RESERVED
-- The entire notice above must be reproduced on all authorized copies.
--
-- Filename : RCA_define.v
-- Author : Hung Nguyen
-- Date : 
-- Version : 0.1
-- Description Package declares all constants, types, 
-- and components for project.               
-- Modification History:
-- Date By Version Change Description
-- ========================================================
-- 05/08.2014  0.1 Original
-- ========================================================
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all ;
USE std.textio.all;

PACKAGE Sys_Definition IS

	CONSTANT DATA_WIDTH: integer := 16;     -- Word Width
	CONSTANT ADDR_WIDTH: integer := 16;     -- Address width
	CONSTANT RF_ADDR_WIDTH: integer := 4;   -- Register File address width

-- Type Definition

	-- type for controller
	TYPE state_type IS (s_reset,s_fetch,s_IRload,s_decode,s_ld,s_ld2,s_sd,s_sd2,s_lr,s_lr2,s_lr3,s_sr,
	s_sr2,s_li,s_add,s_add2,s_sub,s_sub2,s_or,s_or2,s_and,s_and2,s_jpz,s_jpz_comp,s_jmp,s_halt);
	
	-- type for memory
	TYPE DATA_ARRAY IS ARRAY (integer RANGE <>) OF std_logic_vector (DATA_WIDTH-1 downto 0); -- Memory Type

	-- type for register file
	TYPE RF_ARRAY IS ARRAY (integer RANGE <>) OF std_logic_vector (DATA_WIDTH-1 downto 0); -- RF Type
	
	
-- **************************************************************
--COMPONENTs
-- CPU
COMPONENT cpu
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
END COMPONENT;
-----------------------------
-- Control unit
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
----------------------------
-- Controller

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
	RFwe, OPr1e, OPr2e : OUT std_logic;  -- Enable
	current_state : OUT state_type
	);
END COMPONENT;
-----------------------------
-- Datapath
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
-------------------------------------
-- Data/Program_memory
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
	Wen : IN std_logic; -- Write Enable
	Data_in : IN std_logic_vector (DATA_WIDTH-1 downto 0) := (OTHERS => '0'); -- Input Data
	-- Reading Port
	Ren : IN std_logic; -- Read Enable
	Data_out : OUT std_logic_vector (DATA_WIDTH-1 downto 0)  -- Output data
	);
END COMPONENT;
------------------------------------------------------
-- MUX
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
-------------------------------------
-- ALU
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
------------------------------------------
-- adder n bit
COMPONENT adder_n_bit
GENERIC (
	DATA_WIDTH : integer := 16
	);
PORT (
	a, b: IN std_logic_vector(DATA_WIDTH-1 downto 0);
	sum: OUT std_logic_vector(DATA_WIDTH-1 downto 0)
	);
END COMPONENT;
----------------------------------
-- full adder
COMPONENT full_adder
PORT (
	a, b: IN std_logic;
	cin: IN std_logic;
	cout: OUT std_logic;
	sum: OUT std_logic
	);
END COMPONENT;
-- PC
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
----------------------------------
-- IR
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
-----------------------------
-- RF(16)
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
---------------------------------
END Sys_Definition;

PACKAGE BODY Sys_Definition IS
	-- package body declarations

END PACKAGE BODY Sys_Definition;