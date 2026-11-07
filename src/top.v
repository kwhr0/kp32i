module top(I_clk, lcd_rst_n, lcd_cs_n, lcd_a0, sck, sda);
input I_clk;
output sck, sda;
output lcd_rst_n, lcd_cs_n, lcd_a0;

function [7:0] sel4x8;
	input [1:0] sel;
	input [31:0] a;
	begin
		case (sel)
			2'b00: sel4x8 = a[7:0];
			2'b01: sel4x8 = a[15:8];
			2'b10: sel4x8 = a[23:16];
			2'b11: sel4x8 = a[31:24];
		endcase
	end
endfunction

wire [31:2] pc, adr;
wire [31:0] data_in, data_out;
wire [3:0] wr;

reg [31:0] text[0:'h1fff]; // 32kB
initial $readmemh("text0.mem", text);
reg [31:0] insn;
always @(posedge clk)
	insn <= text[pc[15:2]];

wire is_io = adr[19:2] == 20'h4eff0 >> 2;
wire is_vram = adr[19:12] == 8'h49;

wire en0 = ~adr[15];
wire en1 = adr[15:13] == 3'b100;

// data 32kB+8kB
wire [7:0] d00, d01, d02, d03, d10, d11, d12, d13;
ram #(.MSB(12), .FILE("data00.mem"))
	ram00(.clk(clk), .ad(adr[14:2]), .din(data_out[7:0]), .dout(d00), .wre(wr[0] & en0));
ram #(.MSB(12), .FILE("data01.mem"))
	ram01(.clk(clk), .ad(adr[14:2]), .din(data_out[15:8]), .dout(d01), .wre(wr[1] & en0));
ram #(.MSB(12), .FILE("data02.mem"))
	ram02(.clk(clk), .ad(adr[14:2]), .din(data_out[23:16]), .dout(d02), .wre(wr[2] & en0));
ram #(.MSB(12), .FILE("data03.mem"))
	ram03(.clk(clk), .ad(adr[14:2]), .din(data_out[31:24]), .dout(d03), .wre(wr[3] & en0));

ram #(.MSB(10), .FILE("zero.mem"))
	ram10(.clk(clk), .ad(adr[12:2]), .din(data_out[7:0]), .dout(d10), .wre(wr[0] & en1));
ram #(.MSB(10), .FILE("zero.mem"))
	ram11(.clk(clk), .ad(adr[12:2]), .din(data_out[15:8]), .dout(d11), .wre(wr[1] & en1));
ram #(.MSB(10), .FILE("zero.mem"))
	ram12(.clk(clk), .ad(adr[12:2]), .din(data_out[23:16]), .dout(d12), .wre(wr[2] & en1));
ram #(.MSB(10), .FILE("zero.mem"))
	ram13(.clk(clk), .ad(adr[12:2]), .din(data_out[31:24]), .dout(d13), .wre(wr[3] & en1));

reg dadrmsb = 0;
always @(posedge clk)
	dadrmsb <= adr[15];

assign data_in = is_io ? 32'h0/*not used*/ :
	dadrmsb ? { d13, d12, d11, d10 } : { d03, d02, d01, d00 };

kp32i kp32i(.clk(clk), .reset(reset), .pc_out(pc), .insn_in(insn),
	.adr_out(adr), .data_in(data_in), .data_out(data_out), .rd(), .wr(wr),
	.intreq(1'b0), .intack());

wire [9:0] vadr = adr[11:2];
reg [7:0] vram0[0:'h3ff], vram1[0:'h3ff], vram2[0:'h3ff], vram3[0:'h3ff];
always @(posedge clk)
	if (is_vram) begin
		if (wr[0]) vram0[vadr] <= data_out[7:0];
		if (wr[1]) vram1[vadr] <= data_out[15:8];
		if (wr[2]) vram2[vadr] <= data_out[23:16];
		if (wr[3]) vram3[vadr] <= data_out[31:24];
	end

reg [7:0] vramadr_l, vramout;
reg [3:0] vramadr_u;
wire [11:0] vramadr = { vramadr_u, vramadr_l };
always @(posedge c_clk)
	vramout <= sel4x8(vramadr_l[1:0],
		{ vram3[vramadr[11:2]], vram2[vramadr[11:2]], vram1[vramadr[11:2]], vram0[vramadr[11:2]] });

reg [2:0] vrtc;
always @(posedge clk)
	vrtc <= { lcd_cs_n, vrtc[2:1] };

reg trans_start;
reg [4:0] start_adr = 0;
always @(posedge clk)
	if (vrtc[1:0] == 2'b01) trans_start <= 0;
	else if (is_io & wr[1]) begin
		start_adr <= data_out[12:8];
		trans_start <= 1;
	end

localparam SYSCLK = 60000000;

pll pll(.clkin(I_clk), .mdclk(I_clk), .clkout0(clk), .lock(lock));
wire c_clk = clk;
reg [17:0] lockcnt = 0;
assign reset = ~lockcnt[17]; // >2mS
always @(posedge clk)
	if (~lock) lockcnt <= 0;
	else if (reset) lockcnt <= lockcnt + 1'b1;

wire [2:0] port;
wire [7:0] port_out;

f1802 f1802(.clk(c_clk), .reset(reset),
	.ef({ 1'b0, trans_start, timer_active, spi_busy }), .q(lcd_a0),
	.iord(), .iowr(c_iowr), .port(port),
	.port_in(port[0] ? vramout : start_adr), .port_out(port_out));

spi #(.CLK(SYSCLK))
	spi(.clk(c_clk), .wr(c_iowr & port == 1), .fast(1'b1),
	.data_in(port_out), .data_out(), .busy(spi_busy),
	.mosi(sda), .sclk(sck), .miso(1'b1));

timer #(.CLK(SYSCLK))
	timer(.clk(c_clk), .wr(c_iowr & port == 3), .active(timer_active));

reg lcd_rst_n, lcd_cs_n;
always @(posedge c_clk)
	if (c_iowr)
		case (port)
			2: { lcd_rst_n, lcd_cs_n } <= port_out[1:0];
			4: vramadr_l <= port_out;
			5: vramadr_u <= port_out[3:0];
		endcase


endmodule
