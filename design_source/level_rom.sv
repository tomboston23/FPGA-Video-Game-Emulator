`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/02/2024 04:47:21 PM
// Design Name: 
// Module Name: level_rom
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module level_rom(input logic [3:0] addr,
    output logic [9:0] data
    );
    parameter ADDR_WIDTH = 4;
    parameter DATA_WIDTH = 10;
    parameter [0:10][DATA_WIDTH-1:0] ROM = {
    10'b1111111111,
    10'b1111111111,
    10'b1111111111,
    10'b0000111000,
    10'b0001101100,
    10'b0011000110,
    10'b0110000011,
    10'b1100000001,
    10'b1111111111,
    10'b1111111111,
    10'b1111111111
    };
    assign data = ROM[addr];
endmodule