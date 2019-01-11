library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dice_simulator is
	Port(
		CLK: in STD_LOGIC;
		PS2_CLK: in STD_LOGIC;
		PS2_data: in STD_LOGIC;  
		Dseg: out STD_LOGIC_VECTOR(6 downto 0)
	);
end dice_simulator;

architecture Behavioral of dice_simulator is
constant MAX_VAL: integer := 100;
signal counter: integer := 0;
signal prev_val: integer := 6;
signal PS2_code_new: OUT STD_LOGIC;
signal PS2_code: OUT STD_LOGIC;
begin
	process(CLK)
	begin
		if rising_edge(CLK) then
			if counter = MAX_VAL then
				counter <= 0;
			else
				counter <= counter + 1;
			end if;	
		end if;
	end process;
	
	process(Switch)
	begin
		if rising_edge(Switch) then
			prev_val <= counter * prev_val;
			prev_val <= prev_val mod 8;
			if prev_val >= 6 then
				prev_val <= prev_val - 6;
			end if;
			prev_val <= prev_val +1;	
		end if;
	end process;
	with std_logic_vector(to_unsigned(prev_val, 3)) select
		Dseg <= "1001111" WHEN "001",
				"0010010" WHEN "010",
				"0000110" WHEN "011",
				"1001100" WHEN "100",
				"0100100" WHEN "101",
				"0100000" WHEN "110",
				"0000000" WHEN OTHERS;
end Behavioral;