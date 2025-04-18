# 1) Basic Dual-Clock FIFO Memory  
This Code contains the Verilog implementation of an dual-clock/Asynchronous FIFO memory, designed for efficient data transfer between asynchronous clock domains. A Queue but acts as a circular buffer that comes with read/write control, 
empty/full status flags and a count. the fifo counter counts no of words present in the fifo, for example if each word length(DATAD)=8, it counts no of 8 bits are there in the fifo. By varying the paramets, we can adjust the fifo to our requirement.
This code is avery basic and i recognise it is not adjusted to Clock Domain Crossing. This is a basic asynchronous fifo and can be used as buffer registers for application such as uart to processor, packet transfer between 2 systems

# 2) Adjusted Dual-Clock FIFO Memory
This code contains the Verilog Implementation of the modified dual-clock/asynchronous FIFO memeory adjusted for Cross Domain Crossing(CDC) using 2 flip flop synchronizer and gray code to minimize switching to avoid glitches dual to more than bit toggling.The dual flop-flop
reduces the chances of metastability.The FIFO counter is removes as it is the place with higher chance of CDC.The aditional registers added function as the synchronizer.The functions are used to convert from binary to gray or gray to binary.
