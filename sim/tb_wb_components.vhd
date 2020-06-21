----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.06.2020 21:58:10
-- Design Name: 
-- Module Name: tb_wb_components - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.wb_pkg.all;
use work.wb_tb_pkg.all;

entity tb_wb_components is
end tb_wb_components;

architecture Behavioral of tb_wb_components is
    constant tclk    : time := 10ns;
    signal clk       : std_logic := '0';
    signal reset     : std_logic := '0';
    signal wb_mosi   : t_wb_mosi;
    signal wb_miso   : t_wb_miso;
    signal rdata     : UNSIGNED(31 downto 0);
begin

clk <= not clk after tclk/2;

master_stimulus : process is 
    variable address : unsigned(31 downto 0) := x"0000_0000";
    variable wdata : unsigned(31 downto 0) := x"0000_0001";
begin
    wait until clk = '1';
    p_wb_write(wb_clk => clk, wb_mosi => wb_mosi, wb_miso => wb_miso, address => address, wdata => wdata);
    p_wb_read(wb_clk => clk, wb_mosi => wb_mosi, wb_miso => wb_miso, address => address, rdata => rdata);
    
    wait until clk = '1';    
    
    wait;
    
end process; 

slave : process is 
    constant delay : integer := 1; 
begin 
    p_wb_respond(wb_clk => clk, wb_mosi => wb_mosi, wb_miso => wb_miso, delay => delay);
end process;

end Behavioral;
