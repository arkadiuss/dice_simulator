--------------------------------------------------------------------------------
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 11/25/2013 Scott Larson
--     Initial Public Release
--    
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY ps2_keyboard IS
  GENERIC(
    clk_freq              : INTEGER := 50_000_000; 
    debounce_counter_size : INTEGER := 8);         
  PORT(
    clk          : IN  STD_LOGIC;                     
    ps2_clk      : IN  STD_LOGIC;                     
    ps2_data     : IN  STD_LOGIC;                    
    ps2_code_new : OUT STD_LOGIC;
    ps2_code     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END ps2_keyboard;

ARCHITECTURE logic OF ps2_keyboard IS
  SIGNAL sync_ffs     : STD_LOGIC_VECTOR(1 DOWNTO 0);      
  SIGNAL ps2_clk_int  : STD_LOGIC;                          
  SIGNAL ps2_data_int : STD_LOGIC;                          
  SIGNAL ps2_word     : STD_LOGIC_VECTOR(10 DOWNTO 0);      
  SIGNAL error        : STD_LOGIC;                      
  SIGNAL count_idle   : INTEGER RANGE 0 TO clk_freq/18_000; 
  
  
  COMPONENT debounce IS
    GENERIC(
      counter_size : INTEGER);
    PORT(
      clk    : IN  STD_LOGIC;  
      button : IN  STD_LOGIC; 
      result : OUT STD_LOGIC);
  END COMPONENT;
BEGIN

  PROCESS(clk)
  BEGIN
    IF RISING_EDGE(clk) THEN  
      sync_ffs(0) <= ps2_clk;          
      sync_ffs(1) <= ps2_data;
    END IF;
  END PROCESS;

  debounce_ps2_clk: debounce
    GENERIC MAP(counter_size => debounce_counter_size)
    PORT MAP(clk => clk, button => sync_ffs(0), result => ps2_clk_int);
  debounce_ps2_data: debounce
    GENERIC MAP(counter_size => debounce_counter_size)
    PORT MAP(clk => clk, button => sync_ffs(1), result => ps2_data_int);

  PROCESS(ps2_clk_int)
  BEGIN
    IF FALLING_EDGE(ps2_clk_int) THEN    
      ps2_word <= ps2_data_int & ps2_word(10 DOWNTO 1);  
    END IF;
  END PROCESS;
    
  error <= NOT (NOT ps2_word(0) AND ps2_word(10) AND (ps2_word(9) XOR ps2_word(8) XOR
        ps2_word(7) XOR ps2_word(6) XOR ps2_word(5) XOR ps2_word(4) XOR ps2_word(3) XOR 
        ps2_word(2) XOR ps2_word(1)));  

  PROCESS(clk)
  BEGIN
    IF RISING_EDGE(clk) THEN           
    
      IF(ps2_clk_int = '0') THEN               
        count_idle <= 0;                          
      ELSIF(count_idle /= clk_freq/18_000) THEN 
          count_idle <= count_idle + 1;      
      END IF;
      
      IF(count_idle = clk_freq/18_000 AND error = '0') THEN
        ps2_code_new <= '1';                                
        ps2_code <= ps2_word(8 DOWNTO 1);                
      ELSE                                                  
        ps2_code_new <= '0'; 
      END IF;
      
    END IF;
  END PROCESS;
  
END logic;
