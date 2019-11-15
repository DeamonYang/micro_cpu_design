`timaecale 1ns/1ps
/****************************************************************
@file name	: if_stage.sv
@description: instruction fetch top wrapper
=================================================================
revision		data		author		commit
  0.1		2019/11/13	  deamonyang	draft
****************************************************************/

module if_stage#(
		parameter	IF_DAT_WIDTH = 32,
		parameter	IF_ADD_WIDTH = 30
	)(
		input	wire							clk_i,
		input	wire							rst_n_i,
		/*spm interface*/
		input	wire	[IF_DAT_WIDTH-1:0]		spm_rd_data_i,
		output	logic	[IF_ADD_WIDTH-1:0]		spm_addr_o,
		output	logic							spm_as_o,
		output	logic							spm_rw_o,
		output	logic	[IF_DAT_WIDTH-1:0]		spm_wr_data_o,
		
		/*system bus port*/
		input	wire	[IF_DAT_WIDTH-1:0]		bus_rd_data_i,
		input	wire							bus_rdy_i,
		input	wire							bus_grnt_i,
		output	logic	[IF_ADD_WIDTH-1:0]		bus_addr_o,
		output	logic							bus_as_o,
		output	logic							bus_rw_o,
		output	logic	[IF_DAT_WIDTH-1:0]		bus_wr_data_o,
		
		/*if control signal*/
		input	wire							stall_i,//pipline delay
		input	wire							flush_i,
		input	wire	[ADD_WIDTH-1:0]			new_pc_i,
		input	wire							br_taken_i,
		input	wire	[ADD_WIDTH-1:0]			br_addr_i,
		output	logic							pip_busy_o,
		
		output	logic	[IF_ADD_WIDTH-1:0]		if_pc_o,
		output	logic	[IF_DAT_WIDTH-1:0]		if_instru_o,
		output	logic							if_en_o
		
	);
	
	logic	[IF_DAT_WIDTH-1:0]	instru;

	if_reg#(
		.DAT_WIDTH	(IF_DAT_WIDTH),
		.ADD_WIDTH	(IF_ADD_WIDTH)
	)if_reg_inst(
		.clk_i		(clk_i		),
		.rst_n_i	(rst_n_i	),		
		.instru_i	(instru		),		
		.stall_i	(stall_i	),//pipline delay
		.flush_i	(flush_i	),
		.new_pc_i	(new_pc_i	),
		.br_taken_i	(br_taken_i	),
		.br_addr_i	(br_addr_i	),		
		.if_pc_o	(if_pc_o	),
		.if_instru_o(if_instru_o),
		.if_en_o	(if_en_o	)		//pipline data is valid
	); 
		
	
	bus_if#(
		.BUS_ADD_WIDTH (IF_ADD_WIDTH	),
		.BUS_DAT_WIDTH (IF_DAT_WIDTH	),
		.BUS_SLAV_WIDTH( 3				)
	)bus_if_insrt(
		.clk_i			(clk_i			),
		.rst_n_i		(rst_n_i		),		
		/*pipline state signal*/		
		.pip_stall_i	(stall_i		),
		.pip_flush_i	(flush_i		),
		.pip_busy_o		(pip_busy_o		),
		
		/*cpu interface*/
		.cpu_addr_i		(if_pc_o		),		//address bus
		.cpu_acs_i		(1'b1			),		//address selsct
		.cpu_rw_i		(1'b1			),	
		.cpu_wr_data_i	('d0			),	//write data input
		.cpu_rd_data_o	(instru			),	//output data port
		
		/*SPM interface*/
		.spm_rd_data_i	(spm_rd_data_i	),
		.spm_addr_o		(spm_addr_o		),
		.spm_as_o		(spm_as_o		),
		.spm_rw_o		(spm_rw_o		),
		.spm_wr_data_o	(spm_wr_data_o	),
		
		/*system bus interface*/
		.bus_rd_data_i	(bus_rd_data_i	),
		.bus_rdy_i		(bus_rdy_i		),
		.bus_grnt_i		(bus_grnt_i		),
		.bus_req_o		(bus_req_o		),
		.bus_addr_o		(bus_addr_o		),
		.bus_as_o		(bus_as_o		),
		.bus_rw_o		(bus_rw_o		),		//bus read == 1'b1 / write == 1'b0 
		.bus_wr_data_o	(bus_wr_data_o	)
	);

endmodule


