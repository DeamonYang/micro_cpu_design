`timaecale 1ns/1ps
/****************************************************************
@file name	: mem_stage.sv
@description: mem  control top wrapper
=================================================================
revision		data		author		commit
  0.1		2019/11/16	  deamonyang	draft
****************************************************************/

`include "isa.h"
`include "cpu.h"


module mem_stage#(
		parameter WORD_DATA_WIDTH 	= 32,
		parameter WORD_ADDR_WIDTH	= 30,
		parameter CTRL_OP_BUS		= 2 ,
		parameter ISA_EXP_BUS		= 3 ,
		parameter REG_ADDR_BUS		= 5 ,
		parameter MEM_OP_BUS		= 2 ,
		parameter BUS_SLAV_WIDTH 	= 3
	)(
		input	wire 							clk_i				,
		input	wire 							rst_n_i				,
		
		input	wire 							stall_i				,
		input	wire 							flush_i				,
		output	logic							busy_o				,
			
		output	logic	[WORD_DATA_WIDTH-1:0]	fwd_data_o			,
			
		/*SPM interface*/	
		input	wire	[WORD_DATA_WIDTH-1:0]	spm_rd_data_i		,
		output	logic	[WORD_ADDR_WIDTH-1:0]	spm_addr_o			,
		output	logic							spm_as_o			,
		output	logic							spm_rw_o			,
		output	logic	[WORD_DATA_WIDTH-1:0]	spm_wr_data_o		,
			
		/*system bus interface*/	
		input	wire	[WORD_DATA_WIDTH-1:0]	bus_rd_data_i		,
		input	wire							bus_rdy_i			,
		input	wire							bus_grnt_i			,
		output	logic							bus_req_o			,
		output	logic	[WORD_ADDR_WIDTH-1:0]	bus_addr_o			,
		output 	logic							bus_as_o			,
		output 	logic							bus_rw_o			,		//bus read == 1'b1 / write == 1'b0 
		output	logic	[WORD_DATA_WIDTH-1:0]	bus_wr_data_o		,
		
		/*EXE->MEM*/		
		input	wire 	[WORD_ADDR_WIDTH-1:0]	exe_pc_i			,
		input	wire 							exe_en_i			,
		input	wire 							exe_br_flag_i		,
		input	wire 	[MEM_OP_BUS-1:0]		exe_mem_op_i		,
		input	wire 	[WORD_DATA_WIDTH-1:0]	exe_mem_wr_data_i	,
		input	wire 	[WORD_DATA_WIDTH-1:0]	exe_out_i			,
		input	wire 	[CTRL_OP_BUS-1:0]		exe_ctrl_op_i		,
		input	wire 	[REG_ADDR_BUS-1:0]		exe_dst_addr_i		,
		input	wire 							exe_gpr_wre_i		,
		input	wire 	[ISA_EXP_BUS-1:0]		exe_exp_code_i		,
		
		output	logic 	[WORD_ADDR_WIDTH-1:0]	mem_pc_o			,
		output	logic 							mem_en_o			,
		output	logic 							mem_br_flag_o		,
		output	logic 	[CTRL_OP_BUS-1:0]		mem_ctrl_op_o		,
		output	logic 	[REG_ADDR_BUS-1:0]		mem_dst_addr_o		,
		output	logic 							mem_gpr_wre_o		,
		output	logic 	[ISA_EXP_BUS-1:0]		mem_exp_code_o		,
		output	logic 	[WORD_DATA_WIDTH-1]		mem_out_o
		
	
	);
		logic	[WORD_DATA_WIDTH-1:0]	rd_data;
		logic	[WORD_ADDR_WIDTH-1:0]	addr;
		logic							addrs;
		logic							rw;
		logic	[WORD_DATA_WIDTH-1:0]	wr_data;
		logic	[WORD_DATA_WIDTH-1:0]	out;
		logic							miss_align;
		
		assign fwd_data_o = out;
	

	mem_ctrl#(
		.MEM_OP_BUS			(MEM_OP_BUS			),
		.WORD_DATA_WIDTH 	(WORD_DATA_WIDTH 	),
		.WORD_ADDR_WIDTH	(WORD_ADDR_WIDTH	)
	)mem_ctrl_inst(
		.exe_en_i			(exe_en_i			),
		.exe_mem_op_i		(exe_mem_op_i		),
		.exe_mem_wr_data_i	(exe_mem_wr_data_i	),
		.exe_out_i			(exe_out_i			),
		
		.rd_data_i			(rd_data			),
		.addr_o				(addr				),
		.addrs_o			(addrs				),
		.rw_o				(rw 				),
		.wr_data_o			(wr_data			),
		.out_o				(out				),
		.miss_align_o		(miss_align			)
	);


	mem_reg#(
		.WORD_DATA_WIDTH 	(WORD_DATA_WIDTH 	),
		.WORD_ADDR_WIDTH	(WORD_ADDR_WIDTH	),
		.CTRL_OP_BUS		(CTRL_OP_BUS		),
		.ISA_EXP_BUS		(ISA_EXP_BUS		),
		.REG_ADDR_BUS		(REG_ADDR_BUS		)
	)mem_reg_insrt(
		.clk_i			(clk_i			),
		.rst_n_i		(rst_n_i		),
		.out_i			(out			),
		.miss_align_i	(miss_align		),
		.stall_i		(stall_i		),
		.flush_i		(flush_i		),

		.exe_pc_i		(exe_pc_i		),
		.exe_en_i		(exe_en_i		),
		.exe_br_flag_i	(exe_br_flag_i	),
		.exe_ctrl_op_i	(exe_ctrl_op_i	),
		.exe_dst_addr_i	(exe_dst_addr_i	),
		.exe_gpr_wre_i	(exe_gpr_wre_i	),
		.exe_exp_code_i	(exe_exp_code_i	),
 
		.mem_pc_o		(mem_pc_o		),
		.mem_en_o		(mem_en_o		),
		.mem_br_flag_o	(mem_br_flag_o	),
		.mem_ctrl_op_o	(mem_ctrl_op_o	),
		.mem_dst_addr_o	(mem_dst_addr_o	),
		.mem_gpr_wre_o	(mem_gpr_wre_o	),
		.mem_exp_code_o	(mem_exp_code_o	),
		.mem_out_o		(mem_out_o		)
	);

	bus_if#(
		.BUS_ADD_WIDTH (WORD_ADDR_WIDTH	),
		.BUS_DAT_WIDTH (WORD_DATA_WIDTH	),
		.BUS_SLAV_WIDTH(BUS_SLAV_WIDTH	)
	)bus_if_inst(
		.clk_i			(clk_i			),
		.rst_n_i		(rst_n_i		),
				
		/*pipline state signal*/		
		.pip_stall_i	(stall_i		),
		.pip_flush_i	(flush_i		),
		.pip_busy_o		(busy_o			),
		
		/*cpu interface*/
		.cpu_addr_i		(addr			),		//address bus
		.cpu_acs_i		(addrs			),		//address selsct
		.cpu_rw_i		(rw				),	
		.cpu_wr_data_i	(wr_data		),	//write data input
		.cpu_rd_data_o	(rd_data		),	//output data port
		
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



