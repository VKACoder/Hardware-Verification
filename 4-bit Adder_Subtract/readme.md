The 4-bit Adder/Subtractor is the basic building of an ALU. 

It works as follows:

-> The inputs to the block are: A, B and Cin

-> The outputs are: sum and cout

-> The block performs A+B (addition) when Cin = 0 and A-B (subtraction) when Cin = 1.

-> During the addition operation, the augend and addend are passed as such and the block performs ripple carry addition (simplest N-bit adder architecture).

-> However during subtraction operation, the addend is convert to its 2's complement using controlled inverter circuit (EXOR with one input as 1, which is Cin). This enables the same adder architecture to perform addition and 2's complement subtraction, thus saving hardware resources(area).

<img width="512" height="240" alt="fullAdder-1" src="https://github.com/user-attachments/assets/3ea16e1f-f179-4fd9-9669-3d80d4c70db7" />

Fig 1: Full Adder

<img width="613" height="340" alt="dig51" src="https://github.com/user-attachments/assets/1a99910b-6a20-479e-acf0-bea3f09f72f9" />

Fig 2: 4-bit Adder/Subtractor circuit using Full adders and EXOR.

EDA Playground link: https://edaplayground.com/x/mpVw
