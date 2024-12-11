`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/28/2024 07:52:29 PM
// Design Name: 
// Module Name: collision
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


module collision(
    input logic [9:0] BallX, 
    input logic [9:0] BallY, 
    input logic [9:0] barrel1x, 
    input logic [9:0] barrel1y, 
    input logic [9:0] barrel2x, 
    input logic [9:0] barrel2y, 
    //barrel3x, barrel3y, barrel4x, barrel4y, etc
    output logic collision
    );
    //mario x-y range
    logic [9:0] marioXMax = BallX + 6; 
    logic [9:0] marioYMax = BallY + 15;
    logic [9:0] marioXMin = BallX - 6;
    logic [9:0] marioYMin = BallY;
    
    //barrel 1 x-y range
    //modeling it as a square using size = 12 rather than 16 to account for the curvature
    logic [9:0] barrel1XMax = barrel1x + 9; 
    logic [9:0] barrel1YMax = barrel1y + 9;
    logic [9:0] barrel1XMin = barrel1x - 9;
    logic [9:0] barrel1YMin = barrel1y - 9;
    
    //barrel 2 x-y range
    logic [9:0] barrel2XMax = barrel2x + 9; 
    logic [9:0] barrel2YMax = barrel2y + 9;
    logic [9:0] barrel2XMin = barrel2x - 9;
    logic [9:0] barrel2YMin = barrel2y - 9;
    
//    //barrel 3 x-y range
//    logic [9:0] barrel3XMax = barrel3x + 12; 
//    logic [9:0] barrel3YMax = barrel3y + 12;
//    logic [9:0] barrel3XMin = barrel3x - 12;
//    logic [9:0] barrel3YMin = barrel3y - 12;
    
    //and so on...
    
    
    //actual collision logic
    logic barrel1col, barrel2col; //making an individual variable for each barrel's collision then OR-ing the signals later
    
    always_comb 
    begin: collisions
        if(marioYMax >= barrel1YMin && marioYMin <= barrel1YMax && marioXMax >= barrel1XMin && marioXMin <= barrel1XMax) 
            barrel1col = 1;
        else
            barrel1col = 0;
        if(marioYMax >= barrel2YMin && marioYMin <= barrel2YMax && marioXMax >= barrel2XMin && marioXMin <= barrel2XMax) 
            barrel2col = 1;
        else
            barrel2col = 0;
     // if(marioYMax >= barrel3YMin && marioYMin <= barrel3YMax && marioXMax >= barrel3XMin && marioXMin <= barrel3XMax)
     //     barrel3col = 1;
     // else 
     //     barrel3col = 0;
    end
    
    
    assign collision = (barrel1col || barrel2col); // || barrel3col)
    
    
    
    
endmodule
