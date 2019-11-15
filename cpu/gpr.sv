`timaecale 1ns/1ps
/****************************************************************
@file name	: gpr.sv
@description: generial register group
=================================================================
revision		data		author		commit
  0.1		2019/11/13	  deamonyang	draft
****************************************************************/
module gpr #(
		parameter REG_ADD_WIDTH = 5,
		parameter REG_DAT_WIDTH = 32,
		parameter REG_NUM = 32
	)(
		input	wire						clk_i,
		input	wire						rst_n_i,
		input	wire	[REG_ADD_WIDTH-1:0]	rd_addr_0_i,
		output	logic	[REG_DAT_WIDTH-1:0]	rd_data_0_o,
		
		input	wire	[REG_ADD_WIDTH-1:0]	rd_addr_1_i,
		output	logic	[REG_DAT_WIDTH-1:0]	rd_data_1_o,
		
		input	wire						wre_i, 		//write enable
		input	wire	[REG_ADD_WIDTH-1:0]	wr_addr_i,	//write address
		input	wire	[REG_DAT_WIDTH-1:0]	wr_data_i	//write data
	);
	
	logic[REG_DAT_WIDTH-1:0]	gpr[REG_NUM-1:0];
	integer i;
	
	assign rd_data_0_o = ((wre_i) && (wr_addr_i == rd_addr_0_i))?
							wr_data_i : gpr[rd_addr_0_i];
	
	assign rd_data_1_o = ((wre_i) && (wr_addr_i == rd_addr_1_i))?
							wr_data_i : gpr[rd_addr_1_i];	
							
	always_ff@(posedge clk_i or negedge rst_n_i)
	if(!rst_n_i) begin
		for(i = 0; i < REG_NUM; i = i + 1)begin:init_gpr
			gpr[i] <= 'd0;
		end
	end else if(wre_i)
		gpr[wr_addr_i] <= wr_data_i;
	else
		gpr[wr_addr_i] <= gpr[wr_addr_i];
		
endmodule
