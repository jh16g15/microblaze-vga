----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.06.2020 20:50:04
-- Design Name: 
-- Module Name: wb_slave_interface - rtl
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.wb_pkg.all;

entity wb_slave_interface is
Generic(
    WB_DAT_W   : integer := 32;
    WB_ADR_W   : integer := 32;
    WB_GRAN : integer := 8     
);
Port (
    wb_clk_i    : in  std_logic;        -- clock
    wb_rst_i    : in  std_logic;        -- reset
    wb_slave    : in  t_wb_slave    
);
end wb_slave_interface;

architecture rtl of wb_slave_interface is
    -- AXI style signals to connect to memory
    signal valid    : std_logic;
    signal ready    : std_logic;
    signal address  : std_logic_vector(WB_ADR_W-1 downto 0);
    signal wdata    : std_logic_vector(WB_DAT_W-1 downto 0);
    signal rdata    : std_logic_vector(WB_DAT_W-1 downto 0);
    signal write_en : std_logic;
    signal byte_sel : std_logic_vector(WB_DAT_W/WB_GRAN-1 downto 0);
    
begin


end rtl;
