----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.06.2020 22:28:59
-- Design Name: 
-- Module Name: wb_slave_gpio - rtl
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description:  Module to handle basic IO of switches, buttons and LEDs. Includes basic debouncing, although this
--               shouldn't be needed as we will be polling it with a CPU when necessary 
--
--               To ease the burden on the CPU, each LED, Switch and Button has 
--               a separate address to just access that specific value for ease of programming               
--
--               Also functions as an example of an Asynchronous Cycle Termination wishbone slave (no wait states)
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

entity wb_slave_gpio is
    generic(
        g_num_leds  : integer := 16;
        g_num_sw    : integer := 16;
        g_num_btn   : integer := 5 
    );
    Port (
        wb_clk_i    : in  std_logic;        -- clock
        wb_rst_i    : in  std_logic;        -- reset
        wb_mosi    : in  t_wb_mosi;   
        wb_miso    : out t_wb_miso;   
        leds_out : out STD_LOGIC_VECTOR (g_num_leds-1 downto 0);
        switches_in : in STD_LOGIC_VECTOR (g_num_sw-1 downto 0);
        buttons_in : in STD_LOGIC_VECTOR (g_num_btn-1 downto 0)
    );
end wb_slave_gpio;

architecture rtl of wb_slave_gpio is
    type t_gpio_registers is record
        LED : std_logic_vector(31 downto 0);
        SW  : std_logic_vector(31 downto 0);
        BTN : std_logic_vector(31 downto 0);     
    end record t_gpio_registers; 

    signal gpio_regs : t_gpio_registers;
    
    -- for indexing
    signal sel_bank : integer;  
    signal sel_register : integer;
    signal sel_byte : integer;
    
begin
    -- I/O, TODO add debouncing for inputs with a slow clk
    leds_out <= gpio_regs.LED(g_num_leds-1 downto 0);
    
    -- synchronous write, asynchronous read
    -- always acknowledge on same cycle
    wb_miso.ack <= wb_mosi.stb and wb_mosi.cyc;
    
    -- Memory Map
    ----------------------------------------------------
    -- bank select [11:8]
    -- bank 0 : whole IO access
        -- 0 : LEDs
        -- 4 : Switches
        -- 8 : Buttons
    -- bank 1 : Bitwise LEDs bit=[7:2]
        -- 0 : LED[0]
        -- 4 : LED[1]
        -- ...
    -- bank 2 : Bitwise Switches bit=[7:2]
        -- 0 : SW[0]
        -- 4 : SW[1]
        -- ...
     -- bank 3 : Bitwise Buttons bit=[7:2]
        -- 0 : BTN[0]
        -- 4 : BTN[1]
        -- ...
    
    -- address decoding indexes
    sel_bank <= to_integer(unsigned(wb_mosi.adr(11 downto 8)));
    sel_register <= to_integer(unsigned(wb_mosi.adr(7 downto 3)));
    sel_byte <= to_integer(unsigned(wb_mosi.adr(1 downto 0)));
        
    
    read_process: process(all)
    begin
        -- async read when we get selected on a valid cycle
        -- as it doesn't matter if we always send rdata 
        
        -- todo: make byte-addressable 
        
        -- bank select
        case sel_bank is
            when 0 => 
                case sel_register is
                    when 0 => wb_miso.rdata <=  gpio_regs.LED;
                    when 1 => wb_miso.rdata <=  gpio_regs.SW;
                    when 2 => wb_miso.rdata <=  gpio_regs.BTN;
                    when others =>  wb_miso.rdata <= x"BAAD_D0D0";
                end case;
            when 1 =>
                wb_miso.rdata(31 downto 1) <= (others => '0');
                wb_miso.rdata(0) <= gpio_regs.LED(sel_register);               
            when 2 => 
                wb_miso.rdata(31 downto 1) <= (others => '0');
                wb_miso.rdata(0) <= gpio_regs.SW(sel_register);  
            when 3 =>
                wb_miso.rdata(31 downto 1) <= (others => '0');
                wb_miso.rdata(0) <= gpio_regs.BTN(sel_register);   
            when others => wb_miso.rdata <= x"BAAD_D0D0";
        end case;
        
    end process;
    
    write_process : process(wb_clk_i, wb_rst_i) is 
    begin
        if wb_rst_i = '1' then
           gpio_regs.LED <= x"0000_0000";  
        else
            if rising_edge(wb_clk_i) then 
                if wb_mosi.cyc = '1' and wb_mosi.stb = '1' and wb_mosi.we = '1' then 
                    case sel_bank is
                        when 0 => 
                            case sel_register is
                                when 0 => gpio_regs.LED <= wb_mosi.wdata;
--                                when 1 => gpio_regs.SW  <= wb_mosi.wdata; -- read only 
--                                when 2 => gpio_regs.BTN <= wb_mosi.wdata; -- read only
                                when others => null;
                            end case;
                        when 1 =>
                            gpio_regs.LED(sel_register) <= wb_mosi.wdata(0);               
                        when 2 => 
--                            gpio_regs.SW(sel_register)  <= wb_mosi.wdata(0); 
                        when 3 =>
--                            gpio_regs.BTN(sel_register) <= wb_mosi.wdata(0); 
                        when others => null;
                    end case;        
                end if;
            end if;
        end if;
    end process;

 -- register latest values for RO registers
 -- TODO: insert debouncing here
 reg_update_proc : process(wb_clk_i, wb_rst_i)
 
 begin
    if wb_rst_i = '1' then
           gpio_regs.SW  <= x"0000_0000"; 
           gpio_regs.BTN <= x"0000_0000"; 
    else
        if rising_edge(wb_clk_i) then
            gpio_regs.SW(g_num_sw-1 downto 0) <= switches_in;
            gpio_regs.BTN(g_num_btn-1 downto 0) <= buttons_in;
        end if;
    end if;
 end process;   


end rtl;
