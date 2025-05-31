# Battle-City-Game-spartan6

Project Overview
This repository contains the final project for the Computer-Aided Design course offered by the Computer Engineering Department at the University of Guilan, Rasht, Iran, for the Fall 2021 semester. The goal of this project is to design a hardware-based interactive game using VHDL, controlling visual game elements displayed on a monitor through a VGA interface. The project demonstrates the application of computer-aided design principles, including digital logic design, VHDL programming, FPGA implementation, and VGA signal generation, while providing an interactive platform for users to engage with the hardware.
The randomly generated sequences are used at the beginning to create a map of blocks consisting of dirt, rock, space, and ice. Each block has unique characteristics; for example, moving on ice increases movement speed, while dirt blocks are destructible.


Objective: Players interact with random visual outputs (e.g., moving shapes, colored pixels, or patterns) by pressing buttons or toggling switches to capture the green flag by moving or shooting the blocks ahead.

Example Game Scenario

The LFSR generates a random number, which is mapped to a visual element, such as a colored square appearing at a random position on the screen.
The player must press a button to "select" the element when it appears in a specific region or matches a certain color.
If the player responds correctly, the game progresses to the next random pattern; otherwise, it may display a "game over" message or reset the display.
The VGA interface continuously refreshes the monitor to show the updated game state.

Board : 

   Spartan6-LX9
   The Spartan-6 LX9 is a cost-effective FPGA from AMD (formerly Xilinx), designed for high-performance applications with optimized power efficiency. It features 9,152 logic cells, 576 Kb of memory, and 16 DSP slices, making it suitable for embedded systems, industrial automation, and digital signal processing. The LX9 variant is part of the Spartan-6 family, known for its high I/O-to-logic ratio, support for multiple I/O standards, and integration with the MicroBlaze soft processor
      
   Documents: https://github.com/mhaghighi/posedge_one/tree/master/Posedge_One
<br /><br />
pictures of game envirement :
<br /><br />
![Game Envirement](https://github.com/FaryarD/Battle-City-Game-spartan6/blob/main/Pictures/Game_1.jpg)
<br /><br />
![Game Envirement](https://github.com/FaryarD/Battle-City-Game-spartan6/blob/main/Pictures/Game_2.jpg)
<br /><br />
picture of the board :
<br /><br />
![Board](https://github.com/FaryarD/Battle-City-Game-spartan6/blob/main/Pictures/board.jpg)

Video of AI playing the game:
[![AI Playing Test](https://github.com/FaryarD/Battle-City-Game-spartan6/blob/main/Pictures/board.jpg)](https://youtube.com/shorts/GZpM-0rKwTw)








