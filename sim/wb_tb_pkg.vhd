----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.06.2020 23:42:54
-- Design Name: 
-- Module Name: wb_tb_pkg - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description:     Wishbone Master Procedures for Testbench reads and writes
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

use std.textio.all;

use work.wb_pkg.all;

package wb_tb_pkg is

    constant wb_tclk_default : time := 10ns;
    procedure p_wb_write(
        signal   wb_clk    : in  std_logic;
        signal   wb_mosi   : out t_wb_mosi;
        signal   wb_miso   : in  t_wb_miso;
        constant address   : unsigned(WB_ADR_W-1 downto 0) := x"1000_0000";
        constant wdata     : unsigned(WB_DAT_W-1 downto 0) := x"DEAD_BEEF";
        constant byte_sel  : std_logic_vector(WB_DAT_W/WB_GRAN-1 downto 0) := x"F"  
    );
    procedure p_wb_read(
        signal   wb_clk    : in  std_logic;
        signal   wb_mosi   : out t_wb_mosi;
        signal   wb_miso   : in  t_wb_miso;
        constant address   : unsigned(WB_ADR_W-1 downto 0);
        signal   rdata     : out unsigned(WB_DAT_W-1 downto 0)
    );
    procedure p_wb_respond(
        signal   wb_clk    : in std_logic;
        signal   wb_mosi   : in  t_wb_mosi;
        signal   wb_miso   : out t_wb_miso;
        constant rdata     :  in unsigned(WB_DAT_W-1 downto 0) := x"DABEEFEE";
        constant delay     :  in integer := 0
    );
end wb_tb_pkg;

package body wb_tb_pkg is 
    procedure p_wb_write(
        signal   wb_clk    : in  std_logic;
        signal   wb_mosi   : out t_wb_mosi;
        signal   wb_miso   : in  t_wb_miso;
        constant address   : unsigned(WB_ADR_W-1 downto 0) := x"1000_0000";
        constant wdata     : unsigned(WB_DAT_W-1 downto 0) := x"DEAD_BEEF";
        constant byte_sel  : std_logic_vector(WB_DAT_W/WB_GRAN-1 downto 0) := x"F" 
    ) is
    begin
        -- Set Master control Signals
        report "Setting Master Control Signals for WRITE"; 
        wb_mosi.stb <= '1';
        wb_mosi.we <= '1';
        wb_mosi.sel <= byte_sel;
        wb_mosi.cyc <= '1';
        -- Set Master Data signals
        wb_mosi.adr <= std_logic_vector(address);
        wb_mosi.wdata <= std_logic_vector(wdata);
        
        -- Wait for slave to accept wdata
        report "Waiting for Slave to accept Wdata";
        wait for 1 ns;
        wait until wb_miso.ack = '1' and wb_clk = '1';
        
        report "Deasserting Master Control Signals";
        -- Deassert Master Control Signals
        wb_mosi.stb <= '0';
        wb_mosi.cyc <= '0';
--        wait until wb_clk = '1';
    end p_wb_write;

    procedure p_wb_read(
        signal   wb_clk    : in  std_logic;
        signal   wb_mosi   : out t_wb_mosi;
        signal   wb_miso   : in  t_wb_miso;
        constant address   : in unsigned(WB_ADR_W-1 downto 0);
        signal   rdata     : out unsigned(WB_DAT_W-1 downto 0)
    ) is
        constant byte_sel  : std_logic_vector(WB_DAT_W/WB_GRAN-1 downto 0) := x"F";
    begin
       -- Set Master Control Signals 
       report "Setting Master Control Signals for READ"; 
        wb_mosi.stb <= '1';
        wb_mosi.we <= '0';
        wb_mosi.sel <= byte_sel;
        wb_mosi.cyc <= '1';
        wb_mosi.adr <= std_logic_vector(address);        
        report "Waiting for RDATA"; 
        -- Wait for slave to send rdata 
        wait until wb_clk = '1' and wb_miso.ack = '1';
        report "Accepting RDATA";
        -- Accept rdata
        rdata <= unsigned(wb_miso.rdata);
        report "Deasserting Master Control Signals";
        -- Deassert Master Control Signals
        wb_mosi.stb <= '0';
        wb_mosi.cyc <= '0';
        wait until wb_clk = '1';
    end p_wb_read;
    
    
    procedure p_wb_respond(
        signal   wb_clk      : in std_logic;
        signal   wb_mosi   : in  t_wb_mosi;
        signal   wb_miso   : out t_wb_miso;
        constant rdata       : in unsigned(WB_DAT_W-1 downto 0) := x"DABEEFEE";
        constant delay       : in integer := 0
    ) is 
        variable delay_count : integer;
    begin
        -- wait for a command
        report "SLAVE waiting for a valid Command";
        wait until wb_clk = '1' and wb_mosi.cyc = '1' and wb_mosi.stb = '1';
        report "SLAVE command received";
        -- insert wait states if required
        if delay > 0 then
            for i in 0 to delay-1
            loop
                wait until wb_clk = '1';
                report "SLAVE waited " & integer'image(i) & " cycles of " & integer'image(delay);
            end loop;
        end if;
        -- repond to command
        if wb_mosi.we = '1' then
            report("Write of " & to_hstring(wb_mosi.wdata) & " to address " & to_hstring(wb_mosi.adr));
        else 
            report("Read of " & to_hstring(rdata) & " at address " & to_hstring(wb_mosi.adr));
            wb_miso.rdata <= std_logic_vector(rdata);
        end if;
        -- acknowledge command
        wb_miso.ack <= '1';
        
        -- wait until slave select is de-asserted
--        wait until wb_clk = '1' and wb_mosi.stb = '0';
        wait until wb_mosi.stb = '0';
        
        -- finish acknowledement
        wb_miso.ack <= '0';
    end p_wb_respond;

end wb_tb_pkg;
