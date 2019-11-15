`timaecale 1ns/1ps
/****************************************************************
@file name	: smp.sv
@description: search pad memory (something like cache)
=================================================================
revision		data		author		commit
  0.1		2019/11/13	  deamonyang	draft
****************************************************************/

module #(
		parameter SPM_ADD_WIDTH = 12,
		parameter SPM_DAT_WIDTH = 32
	)(
		input	wire							clk_i,
		input	wire							rst_n_i,
		
		/*instruction fetch buffer interface*/
		input	wire	[SPM_ADD_WIDTH-1:0]		if_spm_addr_i,
		input	wire							if_spm_as_i,	//address select
		input	wire							if_spm_rw_i,	//read(==1) /write(==0)
		input	wire	[SPM_DAT_WIDTH-1:0]		if_spm_wr_data_i,
		output	logic	[SPM_DAT_WIDTH-1:0]		if_spm_rd_data_o,
		
		/*memory access buffer interface*/
		input	wire	[SPM_ADD_WIDTH-1:0]		mem_spm_addr_i,
		input	wire							mem_spm_as_i,	//address select
		input	wire							mem_spm_rw_i,	//read(==1) /write(==0)
		input	wire	[SPM_DAT_WIDTH-1:0]		mem_spm_wr_data_i,
		output	logic	[SPM_DAT_WIDTH-1:0]		mem_spm_rd_data_o,		
		
	);

	logic		wea;
	logic		web;

	assign wea = ((if_spm_as_i) & (~if_spm_rw_i))? 1'b1 : 1'b0;
	
	assign web = ((mem_spm_as_i) & (~mem_spm_rw_i))? 1'b1 : 1'b0;
	
	/*insert xilinx Du-port RAM*/
	x_s3e_dpram x_s3e_dpram (
		.clka  (clk_i),			  
		.addra (if_spm_addr_i),	  
		.dina  (if_spm_wr_data_i),  
		.wea   (wea),			  
		.douta (if_spm_rd_data_o),  

		.clkb  (clk_i),			  
		.addrb (mem_spm_addr_i),	  
		.dinb  (mem_spm_wr_data_i), 
		.web   (web),			  
		.doutb (mem_spm_rd_data_o)  
	);	



endmodule

