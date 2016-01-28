# This program creates the lookup memory initialisation file
# for the structure of the lookup memory see switch_port_rxpath_lookup_memory.svg
##############################################################
import math
	
### Constant definitions:
# File parameters
filename = 'lookup_mem_init.coe'
NR_FRAMES = 256 # number of different destination addresses sent by test bench
NO_ENTRY_RATE = 4 # one fourth of all the destination addresses sent by test bench are not in lookup memory
NR_ENTRIES = int(math.ceil(NR_FRAMES * 3/NO_ENTRY_RATE)) + 1 # unicast messages + 1 broadcast message
PRIO1_MAX = 3 # Frames with destination address up to PRIO1_MAX have high priority, others low priority

# Bit lengths
MAC_LENGTH = 48
ADDR_LENGTH = 9
BYTE_LENGTH = 8
PORT_LENGTH = 4
PRIO_LENGTH = 3
ENABLE_LENGTH = 1
SKIP_LENGTH = 1

# Start positions of fields in configuration file
DEF_ADDR_START = 0 # base configuration
LOWER_ADDR_START = 20 # base config
UPPER_ADDR_START = 40 # base config
ENABLE_START = 63 # base config
MAC_START = 0 # frame config
PRIO_START = 48 # frame and def config
PORTS_START = 60 # frame and def config
SKIP_START = 0 # def config

# Base Configuration Values
ENABLE = 0b1
LOWER_ADDR = 1
UPPER_ADDR = NR_ENTRIES
DEF_ADDR = NR_ENTRIES + 1

# MAC Configuration Values
DEST_MAC1 = 0xDA
DEST_MAC2 = 0xDA
DEST_MAC3 = 0xDA
DEST_MAC4 = 0xDA
DEST_MAC5 = 0xDA
DEST_MAC6 = 0x00
BROAD_MAC = 0xFF

# Default Configuration Values`
DEF_PORT = 0b1111
DEF_PRIO = 0b000
SKIP_FRAME = 0b1

### Function definitions
# return string of 0s of length n
def zero_string(n):
	i = 0
	string = ''
	while i < n:
		string = string + '0'
		i = i + 1
	return string

# return a binary string of number x of length n
def bit_string(x, n):
	string = "{0:b}".format(x)
	while len(string) < n:
		string = '0' + string
	return string

# return the port vector for a destination address depending on the last destination MAC Byte (x)
def get_ports(x):
	x = x % NO_ENTRY_RATE
	port = 2**x # one hot encoding
	return bit_string(port, PORT_LENGTH)
	
### write configuration to file
f = open(filename, 'w')
f.write("memory_initialization_radix=2;\n")
f.write("memory_initialization_vector=\n")
# Base Configuration
f.write(bit_string(ENABLE, ENABLE_LENGTH) + \
		zero_string(ENABLE_START-(UPPER_ADDR_START+ADDR_LENGTH)) + \
		bit_string(UPPER_ADDR, ADDR_LENGTH) + \
		zero_string(UPPER_ADDR_START-(LOWER_ADDR_START+ADDR_LENGTH)) + \
		bit_string(LOWER_ADDR, ADDR_LENGTH) + \
		zero_string(LOWER_ADDR_START-(DEF_ADDR_START+ADDR_LENGTH)) + \
		bit_string(DEF_ADDR, ADDR_LENGTH) + \
		'\n')

# Frame Configurations
loop = 0
while loop < 256:
	DEST_MAC6 = loop
	if ((loop+1) % NO_ENTRY_RATE) == 0: # dest_mac6 0x03, 0x07, 0x0b ... has no entry in lookup table
		loop = loop + 1
		continue
	mac_string = bit_string(DEST_MAC1, BYTE_LENGTH) + \
			bit_string(DEST_MAC2, BYTE_LENGTH) + \
			bit_string(DEST_MAC3, BYTE_LENGTH) + \
			bit_string(DEST_MAC4, BYTE_LENGTH) + \
			bit_string(DEST_MAC5, BYTE_LENGTH) + \
			bit_string(DEST_MAC6, BYTE_LENGTH)
	port_string = get_ports(loop)
	if loop <= PRIO1_MAX:
		prio_string = '001'
	else:
		prio_string = '000'
	f.write(port_string + \
			zero_string(PORTS_START-(PRIO_START+PRIO_LENGTH)) + \
			prio_string + \
			mac_string + \
			'\n')
	loop = loop + 1
	
# Broadcast Configuration
mac_string = bit_string(BROAD_MAC, BYTE_LENGTH) + \
		bit_string(BROAD_MAC, BYTE_LENGTH) + \
		bit_string(BROAD_MAC, BYTE_LENGTH) + \
		bit_string(BROAD_MAC, BYTE_LENGTH) + \
		bit_string(BROAD_MAC, BYTE_LENGTH) + \
		bit_string(BROAD_MAC, BYTE_LENGTH)
port_string = '1111'
prio_string = '000'
f.write(port_string + \
		zero_string(PORTS_START-(PRIO_START+PRIO_LENGTH)) + \
		prio_string + \
		mac_string + \
		'\n')
	
# Default Configuration
f.write(bit_string(DEF_PORT, PORT_LENGTH) + \
		zero_string(PORTS_START-(PRIO_START+PRIO_LENGTH)) + \
		bit_string(DEF_PRIO, PRIO_LENGTH) + \
		zero_string(PRIO_START-(SKIP_START+SKIP_LENGTH)) + \
		bit_string(SKIP_FRAME, SKIP_LENGTH) + \
		'\n')

f.close()
