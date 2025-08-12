# Distributed Arthimetic FIR filter
The code implements a 3-tap FIR filter using Distributed Arithmetic (DA).It calculates the FIR filter output as  
                                                                          <div align="center">

Y = $c_0 \times x_0$ + $c_1 \times x_1$ + $c_2 \times x_2$

</div>
  
where x is input and c is the FIR filer coefficients. The calculation is done bit-serially using a lookup table (LUT) instead of traditional multipliers, which saves hardware. The accumulator(da_accum) stores all the partial results during DA. DA is used as it saves hardware and hence fast and efficient. While it is useful for FPGA implementation, small tap filte, devices without or with low amount of multipliers, etc; it cannot be used for high-performance DSPs and high-precision filtering.
