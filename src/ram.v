module ram #(parameter MSB=10, parameter FILE="")(clk, ad, din, dout, wre);
input clk, wre;
input [MSB:0] ad;
input [7:0] din;
output reg [7:0] dout;
reg [7:0] mem[0:(1<<MSB+1)-1];
initial $readmemh(FILE, mem);
always @(posedge clk)
	if (wre) mem[ad] <= din;
always @(posedge clk)
	if (wre) dout <= din;
	else dout <= mem[ad];
endmodule
