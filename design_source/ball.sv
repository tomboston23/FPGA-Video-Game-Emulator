

module  player
(
    input  logic        Reset,
    input  logic        frame_clk,
    input  logic [7:0]  keycode,
    input logic [7:0] keycode2,

    output logic [9:0]  BallX,
    output logic [9:0]  BallY,
    output logic [9:0]  BallS,
    output logic A, 
    output logic D,
    input logic colliding,
    output logic [1:0] lives,
    output logic pause_test,
    output logic enter_test
);
   


    parameter [9:0] Ball_X_Center=50;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=414;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis

    logic [17:0] Ball_X_Motion;
    logic [17:0] Ball_X_Motion_next;
    logic [17:0] Ball_Y_Motion;
    logic [17:0] Ball_Y_Motion_next;
    


    logic [17:0] Ball_X_next;
    logic [17:0] Ball_Y_next;

    //debug info

   logic [1:0] lifecount;
   typedef enum logic { GOING, PAUSED } game_t;
   game_t gamestate;
   logic ladder;
   logic climb;
    
   logic w, a, s, d, space, enter;
   assign enter_test = enter;
   
   assign D = d;
   assign A = a;
    
    always_comb begin //get keycodes
        if(keycode == 8'h28 || keycode2 == 8'h28) begin
            enter = 1'b1;
        end else enter = 1'b0;
        if(keycode == 8'h04 || keycode2 == 8'h04) begin
            if(keycode != 8'h07 && keycode2 != 8'h07) begin
                a = 1'b1;
            end else begin
                a = 1'b0;
                d = 1'b0;
            end
        end else begin
            a = 1'b0;
        end
        if(keycode == 8'h07 || keycode2 == 8'h07) begin
            if(keycode != 8'h04 && keycode2 != 8'h04) begin
                d = 1'b1;
            end else begin
                a = 1'b0;
                d = 1'b0;
            end
        end else begin
            d = 1'b0;
        end
        if(keycode == 8'h2c || keycode2 == 8'h2c) begin
            space = 1'b1;
        end else begin
            space = 1'b0;
        end
        if(keycode == 8'h1A || keycode2 == 8'h1A) begin
            if(keycode != 8'h2c && keycode2 != 8'h2c) begin
                w = 1'b1;
            end else begin
                w = 1'b0;
            end
        end else begin
            w = 1'b0;
        end
        if(keycode == 8'h16 || keycode2 == 8'h16) begin
            if(keycode != 8'h2c && keycode2 != 8'h2c) begin
                if(keycode != 8'h1A && keycode2 != 8'h1A) begin
                    s = 1'b1;
                end else begin
                    s = 1'b0;
                end
            end else begin
                s = 1'b0;
            end
            
        end else begin
            s = 1'b0;
        end
    end
    
    
    //State machine states
    typedef enum logic { ON_GROUND, IN_AIR} state_t;
    state_t state, next_state;
    logic [6:0] counter;
    logic [17:0] floor;
    logic paused;
    assign pause_test = paused;
    
    always_comb begin
        Ball_Y_Motion_next = Ball_Y_Motion; // set default motion to be same as prev clock cycle
        Ball_X_Motion_next = Ball_X_Motion;
        

       
        if(a) begin //the A key or the left arrow
            if(climb) begin
                Ball_X_Motion_next = 10'd0;
            end else Ball_X_Motion_next = -10'd2;
            

        end
       
       
           
        if(d) begin//the D key or the right arrow
            if(climb) begin
                Ball_X_Motion_next = 10'd0;
            end else Ball_X_Motion_next = 10'd2;
        end
           
        if(!(a || d)) begin
            Ball_X_Motion_next = 10'd0;
        end
       
       

       else
            Ball_Y_Motion = Ball_Y_Motion; //redundant last case to avoid inferred latches

    end

    assign BallS = 16;  // default ball size
    assign Ball_X_next = (BallX + Ball_X_Motion_next);
    assign Ball_Y_next = (BallY + Ball_Y_Motion_next);
    
    assign floortest = floor;
    assign test = d;
    logic check;
    assign lives = lifecount;
   
    always_ff @(posedge frame_clk or posedge Reset) //make sure the frame clock is instantiated correctly
    begin
        if (Reset)
        begin
            gamestate <= PAUSED;
            state <= ON_GROUND;
            Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
            Ball_X_Motion <= 10'd0; //Ball_X_Step;
           
            BallY <= Ball_Y_Center;
            BallX <= Ball_X_Center;
            
            ladder <= 0;
            climb <= 0;
            lifecount <= 3;
        end
        else
        begin
            if(gamestate == PAUSED) begin
                paused <= 1;
                BallX<=BallX;
                BallY<=BallY;
                Ball_X_Motion <= 0;
                Ball_Y_Motion <= 0;
                if(enter) begin
                    gamestate <= GOING;
                    BallX<= Ball_X_Center;
                    BallY<= Ball_Y_Center;
                end
            end else if(gamestate == GOING) begin //not paused
                paused <= 0;
                if(colliding)begin
                    gamestate <= PAUSED;
                    if(!check) begin
                        if(lifecount != 0) begin
                            lifecount <= lifecount - 1;
                        end else 
                            lifecount <= lifecount;
                        check <= 1;
                    end     
                    
                end else begin
                    check <= 0;
                    lifecount <= lifecount;
                end
                
    
    //            Ball_Y_Motion <= Ball_Y_Motion_next;
    //            Ball_X_Motion <= Ball_X_Motion_next;
    
                BallY <= Ball_Y_next;  // Update ball position
                BallX <= Ball_X_next;
                
                //ladder
                if(BallX > 300 && BallX < 315 && BallY <= 415 && BallY > 354) begin
                    ladder <= 1;
                end else if(BallX > 535 && BallX < 550 && BallY <= 415 && BallY > 354) begin
                    ladder <= 1;
                end else if(BallX > 100 && BallX < 115 && BallY <= 355 && BallY > 294) begin
                    ladder <= 1;
                end else if(BallX > 250 && BallX < 265 && BallY <= 295 && BallY > 234) begin
                    ladder <= 1;
                end else if(BallX > 500 && BallX < 515 && BallY <= 295 && BallY > 234) begin
                    ladder <= 1;
                end else if(BallX > 120 && BallX < 135 && BallY <= 235 && BallY > 174) begin
                    ladder <= 1;
                end else if(BallX > 320 && BallX < 335 && BallY <= 235 && BallY > 174) begin
                    ladder <= 1;
                end else if(BallX > 515 && BallX < 530 && BallY <= 175 && BallY > 114) begin
                    ladder <= 1;
                end else if(BallX > 185 && BallX < 200 && BallY <= 115 && BallY > 74) begin
                    ladder <= 1;
                end else
                ladder <= 0;
                
                //floor
                if(BallX > 618 || BallX < 22) begin
                    floor = 10'd464; //the mario should fall to the bottom of the screen
                end else if((BallX >= 25 && BallX <= 615 && BallY <= 417 && BallY > 370) || (BallX > 565 && BallX <= 615 && BallY <= 417 && BallY > 310)) begin
                    floor = 10'd414;
                end else if((BallX >= 25 && BallX <= 565 && BallY <= 357 && BallY > 310) || (BallX >= 25 && BallX < 75 && BallY <= 357 && BallY > 250)) begin
                    floor = 10'd354;
                end else if((BallX >= 75 && BallX <= 615 && BallY <= 297 && BallY > 250) || (BallX > 565 && BallX <= 615 && BallY <= 297 && BallY > 190)) begin
                    floor = 10'd294;
                end else if((BallX <= 565 && BallY <= 237 && BallY > 190) || (BallX < 75 && BallY <= 237 && BallY > 130)) begin
                    floor = 10'd234;
                end else if((BallX >= 75 && BallY <= 177 && BallY > 130) || (BallX > 565 && BallY <= 177)) begin
                    floor = 10'd174;
                end else if((BallX > 205 && BallY <= 117)|| (BallY <= 117 && BallY > 90) || (BallY <= 117 && BallX < 120)) begin
                    floor = 10'd114;
                end else if(BallX >= 120 && BallX <= 205 && BallY <= 77) begin
                    floor = 10'd74;
                end else begin
                    floor = floor;
                end
                
    
                
                
                unique case (state)
                    ON_GROUND: begin
                        if(BallY == floor && floor == 10'd74) begin //check to see if you beat the game
                            gamestate <= PAUSED;
                        end else begin
                        if (w) begin //the W key or up arrow
                            if(ladder) begin
                                Ball_Y_Motion <= -10'd1;
                            end else Ball_Y_Motion <= 0;
                        end
                           
                
                        if (s) begin //the S key or the down arrow
                            if(ladder && (BallY != floor)) begin
                                Ball_Y_Motion <= 10'd1;
                            end else Ball_Y_Motion <= 0;
                        end
                        
                        if(ladder) begin
                            if(w||s) begin
                                climb <= 1;
                            end else begin
                                if(!space) begin
                                    Ball_Y_Motion <= 0;
                                    if(BallY == floor)
                                        climb <= 0;
                                    else climb <= climb;
                                 
                                end
                            end
                        end else climb <= 0;
                    
                        if(!climb) begin
                            
                            
                            if(BallY < floor)begin
                                state<= IN_AIR;
                                Ball_Y_Motion <= 0;
                            end
                            else BallY <= floor;
                            
                            if(space) begin
                                state<= IN_AIR;
                                Ball_Y_Motion = -3;
                                counter = 0;
                            end else Ball_Y_Motion = 0;
                        end
                        end
                      end
                    IN_AIR: begin
                        climb <= 0;
                        if(w||s) begin
                            if(ladder) begin
                                state <= ON_GROUND;
                                climb <= 1;
                                Ball_Y_Motion <= 0;
                            end
                        end
                        if(counter != 9) begin
                            counter = counter +1; end
                        else begin
                            Ball_Y_Motion = Ball_Y_Motion + 1;
                            if(BallY > floor || BallY + Ball_Y_Motion > floor) begin
                                if(Ball_Y_Motion > 10) begin
                                    BallY <= floor;
                                    if(lifecount != 0) lifecount <= lifecount -1;
                                    gamestate <= PAUSED; //pause if he's going fast enough - probably fell multiple layers?
                                end else begin
                                    state <= ON_GROUND; 
                                    BallY <= floor;
                                end
                            end
                        end
                   end
                endcase    
            end       

end  
    end
   
    endmodule