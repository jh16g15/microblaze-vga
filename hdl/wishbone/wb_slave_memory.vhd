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

entity wb_slave_memory is
Generic(
    G_ADDR_W         : integer   := 10;
	G_DATA_W         : integer   := 16;
	G_DEPTH          : integer   := 1024;
	G_USE_INIT_FILE  : boolean   := false;
	G_INIT_FILE_NAME : string    := ""
);
Port (
    wb_clk_i    : in  std_logic;        -- clock
    wb_rst_i    : in  std_logic;        -- reset
    wb_mosi    : in  t_wb_mosi;   
    wb_miso    : out t_wb_miso   
);
end wb_slave_memory;

architecture rtl of wb_slave_memory is
    -- AXI style signals to connect to memory
    signal valid    : std_logic;
    signal ready    : std_logic;
    signal address  : std_logic_vector(WB_ADR_W-1 downto 0);
    signal wdata    : std_logic_vector(WB_DAT_W-1 downto 0);
    signal rdata    : std_logic_vector(WB_DAT_W-1 downto 0);
    signal write_en : std_logic;
    signal byte_sel : std_logic_vector(WB_DAT_W/WB_GRAN-1 downto 0);
    
    signal enable   : std_logic;
    signal reg_enable  : std_logic;
begin
    
    -- enable signal
    enable <= wb_mosi.stb and wb_mosi.cyc;

    -- we want to introduce a single cycle WAIT state upon read operations
    ack_select_proc : process(all) is 
    begin
        case wb_mosi.we is
            when '0' => wb_miso.ack <= reg_enable;
            when '1' => wb_miso.ack <= enable;
            when others => null;    -- impossible branch
        end case;
    end process;
   
    reg_enable_proc : process(wb_clk_i) is
    begin   
        if rising_edge(wb_clk_i) then
            reg_enable <= enable;
        end if;
    end process;
     

    u_memory : entity work.simple_dual_two_clocks
    generic map(
        ADDR_W => G_ADDR_W,
        DATA_W => G_DATA_W,
        DEPTH => G_DEPTH,  -- words (1024 =4 Kbit)
        USE_INIT_FILE => G_USE_INIT_FILE,
        INIT_FILE_NAME => G_INIT_FILE_NAME
    )
    port map(
        clka => wb_clk_i,
        clkb => wb_clk_i,
        ena => enable, 
        enb => enable,
        wea => wb_mosi.we,
        addra => wb_mosi.adr(G_ADDR_W-1 downto 0),
        addrb => wb_mosi.adr(G_ADDR_W-1 downto 0),
        dia => wb_mosi.wdata(G_DATA_W-1 downto 0),
        dob => wb_miso.rdata(G_DATA_W-1 downto 0)
    ); 
    

end rtl;
