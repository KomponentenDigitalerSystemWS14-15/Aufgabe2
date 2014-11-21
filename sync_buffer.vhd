
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
    CONSTANT CNTLEN : natural := 5; -- after 32 clock cycles value is applied
    CONSTANT CNTFULL : std_logic_vector(CNTLEN-1 DOWNTO 0) := (OTHERS => '1');
    CONSTANT CNTEMPTY : std_logic_vector(CNTLEN-1 DOWNTO 0) := (OTHERS => '0');
    
    SIGNAL cnt : std_logic_vector(CNTLEN-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL state : std_logic := '0';
    
    SIGNAL flipflop1 : std_logic := '0';
    SIGNAL flipflop2 : std_logic := '0';
    
BEGIN
    
    dout <= state;
    
	PROCESS (rst, clk)
    BEGIN
		IF rst = RSTDEF THEN
            flipflop1 <= '0';
            flipflop2 <= '0';
            state <= '0';
            cnt <= CNTEMPTY;
            
			redge <= '0';
			fedge <= '0';
		ELSIF rising_edge(clk) THEN
			IF swrst = RSTDEF THEN
                flipflop1 <= '0';
                flipflop2 <= '0';
                state <= '0';
                cnt <= CNTEMPTY;
                
				redge <= '0';
				fedge <= '0';
			ELSIF en = '1' THEN
                flipflop1 <= din;
                flipflop2 <= flipflop1;
                redge <= '0';
                fedge <= '0';
                            
                IF state = '0' THEN
                    IF flipflop2 = '0' THEN
                        IF cnt /= CNTEMPTY THEN
                            cnt <= cnt - 1;
                        END IF;
                    ELSIF flipflop2 = '1' THEN
                        IF cnt /= CNTFULL THEN
                            cnt <= cnt + 1;
                        ELSE
                            redge <= '1';
                            state <= '1';
                        END IF;
                    END IF;
                ELSE
                    IF flipflop2 = '1' THEN
                        IF cnt /= CNTFULL THEN
                            cnt <= cnt + 1;
                        END IF;
                    ELSIF flipflop2 = '0' THEN
                        IF cnt /= CNTEMPTY THEN
                            cnt <= cnt - 1;
                        ELSE
                            fedge <= '1';
                            state <= '0';
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
	END PROCESS;
    
END behavioral;
