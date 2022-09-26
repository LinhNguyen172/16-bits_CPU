library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
    generic (
        DATA_WIDTH : integer
    );
    port (
        ALUs : in std_logic_vector(1 downto 0);
        OPr1, OPr2 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        ALUr : out std_logic_vector(DATA_WIDTH-1 downto 0);
        ALUz : out std_logic
    );
end ALU;

architecture rtl of ALU is

begin

end architecture;