`timescale 1ns/1ps


module rom#(
		parameter ADD_WIDTH = 11,
		parameter DAT_WIDTH = 32
	)(
		input	wire					clk_i,
		input	wire					rst_n_i,
		input	wire					cs_i,	//chip select
		input	wire					ac_i,	//address select
		input	wire[ADD_WIDTH-1:0]		addr_i,
		output	logic					rdy_o,	//data ready
		output	logic[DAT_WIDTH-1:0]	rd_data_o//read data output port
	);
	
	/*insert rom ip core*/
	xilinx_rom_ip xrom_inst(
		.clka(clk_i),
		.addra(addr_i),
		.douta(rd_data_o)
	);
	
	always_ff@(posedge clk_i or negedge rst_n_i)
	if(!rst_n_i)
		rdy_o <= 1'b0;
	else if(cs_i & ac_i)
		rdy_o <= 1'b1;
	else
		rdy_o <= 1'b0;
	
endmodule
