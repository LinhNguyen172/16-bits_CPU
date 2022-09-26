LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY full_adder IS
PORT (
	a, b: IN std_logic;
	cin: IN std_logic;
	cout: OUT std_logic;
	sum: OUT std_logic
	);
END full_adder;

ARCHITECTURE architecture_full_adder OF full_adder IS
BEGIN
PROCESS (a,b,cin)
	BEGIN 
		IF a = b THEN
			cout <= a;
			sum <= cin;
		ELSE
			cout <= cin;
			sum <= NOT cin;
		END IF;
END PROCESS;
END architecture_full_adder;
