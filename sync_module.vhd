
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

--
-- Im Rahmen der 2. Aufgabe soll hier die Architekturbeschreibung
-- zur Entity sync_module implementiert werden.
--

ARCHITECTURE behavioral OF sync_module IS
BEGIN
	-- synchronizes button input with system clock
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
			ELSE
				load <= BTN0;
				dec <= BTN1;
				inc <= BTN2;
			END IF;
		END IF;
	END PROCESS;
END behavioral;
