//-------------------------------------------------------------------------
//    mb_usb_hdmi_top.sv                                                 --
//    Zuofu Cheng                                                        --
//    2-29-24                                                            --
//                                                                       --
//                                                                       --
//    Spring 2024 Distribution                                           --
//                                                                       --
//    For use with ECE 385 USB + HDMI                                    --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module mb_usb_hdmi_top(
    input logic Clk,
    input logic reset_rtl_0,
    
    //USB signals
    input logic [0:0] gpio_usb_int_tri_i,
    output logic gpio_usb_rst_tri_o,
    input logic usb_spi_miso,
    output logic usb_spi_mosi,
    output logic usb_spi_sclk,
    output logic usb_spi_ss,
    
    //UART
    input logic uart_rtl_0_rxd,
    output logic uart_rtl_0_txd,
    
    //HDMI
    output logic hdmi_tmds_clk_n,
    output logic hdmi_tmds_clk_p,
    output logic [2:0]hdmi_tmds_data_n,
    output logic [2:0]hdmi_tmds_data_p,
        
    //HEX displays
    output logic [7:0] hex_segA,
    output logic [3:0] hex_gridA,
    output logic [7:0] hex_segB,
    output logic [3:0] hex_gridB,
    
    output logic led[3:0]
);
    
    logic [31:0] keycode0_gpio, keycode1_gpio;
    logic clk_25MHz, clk_125MHz, clk, clk_100MHz;
    logic locked;
    logic colliding;
    logic pause_test;
    logic enter_test;
    logic [9:0] drawX, drawY, ballxsig, ballysig, ballsizesig;
    
    logic [2:0] lives;

    logic hsync, vsync, vde;
    logic [3:0] red, green, blue;
    logic reset_ah;
    
    assign reset_ah = reset_rtl_0;
    assign led[0] = colliding;
    assign led[1] = pause_test;
    assign led[2] = enter_test;
    assign led[3] = (lives >= 3);
    logic [9:0] floortest;
    logic [15:0] inset;
    
    logic [15:0] out;
    assign inset = out;
    
    //Keycode HEX drivers
    hex_driver HexA (
        .clk(Clk),
        .reset(reset_ah),
        .in({inset[15:12], inset[11:8], inset[7:4], inset[3:0]}),
        .hex_seg(hex_segA),
        .hex_grid(hex_gridA)
    );
    
    hex_driver HexB (
        .clk(Clk),
        .reset(reset_ah),
        .in({keycode0_gpio[15:12], keycode0_gpio[11:8], keycode0_gpio[7:4], keycode0_gpio[3:0]}),
        .hex_seg(hex_segB),
        .hex_grid(hex_gridB)
    );
    
    mb_block mb_block_i (
        .clk_100MHz(Clk),
        .gpio_usb_int_tri_i(gpio_usb_int_tri_i),
        .gpio_usb_keycode_0_tri_o(keycode0_gpio),
        .gpio_usb_keycode_1_tri_o(keycode1_gpio),
        .gpio_usb_rst_tri_o(gpio_usb_rst_tri_o),
        .reset_rtl_0(~reset_ah), //Block designs expect active low reset, all other modules are active high
        .uart_rtl_0_rxd(uart_rtl_0_rxd),
        .uart_rtl_0_txd(uart_rtl_0_txd),
        .usb_spi_miso(usb_spi_miso),
        .usb_spi_mosi(usb_spi_mosi),
        .usb_spi_sclk(usb_spi_sclk),
        .usb_spi_ss(usb_spi_ss)
    );
        
    //clock wizard configured with a 1x and 5x clock for HDMI
    clk_wiz_0 clk_wiz (
        .clk_out1(clk_25MHz),
        .clk_out2(clk_125MHz),
        .reset(reset_ah),
        .locked(locked),
        .clk_in1(Clk)
    );
    
    //VGA Sync signal generator
    vga_controller vga (
        .pixel_clk(clk_25MHz),
        .reset(reset_ah),
        .hs(hsync),
        .vs(vsync),
        .active_nblank(vde),
        .drawX(drawX),
        .drawY(drawY)
    );    

    //Real Digital VGA to HDMI converter
    hdmi_tx_0 vga_to_hdmi (
        //Clocking and Reset
        .pix_clk(clk_25MHz),
        .pix_clkx5(clk_125MHz),
        .pix_clk_locked(locked),
        //Reset is active LOW
        .rst(reset_ah),
        //Color and Sync Signals
        .red(red),
        .green(green),
        .blue(blue),
        .hsync(hsync),
        .vsync(vsync),
        .vde(vde),
        
        //aux Data (unused)
        .aux0_din(4'b0),
        .aux1_din(4'b0),
        .aux2_din(4'b0),
        .ade(1'b0),
        
        //Differential outputs
        .TMDS_CLK_P(hdmi_tmds_clk_p),          
        .TMDS_CLK_N(hdmi_tmds_clk_n),          
        .TMDS_DATA_P(hdmi_tmds_data_p),         
        .TMDS_DATA_N(hdmi_tmds_data_n)          
    );
    
    
    //Ball Module
    player ball_instance(
        .Reset(reset_rtl_0), 
        .frame_clk(vsync),//add vsync as the frame clk                    //Figure out what this should be so that the ball will move
        .keycode(keycode0_gpio[7:0]),    //Notice: only one keycode connected to ball by default
        .BallX(ballxsig),
        .BallY(ballysig),
        .BallS(ballsizesig),
        .keycode2(keycode0_gpio[15:8]),
        .A,
        .D,
        .colliding, 
        .lives,
        .pause_test,
        .enter_test
    );
    
    logic [9:0] barrelxsig, barrelysig, barrelsizesig; logic barstate;
    logic [9:0] barrel2xsig, barrel2ysig; logic bar2state; 
    logic [9:0] barrel3xsig, barrel3ysig;  logic bar3state;
    
    logic A, D;
    

    
    
    barrel barrel(
        .Reset(reset_rtl_0),
        .frame_clk(vsync),
        .BarrelX(barrelxsig),
        .BarrelY(barrelysig),
        .BarrelS(barrelsizesig),
        .BarrelState(barstate),   
        .pause(pause_test),
        .enter(enter_test)
    );
    
    barrel #(.Delay(300)) barrel2(
        .Reset(reset_rtl_0),
        .frame_clk(vsync),
        .BarrelX(barrel2xsig),
        .BarrelY(barrel2ysig),
        .BarrelS(barrelsizesig),
        .BarrelState(bar2state),
        .pause(pause_test),
        .enter(enter_test) 
    );
    
    //Color Mapper Module   
    color_mapper color_instance(
        .BallX(ballxsig),
        .BallY(ballysig),
        .BarrelX(barrelxsig),
        .BarrelY(barrelysig),
        .Barrel2X(barrel2xsig),
        .Barrel2Y(barrel2ysig),
        .Barrel_size(barrelsizesig),
        .DrawX(drawX),
        .DrawY(drawY),
        .Ball_size(ballsizesig),
        .Red(red),
        .Green(green),
        .Blue(blue),
        .a(A), .d(D),
        .pngClk(clk_25MHz),
        .frame_clk(vsync),
        .reset(reset_rtl_0),
        .out,
        .lifecount(lives),
        .pause(pause_test)
    );
    
    collision collisions(
        .BallX(ballxsig),
        .BallY(ballysig),
        .barrel1x(barrelxsig),
        .barrel1y(barrelysig),
        .barrel2x(barrel2xsig),
        .barrel2y(barrel2ysig),
        .collision(colliding)
    );

    
endmodule
