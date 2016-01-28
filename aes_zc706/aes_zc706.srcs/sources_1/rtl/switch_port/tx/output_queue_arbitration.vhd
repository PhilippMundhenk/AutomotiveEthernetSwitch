----------------------------------------------------------------------------------
-- Company: TUM CREATE
-- Engineer: Andreas Ettner
-- 
-- Create Date: 11.12.2013 10:00:16
-- Design Name: 
-- Module Name: output_queue_arbitration - rtl
-- Project Name: automotive ethernet gateway
-- Target Devices: zynq 7000
-- Tool Versions: vivado 2013.3
--
-- Description: This module forwards the frames in the output queue memory to the transmitter-side of the MAC
-- The output queue fifo provides the start address in the output queue memory and the length in bytes
-- 
-- further information can be found in switch_port_txpath_output_queue.svg
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

entity output_queue_arbitration is
    Generic (
        TRANSMITTER_DATA_WIDTH      : integer;
        FRAME_LENGTH_WIDTH          : integer;
        NR_OQ_FIFOS                 : integer;
        TIMESTAMP_WIDTH             : integer;
        OQ_MEM_ADDR_WIDTH           : integer;
        OQ_FIFO_DATA_WIDTH          : integer;
        OQ_FIFO_LENGTH_START        : integer;
        OQ_FIFO_TIMESTAMP_START     : integer;
        OQ_FIFO_MEM_PTR_START       : integer
    );
    Port (
        clk                         : in  std_logic;
        reset                       : in  std_logic;
        -- input interface fifo
        oqarb_in_fifo_enable        : out std_logic;
        oqarb_in_fifo_prio          : out std_logic;
        oqarb_in_fifo_empty         : in std_logic_vector(NR_OQ_FIFOS-1 downto 0);
        oqarb_in_fifo_data          : in std_logic_vector(NR_OQ_FIFOS*OQ_FIFO_DATA_WIDTH-1 downto 0);
        -- timestamp
        oqarb_in_timestamp_cnt      : in std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        oqarb_out_latency           : out std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        -- input interface memory
        oqarb_in_mem_data           : in  std_logic_vector(NR_OQ_FIFOS*TRANSMITTER_DATA_WIDTH-1 downto 0);
        oqarb_in_mem_enable         : out  std_logic;
        oqarb_in_mem_addr           : out  std_logic_vector(OQ_MEM_ADDR_WIDTH-1 downto 0);
        oqarb_in_mem_prio           : out std_logic;
        -- output interface mac
        oqarb_out_data              : out std_logic_vector(TRANSMITTER_DATA_WIDTH-1 downto 0);
        oqarb_out_valid             : out std_logic;
        oqarb_out_last              : out std_logic;
        oqarb_out_ready             : in std_logic
    );
end output_queue_arbitration;

architecture rtl of output_queue_arbitration is

    -- state machine
    type state is (
        IDLE,
        ARBITRATE,
        READ_MEM
    );
    -- state signals
    signal cur_state       	: state;
    signal nxt_state        : state;

    signal empty_const          : std_logic_vector(NR_OQ_FIFOS-1 downto 0) := (others => '1');
    
    -- config_output_state machine signals
    signal update_cnt_sig          	: std_logic;
    signal reset_frame_length_sig   : std_logic;
    signal measure_latency_sig      : std_logic;
    signal choose_fifo_sig          : std_logic;
    
    -- process registers
    signal frame_length_cnt         : std_logic_vector(FRAME_LENGTH_WIDTH-1 downto 0);
    signal latency_reg              : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
    signal winner_fifo_reg          : std_logic_vector(0 downto 0);
    
begin

    -- next state logic
    next_state_logic_p : process(clk)
    begin
        if (clk'event and clk = '1') then
            if reset = '1' then
                cur_state <= IDLE;
            else
                cur_state <= nxt_state;
            end if;
        end if;
    end process next_state_logic_p;

    -- Decode next data_input_state, combinitorial logic
    output_logic_p : process(cur_state, oqarb_in_fifo_empty, oqarb_out_ready, frame_length_cnt, oqarb_in_fifo_data, empty_const, winner_fifo_reg)
    begin
        -- default signal assignments
        nxt_state <= IDLE;
        update_cnt_sig <= '0';
        measure_latency_sig <= '0';
        reset_frame_length_sig <= '0';
        oqarb_in_fifo_enable <= '0';
        oqarb_out_last <= '0';
        oqarb_out_valid <= '0';
        oqarb_in_fifo_prio <= '0';
        choose_fifo_sig <= '0';

        case cur_state is
            when IDLE =>
                if oqarb_in_fifo_empty /= empty_const and oqarb_out_ready = '1' then
                    nxt_state <= ARBITRATE;
                    choose_fifo_sig <= '1'; -- choose_fifo_p
                end if;
            
            when ARBITRATE =>
                nxt_state <= READ_MEM;
                update_cnt_sig <= '1'; -- cnt_frame_length_p
                measure_latency_sig <= '1'; -- timestamp_p
            
            when READ_MEM => 
                if frame_length_cnt >= oqarb_in_fifo_data(to_integer(unsigned(winner_fifo_reg))*OQ_FIFO_DATA_WIDTH+OQ_FIFO_LENGTH_START+FRAME_LENGTH_WIDTH-1 
                                                          downto to_integer(unsigned(winner_fifo_reg))*OQ_FIFO_DATA_WIDTH+OQ_FIFO_LENGTH_START) 
                                        and oqarb_out_ready = '1' then
                    nxt_state <= IDLE;
                    reset_frame_length_sig <= '1'; -- cnt_frame_length_p
                    oqarb_in_fifo_enable <= '1';
                    oqarb_in_fifo_prio <= winner_fifo_reg(0);
                    oqarb_out_last <= '1';
                    oqarb_out_valid <= '1';
                else
                    nxt_state <= READ_MEM;
                    update_cnt_sig <= oqarb_out_ready; -- cnt_frame_length_p
                    oqarb_out_valid <= oqarb_out_ready;
                end if;
                
        end case;
    end process output_logic_p;

    -- count frame bytes received from fabric
    cnt_frame_length_p : process(clk)
    begin
        if (clk'event and clk = '1') then
            if reset = '1' then
                frame_length_cnt <= (others => '0');
            else
                frame_length_cnt <= frame_length_cnt;
                if reset_frame_length_sig = '1' then
                    frame_length_cnt <= (others => '0');
                elsif update_cnt_sig = '1' then
                    frame_length_cnt <= frame_length_cnt + 1;
                end if;
            end if;
        end if;
    end process;
    
    -- take transmission timestamp of the message
    timestamp_p : process(clk)
    begin
        if (clk'event and clk = '1') then
            if reset = '1' then
                latency_reg <= (others => '0');
            else
                latency_reg <= latency_reg;
                if measure_latency_sig = '1' then
                    latency_reg <= oqarb_in_timestamp_cnt - oqarb_in_fifo_data
                               (to_integer(unsigned(winner_fifo_reg))*OQ_FIFO_DATA_WIDTH+OQ_FIFO_TIMESTAMP_START+TIMESTAMP_WIDTH-1 
                               downto to_integer(unsigned(winner_fifo_reg))*OQ_FIFO_DATA_WIDTH+OQ_FIFO_TIMESTAMP_START)
                       + 50; -- considering the clock cycles through mac, rx, tx_fifo
                end if;
            end if;
        end if;
    end process;
    
    -- determine the fifo to be read from
    choose_fifo_p : process(clk)
    begin
        if (clk'event and clk = '1') then
            if reset = '1' then
                winner_fifo_reg <= (others => '0');
            else
                winner_fifo_reg <= winner_fifo_reg;
                if choose_fifo_sig = '1' then
                    if NR_OQ_FIFOS = 2 and oqarb_in_fifo_empty(NR_OQ_FIFOS-1) = '0' then -- high priority fifo
                        winner_fifo_reg(0) <= '1';
                    else
                        winner_fifo_reg(0) <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    output_p : process(oqarb_in_mem_data, winner_fifo_reg)
    begin
        if NR_OQ_FIFOS = 1 then
            oqarb_out_data <= oqarb_in_mem_data(TRANSMITTER_DATA_WIDTH-1 downto 0);
        else
            if winner_fifo_reg(0) = '0' then
                oqarb_out_data <= oqarb_in_mem_data(TRANSMITTER_DATA_WIDTH-1 downto 0);
            else
                oqarb_out_data <= oqarb_in_mem_data(NR_OQ_FIFOS*TRANSMITTER_DATA_WIDTH-1 downto TRANSMITTER_DATA_WIDTH);
            end if;
        end if;
    end process;
    
    oqarb_in_mem_enable <= oqarb_out_ready;
    oqarb_in_mem_addr <= oqarb_in_fifo_data(to_integer(unsigned(winner_fifo_reg))*OQ_FIFO_DATA_WIDTH+OQ_FIFO_MEM_PTR_START+OQ_MEM_ADDR_WIDTH-1 
                                            downto to_integer(unsigned(winner_fifo_reg))*OQ_FIFO_DATA_WIDTH+OQ_FIFO_MEM_PTR_START) + frame_length_cnt;
    
    oqarb_out_latency <= latency_reg;
    oqarb_in_mem_prio <= winner_fifo_reg(0);
    
end rtl;
