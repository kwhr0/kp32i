// KP32i
// Copyright 2026 © Yasuo Kuwahara

// MIT License

module kp32i(clk, reset, pc_out, insn_in,
	adr_out, data_in, data_out, rd, wr, intreq, intack);
input clk, reset, intreq;
input [31:0] insn_in, data_in;
output [31:0] data_out;
output [31:2] pc_out, adr_out;
output [3:0] rd, wr;
output intack;

//
// DECODE
//

wire force_nop = exec_br1 | use_sp1 & ~intack | exec_int;
wire [31:0] o = { insn_in[31:24] & {8{ ~force_nop }}, insn_in[23:0] };
wire [7:0] op = o[31:24];

localparam ADDiSUBNEG = 0;
localparam ANDi = 1;
localparam ANDiORi = 2;
localparam ANDIORI = 3;
localparam BEQ = 4;
localparam BNE = 5;
localparam BRA = 6;
localparam CALL = 7;
localparam CALLV = 8;
localparam CALLv = 9;
localparam CMP = 10;
localparam DI = 11;
localparam DIVREM = 12;
localparam DIVu = 13;
localparam DIVuREMu = 14;
localparam EI = 15;
localparam IMM = 16;
localparam LDu = 17;
localparam LDu2 = 18;
localparam LD4 = 19;
localparam LI = 20;
localparam LOGIC = 21;
localparam LuI = 22;
localparam MUL = 23;
localparam MULu = 24;
localparam MULuDIVuREMu = 25;
localparam NEG = 26;
localparam RETI = 27;
localparam RETi = 28;
localparam SEQSNE = 29;
localparam SEQSNESGTuSLEu = 30;
localparam SHIFT = 31;
localparam SNESGTuSGEu = 32;
localparam SGSL = 33;
localparam SLLv = 34;
localparam SRAv = 35;
localparam ST = 36;
localparam ST12 = 37;
localparam ST2 = 38;
localparam ST4CALLv = 39;
localparam SUB = 40;
localparam XOR = 41;
localparam IMSB = 42;
localparam I1MAX = 42;
//
localparam ADD = 43;
localparam ADDI = 44;
localparam AND = 45;
localparam ANDI = 46;
localparam COM = 47;
localparam DIV = 48;
localparam DIVU = 49;
localparam LD = 50;
localparam LD2 = 51;
localparam LD12 = 52;
localparam LDU = 53;
localparam LDU2 = 54;
localparam LDRETi = 55;
localparam LEA = 56;
localparam LUI = 57;
localparam MOV = 58;
localparam MULU = 59;
localparam OR = 60;
localparam ORI = 61;
localparam REM = 62;
localparam REMU = 63;
localparam RET = 64;
localparam SEQ = 65;
localparam SGE = 66;
localparam SGEU = 67;
localparam SGT = 68;
localparam SGTU = 69;
localparam SLE = 70;
localparam SLEU = 71;
localparam SLL = 72;
localparam SLLV = 73;
localparam SLT = 74;
localparam SLTU = 75;
localparam SNE = 76;
localparam SRA = 77;
localparam SRAV = 78;
localparam SRL = 79;
localparam SRLV = 80;
localparam ST4 = 81;
localparam IMAX = 81;
wire [IMAX:0] i;
assign i[EI] = op == 8'h02;
assign i[DI] = op == 8'h03;
assign i[RET] = op == 8'h04;
assign i[RETI] = op == 8'h05;
assign i[CALLV] = op == 8'h08;
assign i[COM] = op == 8'h09;
assign i[NEG] = op == 8'h0a;
assign i[BRA] = op == 8'h10;
assign i[CALL] = op == 8'h11;
assign i[ADDI] = op == 8'h14;
assign i[LUI] = op == 8'h16;
assign i[ANDI] = op == 8'h18;
assign i[ORI] = op == 8'h19;
assign i[LI] = op == 8'h1b;
assign i[SLL] = op == 8'h1c;
assign i[SRL] = op == 8'h1e;
assign i[SRA] = op == 8'h1f;
assign i[BEQ] = op == 8'h20;
assign i[BNE] = op == 8'h21;
assign i[LEA] = op == 8'h2f;
assign i[ST] = op == 8'h30;
assign i[ST2] = op == 8'h31;
assign i[ST4] = op == 8'h32;
assign i[LD] = op == 8'h38;
assign i[LD2] = op == 8'h39;
assign i[LD4] = op == 8'h3a;
assign i[LDU] = op == 8'h3c;
assign i[LDU2] = op == 8'h3d;
assign i[ADD] = op == 8'h40;
assign i[SUB] = op == 8'h41;
assign i[MUL] = op == 8'h42;
assign i[DIV] = op == 8'h43;
assign i[REM] = op == 8'h44;
assign i[MULU] = op == 8'h45;
assign i[DIVU] = op == 8'h46;
assign i[REMU] = op == 8'h47;
assign i[AND] = op == 8'h4c;
assign i[OR] = op == 8'h4d;
assign i[XOR] = op == 8'h4e;
assign i[MOV] = op == 8'h4f;
assign i[SLLV] = op == 8'h50;
assign i[SRLV] = op == 8'h52;
assign i[SRAV] = op == 8'h53;
assign i[SEQ] = op == 8'h54;
assign i[SNE] = op == 8'h55;
assign i[SLT] = op == 8'h58;
assign i[SLE] = op == 8'h59;
assign i[SLTU] = op == 8'h5a;
assign i[SLEU] = op == 8'h5b;
assign i[SGT] = op == 8'h5c;
assign i[SGE] = op == 8'h5d;
assign i[SGTU] = op == 8'h5e;
assign i[SGEU] = op == 8'h5f;
assign i[ADDiSUBNEG] = i[NEG] | i[ADD] | i[ADDI] | i[SUB];
assign i[ANDi] = i[AND] | i[ANDI];
assign i[ANDIORI] = i[ANDI] | i[ORI];
assign i[ANDiORi] = i[ANDi] | i[OR] | i[ORI];
assign i[CALLv] = i[CALL] | i[CALLV];
assign i[CMP] = i[SEQSNE] | i[SGSL] | i[SLTU] | i[SLEU] | i[SGTU] | i[SGEU];
assign i[DIVu] = i[DIV] | i[DIVU];
assign i[DIVREM] = i[DIV] | i[REM];
assign i[DIVuREMu] = i[DIVu] | i[REM] | i[REMU];
assign i[IMM] = i[ADDI] | i[ANDIORI] | i[SLL] | i[SRL] | i[SRA] | i[LI];
assign i[LD12] = i[LD] | i[LD2];
assign i[LDu] = i[LD] | i[LDU];
assign i[LDu2] = i[LD2] | i[LDU2];
assign i[LDRETi] = i[RETi] | i[LDu] | i[LDu2] | i[LD4];
assign i[LOGIC] = i[COM] | i[ANDIORI] | i[AND] | i[OR] | i[XOR];
assign i[LuI] = i[LUI] | i[LI];
assign i[MULu] = i[MUL] | i[MULU];
assign i[MULuDIVuREMu] = i[MULu] | i[DIVuREMu];
assign i[RETi] = i[RET] | i[RETI];
assign i[SEQSNE] = i[SEQ] | i[SNE];
assign i[SEQSNESGTuSLEu] = i[SEQSNE] | i[SLE] | i[SLEU] | i[SGT] | i[SGTU];
assign i[SNESGTuSGEu] = i[SNE] | i[SGT] | i[SGTU] | i[SGE] | i[SGEU];
assign i[SGSL] = i[SLT] | i[SLE] | i[SGT] | i[SGE];
assign i[SHIFT] = i[SLL] | i[SRL] | i[SLLV] | i[SRLV] | i[SRAv];
assign i[SLLv] = i[SLL] | i[SLLV];
assign i[SRAv] = i[SRA] | i[SRAV];
assign i[ST12] = i[ST] | i[ST2];
assign i[ST4CALLv] = i[CALLv] | i[ST4];
assign i[IMSB] = ~i[ANDIORI] & o[15];

wire clken = ~(div_start | div_busy | sr_load[0]);
reg [I1MAX:0] i1;
reg [15:0] o1l;
always @(posedge clk) if (clken) begin
	i1 <= i[I1MAX:0];
	o1l <= o[15:0];
end

//
// REGISTER
//

reg [31:0] r[0:15];
reg [31:0] r_a, r_b;
wire [3:0] rnum_a = o[23:20];
wire [3:0] rnum_b = o[19:16] | {4{ use_sp }};
wire use_sp = i[CALLv] | exec_int | i[RETi];
wire r_w = i[LuI] | i[LEA] | i[MOV] | i[ADDiSUBNEG] | i[MULuDIVuREMu] |
	i[LOGIC] | i[SHIFT] | i[CMP] | i[LDRETi];
wire [31:0] nextsp1 = r_b + { {29{ ~i1[RETi] }}, 3'b100 };
wire [31:0] r_in = use_sp1 ? nextsp1 : sr_load[1] ? data_ld : alu_y;
reg use_sp1, r_write;
reg [3:0] rnum_w;
always @(posedge clk)
	if (reset) use_sp1 <= 0;
	else if (clken) begin
		use_sp1 <= use_sp;
		r_write <= r_w | use_sp;
		rnum_w <= rnum_a | {4{ use_sp }};
		r_a <= r_write & rnum_a == rnum_w ? r_in : r[rnum_a];
		r_b <= r_write & rnum_b == rnum_w ? r_in : r[rnum_b];
		if (r_write) r[rnum_w] <= r_in;
	end

//
// PC
//

reg [31:2] pc, int_pc, nextpc_rel1;
reg active;
wire [31:2] nextpc_normal = pc + 1'b1;
wire [31:2] nextpc_rel = nextpc_normal + { {14{ o[15] }}, o[15:0] };
wire eq = r_a == r_b;
wire exec_br1 = i1[BRA] | i1[BEQ] & eq | i1[BNE] & ~eq;
wire [31:2] nextpc = exec_int ? 1 : // interrupt vector
	exec_br1 ? nextpc_rel1 :
	i1[CALL] ? o1l :
	i1[CALLV] ? r_a[31:2] :
	i1[RETi] ? data_in[31:2] : nextpc_normal;
always @(posedge clk)
	if (reset) begin
		active <= 0;
		pc <= 0;
	end
	else if (clken) begin
		active <= 1;
		nextpc_rel1 <= nextpc_rel;
		int_pc <= pc;
		pc <= pc_out;
	end
assign pc_out = active & clken ? nextpc : pc;

//
// ALU
//

wire [31:0] imm1 = { {16{ i1[IMSB] }}, o1l };
wire [31:0] alu_b = i1[IMM] ? imm1 : r_b;
wire [31:0] addsub_y = i1[NEG] ? -r_a : i1[SUB] ? r_a - r_b : r_a + alu_b;
wire [31:0] mul_y = $signed(r_a) * $signed(r_b);
wire [31:0] mulu_y = r_a * r_b;
reg div_start2;
always @(posedge clk)
	div_start2 <= i1[DIVuREMu]; // no clken
wire [31:0] div_q, div_r;
wire div_start = i1[DIVuREMu] & ~div_start2;
div div(.clk(clk), .start(div_start), .sign(i1[DIVREM]),
	.a(r_a), .b(r_b), .q(div_q), .r(div_r), .busy(div_busy));
wire [31:0] muldiv_y = i1[MULu] ?
	i1[MUL] ? mul_y : mulu_y :
	i1[DIVu] ? div_q : div_r;
wire [31:0] logic_y = i1[ANDiORi] ?
	i1[ANDi] ? r_a & alu_b : r_a | alu_b :
	i1[XOR] ? r_a ^ alu_b : ~r_a;
wire [63:0] r_a_ext = { {32{ i1[SRAv] & r_a[31] }}, r_a };
wire [31:0] shift_y = i1[SLLv] ? r_a << alu_b[4:0] : r_a_ext >> alu_b[4:0];
wire [31:0] imm_y = i1[LI] ? imm1 : { o1l, 16'b0 };
wire [31:0] r_ax = { r_a[31] ^ i1[SGSL], r_a[30:0] };
wire [31:0] r_bx = { r_b[31] ^ i1[SGSL], r_b[30:0] };
wire cmp_y = (r_ax < r_bx & ~i1[SEQSNE] | eq & i1[SEQSNESGTuSLEu]) ^
	i1[SNESGTuSGEu];
wire [31:0] alu_y =
	i1[ADDiSUBNEG] ? addsub_y :
	i1[MULuDIVuREMu] ? muldiv_y :
	i1[LOGIC] ? logic_y :
	i1[SHIFT] ? shift_y :
	i1[LuI] ? imm_y :
	i1[CMP] ? cmp_y :
	r_b + (i1[CALLv] | intack ? -4 : i1[RETi] ? 0 : imm1); // address

//
// DATA
//

reg [1:0] sr_load, sr_b, sr_h, sr_ext, sel_load;
always @(posedge clk) /*if (clken) */begin
	sr_load <= { sr_load[0], ~sr_load[0] & i[LDRETi] };
	sr_b <= { sr_b[0], i[LDu] };
	sr_h <= { sr_h[0], i[LDu2] };
	sr_ext <= { sr_ext[0], i[LD12] };
	sel_load <= alu_y[1:0];
end

wire [7:0] data_b = sel_load[1] ?
	sel_load[0] ? data_in[31:24] : data_in[23:16] :
	sel_load[0] ? data_in[15:8] : data_in[7:0];
wire [31:0] data_b_ext = { {24{ sr_ext[1] & data_b[7] }}, data_b };
wire [15:0] data_h = sel_load[1] ? data_in[31:16] : data_in[15:0];
wire [31:0] data_h_ext = { {16{ sr_ext[1] & data_h[15] }}, data_h };
wire [31:0] data_ld = sr_b[1] ? data_b_ext : sr_h[1] ? data_h_ext : data_in;

assign adr_out = alu_y[31:2];
assign data_out = intack ? { int_pc, 2'b00 } :
	i1[CALLv] ? { pc, 2'b00 } : {
	i1[ST] ? r_a[7:0] : i1[ST2] ? r_a[15:8] : r_a[31:24],
	i1[ST12] ? r_a[7:0] : r_a[23:16],
	i1[ST] ? r_a[7:0] : r_a[15:8],
	r_a[7:0]
};
assign rd = {
	i1[LDu] & alu_y[1:0] == 3 | i1[LDu2] & alu_y[1] | i1[LD4],
	i1[LDu] & alu_y[1:0] == 2 | i1[LDu2] & alu_y[1] | i1[LD4],
	i1[LDu] & alu_y[1:0] == 1 | i1[LDu2] & ~alu_y[1] | i1[LD4],
	i1[LDu] & alu_y[1:0] == 0 | i1[LDu2] & ~alu_y[1] | i1[LD4]
};
assign wr = {
	i1[ST] & alu_y[1:0] == 3 | i1[ST2] & alu_y[1] | i1[ST4CALLv] | intack,
	i1[ST] & alu_y[1:0] == 2 | i1[ST2] & alu_y[1] | i1[ST4CALLv] | intack,
	i1[ST] & alu_y[1:0] == 1 | i1[ST2] & ~alu_y[1] | i1[ST4CALLv] | intack,
	i1[ST] & alu_y[1:0] == 0 | i1[ST2] & ~alu_y[1] | i1[ST4CALLv] | intack
};

//
// INTERRUPT
//

reg iff, intack;
wire exec_int = intreq & iff & ~(exec_br1 | use_sp1);
always @(posedge clk)
	if (reset) iff <= 0;
	else if (clken) begin
		if (exec_int | i1[DI]) iff <= 0;
		else if (i1[EI] | i1[RETI]) iff <= 1;
	end
always @(posedge clk)
	if (reset | intack) intack <= 0;
	else if (clken & exec_int) intack <= 1;

//

integer c;
initial begin
	for (c = 0; c <= 15; c = c + 1) r[c] = 0;
	for (c = 0; c <= I1MAX; c = c + 1) i1[c] = 0;
end

wire [31:0] _pc = { pc, 2'b00 };
wire [31:0] _adr = { adr_out, 2'b00 };
wire [7:0] rwc = clken & r_write === 1 ?
	rnum_w <= 9 ? rnum_w + "0" : rnum_w + "a" - 10 : "-";
initial $monitor("%x %b %x %c %x %bM %x %x %x  %b",
	_pc, force_nop, insn_in, rwc, r_in, wr, _adr, data_out, data_in, rd);
endmodule
