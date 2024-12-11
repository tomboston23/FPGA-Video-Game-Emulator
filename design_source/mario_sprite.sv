`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/18/2024 02:19:55 PM
// Design Name: 
// Module Name: mario_sprite
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


module mario_sprite(
    input [3:0] X,
    input [3:0] Y,
    output [1:0] pal

    );
    //00 means alpha = 0
    //01 means red
    //10 means dark brown
    //11 means light brown
    
    parameter[0:15][0:31] ROM = {
    32'b00000000000101010101010000000000,
    32'b00000000010101010101010101000000,
    32'b00000010101010111110110000000000,
    32'b00001010111011111110111111000000,
    32'b00001010111010111111101111110000,
    32'b00001010101111111110101010000000,
    32'b00000000111111111111111100000000,
    32'b00000010101001101010000000000000,
    32'b00001010101001101001101010000000,
    32'b00101010101001010101101010100000,
    32'b00111111100111010111011011110000,
    32'b00111111110101010101011111110000,
    32'b00111111010101010101010111110000,
    32'b00000001010101000101010100000000,
    32'b00001010101000000010101010000000,
    32'b00101010101000000010101010100000
    };
    logic [31:0] data = ROM[Y];
    assign pal = data[X*2 +:2];
    
endmodule
