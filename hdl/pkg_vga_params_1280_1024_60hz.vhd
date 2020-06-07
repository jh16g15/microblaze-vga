library ieee;
use ieee.std_logic_1164.all;

package pkg_vga_params_1280_1024_60hz is
    -- from http://tinyvga.com/vga-timing/1280x1024@60Hz
	constant PIXELCLK_FREQ : integer := 108000000; -- 108MHz (9.26ns)
    constant END_ACTIVE_X    : integer := 1280;
    constant END_FPORCH_X    : integer := 1328;
    constant END_SYNC_X      : integer := 1440;
    constant END_BPORCH_X    : integer := 1688;
    
    constant END_ACTIVE_Y    : integer := 1024;
    constant END_FPORCH_Y    : integer := 1025;
    constant END_SYNC_Y      : integer := 1028;
    constant END_BPORCH_Y    : integer := 1066;
    
    -- '1' for active high, '0' for active low
    constant ACTIVE_HS  : std_logic := '1';
    constant ACTIVE_VS  : std_logic := '1';      
end pkg_vga_params_1280_1024_60hz;