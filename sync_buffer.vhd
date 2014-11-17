
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY sync_buffer IS
   GENERIC(RSTDEF:  std_logic := '1');
   PORT(rst:    IN  std_logic;  -- reset, RSTDEF active
        clk:    IN  std_logic;  -- clock, rising edge
        en:     IN  std_logic;  -- enable, high active
        swrst:  IN  std_logic;  -- software reset, RSTDEF active
        din:    IN  std_logic;  -- data bit, input
        dout:   OUT std_logic;  -- data bit, output
        redge:  OUT std_logic;  -- rising  edge on din detected
        fedge:  OUT std_logic); -- falling edge on din detected
END sync_buffer;

-- sync_buffer waits 2**CNTLEN clock cycles until it puts din on dout

ARCHITECTURE behavioral OF sync_buffer IS
    
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
       
    CONSTANT CNTLEN : natural := 5; -- after 32 clock cycles value is applied
    SIGNAL cnt_inc : std_logic := '1';
    SIGNAL cnt_carry : std_logic;
    SIGNAL cnt_data : std_logic_vector(CNTLEN-1 DOWNTO 0);
BEGIN

    counter : std_counter
    GENERIC MAP(RSTDEF => RSTDEF,
                CNTLEN => CNTLEN)
    PORT MAP(rst => rst,
             clk => clk,
             en => en,
             inc => cnt_inc,
             dec => '0',
             load => '0',
             swrst =>swrst,
             cout => cnt_carry,
             din => (OTHERS => '0'),
             dout => cnt_data);
    
	PROCESS (rst, clk) BEGIN
		IF rst = RSTDEF THEN
			dout <= '0';
			redge <= '0';
			fedge <= '0';
		ELSIF rising_edge(clk) THEN
			IF swrst = RSTDEF THEN
				dout <= '0';
				redge <= '0';
				fedge <= '0';
			ELSIF en = '1' THEN
                IF din = '0' AND cnt_carry = '1' THEN
                    cnt_inc <= '1'; -- increment until counter overflow
                ELSIF din = '1' AND cnt_carry = '0' THEN
                    cnt_inc <= '1'; -- increment until counter overflow
                ELSE
                    -- stop counter increment, reached stable state
                    cnt_inc <= '0';
                    dout <= din;
                    -- TODO edge calculation may miss din edges
                    redge <= '0';
                    fedge <= '0';
                    IF rising_edge(din) THEN
                        redge <= '1';
                    ELSIF falling_edge(din) THEN
                        fedge <= '1';
                    END IF;
                END IF;
			END IF;
		END IF;
	END PROCESS; 
END behavioral;
