
module stack_structural_normal(
    inout wire[3:0] IO_DATA, 
    input wire RESET, 
    input wire CLK, 
    input wire[1:0] COMMAND,
    input wire[2:0] INDEX
    ); 

    wire nope, push, pop, get, g1_out;

    decoder g1(nope, push, pop, get, g1_out, COMMAND[0], COMMAND[1], 1'b0);
     
    wire[2:0] ind;
    and g2(ind[0], INDEX[0], get);
    and g3(ind[1], INDEX[1], get);
    and g4(ind[2], INDEX[2], get);

    wire[2:0] ptr1, ptr2, ptr3;  
    pointer g5(ptr1, CLK, RESET, push, pop);
    increment g6(ptr2, ptr1, pop);
    sum3 g7(ptr3, ptr2, ind);

    wire[4:0] Q, RW, C;

    decoder g8(Q[0], Q[1], Q[2], Q[3], Q[4], ptr3[0], ptr3[1], ptr3[2]);

    and g9(C[0], Q[0], CLK);
    and g10(C[1], Q[1], CLK);
    and g11(C[2], Q[2], CLK);
    and g12(C[3], Q[3], CLK);
    and g13(C[4], Q[4], CLK);

    and g14(RW[0], Q[0], push);
    and g15(RW[1], Q[1], push);
    and g16(RW[2], Q[2], push);
    and g17(RW[3], Q[3], push);
    and g18(RW[4], Q[4], push);

    wire[3:0] d0, d1, d2, d3, d4, r0, r1, r2, r3, r4;

    stack_cell g19(d0, RW[0], C[0], RESET , IO_DATA);
    stack_cell g20(d1, RW[1], C[1], RESET, IO_DATA);
    stack_cell g21(d2, RW[2], C[2], RESET, IO_DATA);
    stack_cell g22(d3, RW[3], C[3], RESET, IO_DATA);
    stack_cell g23(d4, RW[4], C[4], RESET, IO_DATA);

    read g24(r0[0], r0[1], r0[2], r0[3], d0, Q[0]);
    read g25(r1[0], r1[1], r1[2], r1[3], d1, Q[1]);
    read g26(r2[0], r2[1], r2[2], r2[3], d2, Q[2]);
    read g27(r3[0], r3[1], r3[2], r3[3], d3, Q[3]);
    read g28(r4[0], r4[1], r4[2], r4[3], d4, Q[4]);

    wire[3:0] ans;

    or g29(ans[0], r0[0], r1[0], r2[0], r3[0], r4[0]);
    or g30(ans[1], r0[1], r1[1], r2[1], r3[1], r4[1]);
    or g31(ans[2], r0[2], r1[2], r2[2], r3[2], r4[2]);
    or g32(ans[3], r0[3], r1[3], r2[3], r3[3], r4[3]);

    wire g33_out, g34_out, g35_out, g36_out;
    
    nor g33(g33_out, pop, get);
    not g34(g34_out, CLK);
    or g35(g35_out, g34_out, g33_out);
    not g36(g36_out, g35_out);

    cmos g37(IO_DATA[0], ans[0], g36_out, g35_out);
    cmos g38(IO_DATA[1], ans[1], g36_out, g35_out);
    cmos g39(IO_DATA[2], ans[2], g36_out, g35_out);
    cmos g40(IO_DATA[3], ans[3], g36_out, g35_out);

endmodule

module stack_cell(
    output wire[3:0] Q,
    input wire RW,
    input wire C,
    input wire reset,
    input wire[3:0] D
    );
    
    wire g1_out;
    and g1(g1_out, RW, C);

    d_trigger g2(Q[0], g1_out, D[0], reset);
    d_trigger g3(Q[1], g1_out, D[1], reset);
    d_trigger g4(Q[2], g1_out, D[2], reset);
    d_trigger g5(Q[3], g1_out, D[3], reset);

endmodule;

module rs_trigger(
    output wire Q,
    input wire R,
    input wire C,
    input wire S,
    input wire reset
    );
    
    wire g1_out, g2_out, g3_out, g4_out, g5_out;
    
    and g1(g1_out, R, C);
    and g2(g2_out, S, C);
    
    nor g3(g3_out, g1_out, g5_out);
    nor g4(g4_out, g2_out, g3_out);
    or g5(g5_out, g4_out, reset);
    
    assign Q = g3_out;
    
endmodule;

module d_trigger(
    output wire Q,
    input wire C,
    input wire D,
    input wire reset
    );

    wire not_D;
    not g1(not_D, D);
    rs_trigger g2(Q, not_D, C, D, reset);

endmodule;

module decoder(
    output wire Q0,
    output wire Q1,
    output wire Q2,
    output wire Q3,
    output wire Q4,
    input wire A0,
    input wire A1,
    input wire A2
    );

    wire not_A0, not_A1, not_A2;

    not g1(not_A0, A0);
    not g2(not_A1, A1);
    not g3(not_A2, A2);

    and g4(Q0, not_A0, not_A1, not_A2);
    and g5(Q1, A0, not_A1, not_A2);
    and g6(Q2, not_A0, A1, not_A2);
    and g7(Q3, A0, A1, not_A2);
    and g8(Q4, not_A0, not_A1, A2);

endmodule;

module half_summator(
    output wire C,
    output wire S,
    input wire A0,
    input wire A1
    );

    and g1(C, A0, A1);
    xor g2(S, A0, A1);

endmodule;

module summator(
    output wire C,
    output wire S,
    input wire A0,
    input wire A1,
    input wire A2
    );

    wire g1_s, g1_c, g2_c;
    
    half_summator g1(g1_c, g1_s, A1, A2);
    half_summator g2(g2_c, S, A0, g1_s);
    xor g3(C, g1_c, g2_c);

endmodule;

module sum3(
    output wire[2:0] Q,
    input wire[2:0] A0,
    input wire[2:0] A1
    );

    wire g1_s, g1_c, g2_s, g2_c, g3_s, g3_c;

    half_summator g1(g1_c, g1_s, A0[0], A1[0]);
    summator g2(g2_c, g2_s, A0[1], A1[1], g1_c);
    summator g3(g3_c, g3_s, A0[2], A1[2], g2_c);
    mod5 g4(Q, g3_c, g3_s, g2_s, g1_s);

endmodule;

module mod5(
    output wire[2:0] Q,
    input wire A0,
    input wire A1,
    input wire A2,
    input wire A3
    );

    wire not_A0, not_A1, not_A2, not_A3;
    not g1(not_A0, A0);
    not g2(not_A1, A1);
    not g3(not_A2, A2);
    not g4(not_A3, A3);

    wire[8:0] g_out;

    and g5(g_out[0], A1, not_A2, not_A3);
    and g6(g_out[1], A0, not_A2, A3);

    and g7(g_out[2], A0, not_A2, not_A3);
    and g8(g_out[3], not_A0, A2, A3);
    and g9(g_out[4], not_A0, not_A1, A2);

    and g10(g_out[5], A0, not_A2, not_A3);
    and g11(g_out[6], not_A1, A2, A3);
    and g12(g_out[7], A1, A2, not_A3);
    and g13(g_out[8], not_A0, not_A1, A3);
   
    or g14(Q[2], g_out[0], g_out[1]);
    or g15(Q[1], g_out[2], g_out[3], g_out[4]);
    or g16(Q[0], g_out[5], g_out[6], g_out[7], g_out[8]);

endmodule;

module increment(
    output wire[2:0] newIND,
    input wire[2:0] IND,
    input wire need
    );

    wire[2:0] g;
    assign g[0] = 1'b0;
    assign g[1] = 1'b0;
    and g1(g[2], need, 1'b1);
    sum3 g2(newIND, IND, g);

endmodule;

module decrement(
    output wire[2:0] newIND,
    input wire[2:0] IND,
    input wire need
    );

    wire[2:0] g;
    assign g[0] = need;
    assign g[1] = 1'b0;
    assign g[2] = 1'b0;
    sum3 g1(newIND, IND, g);

endmodule;

module pointer(
    output wire[2:0] Q,
    input wire C,
    input wire reset,
    input wire needInc,
    input wire needDec
    );

    wire[2:0] ind, g1_out, g2_out, g6_out;
    increment g1(g1_out, ind, needInc);
    decrement g2(g2_out, g1_out, needDec);

    assign Q = g2_out;

    wire g3_out, g4_out, g5_out;
    or g3(g3_out, needInc, needDec);
    and g4(g4_out, g3_out, C);
    not g5(g5_out, g4_out);

    pointer_cell g6(g6_out, g4_out, reset, g2_out);
    pointer_cell g7(ind, g5_out, reset, g6_out);

endmodule;

module pointer_cell(
    output wire[2:0] Q,
    input wire C,
    input wire reset,
    input wire[2:0] D
    );

    d_trigger g1(Q[0], C, D[0], reset);
    d_trigger g2(Q[1], C, D[1], reset);
    d_trigger g3(Q[2], C, D[2], reset);

endmodule;

module read(
    output wire Q0,
    output wire Q1,
    output wire Q2,
    output wire Q3,
    input wire[3:0] A,
    input wire R
    );

    and g1(Q0, A[0], R);
    and g2(Q1, A[1], R);
    and g3(Q2, A[2], R);
    and g4(Q3, A[3], R);
endmodule;
