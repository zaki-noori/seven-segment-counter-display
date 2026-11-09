
module testinginclass (
    input  [3:0]  KEY,
    input  [17:0] SW,
    output [6:0]  HEX0
);

    
    wire clk = ~KEY[0];

    wire       sel  = SW[17];
    wire [3:0] b_in = SW[3:0];

    reg  [3:0] q = 4'd5;    
    wire [3:0] m;               

    wire T = q[3] & q[2] & q[1] & q[0];     // terminate at 1111 (15)

    always @(posedge clk) begin
        q[0] <= ~q[0]                       | T;    // start value bit 0 = 1
        q[1] <= (q[1] ^ q[0])               & ~T;   // start value bit 1 = 0
        q[2] <= (q[2] ^ (q[0] & q[1]))      | T;    // start value bit 2 = 1
        q[3] <= (q[3] ^ (q[0] & q[1] & q[2])) & ~T; // start value bit 3 = 0
    end


    //  2-CHANNEL 4-BIT MULTIPLEXER      Y = S'A + SB

    assign m = ({4{~sel}} & q) | ({4{sel}} & b_in);


    //  7-SEGMENT DECODER

    wire D = m[3], C = m[2], B = m[1], A = m[0];

    assign HEX0[0] = ~( ~C | (B & A) | (~B & ~A) );                        // a
    assign HEX0[1] = ~( ~D | (~C & ~A) | (C & ~B & A) );                   // b
    assign HEX0[2] = ~( ~D | ~C | (B & ~A) );                              // c
    assign HEX0[3] = ~( (~C & A) | (~B & ~A) | (D & B & A) );              // d
    assign HEX0[4] = ~( (~C & ~B & ~A) | (D&C&~B&A) | (D&C&B&~A) );        // e
    assign HEX0[5] = ~( (~C & ~B) | (~C & A) | (~D & ~B) );                // f
    assign HEX0[6] = ~( (D & C) | (~C & A) | (~B & A) );                   // g

endmodule
