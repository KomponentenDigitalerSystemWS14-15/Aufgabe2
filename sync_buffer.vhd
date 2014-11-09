
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

--
-- Im Rahmen der 2. Aufgabe soll hier die Architekturbeschreibung
-- zur Entity sync_buffer implementiert werden.
--

ARCHITECTURE behavioral OF sync_buffer IS
BEGIN
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
				dout <= din;
				redge <= rising_edge(din);
				fedge <= falling_edge(din);
			END IF;
		END IF;
	END PROCESS;
END behavioral;
