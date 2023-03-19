# 32-bit-RISC-V-Cpu-Design-Verilog
This RISCV CPU Architecture is designed on the efficient and effective operation of all instructions. However, for simulation purposes, a processor that can work with 15 instructions has been designed. The designed processor produces the correct output for all the specified instructions in a single cycle.

![image](https://user-images.githubusercontent.com/70805475/226185845-bdee06cd-6592-4560-81c8-2c1cc6e9d722.png)

For the 15 instructions mentioned here, the first 7 bits in each instruction can be assigned as opcode, thus distinguishing which instruction type it is. After the instruction type is distinguished, the operation to be performed is determined by looking at the 13-14-15.bits in the instruction.

- In order to complete all orders in a single cycle, when the posedge (rising edge) of each clk value comes, it processes and completes the orders.
- 8 32-bit registers are created in the module as register_obegi.
- 32-bit data consisting of 128 lines is created and stored as data_memory. (The 0x0000_0000 address is the beginning of the first 4 bytes in memory, and the 0x0000_0004 is the beginning of the second 4 bytes.)
- Since 4-byte addressing is used in the memory, the addresses are shifted to the right 2 times in the code. (address >> 2)
- command_memory does read only and data_memory does both read and write.
- The first element of the register always takes the value 0.
( register_obegi[0] = 32'b00000000_00000000_00000000_00000000; )
- It is obtained in 3 steps after each command by keeping 2 different variables for the ps value.

(1) counter_next = counter + 4 | (2) counter <= counter_next | (3) ps <= counter_next

The purpose here is to use the counter with the ps value to show the next instruction.
