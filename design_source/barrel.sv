module  barrel #(parameter Delay = 0)
                    
             ( input logic Reset, frame_clk, pause, enter,
               output logic [9:0]  BarrelX, BarrelY, BarrelS,
               output logic BarrelState );
    
    logic [9:0] Barrel_X_Motion, Barrel_Y_Motion;
	 	 
    parameter [9:0] Barrel_X_Center=130;  // Center position on the X axis
    parameter [9:0] Barrel_Y_Center=130-12;  // Center position on the Y axis
    parameter [9:0] Barrel_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Barrel_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Barrel_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Barrel_Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] Barrel_X_Step=3;      // Step size on the X axis
    parameter [9:0] Barrel_Y_Step=3;      // Step size on the Y axis
    localparam [9:0] Box_1_X_Start = 30;
    localparam [9:0] Box_1_X_End = 610;
    localparam [9:0] Box_1_Y = 430;
    
    localparam [9:0] Box_2_X_Start = 30;
    localparam [9:0] Box_2_X_End = 560;
    localparam [9:0] Box_2_Y = 370;
    
    localparam [9:0] Box_3_X_Start = 80;
    localparam [9:0] Box_3_X_End = 610;
    localparam [9:0] Box_3_Y = 310;
    
    localparam [9:0] Box_4_X_Start = 30;
    localparam [9:0] Box_4_X_End = 560;
    localparam [9:0] Box_4_Y = 250;
    
    localparam [9:0] Box_5_X_Start = 80;
    localparam [9:0] Box_5_X_End = 610;
    localparam [9:0] Box_5_Y = 190;
    
    localparam [9:0] Box_6_X_Start = 30;
    localparam [9:0] Box_6_X_End = 560;
    localparam [9:0] Box_6_Y = 130;

    

    assign BarrelS = 12;  // default Barrel size
    

    logic [3:0] counter;
    int barrel_delay;
   
    always_ff @ (posedge frame_clk or posedge Reset) //make sure the frame clock is instantiated correctly
    begin: Move_Barrel
        if (Reset)  // asynchronous Reset
        begin 
            barrel_delay <= Delay;
            BarrelState <= 1'b0;
            counter <= 4'h0;
            Barrel_Y_Motion <= -10'd1; //Barrel_Y_Step;
			Barrel_X_Motion <= 10'd0; //Barrel_X_Step;
			BarrelY <= Barrel_Y_Center;
			BarrelX <= Barrel_X_Center;
        end
        
        else if(pause == 1) begin
            
			
			if(enter == 1) begin
                barrel_delay <= Delay;
                BarrelState <= 1'b0;
                counter <= 4'h0;
                Barrel_Y_Motion <= -10'd1; //Barrel_Y_Step;
                Barrel_X_Motion <= 10'd0; //Barrel_X_Step;
                BarrelY <= Barrel_Y_Center;
                BarrelX <= Barrel_X_Center;
			end else begin
                barrel_delay <= Delay;
                BarrelState <= 1'b0;
                counter <= 4'h0;
                Barrel_Y_Motion <= 10'd0; //Barrel_Y_Step;
                Barrel_X_Motion <= 10'd0; //Barrel_X_Step;
                BarrelY <= BarrelY;
                BarrelX <= BarrelX;
			end
        end
        
        else if (barrel_delay > 0)
            barrel_delay <= barrel_delay - 1;
        
           
        else 
        begin 
            if(counter >= 4'h8)
            begin
                BarrelState <= ~(BarrelState);
                counter <= 4'h0;
            end
            else
                counter <= counter + 1;
                if ( (BarrelY + BarrelS) >= Box_6_Y && (BarrelY + BarrelS) <= (Box_6_Y + 20) && (BarrelX - BarrelS) <= Box_6_X_End)
                begin
                    Barrel_Y_Motion <= 1'b0;
                    Barrel_X_Motion <= Barrel_X_Step;
                end
                else if ( (BarrelY + BarrelS) >= Box_5_Y && (BarrelY + BarrelS) <= (Box_5_Y + 20) && (BarrelX + BarrelS) >= Box_5_X_Start)
                begin
                    Barrel_Y_Motion <= 1'b0;
                    Barrel_X_Motion <= (-1*Barrel_X_Step);
                end
                else if ( (BarrelY + BarrelS) >= Box_4_Y && (BarrelY + BarrelS) <= (Box_4_Y + 20) && (BarrelX - BarrelS) <= Box_4_X_End)
                begin
                    Barrel_Y_Motion <= 1'b0;
                    Barrel_X_Motion <= Barrel_X_Step;
                end
                else if ( (BarrelY + BarrelS) >= Box_3_Y && (BarrelY + BarrelS) <= (Box_3_Y + 20) && (BarrelX + BarrelS) >= Box_3_X_Start)
                begin
                    Barrel_Y_Motion <= 1'b0;
                    Barrel_X_Motion <= (-1*Barrel_X_Step);
                end                                
                else if ( (BarrelY + BarrelS) >= Box_2_Y && (BarrelY + BarrelS) <= (Box_2_Y + 20) && (BarrelX - BarrelS) <= Box_2_X_End)
                begin
                    Barrel_Y_Motion <= 1'b0;
                    Barrel_X_Motion <= Barrel_X_Step;
                end
                else if ( (BarrelY + BarrelS) >= Box_1_Y && (BarrelY + BarrelS) <= (Box_1_Y + 20) && (BarrelX + BarrelS) >= Box_1_X_Start)
                begin
                    Barrel_Y_Motion <= 1'b0;
                    Barrel_X_Motion <= (-1*Barrel_X_Step);
                end                                   				
				
				else if ( (BarrelY + BarrelS) >= Barrel_Y_Max )  // Barrel is at the bottom edge, BOUNCE!
				begin
					  Barrel_Y_Motion <= 1'b0;  // 2's complement.
                      Barrel_X_Motion <= (~ (Barrel_X_Step) + 1'b1);
				end
					  
				else if ( (BarrelY - BarrelS) <= Barrel_Y_Min )  // Barrel is at the top edge, BOUNCE!
					  Barrel_Y_Motion <= Barrel_Y_Step;
					  
				else if ( (BarrelX + BarrelS) >= Barrel_X_Max )  // Barrel is at the Right edge, BOUNCE!
					  Barrel_X_Motion <= (~ (Barrel_X_Step) + 1'b1);  // 2's complement.
					  
				
					  
				else 
				begin
	 			     Barrel_Y_Motion <= Barrel_Y_Step;  // Barrel is somewhere in the middle, don't bounce, just keep moving
	 			     Barrel_X_Motion <= 1'b0;  // Barrel is somewhere in the middle, don't bounce, just keep moving
				end	  
				 if((BarrelX - BarrelS) >= Barrel_X_Min && (BarrelX + BarrelS) < Barrel_X_Max)
				 begin
				    BarrelY <= (BarrelY + Barrel_Y_Motion);  // Update Barrel position
				    BarrelX <= (BarrelX + Barrel_X_Motion);
				 end
				 else
				 begin
				    Barrel_Y_Motion <= -10'd1; //Barrel_Y_Step;
                    Barrel_X_Motion <= 10'd0; //Barrel_X_Step;
                    BarrelY <= Barrel_Y_Center;
                    BarrelX <= Barrel_X_Center;
                 end
			
		end  
    end
      
endmodule
