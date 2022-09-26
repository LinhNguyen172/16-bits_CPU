--This confidential and proprietary software may be used
--only as authorized by a licensing agreement from
--Laboratory for Smart Integrated Systems (SIS), VNU University of Engineering and Technology (VNU-UET).
-- (C) COPYRIGHT 2014 
-- ALL RIGHTS RESERVED
-- The entire notice above must be reproduced on all authorized copies.
--
-- Filename : Mux4to1.vhd
-- Author : Hung Nguyen
-- Date : 
-- Version : 0.1
-- Description : A processing Element.
--                
-- Modification History:
-- Date By Version Change Description
-- ========================================================
-- 05/08.2014  0.1 Original
-- ========================================================
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all ;
--use IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;
USE work.Sys_Definition.all;

ENTITY MUX4to1 IS
GENERIC ( 
	DATA_WIDTH : integer := 8
	);
PORT (
	A, B, C, D : IN std_logic_vector (DATA_WIDTH-1 downto 0);
	SEL : IN std_logic_vector (1 downto 0);
	Z : OUT std_logic_vector (DATA_WIDTH-1 downto 0)
	);
END MUX4to1;

ARCHITECTURE bev OF MUX4to1 IS
BEGIN
	-- write your code here
	WITH SEL SELECT Z <= A WHEN "00",
			     B WHEN "01",
			     C WHEN "10",
			     D WHEN OTHERS;
END bev;

