module rx_path_lookup 
#(
    parameter DEST_MAC_WIDTH          = 48,
    parameter NR_PORTS                = 4,
    parameter PORT_ID                 = 0,
    parameter LOOKUP_MEM_ADDR_WIDTH   = 9,
    parameter LOOKUP_MEM_DATA_WIDTH   = 64,
    parameter VLAN_PRIO_WIDTH         = 0,
    parameter TIMESTAMP_WIDTH         = 0,
    // lookup memory address constants
    parameter LOWER_ADDR_START       = 20,
    parameter UPPER_ADDR_START       = 40,
    parameter DEF_ADDR_START         = 0,
    parameter ENABLE_START           = 63,
    parameter PORTS_START            = 60,
    parameter PRIO_START             = 48,
    parameter SKIP_FRAME_START       = 0,
    parameter DEST_MAC_START         = 0
    )

(
        clk,
        reset,                   
        lookup_in_dest,          
        lookup_in_vlan_enable,   
        lookup_in_vlan_prio,     
        lookup_in_valid,         
        lookup_in_timestamp,     
        lookup_in_ready,         
        lookup_out_ports,        
        lookup_out_prio,         
        lookup_out_skip,         
        lookup_out_timestamp,    
        lookup_out_valid,        
        mem_enable,              
        mem_addr,                
        mem_data                
);

        input  clk ;
        input  reset;
        // input interface
        input  [DEST_MAC_WIDTH-1:0]  lookup_in_dest;
        input                        lookup_in_vlan_enable;
        input  [VLAN_PRIO_WIDTH-1:0] lookup_in_vlan_prio;
        input                        lookup_in_valid;
        input  [TIMESTAMP_WIDTH-1:0] lookup_in_timestamp;
        output reg                   lookup_in_ready;
        // output interface
        output [NR_PORTS-1:0]        lookup_out_ports;
        output [VLAN_PRIO_WIDTH-1:0] lookup_out_prio;
        output                       lookup_out_skip;
        output [TIMESTAMP_WIDTH-1:0] lookup_out_timestamp;
        output reg                   lookup_out_valid;
        // lookup memory interface
        output reg                              mem_enable;
        output reg [LOOKUP_MEM_ADDR_WIDTH-1:0]  mem_addr;
        input  [LOOKUP_MEM_DATA_WIDTH-1:0]  mem_data;
        
        parameter IDLE          = 2'd0;
        parameter READ_BASE     = 2'd1;
        parameter LOOKUP        = 2'd2;
        parameter READ_DEFAULT  = 2'd3;
        
        reg [1:0] state;
        
        reg                                  read_header_sig;
        reg                                  read_base_sig;
        reg                                  read_default_sig;
        reg                                  lookup_valid_sig;
        reg                                  read_lookup_sig;
        reg                                  update_sig;
        reg                                  mem_enable_d1;
        reg  [LOOKUP_MEM_ADDR_WIDTH-1 : 0]   lower_sig;
        reg  [LOOKUP_MEM_ADDR_WIDTH-1 : 0]   upper_sig;
        
        //   process registers
        reg  [DEST_MAC_WIDTH-1 : 0]          dest_mac_reg;     
        reg                                  vlan_enable_reg;
        reg  [VLAN_PRIO_WIDTH-1 : 0]         vlan_prio_reg; 
        reg  [LOOKUP_MEM_ADDR_WIDTH-1 : 0]   lower_reg;
        reg  [LOOKUP_MEM_ADDR_WIDTH-1 : 0]   upper_reg;
        reg  [LOOKUP_MEM_ADDR_WIDTH-1 : 0]   median_reg;
        reg  [LOOKUP_MEM_ADDR_WIDTH-1 : 0]   default_reg;
        reg  [NR_PORTS-1 : 0]                ports_reg;
        reg  [VLAN_PRIO_WIDTH-1 : 0]         prio_reg;
        reg                                  skip_frame_reg;
        reg  [TIMESTAMP_WIDTH-1 : 0]         timestamp_reg;
        
        // alias signals for memory read access
        wire [LOOKUP_MEM_ADDR_WIDTH-1 : 0]   mem_lower_sig;
        wire [LOOKUP_MEM_ADDR_WIDTH-1 : 0]   mem_upper_sig;
        wire [LOOKUP_MEM_ADDR_WIDTH-1 : 0]   mem_default_sig;
        wire                                 mem_lookup_enable_sig;
        wire [NR_PORTS-1 : 0]                mem_ports_sig;
        wire [VLAN_PRIO_WIDTH-1 : 0]         mem_prio_sig;
        wire                                 mem_skip_frame_sig;
        wire [DEST_MAC_WIDTH-1 : 0]          mem_dest_mac_sig;
        
        // internal registers (to be connected to the outside, e.g. housekeeping processor)
        reg [LOOKUP_MEM_ADDR_WIDTH-1 : 0]    base_address = 'd0;
        reg [LOOKUP_MEM_ADDR_WIDTH-1 : 0]    mem_addr_sig;
        
        assign  mem_lower_sig 			= mem_data[LOWER_ADDR_START+LOOKUP_MEM_ADDR_WIDTH-1 : LOWER_ADDR_START];
        assign  mem_upper_sig 			= mem_data[UPPER_ADDR_START+LOOKUP_MEM_ADDR_WIDTH-1 : UPPER_ADDR_START];
        assign  mem_default_sig 		= mem_data[DEF_ADDR_START+LOOKUP_MEM_ADDR_WIDTH-1 : DEF_ADDR_START];
        assign  mem_lookup_enable_sig 	= mem_data[ENABLE_START];
        assign  mem_ports_sig 			= mem_data[PORTS_START+NR_PORTS-1 : PORTS_START];
        assign  mem_prio_sig            = mem_data[PRIO_START+VLAN_PRIO_WIDTH-1 : PRIO_START];
        assign  mem_skip_frame_sig 		= mem_data[SKIP_FRAME_START];
        assign  mem_dest_mac_sig 		= mem_data[DEST_MAC_START+DEST_MAC_WIDTH-1 : DEST_MAC_START];
        
        
        
        always @ (posedge clk) 
        begin
        if (reset) begin
            state <= IDLE;
            read_header_sig <= 1'b0;    // read_header_p
            read_base_sig <= 1'b0;      // write_internal_registers_p
            read_default_sig <= 1'b0;   // output_reg_p
            lookup_valid_sig <= 1'b0;   // output_valid_p
            read_lookup_sig <= 1'b0;    // output_reg_p
            update_sig <= 1'b0;         // write_internal_registers_p
            upper_reg <= 'b0; 
            upper_sig <= 'b0; 
            lower_reg  <= 'b0; 
            lower_sig  <= 'b0; 
            median_reg <= 'b0; 
            default_reg <= 'b0; 
            mem_enable <= 1'b0;
            mem_enable_d1 <= 1'b0;
            mem_addr <= 'hFFF;
			dest_mac_reg <= 'b0;
			vlan_enable_reg <= 1'b0;
			vlan_prio_reg <= 'b0;
			timestamp_reg <= 'b0;
            lookup_in_ready <= 1'b0;            
        end
        else begin
        // 1 Pulse
          read_header_sig <= 1'b0; 
          read_base_sig <= 1'b0; 
          read_default_sig <= 1'b0;
          lookup_valid_sig <= 1'b0;
          read_lookup_sig <= 1'b0;
          update_sig <= 1'b0;
          lookup_in_ready <= 1'b0;
          upper_reg <= upper_sig;
          lower_reg <= lower_sig;
          mem_enable_d1 <= mem_enable;
		  case(state)
			IDLE : begin // waiting for a new header
				if (lookup_in_valid) begin
					state <= READ_BASE;
					read_header_sig <= 1'b1; // read_header_p
					mem_enable <= 1'b1;
					mem_addr <= base_address;
                    // Hand shakes
                    dest_mac_reg <= lookup_in_dest;
                    vlan_enable_reg <= lookup_in_vlan_enable;
                    vlan_prio_reg <= lookup_in_vlan_prio;
                    timestamp_reg <= lookup_in_timestamp;
                    lookup_in_ready <= 1'b1;                    
				end
            end
			READ_BASE : begin // read base address, determine if lookup is enabled
			  if (mem_enable_d1 && mem_enable) begin
			    mem_enable_d1 <= 1'b0; // force a 1 pulse wait
				read_base_sig <= 1'b1; // internal_reg_p
                default_reg <= mem_default_sig;
				mem_enable <= 1'b1;
				if (~mem_lookup_enable_sig) begin // lookup disabled, read default configuration
					state <= READ_DEFAULT;
					mem_addr <= mem_default_sig;
                end
				else begin // lookup enabled, search for address in the middle of binary lookup list
					state <= LOOKUP;
					upper_sig <= mem_upper_sig; // upper_add_lower_by2_f
					upper_reg <= mem_upper_sig; // upper_add_lower_by2_f
					lower_sig <= mem_lower_sig; // upper_add_lower_by2_f
					lower_reg <= mem_lower_sig; // upper_add_lower_by2_f
					mem_addr <= (mem_upper_sig + mem_lower_sig)/2; // upper_add_lower_by2_f
				end
		      end
            end
			LOOKUP : begin // lookup the median memory address and check if the memory mac address matches the frame mac address
			  if (mem_enable_d1 && mem_enable) begin
			    mem_enable_d1 <= 1'b0; // force a 1 pulse wait	
				if (dest_mac_reg == mem_dest_mac_sig) begin // MAC ADDRESS found -> Algorithm terminates
					state <= IDLE;
					read_lookup_sig <= 1'b1; // output_reg_p
					lookup_valid_sig  <= 1'b1; // output_valid_p
                    mem_enable <= 1'b0;
                end
				else if (upper_reg == lower_reg) begin // MAC ADDRESS not found -> Algorithm terminats with default configuration
					state <= READ_DEFAULT;
					mem_addr <= default_reg;
					//mem_enable <= 1'b1;
                end
				else begin // MAC ADDRESS not found, Algorithm not terminated yet, continue lookup with decreased search space
					update_sig <= 1'b1; // internal_reg_p
					//mem_addr <= median_reg[LOOKUP_MEM_ADDR_WIDTH-1:1]; // upper_add_lower_by2_f
					// mem_enable <= 1'b1;
					state <= LOOKUP;
					if (dest_mac_reg > mem_dest_mac_sig) begin
                        if (upper_sig == lower_sig + 1'b1) begin
                            upper_sig <= lower_sig;
                            mem_addr  <= lower_sig;
                        end
                        else begin
                            lower_sig <= mem_addr; // upper_add_lower_by2_f
                            mem_addr  <= (upper_sig[LOOKUP_MEM_ADDR_WIDTH-1:1] + mem_addr[LOOKUP_MEM_ADDR_WIDTH-1:1] + (|{mem_addr[0],upper_sig[0]}));					
                        end
                    end
                    
					else begin // dest_mac_reg < mem_dest_mac_sig
                        if (upper_sig == lower_sig + 1'b1) begin
                            upper_sig <= lower_sig;
                            mem_addr  <= lower_sig;
                        end
                        else begin					
						    upper_sig <= mem_addr; // upper_add_lower_by2_f
                            mem_addr  <= (lower_sig[LOOKUP_MEM_ADDR_WIDTH-1:1] + mem_addr[LOOKUP_MEM_ADDR_WIDTH-1:1] + (|{mem_addr[0],lower_sig[0]}));
					    end
					end
				end
		      end
              median_reg <= (upper_sig + lower_sig);
                
			end

			READ_DEFAULT : begin
			  if (mem_enable_d1 && mem_enable) begin  
			    state <= IDLE;
				read_default_sig  <= 1'b1; // output_reg_p
				lookup_valid_sig  <= 1'b1; // output_valid_p
                mem_enable <= 1'b0;
              end
            end
		  endcase
        end
	end


	// updates the output value registers (ports, priority and skip)
	always @ (posedge clk)
	begin
		if (reset) begin
			ports_reg <= 'b0;
			prio_reg <= 'b0;
			skip_frame_reg <= 1'b0;
        end
		else begin
			ports_reg <= ports_reg;
			prio_reg <= prio_reg;
			skip_frame_reg <= skip_frame_reg;
			if (read_default_sig) begin
				ports_reg <= mem_ports_sig;
				ports_reg[PORT_ID] <= 1'b0;
				if (lookup_in_vlan_enable)
				   prio_reg <= vlan_prio_reg;
				else
				   prio_reg <= mem_prio_sig;
				skip_frame_reg <= mem_skip_frame_sig;
            end    
            
			else if (read_lookup_sig) begin
				ports_reg <= mem_ports_sig;
				ports_reg[PORT_ID] <= 1'b0; // comment for loopback functionality
				if (lookup_in_vlan_enable)
				   prio_reg <= vlan_prio_reg;
			    else
				   prio_reg <= mem_prio_sig;
				skip_frame_reg <= 1'b0;
			end
		end
	end

	// sets the output valid bit
	always @ (posedge clk)
	begin
		if (reset)
			lookup_out_valid <= 1'b0;
		else begin
			lookup_out_valid <= 1'b0;
			if (lookup_valid_sig)
				lookup_out_valid <= 1'b1;

		end
	end
  
	// other outputs
	assign lookup_out_ports  = ports_reg;
	assign lookup_out_prio   = prio_reg;
	assign lookup_out_skip   = skip_frame_reg;
	assign lookup_out_timestamp = timestamp_reg;
  
endmodule
    