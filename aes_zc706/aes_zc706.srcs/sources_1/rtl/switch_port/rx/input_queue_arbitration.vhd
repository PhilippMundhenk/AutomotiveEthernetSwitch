----------------------------------------------------------------------------------
-- Company: TUM CREATE
-- Engineer: Andreas Ettner
-- 
-- Create Date: 26.11.2013 17:14:16
-- Design Name: 
-- Module Name: input_queue_scheduling - rtl
-- Project Name: automotive ethernet gateway
-- Target Devices: zynq 7000
-- Tool Versions: vivado 2013.3
--
-- Description:
-- The arbitration module decides which fifo to read from depending on the priority
-- access to the ports in the output_ports signal is requested
-- upon acknowledgement data are read from the memory and the corresponding singals (valid, last) are set
-- for multicast messages the ports_reg indicating the remaining output ports is updated
-- the overflow signal resets the state machine to idle state exept it is in send_frame state
-- 
-- more detailed information can found in file switch_port_rxpath_input_queue_arbitration.svg
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

entity input_queue_arbitration is
    Generic(
        FABRIC_DATA_WIDTH           : integer;
        IQ_FIFO_DATA_WIDTH          : integer;
        NR_PORTS                    : integer;
        IQ_MEM_ADDR_WIDTH_A         : integer;
        IQ_MEM_ADDR_WIDTH_B         : integer;
        FRAME_LENGTH_WIDTH          : integer;
        VLAN_PRIO_WIDTH             : integer;
        TIMESTAMP_WIDTH             : integer;
        IQ_FIFO_PRIO_START          : integer;
        IQ_FIFO_FRAME_LEN_START     : integer;
        IQ_FIFO_TIMESTAMP_START     : integer;
        IQ_FIFO_PORTS_START         : integer;
        IQ_FIFO_MEM_PTR_START       : integer;
        IQ_MEM_DATA_WIDTH_RATIO 	: integer;
        NR_IQ_FIFOS                 : integer
    );
    Port ( 
        clk                         : in std_logic;
        reset                       : in std_logic;
        -- input interface memory
        iqarb_in_mem_enable         : out std_logic;
        iqarb_in_mem_addr           : out std_logic_vector(IQ_MEM_ADDR_WIDTH_B-1 downto 0);
        iqarb_in_mem_data           : in std_logic_vector(FABRIC_DATA_WIDTH-1 downto 0);
        -- input interface fifo
        iqarb_in_fifo_enable        : out  std_logic;
        iqarb_in_fifo_prio          : out std_logic;
        iqarb_in_fifo_data          : in std_logic_vector(NR_IQ_FIFOS*IQ_FIFO_DATA_WIDTH-1 downto 0);
        iqarb_in_fifo_empty         : in std_logic_vector(NR_IQ_FIFOS-1 downto 0);
        iqarb_in_fifo_overflow      : in std_logic_vector(NR_IQ_FIFOS-1 downto 0);
        -- output interface arbitration
        iqarb_out_ports_req         : out std_logic_vector(NR_PORTS-1 downto 0);
        iqarb_out_prio              : out std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
        iqarb_out_timestamp         : out std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        iqarb_out_length            : out std_logic_vector(FRAME_LENGTH_WIDTH-1 downto 0);
        iqarb_out_ports_gnt         : in std_logic_vector(NR_PORTS-1 downto 0);
        -- output interface data
        iqarb_out_data             	: out std_logic_vector(FABRIC_DATA_WIDTH-1 downto 0);
        iqarb_out_last              : out std_logic;
        iqarb_out_valid             : out std_logic
    );
end input_queue_arbitration;

architecture rtl of input_queue_arbitration is

    type state is (
        IDLE,
        WAIT_GNT,
        SEND_FRAME,
        PORT_UPDATE
    );
    -- state signals
    signal cur_state            : state;
    signal nxt_state            : state;

    signal empty_const          : std_logic_vector(NR_IQ_FIFOS-1 downto 0) := (others => '1');
    signal higher_prio          : std_logic;
    -- state machine signals
    signal read_fifo_sig       	: std_logic;
    signal req_fabric_sig       : std_logic;
    signal update_mem_cnt_sig   : std_logic;
    signal read_mem_sig         : std_logic;
    signal output_valid_sig     : std_logic;
    signal last_word_sig        : std_logic;
    signal update_ports_sig     : std_logic;
    signal update_fifo_sig      : std_logic;
    -- process registers
    signal prio_reg             : std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
    signal timestamp_reg        : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
    signal mem_ptr_reg          : std_logic_vector(IQ_MEM_ADDR_WIDTH_A-1 downto 0);
    signal length_reg           : std_logic_vector(FRAME_LENGTH_WIDTH-1 downto 0);
    signal ports_reg            : std_logic_vector(NR_PORTS-1 downto 0);
    signal pending_low_prio_ports : std_logic_vector(NR_PORTS-1 downto 0);
    signal fifo_reg             : std_logic_vector(0 downto 0);
    signal mem_cnt_reg          : std_logic_vector(FRAME_LENGTH_WIDTH-1 downto 0);

--    attribute mark_debug : string;
--    attribute mark_debug of cur_state			: signal is "true";
--    attribute mark_debug of mem_ptr_reg			: signal is "true";
--    attribute mark_debug of length_reg			: signal is "true";
--    attribute mark_debug of ports_reg			: signal is "true";
--    attribute mark_debug of mem_cnt_reg			: signal is "true";
--    attribute mark_debug of read_fifo_sig		: signal is "true";
--    attribute mark_debug of req_fabric_sig		: signal is "true";
--    attribute mark_debug of output_valid_sig	: signal is "true";
--    attribute mark_debug of last_word_sig		: signal is "true";
--    attribute mark_debug of update_ports_sig	: signal is "true";
--    attribute mark_debug of update_fifo_sig		: signal is "true";
    
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

    -- Decode next state, combinitorial logic
    output_logic_p : process(cur_state, pending_low_prio_ports, iqarb_in_fifo_empty, ports_reg, iqarb_out_ports_gnt, mem_cnt_reg, length_reg, higher_prio, empty_const)
    begin
        -- default signal assignments
        nxt_state <= IDLE;
        read_fifo_sig <= '0';
        req_fabric_sig <= '0';
        update_mem_cnt_sig <= '0';
        read_mem_sig <= '0';
        output_valid_sig <= '0';
        last_word_sig <= '0';
        update_ports_sig <= '0';
        update_fifo_sig <= '0';
        
        case cur_state is
            when IDLE => -- waiting for a header to appear in fifo and store data to internal registers
                if iqarb_in_fifo_empty /= empty_const or pending_low_prio_ports /= 0 then
                    nxt_state <= WAIT_GNT;
                    read_fifo_sig <= '1'; -- read_fifo_p
                end if; 
                            
            when WAIT_GNT => -- request to send a frame and wait for grant
                if ports_reg = 0 then
                    nxt_state <= IDLE;
                elsif higher_prio = '1' then
                    nxt_state <= WAIT_GNT;
                    read_fifo_sig <= '1'; -- read_fifo_p
                elsif (iqarb_out_ports_gnt and ports_reg) /= 0 then
                    nxt_state <= SEND_FRAME;
                    update_mem_cnt_sig <= '1'; -- mem_cnt_p
                    read_mem_sig <= '1'; -- mem_enable
                else
                    nxt_state <= WAIT_GNT;
                    req_fabric_sig <= '1'; -- request_fabric_access_p
                end if;
                      
            when SEND_FRAME => -- read the frame data from frame queue memory and forward to switch fabric
                if mem_cnt_reg >= length_reg then
                    nxt_state <= PORT_UPDATE;
                    output_valid_sig <= '1'; -- output_valid
                    last_word_sig <= '1'; -- output_last
                    update_ports_sig <= '1'; -- read_fifo_p
                elsif mem_cnt_reg < length_reg then
                    nxt_state <= SEND_FRAME;
                    update_mem_cnt_sig <= '1'; -- mem_cnt_p
                    read_mem_sig <= '1'; -- mem_enable
                    output_valid_sig <= '1'; -- output_valid
                end if;
                
            when PORT_UPDATE => -- update the remaining output ports for the current frame
                if ports_reg = 0 then
                    nxt_state <= IDLE;
                    update_fifo_sig <= '1'; -- fifo_enable
                else
                    nxt_state <= WAIT_GNT;
                end if;
        end case;
    end process output_logic_p;

    -- determine the fifo the be read from and store its contents to internal registers
    read_fifo_p : process(clk)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                prio_reg <= (others => '0');
                timestamp_reg <= (others => '0');
                mem_ptr_reg <= (others => '0');
                length_reg <= (others => '0');
                ports_reg <= (others => '0');
                fifo_reg <= (others => '0');
                pending_low_prio_ports <= (others => '0');
            else
                prio_reg <= prio_reg;
                timestamp_reg <= timestamp_reg;
                mem_ptr_reg <= mem_ptr_reg;
                length_reg <= length_reg;
                ports_reg <= ports_reg;
                fifo_reg <= fifo_reg;
                pending_low_prio_ports <= pending_low_prio_ports;
                if iqarb_in_fifo_overflow(to_integer(unsigned(fifo_reg))) = '1' then
                    ports_reg <= (others => '0');
                    if fifo_reg = "0" then
                        pending_low_prio_ports <= (others => '0');
                    end if;
                elsif update_ports_sig = '1' then
                    ports_reg <= ports_reg and (not iqarb_out_ports_gnt);
                    if NR_IQ_FIFOS = 2 and fifo_reg = "0" then -- a low priority multicast frame might be suppressed by a high priority message before transmitting to all output ports
                        pending_low_prio_ports <= ports_reg and (not iqarb_out_ports_gnt); -- store in this register and continue transmission later
                    end if;
                elsif read_fifo_sig = '1' then
                    if NR_IQ_FIFOS = 2 and iqarb_in_fifo_empty(NR_IQ_FIFOS-1) = '0' then -- high priority fifo
                        prio_reg <= iqarb_in_fifo_data(IQ_FIFO_DATA_WIDTH+IQ_FIFO_PRIO_START+VLAN_PRIO_WIDTH-1 downto IQ_FIFO_DATA_WIDTH+IQ_FIFO_PRIO_START);
                        timestamp_reg <= iqarb_in_fifo_data(IQ_FIFO_DATA_WIDTH+IQ_FIFO_TIMESTAMP_START+TIMESTAMP_WIDTH-1 downto IQ_FIFO_DATA_WIDTH+IQ_FIFO_TIMESTAMP_START);
                        mem_ptr_reg <= iqarb_in_fifo_data(IQ_FIFO_DATA_WIDTH+IQ_FIFO_MEM_PTR_START+IQ_MEM_ADDR_WIDTH_A-1 downto IQ_FIFO_DATA_WIDTH+IQ_FIFO_MEM_PTR_START);
                        length_reg <= iqarb_in_fifo_data(IQ_FIFO_DATA_WIDTH+IQ_FIFO_FRAME_LEN_START+FRAME_LENGTH_WIDTH-1 downto IQ_FIFO_DATA_WIDTH+IQ_FIFO_FRAME_LEN_START);
                        ports_reg <= iqarb_in_fifo_data(IQ_FIFO_DATA_WIDTH+IQ_FIFO_PORTS_START+NR_PORTS-1 downto IQ_FIFO_DATA_WIDTH+IQ_FIFO_PORTS_START);
                        fifo_reg <= "1";
                    else -- low priority fifo
                        prio_reg <= iqarb_in_fifo_data(IQ_FIFO_PRIO_START+VLAN_PRIO_WIDTH-1 downto IQ_FIFO_PRIO_START);
                        timestamp_reg <= iqarb_in_fifo_data(IQ_FIFO_TIMESTAMP_START+TIMESTAMP_WIDTH-1 downto IQ_FIFO_TIMESTAMP_START);
                        mem_ptr_reg <= iqarb_in_fifo_data(IQ_FIFO_MEM_PTR_START+IQ_MEM_ADDR_WIDTH_A-1 downto IQ_FIFO_MEM_PTR_START);
                        length_reg <= iqarb_in_fifo_data(IQ_FIFO_FRAME_LEN_START+FRAME_LENGTH_WIDTH-1 downto IQ_FIFO_FRAME_LEN_START);
                        if pending_low_prio_ports /= 0 then
                            ports_reg <= pending_low_prio_ports;
                        else
                            ports_reg <= iqarb_in_fifo_data(IQ_FIFO_PORTS_START+NR_PORTS-1 downto IQ_FIFO_PORTS_START);
                        end if;
                        fifo_reg <= "0";
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- set the switch fabric signals needed for output arbitration
    request_fabric_access_p : process(clk)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                iqarb_out_ports_req <= (others => '0');
                iqarb_out_prio <= (others => '0');
                iqarb_out_timestamp <= (others => '0');
                iqarb_out_length <= (others => '0');
            else
                iqarb_out_ports_req <= (others => '0');
                iqarb_out_prio <= prio_reg;
                iqarb_out_timestamp <= timestamp_reg;
                iqarb_out_length <= length_reg;
                if req_fabric_sig = '1' then
                    iqarb_out_ports_req <= ports_reg;
                end if;
            end if;
        end if;
    end process;

    -- count bytes read out of memory
    mem_cnt_p : process(clk)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                mem_cnt_reg <= (others => '0');
            else
                mem_cnt_reg <= (others => '0');
                if update_mem_cnt_sig = '1' then
                    mem_cnt_reg <= mem_cnt_reg + IQ_MEM_DATA_WIDTH_RATIO;
                end if;
            end if;
        end if;
    end process;

    -- check if an a higher priority frame is available on a fifo different than the selected one
    higher_prio_p : process(fifo_reg, iqarb_in_fifo_empty)
    begin
        higher_prio <= '0';
        if NR_IQ_FIFOS = 2 and fifo_reg = "0" and iqarb_in_fifo_empty(NR_IQ_FIFOS-1) = '0' then
            higher_prio <= '1';
        end if;
    end process;

    -- singals to input queue memory
    iqarb_in_mem_enable <= read_mem_sig;
    iqarb_in_mem_addr <= mem_ptr_reg(IQ_MEM_ADDR_WIDTH_A-1 downto IQ_MEM_ADDR_WIDTH_A-IQ_MEM_ADDR_WIDTH_B) 
                           + mem_cnt_reg(FRAME_LENGTH_WIDTH-1 downto IQ_MEM_ADDR_WIDTH_A-IQ_MEM_ADDR_WIDTH_B);
    -- output sigals to fabric
    iqarb_out_data <= iqarb_in_mem_data;
    iqarb_out_valid <= output_valid_sig;
    iqarb_out_last <= last_word_sig;
    -- signals to fifo
    iqarb_in_fifo_enable <= update_fifo_sig;
    iqarb_in_fifo_prio <= fifo_reg(0);

end rtl;
