library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dice_simulator is
	Port(
		CLK: in STD_LOGIC;
		Switch: in STD_LOGIC;  
		Dseg: out STD_LOGIC_VECTOR(6 downto 0)
	);
end dice_simulator;

architecture Behavioral of dice_simulator is
signal debounced: STD_LOGIC;
constant MAX_VAL: integer := 100000;
signal counter: integer := 0;
signal prev_val: integer := 6;

component debounce
	PORT(
		clk     : IN  STD_LOGIC;
		button  : IN  STD_LOGIC; 
		result  : OUT STD_LOGIC);		
end component;
begin
deb: debounce
	PORT MAP(
		CLK => clk,
		button => Switch,
		result => debounced
	);
	process(CLK)
	begin
		if rising_edge(CLK) then
			if(counter = MAX_VAL) then
				counter <= 1;
			else
				counter <= counter + 1;
			end if;	
		end if;
	end process;
	
	process(Switch)
	variable new_val: integer;
	begin
		if falling_edge(debounced) then
			new_val := counter * prev_val;
			new_val := new_val mod 8;
			if new_val >= 6 then
				new_val := new_val - 6;
			end if;
			prev_val <= new_val +1;	
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