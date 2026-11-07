module div(clk, start, sign, a, b, q, r, busy);
input clk, start, sign;
input [31:0] a, b;
output reg [31:0] q, r;
output reg busy;

reg [5:0] count = 0;
reg [62:0] d;
reg sign_q, sign_r;
wire [63:0] t = r - d;
wire f = ~|t[63:32];
wire [31:0] abs_a = sign & a[31] ? -a : a;
wire [31:0] abs_b = sign & b[31] ? -b : b;
wire [31:0] abs_q = { q[30:0], f };
wire sign_last = sign & count == 1;
always @(posedge clk) begin
	if (start) begin
		count <= 32;
		r <= abs_a;
		q <= 0;
		d <= { abs_b, 31'b0 };
		sign_q <= a[31] ^ b[31];
		sign_r <= a[31];
	end
	else if (|count) begin
		count <= count - 1'b1;
		if (f) r <= sign_last & sign_r ? -t[31:0] : t[31:0];
		d <= { 1'b0, d[62:1] };
		q <= sign_last & sign_q ? -abs_q : abs_q;
	end
	busy <= start | |count[5:1];
end

initial $monitor("%x %x %x %x %x %x", count, d, t, r, q, busy);
endmodule
