//////////////////////////////////////////////////////////////////////////////////
// Company:        Advans Group
// Module Name:    cordic
// Description:    This module implements the computation of sine and cosine
//                 values using CORDIC algorithm. As input it takes the angle,
//                 and on outputs it generates the sine and cosine values of that
//                 angle.
//////////////////////////////////////////////////////////////////////////////////

module cordic
    #(
        parameter ITERATIONS = 16,
        parameter WIDTH      = 16
    )
    (
        input  logic              clk,
        input  logic              rst_n,
        input  signed [WIDTH-1:0] angle_i,
        output signed [WIDTH-1:0] sine_o,
        output signed [WIDTH-1:0] cosine_o
    );
    


    // This table represents tan(angle_i) representation
    // The starting point is 45 degrees, following values are
    // successive divisions by 2
    localparam signed [31:0] ANGLE_TAN_TABLE [0:31] = {
    32'h2000_0000, // 45.000000 degrees (n = 0)
    32'h12E4_051D, // 26.565051 degrees (n = 1)
    32'h09FB_385B, // 14.036243 degrees (n = 2)
    32'h0511_11D4, // 7.125016 degrees (n = 3)
    32'h028B_0D43, // 3.576334 degrees (n = 4)
    32'h0145_d7e1, // 1.789911 degrees (n = 5)
    32'h00a2_f61e, // 0.895174 degrees (n = 6)
    32'h0051_7c55, // 0.447614 degrees (n = 7)
    32'h0028_be53, // 0.223811 degrees (n = 8)
    32'h0014_5f2e, // 0.111906 degrees (n = 9)
    32'h000a_2f98, // 0.055953 degrees (n = 10)
    32'h0005_17cc, // 0.027976 degrees (n = 11)
    32'h0002_8be6, // 0.013988 degrees (n = 12)
    32'h0001_45f3, // 0.006994 degrees (n = 13)
    32'h0000_a2f9, // 0.003497 degrees (n = 14)
    32'h0000_517c, // 0.001749 degrees (n = 15)
    32'h0000_28be, // 0.000874 degrees (n = 16)
    32'h0000_145f, // 0.000437 degrees (n = 17)
    32'h0000_0a2f, // 0.000219 degrees (n = 18)
    32'h0000_0517, // 0.000109 degrees (n = 19)
    32'h0000_028b, // 0.000055 degrees (n = 20)
    32'h0000_0145, // 0.000027 degrees (n = 21)
    32'h0000_00a2, // 0.000014 degrees (n = 22)
    32'h0000_0051, // 0.000007 degrees (n = 23)
    32'h0000_0028, // 0.000003 degrees (n = 24)
    32'h0000_0014, // 0.000002 degrees (n = 25)
    32'h0000_000a, // 0.000001 degrees (n = 26)
    32'h0000_0005, // 0.0000005 degrees (n = 27)
    32'h0000_0002, // 0.0000002 degrees (n = 28)
    32'h0000_0001, // 0.0000001 degrees (n = 29)
    32'h0000_0000, // 0 degrees (n = 30)
    32'h0000_0000  // 0 degrees (n = 31)
    };

    logic signed            [31:0] START_POINT_X;
    localparam logic signed [31:0] START_POINT_Y = 32'h0000_0000;
    generate
      case(WIDTH) 
        16: assign START_POINT_X = 32'h4db7_0000;
        17: assign START_POINT_X = 32'h4db7_8000;
        18: assign START_POINT_X = 32'h4db8_8000;
        19: assign START_POINT_X = 32'h4db9_8000;
        20: assign START_POINT_X = 32'h4dba_2000;
        21: assign START_POINT_X = 32'h4dba_4000;
        22: assign START_POINT_X = 32'h4dba_4800;
        23: assign START_POINT_X = 32'h4dba_5e00;
        24: assign START_POINT_X = 32'h4dba_6800;
        25: assign START_POINT_X = 32'h4dba_7300;
        26: assign START_POINT_X = 32'h4dba_7480;
        27: assign START_POINT_X = 32'h4dba_75c0;
        28: assign START_POINT_X = 32'h4dba_7650;
        29: assign START_POINT_X = 32'h4dba_7690;
        30: assign START_POINT_X = 32'h4dba_76b0;
        31: assign START_POINT_X = 32'h4dba_76c1;
        32: assign START_POINT_X = 32'h4dba_76c9;
      endcase
    endgenerate

    /////////////////////////////////////////////////
    //             SIGNALS DECLARATION             //
    /////////////////////////////////////////////////
    logic signed [WIDTH - 1 : 0] x_s, y_s;
    // register x,y,z
    logic signed [WIDTH-1:0]      x_w [ITERATIONS-1:0];
    logic signed [WIDTH-1:0]      y_w [ITERATIONS-1:0];
    logic signed [WIDTH-1:0]      z_w [ITERATIONS-1:0];
    logic        [1:0]            quadrant;
    logic        [WIDTH - 1 : 0]  x_ff;
    logic        [WIDTH - 1 : 0]  y_ff;
    logic        [WIDTH - 1 : 0]  z_ff;



    /////////////////////////////////////////////////
    //                    LOGIC                    //
    /////////////////////////////////////////////////

    assign x_s = START_POINT_X[31:31-WIDTH+1];
    assign y_s = START_POINT_Y[31:31-WIDTH+1];
    assign quadrant = angle_i[WIDTH - 1:WIDTH - 2];

    always_ff @(posedge clk, negedge rst_n) begin 
      if(!rst_n) begin
        x_ff <= 0;
        y_ff <= 0;
        z_ff <= 0;
      end
      // make sure the rotation angle is in the -pi/2 to pi/2 range
      else begin
        case(quadrant)
          2'b00, 2'b11:
          begin
            x_ff <= x_s;
            y_ff <= y_s;
            z_ff <= angle_i;
          end
          2'b01:
          begin
            x_ff <= -y_s;
            y_ff <= x_s;
            z_ff <= {2'b00,angle_i[WIDTH-3:0]}; // subtract pi/2 for angle in this quadrant
          end
          2'b10:
          begin
            x_ff <= y_s;
            y_ff <= -x_s;
            z_ff <= {2'b11,angle_i[WIDTH-3:0]}; // add pi/2 to angles in this quadrant
          end
          default: 
          begin
            x_ff <= 0;
            y_ff <= 0;
            z_ff <= 0;
          end
        endcase
      end
    end

    genvar i;
    generate
      for (i = 0; i < ITERATIONS; i++) begin
        if(i==0) begin
          cordic_unit #(.WIDTH(WIDTH))
          inst0(
              .clk(clk),
              .rst_n(rst_n),
              .x_i(x_ff),
              .y_i(y_ff),
              .z_i(z_ff),
              .shift_i(5'b00000),
              .tan_table_i(ANGLE_TAN_TABLE[0][31:31-WIDTH+1]),
              .x_o(x_w[0]),
              .y_o(y_w[0]),
              .z_o(z_w[0])
          );
        end
        else begin
          cordic_unit #(.WIDTH(WIDTH))
          inst_i(
              .clk(clk),
              .rst_n(rst_n),
              .x_i(x_w[i-1]),
              .y_i(y_w[i-1]),
              .z_i(z_w[i-1]),
              .shift_i(i[4:0]),
              .tan_table_i(ANGLE_TAN_TABLE[i][31:31-WIDTH+1]),
              .x_o(x_w[i]),
              .y_o(y_w[i]),
              .z_o(z_w[i])
          );
        end
      end
    endgenerate

    assign sine_o   = y_w[ITERATIONS-1] ;
    assign cosine_o = x_w[ITERATIONS-1] ;

endmodule
