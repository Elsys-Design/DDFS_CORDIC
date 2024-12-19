//////////////////////////////////////////////////////////////////////////////////
// Company:        Advans Group
// Module Name:    cordic_ang_acc
// Description:    This module implements an angle accumulator that produces
//                 angles according to the frequency given on the input.
//////////////////////////////////////////////////////////////////////////////////

module cordic_angle_acc
    #(
        parameter FREQ_START  = 1000000,
        parameter CLK_FREQ    = 100000000,
        parameter ANGLE_WIDTH = 24,
        parameter PARAM_WIDTH = 32
    )
    (
        input  logic                     clk,
        input  logic                     rst_n,
        input  logic [7:0]               freq_i,
        output logic [ANGLE_WIDTH-1:0]   angle_o
    );

    localparam logic [2*PARAM_WIDTH-1:0] basic_inc  = ((2**PARAM_WIDTH - 1) << (PARAM_WIDTH));
    localparam logic [2*PARAM_WIDTH-1:0] basic_step = basic_inc / CLK_FREQ * FREQ_START;

    /////////////////////////////////////////////////
    //             SIGNALS DECLARATION             //
    /////////////////////////////////////////////////
    logic [7:0]               freq,  next_freq;
    logic [PARAM_WIDTH-1:0]   angle, next_angle;
    logic [2*PARAM_WIDTH-1:0] step;


    /////////////////////////////////////////////////
    //                    LOGIC                    //
    /////////////////////////////////////////////////


    assign step = basic_step * freq_i; //step between each angle
    assign angle_o = angle[PARAM_WIDTH-1:PARAM_WIDTH-ANGLE_WIDTH];

    // Update the angle value
    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            angle <= 0;
        end else begin
            angle <= angle + step[2*PARAM_WIDTH-1:PARAM_WIDTH];
        end
    end

endmodule
