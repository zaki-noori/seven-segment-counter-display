
module Project (
    input        clk,       // manual push-button
    input        sel,       // channel select: 0 = counter, 1 = manual inputs
    input  [3:0] b_in,      // channel B manual test inputs
    output [6:0] seg_n      // segments a-g
);

    reg  [3:0] q = 4'd5;    // counter state Q3 Q2 Q1 Q0, powers up at count 5
    wire [3:0] dff;         // D flip-flop inputs = next state
    wire [3:0] m;           // multiplexer output


    //  4-BIT COUNTER

    assign dff[3] = ~q[2] | (q[3] & ~q[1]) | (q[3] & ~q[0]) | (~q[3] & q[1] & q[0]);
    assign dff[2] = (q[3] & q[2]) | (q[2] & ~q[1]) | (q[2] & ~q[0]) | (q[3] & q[1] & q[0]);
    assign dff[1] = (~q[1] & q[0]) | (q[1] & ~q[0]);
    assign dff[0] = ~q[0] | (q[3] & q[2] & q[1]);

    //  The four D flip-flops
    always @(posedge clk) begin
        q <= dff;               // clock the next state in
    end


    //  2-CHANNEL 4-BIT MULTIPLEXER      Y = S'A + SB

    assign m = ({4{~sel}} & q) | ({4{sel}} & b_in);


    //  7-SEGMENT DECODER  -  common anode, outputs inverted so 0 lights a segment
    //  The expression inside each bracket is the minimised K-map result.

    wire D = m[3], C = m[2], B = m[1], A = m[0];

    assign seg_n[6] = ~( ~C | (B & A) | (~B & ~A) );                        // a
    assign seg_n[5] = ~( ~D | (~C & ~A) | (C & ~B & A) );                   // b
    assign seg_n[4] = ~( ~D | ~C | (B & ~A) );                              // c
    assign seg_n[3] = ~( (~C & A) | (~B & ~A) | (D & B & A) );              // d
    assign seg_n[2] = ~( (~C & ~B & ~A) | (D&C&~B&A) | (D&C&B&~A) );        // e
    assign seg_n[1] = ~( (~C & ~B) | (~C & A) | (~D & ~B) );                // f
    assign seg_n[0] = ~( (D & C) | (~C & A) | (~B & A) );                   // g

endmodule
