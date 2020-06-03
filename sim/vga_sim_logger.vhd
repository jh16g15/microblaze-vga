-- VGA Simulator Logger
-- Eric Eastwood
-- https://ericeastwood.com/blog/8/vga-simulator-getting-started

library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity vga_sim_logger is 
    generic(
        G_SWAP_SYNC_POLARITY : boolean := true;
        G_LOG_FILE_NAME : string := "vga_sim_log.txt"
    );
	port(
		clk   : in std_logic;
		hsync : in std_logic; 
		vsync : in std_logic;
		Red   : in std_logic_vector(3 downto 0);
		Green : in std_logic_vector(3 downto 0); 
		Blue  : in std_logic_vector(3 downto 0)
	);
end vga_sim_logger;

architecture sim of vga_sim_logger is
begin
process (clk)
    file file_pointer: text is out G_LOG_FILE_NAME;
    variable line_el: line;
begin

    if rising_edge(clk) then

        -- Write the time
        write(line_el, now); -- write the line.
        write(line_el, string'(":")); -- write the line.

        -- Write the hsync
        write(line_el, string'(" "));
        if G_SWAP_SYNC_POLARITY = true then
            write(line_el, not hsync); -- write the line.
        else 
            write(line_el, hsync); -- write the line.
        end if;

        -- Write the vsync
        write(line_el, string'(" "));
        if G_SWAP_SYNC_POLARITY = true then
            write(line_el, not vsync); -- write the line.
        else 
            write(line_el, vsync); -- write the line.
        end if;

        -- Write the red
        write(line_el, string'(" "));
        write(line_el, Red(3 downto 1)); -- write the line.

        -- Write the green
        write(line_el, string'(" "));
        write(line_el, Green(3 downto 1)); -- write the line.

        -- Write the blue
        write(line_el, string'(" "));
        write(line_el, Blue(3 downto 1)); -- write the line.

        writeline(file_pointer, line_el); -- write the contents into the file.

    end if;
end process;

end architecture sim;