----------------------------------------------------------------------------------
-- Company: TUM CREATE
-- Engineer: Andreas Ettner
-- 
-- Create Date: 10.12.2013 14:15:52
-- Design Name: 
-- Module Name: output_queue_memory - rtl
-- Project Name: automotive ehternet gateway
-- Target Devices: zynq 7000
-- Tool Versions: vivado 2013.3
--
-- Description: wrapper for the output queue memory
-- the output queue memory stores frames received from the switching fabric temporarily
-- until they can be tranismitted via the mac
--
-- further information can be found in switch_port_txpath_output_queue.svg
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

entity output_queue_memory is
    Generic (
        NR_OQ_MEM             : integer;
        VLAN_PRIO_WIDTH       : integer;
        OQ_MEM_ADDR_WIDTH_A   : integer;
        OQ_MEM_ADDR_WIDTH_B   : integer;
        OQ_MEM_DATA_WIDTH_IN  : integer;
        OQ_MEM_DATA_WIDTH_OUT : integer
    );
    Port (
        --Port A -> control module
        oqmem_in_wr_prio      : in  std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
        oqmem_in_wenable      : in std_logic_vector;
        oqmem_in_addr         : in std_logic_vector(OQ_MEM_ADDR_WIDTH_A-1 downto 0);
        oqmem_in_data         : in std_logic_vector(OQ_MEM_DATA_WIDTH_IN-1 downto 0);
        oqmem_in_clk          : in std_logic;
        --Port B -> arbitration module -> mac
        oqmem_out_rd_prio     : in std_logic;
        oqmem_out_enable      : in std_logic;
        oqmem_out_addr        : in std_logic_vector(OQ_MEM_ADDR_WIDTH_B-1 downto 0);
        oqmem_out_data        : out std_logic_vector(NR_OQ_MEM*OQ_MEM_DATA_WIDTH_OUT-1 downto 0);
        oqmem_out_clk         : in std_logic
    );
end output_queue_memory;

architecture rtl of output_queue_memory is

    component blk_mem_gen_2 is
    Port (
        --Port A -> control module
        wea        	: in std_logic_vector;
        addra      	: in std_logic_vector(OQ_MEM_ADDR_WIDTH_A-1 downto 0);
        dina       	: in std_logic_vector(OQ_MEM_DATA_WIDTH_IN-1 downto 0);
        clka       	: in std_logic;
        --Port B -> arbitration module -> mac
        enb        	: in std_logic;  --opt port
        addrb      	: in std_logic_vector(OQ_MEM_ADDR_WIDTH_B-1 downto 0);
        doutb      	: out std_logic_vector(OQ_MEM_DATA_WIDTH_OUT-1 downto 0);
        clkb       	: in std_logic
        );
    end component;
    
    signal rd_en_sig        : std_logic_vector(NR_OQ_MEM-1 downto 0) := (others => '0');
    signal wr_en_sig        : std_logic_vector(NR_OQ_MEM-1 downto 0) := (others => '0');
    
    signal high_priority_border_value_reg   : std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0) := "001";
    
begin

    init_p : process(oqmem_out_enable, oqmem_in_wenable, oqmem_in_wr_prio, oqmem_out_rd_prio, high_priority_border_value_reg)
    begin
        if NR_OQ_MEM = 1 then
            wr_en_sig(0) <= oqmem_in_wenable(0);
            rd_en_sig(0) <= oqmem_out_enable;
        elsif NR_OQ_MEM = 2 then
            if oqmem_in_wr_prio >= high_priority_border_value_reg then
                wr_en_sig(0) <= '0';
                wr_en_sig(NR_OQ_MEM-1) <= oqmem_in_wenable(0);
            else
                wr_en_sig(0) <= oqmem_in_wenable(0);
                wr_en_sig(NR_OQ_MEM-1) <= '0';
            end if;
            if oqmem_out_rd_prio = '1' then
                rd_en_sig(0) <= '0';
                rd_en_sig(NR_OQ_MEM-1) <= oqmem_out_enable;
            else
                rd_en_sig(0) <= oqmem_out_enable;
                rd_en_sig(NR_OQ_MEM-1) <= '0';
            end if;
        end if;
    end process;

    Xmem : for i in 0 to NR_OQ_MEM-1 generate
    output_queue_mem_ip : blk_mem_gen_2
        PORT MAP (
            --Port A
		    wea       	=> wr_en_sig(i downto i),
            addra      	=> oqmem_in_addr,
            dina       	=> oqmem_in_data,
            clka       	=> oqmem_in_clk,
            --Port B
            enb        	=> rd_en_sig(i), 
            addrb      	=> oqmem_out_addr,
            doutb      	=> oqmem_out_data((i+1)*OQ_MEM_DATA_WIDTH_OUT-1 downto i*OQ_MEM_DATA_WIDTH_OUT),
            clkb       	=> oqmem_out_clk
        );
    end generate Xmem;
    
end rtl;
