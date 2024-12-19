//////////////////////////////////////////////////////////////////////////////////
// Company:        Advans Group
// Module Name:    cordic
// Description:    Testbench for the system with the CORDIC core and the angle
//                 accumulator.
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module tb_cordic_test ();

    localparam FREQ_START  = 1000000;
    localparam CLK_FREQ    = 330000000;
    localparam DATA_WIDTH  = 16;
    localparam PARAM_WIDTH = 32;
    localparam ITERATIONS  = 16;

    localparam real CLK_PERIOD = 1.0 / CLK_FREQ * 1e9;

    /////////////////////////////////////////////////
    //             SIGNALS DECLARATION             //
    /////////////////////////////////////////////////

    logic                   clk;
    logic                   rst_n;
    logic [7:0]             freq_i;
    logic [DATA_WIDTH-1:0]  angle_to_cordic;
    logic [DATA_WIDTH-1:0]  sinus_o;
    logic [DATA_WIDTH-1:0]  cosinus_o;

    /////////////////////////////////////////////////
    //                  TEST LOGIC                 //
    /////////////////////////////////////////////////

    initial begin
        clk = 1;

        forever begin
            #(CLK_PERIOD/2);
            clk = ~clk;
        end
    end

    cordic_angle_acc #(.ANGLE_WIDTH(DATA_WIDTH), .PARAM_WIDTH(PARAM_WIDTH), .CLK_FREQ(CLK_FREQ), .FREQ_START(FREQ_START))
    ANG_ACC(
        .clk(clk),
        .rst_n(rst_n),
        .freq_i(freq_i),
        .angle_o(angle_to_cordic)
    );

    cordic #(.ITERATIONS(ITERATIONS), .WIDTH(DATA_WIDTH))
    CORDIC_CORE(
        .clk(clk),
        .rst_n(rst_n),
        .angle_i(angle_to_cordic),
        .sine_o(sinus_o),
        .cosine_o(cosinus_o)
    );

    initial begin
        rst_n = 0;
        #10ns;
        rst_n = 1;
        freq_i = 10;
        #1500ns;
    end

endmodule
