
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY sync_module IS
   GENERIC(RSTDEF: std_logic := '1');
   PORT(rst:   IN  std_logic;  -- reset, active RSTDEF
        clk:   IN  std_logic;  -- clock, risign edge
        swrst: IN  std_logic;  -- software reset, active RSTDEF
        BTN0:  IN  std_logic;  -- push button -> load
        BTN1:  IN  std_logic;  -- push button -> dec
        BTN2:  IN  std_logic;  -- push button -> inc
        load:  OUT std_logic;  -- load,      high active
        dec:   OUT std_logic;  -- decrement, high active
        inc:   OUT std_logic); -- increment, high active
END sync_module;

ARCHITECTURE behavioral OF sync_module IS

    COMPONENT std_counter IS
    GENERIC(RSTDEF: std_logic;
            CNTLEN: natural);
    PORT(rst:   IN  std_logic;  -- reset,          RSTDEF active
         clk:   IN  std_logic;  -- clock,           rising edge
         en:    IN  std_logic;  -- enable,          high active
         inc:   IN  std_logic;  -- increment,       high active
         dec:   IN  std_logic;  -- decrement,       high active
         load:  IN  std_logic;  -- load value,      high active
         swrst: IN  std_logic;  -- software reset,  RSTDEF active
         cout:  OUT std_logic;  -- carry,           high active        
         din:   IN  std_logic_vector(CNTLEN-1 DOWNTO 0);
         dout:  OUT std_logic_vector(CNTLEN-1 DOWNTO 0));
    END COMPONENT;
    
    COMPONENT sync_buffer IS
    GENERIC(RSTDEF:  std_logic);
    PORT(rst:    IN  std_logic;  -- reset, RSTDEF active
         clk:    IN  std_logic;  -- clock, rising edge
         en:     IN  std_logic;  -- enable, high active
         swrst:  IN  std_logic;  -- software reset, RSTDEF active
         din:    IN  std_logic;  -- data bit, input
         dout:   OUT std_logic;  -- data bit, output
         redge:  OUT std_logic;  -- rising  edge on din detected
         fedge:  OUT std_logic); -- falling edge on din detected
    END COMPONENT;

    CONSTANT CNTLEN : natural := 15;
    SIGNAL div_carry : std_logic;
    SIGNAL div_data : std_logic_vector(CNTLEN-1 DOWNTO 0);
    SIGNAL sbuf_en :std_logic := '0';
BEGIN

    freq_div : std_counter
    GENERIC MAP(RSTDEF => RSTDEF,
                CNTLEN => CNTLEN)
    PORT MAP(rst => rst,
             clk => clk,
             en => '1',
             inc => '1',
             dec => '0',
             load => '0',
             swrst =>swrst,
             cout => div_carry,
             din => (OTHERS => '0'),
             dout => div_data);
    
    sbuf0 : sync_buffer
    GENERIC MAP(RSTDEF => RSTDEF)
    PORT MAP(rst => rst,
             clk => clk,
             en => sbuf_en,
             swrst => swrst,
             din => BTN0,
             dout => load,
             redge => OPEN,
             fedge => OPEN);
             
    sbuf1 : sync_buffer
    GENERIC MAP(RSTDEF => RSTDEF)
    PORT MAP(rst => rst,
             clk => clk,
             en => sbuf_en,
             swrst => swrst,
             din => BTN1,
             dout => dec,
             redge => OPEN,
             fedge => OPEN);
             
    sbuf2 : sync_buffer
    GENERIC MAP(RSTDEF => RSTDEF)
    PORT MAP(rst => rst,
             clk => clk,
             en => sbuf_en,
             swrst => swrst,
             din => BTN2,
             dout => inc,
             redge => OPEN,
             fedge => OPEN);
        
	PROCESS (rst, clk) BEGIN
		IF rst = RSTDEF THEN
			load <= '0';
			dec <= '0';
			inc <= '0';
		ELSIF rising_edge(clk) THEN
			IF swrst = RSTDEF THEN
				load <= '0';
				dec <= '0';
				inc <= '0';
			ELSIF rising_edge(div_carry) OR falling_edge(div_carry) THEN
                sbuf_en <= '1'; -- enable only for 1 cycle
            ELSE
                sbuf_en <= '0';
			END IF;
		END IF;
	END PROCESS;
END behavioral;
