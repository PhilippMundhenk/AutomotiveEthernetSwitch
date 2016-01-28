----------------------------------------------------------------------------------
-- Company: TUM CREATE
-- Engineer: Andreas Ettner
-- 
-- Create Date: 19.11.2013 09:52:09
-- Design Name: 
-- Module Name: rx_path_header_extraction - rtl
-- Project Name: automotive ethernet gateway
-- Target Devices: zynq 7000
-- Tool Versions: vivado 2013.3

-- Description:
-- Incoming frames are analyzed and the ethernet header is analyzed
-- the output consists of the source address of the incoming frame,
--     a signal for vlan frame indication and the vlan priority
-- a state machine handles the header extraction and the forwarding of the outputs
--
-- more details in switch_port_rxpath_header_extraction.svg
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

entity rx_path_header_extraction is
    Generic (
        RECEIVER_DATA_WIDTH  	: integer;
        DEST_ADDR_WIDTH       	: integer;
        VLAN_PRIO_WIDTH         : integer;
        TIMESTAMP_WIDTH         : integer
    );
    Port (
        clk                   	: in  std_logic;
        reset                 	: in  std_logic;
        -- input interface
        hext_in_data          	: in std_logic_vector(RECEIVER_DATA_WIDTH-1 downto 0);
        hext_in_valid         	: in std_logic;
        hext_in_last          	: in std_logic; 
        hext_in_timestamp_cnt   : in std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        -- output interface
        hext_out_dest       	: out std_logic_vector(DEST_ADDR_WIDTH-1 downto 0);
        hext_out_vlan_enable    : out std_logic;
        hext_out_vlan_prio      : out std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0);
        hext_out_valid        	: out std_logic;
        hext_out_timestamp      : out std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
        hext_out_ready        	: in std_logic
    );
end rx_path_header_extraction;

architecture rtl of rx_path_header_extraction is

    constant DEST_ADDR_WIDTH_BYTE   : integer := DEST_ADDR_WIDTH/8;
    constant SOURCE_ADDR_WIDTH      : integer := 6;
    constant UPPER_DEST_ADDRESS     : integer := SOURCE_ADDR_WIDTH;
    constant UPPER_SOURCE_ADDRESS   : integer := UPPER_DEST_ADDRESS + SOURCE_ADDR_WIDTH;
    constant CNT_WIDTH              : integer := 5; -- ld ethernet_header size = ld 18
    constant VLAN_TPID1             : std_logic_vector(RECEIVER_DATA_WIDTH-1 downto 0) := x"81";
    constant VLAN_TPID2             : std_logic_vector(RECEIVER_DATA_WIDTH-1 downto 0) := x"00";
    constant TPID_UPPER             : integer := 7;
    constant TPID_LOWER             : integer := 5;

    -- extraction header state machine
    type state is (
        IDLE,
        DEST_ADDR,
        SOURCE_ADDR,
        TYPE_LENGTH1,
        TYPE_LENGTH2,
        VLAN_PRIO,
        HANDSHAKE,
        WAIT_EOF
    );
    signal cur_state    	: state;
    signal nxt_state     	: state;
    
    -- state machine signals
    signal update_cnt_sig       : std_logic := '0';
    signal reset_cnt_sig        : std_logic := '0';
    signal read_dest_sig 	    : std_logic := '0';
    signal vlan_frame_sig       : std_logic := '0';
    signal no_vlan_frame_sig    : std_logic := '0';
    signal read_vlan_prio_sig   : std_logic := '0';
    signal valid_out_sig 	    : std_logic := '0';
    signal read_timestamp_sig   : std_logic := '0';
    -- process registers
    signal dest_reg    	        : std_logic_vector(DEST_ADDR_WIDTH-1 downto 0) := (others => '0'); -- contains mac destination address
    signal vlan_frame_reg       : std_logic := '0'; -- indicates whether the current frame is a vlan frame
    signal vlan_prio_reg        : std_logic_vector(VLAN_PRIO_WIDTH-1 downto 0) := (others => '0'); -- contains the vlan priority
    signal valid_reg            : std_logic := '0'; -- indicates whether output is valid or not
    signal timestamp_reg        : std_logic_vector(TIMESTAMP_WIDTH-1 downto 0);
    signal cnt      	        : std_logic_vector(CNT_WIDTH-1 downto 0) := (others => '0'); -- frame byte counter
	
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
	output_logic_p : process(cur_state, hext_in_valid, cnt, hext_out_ready, hext_in_data, hext_in_last)
	begin
		nxt_state <= IDLE;
		update_cnt_sig <= '0';
		reset_cnt_sig <= '0';
		read_dest_sig <= '0';
		vlan_frame_sig <= '0';
		no_vlan_frame_sig <= '0';
		read_vlan_prio_sig <= '0';
		valid_out_sig <= '0';
		read_timestamp_sig <= '0';
    
		case cur_state is
			when IDLE => -- waiting for a frame
				if hext_in_valid = '1' and hext_in_last = '0' then
					nxt_state <= DEST_ADDR;
					update_cnt_sig <= '1'; -- cnt_p
					read_dest_sig <= '1'; -- dest_mac_p
					read_timestamp_sig <= '1'; -- read_timestamp_p
				end if;
            
			when DEST_ADDR => -- extracting the destination mac address
				if cnt = UPPER_DEST_ADDRESS-1 and hext_in_valid = '1' then
					nxt_state <= SOURCE_ADDR;
				else
					nxt_state <= DEST_ADDR;
			    end if;
			    if hext_in_valid = '1' then
					read_dest_sig <= '1'; -- dest_mac_p
					update_cnt_sig <= '1'; -- cnt_p
				end if;
				
			when SOURCE_ADDR => -- 6 bytes of source mac address
			    if cnt = UPPER_SOURCE_ADDRESS-1 and hext_in_valid = '1' then
                    nxt_state <= TYPE_LENGTH1;
                else
                    nxt_state <= SOURCE_ADDR;
                end if;
                if hext_in_valid = '1' then
                    update_cnt_sig <= '1'; -- cnt_p
                end if;
            
            when TYPE_LENGTH1 => -- first length/type byte, check for vlan frame
                if hext_in_valid = '1' then
                    if hext_in_data = VLAN_TPID1 then
                        nxt_state <= TYPE_LENGTH2;
                    else
                        no_vlan_frame_sig <= '1'; -- vlan_frame_p
                        valid_out_sig <= '1'; -- output_handshake_p
                        nxt_state <= HANDSHAKE;
                    end if;
                else
                    nxt_state <= TYPE_LENGTH1;
                end if;
                
            when TYPE_LENGTH2 => -- second length/type byte, check for vlan frame
                if hext_in_valid = '1' then
                    if hext_in_data = VLAN_TPID2 then
                        nxt_state <= VLAN_PRIO;
                        vlan_frame_sig <= '1'; -- vlan_frame_p
                    else
                        no_vlan_frame_sig <= '1'; -- vlan_frame_p
                        valid_out_sig <= '1'; -- output_handshake_p
                        nxt_state <= HANDSHAKE;
                    end if;
                else
                    nxt_state <= TYPE_LENGTH2;
                end if;
                
            when VLAN_PRIO => -- extract vlan priority field
                if hext_in_valid = '1' then
                    nxt_state <= HANDSHAKE;
                    valid_out_sig <= '1'; -- output_handshake_p
                    read_vlan_prio_sig <= '1'; -- vlan_prio_p
                else
                    nxt_state <= VLAN_PRIO;
                end if;
            
			when HANDSHAKE => -- send output data to next layer
				if hext_out_ready = '1' then
					nxt_state <= WAIT_EOF;
					reset_cnt_sig <= '1'; -- cnt_p
				else
					nxt_state <= HANDSHAKE;
					valid_out_sig <= '1'; -- output_handshake_p
				end if;
            
			when WAIT_EOF => -- wait for last byte of current frame
				if hext_in_last = '1' then
					nxt_state <= IDLE;
				else
					nxt_state <= WAIT_EOF;
				end if;
		end case;
	end process;
 
    -- header bytes counter
    cnt_p : process (clk)
    begin
        if clk'event and clk = '1' then
            if reset = '1'  or reset_cnt_sig = '1' then
                cnt <= (others => '0');
            else
                cnt <= cnt;
                if update_cnt_sig = '1' then
                    cnt <= cnt + 1;
                end if;
            end if;
        end if;
    end process;
 
	-- write the destination address of the current frame to an internal register
	dest_mac_p : process (clk)
		variable remaining_dest_bytes : integer;
	begin
		if clk'event and clk = '1' then
			if reset = '1' then
				dest_reg <= (others => '0');
			else
				dest_reg <= dest_reg;
				if read_dest_sig = '1' then
					remaining_dest_bytes := DEST_ADDR_WIDTH_BYTE - to_integer(unsigned(cnt));
					dest_reg(remaining_dest_bytes*8-1 downto remaining_dest_bytes*8-RECEIVER_DATA_WIDTH) <= hext_in_data;
				end if;
			end if;
		end if;
	end process;

    -- store the timestamp for incoming messages
    read_timestamp_p : process(clk)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                timestamp_reg <= (others => '0');
            else
                timestamp_reg <= timestamp_reg;
                if read_timestamp_sig = '1' then
                    timestamp_reg <= hext_in_timestamp_cnt;
                end if;
            end if;
        end if;
    end process;

    -- write to an internal register if the current frame is a vlan frame
    vlan_frame_p : process (clk)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                vlan_frame_reg <= '0';
            else
                vlan_frame_reg <= vlan_frame_reg;
                if no_vlan_frame_sig = '1' then
                    vlan_frame_reg <= '0';
                elsif vlan_frame_sig = '1' then
                    vlan_frame_reg <= '1';
                end if;
            end if;
        end if;
    end process;
    
    -- write the vlan priority to an internal register
    vlan_prio_p : process (clk)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                vlan_prio_reg <= (others => '0');
            else
                vlan_prio_reg <= vlan_prio_reg;
                if read_vlan_prio_sig = '1' then
                    vlan_prio_reg <= hext_in_data(TPID_UPPER downto TPID_LOWER);
                end if;
            end if;
        end if;
    end process;

	-- handshake protocol to send header to next layer
	output_handshake_p : process (clk)
	begin
		if clk'event and clk = '1' then
			if reset = '1' then
				valid_reg <= '0';
			else
			    valid_reg <= '0';
				if valid_out_sig = '1' then
					valid_reg <= '1';
				end if;
			end if;
		end if;
	end process;

    hext_out_dest <= dest_reg;
	hext_out_vlan_enable <= vlan_frame_reg;
	hext_out_vlan_prio <= vlan_prio_reg;
	hext_out_valid <= valid_reg;
	hext_out_timestamp <= timestamp_reg;
	
end rtl;
