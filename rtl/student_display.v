//=============================================================================
//  UEEEC0069  Troubleshoot Digital Sub-Systems  -  Project
//  Zaki Noori
//
//  Displays: 4 1 7 0 5 7 5 - Z n -   then repeats.
//  Counter starts at count 5 (last digit of student number) and runs to 15,
//  giving 11 states -- the mod-16 to mod-11 conversion required by the brief.
//
//  Decoder is implemented directly from the minimised Boolean expressions
//  derived by K-map in section 4.2 of the report.
//=============================================================================

module student_display (
    input        clk,       // manual push-button (debounced) or clock source
    input        rst_n,     // active-low reset
    input        sel,       // channel select: 0 = counter, 1 = manual inputs
    input  [3:0] b_in,      // channel B manual test inputs, B3..B0
    output [6:0] seg_n      // segments a..g, ACTIVE LOW (common anode)
);

    wire [3:0] count;
    wire [3:0] mux_out;
    wire [6:0] seg;

    counter_mod11 u1 (.clk(clk), .rst_n(rst_n), .q(count));
    mux2ch_4bit   u2 (.sel(sel), .a_in(count), .b_in(b_in), .y(mux_out));
    seg7_decoder  u3 (.d(mux_out), .seg(seg));

    // Common anode: a segment lights when its pin is driven LOW
    assign seg_n = ~seg;

endmodule


//-----------------------------------------------------------------------------
//  Mod-11 counter: 5, 6, 7 ... 15, back to 5
//  The (q < 5) test is an unused-state lockout. Without it the counter can
//  power up in state 0-4 and hang outside the display sequence.
//-----------------------------------------------------------------------------
module counter_mod11 (
    input            clk,
    input            rst_n,
    output reg [3:0] q
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= 4'd5;
        else if (q >= 4'd15 || q < 4'd5)
            q <= 4'd5;
        else
            q <= q + 1'b1;
    end

endmodule


//-----------------------------------------------------------------------------
//  2-channel 4-bit multiplexer
//  Per bit:  Y = S'A + SB        (section 4.1)
//  All four bit-slices are identical and share the one select line.
//-----------------------------------------------------------------------------
module mux2ch_4bit (
    input        sel,
    input  [3:0] a_in,
    input  [3:0] b_in,
    output [3:0] y
);

    assign y[0] = (~sel & a_in[0]) | (sel & b_in[0]);
    assign y[1] = (~sel & a_in[1]) | (sel & b_in[1]);
    assign y[2] = (~sel & a_in[2]) | (sel & b_in[2]);
    assign y[3] = (~sel & a_in[3]) | (sel & b_in[3]);

endmodule


//-----------------------------------------------------------------------------
//  7-segment decoder, built from the minimised K-map expressions (section 4.2)
//
//      seg = { a, b, c, d, e, f, g }      seg[6] = a  ...  seg[0] = g
//      D C B A = Q3 Q2 Q1 Q0
//
//      a = C' + BA + B'A'
//      b = D' + C'A' + CB'A
//      c = D' + C' + BA'
//      d = C'A + B'A' + DBA
//      e = C'B'A' + DCB'A + DCBA'
//      f = C'B' + C'A + D'B'
//      g = DC + C'A + B'A
//-----------------------------------------------------------------------------
module seg7_decoder (
    input  [3:0] d,
    output [6:0] seg
);

    wire D, C, B, A;

    assign D = d[3];
    assign C = d[2];
    assign B = d[1];
    assign A = d[0];

    assign seg[6] = (~C) | (B & A) | (~B & ~A);                                 // a
    assign seg[5] = (~D) | (~C & ~A) | (C & ~B & A);                            // b
    assign seg[4] = (~D) | (~C) | (B & ~A);                                     // c
    assign seg[3] = (~C & A) | (~B & ~A) | (D & B & A);                         // d
    assign seg[2] = (~C & ~B & ~A) | (D & C & ~B & A) | (D & C & B & ~A);       // e
    assign seg[1] = (~C & ~B) | (~C & A) | (~D & ~B);                           // f
    assign seg[0] = (D & C) | (~C & A) | (~B & A);                              // g

endmodule
