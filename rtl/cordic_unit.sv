//////////////////////////////////////////////////////////////////////////////////
// Company:        Advans Group
// Module Name:    cordic_unit
// Description:    This module implements one iteration of the CORDIC
//                 algorithm.
//////////////////////////////////////////////////////////////////////////////////

module cordic_unit
    #(
        parameter WIDTH = 24
    )
    (
        input  logic                clk,
        input  logic                rst_n,
        input  signed [WIDTH - 1:0] x_i,
        input  signed [WIDTH - 1:0] y_i,
        input  signed [WIDTH - 1:0] z_i,
        input  logic  [4:0]         shift_i,
        input  signed [WIDTH - 1:0] tan_table_i,
        output signed [WIDTH - 1:0] x_o,
        output signed [WIDTH - 1:0] y_o,
        output signed [WIDTH - 1:0] z_o
    );

    logic signed [WIDTH - 1 : 0] x_ff;
    logic signed [WIDTH - 1 : 0] y_ff;
    logic signed [WIDTH - 1 : 0] z_ff;

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            x_ff <= 0;
            y_ff <= 0;
            z_ff <= 0;
        end else begin
            x_ff <= x_i;
            y_ff <= y_i;
            z_ff <= z_i;
        end
    end

    // Algorithm's iteration
    assign x_o = z_ff[WIDTH - 1] ? x_ff + (y_ff >>> shift_i) : x_ff - (y_ff >>> shift_i);
    assign y_o = z_ff[WIDTH - 1] ? y_ff - (x_ff >>> shift_i) : y_ff + (x_ff >>> shift_i);
    assign z_o = z_ff[WIDTH - 1] ? z_ff + tan_table_i        : z_ff - tan_table_i;

endmodule
