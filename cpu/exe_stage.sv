`timaecale 1ns/1ps
/****************************************************************
@file name	: exe_stage.sv
@description: execute top wrapper
=================================================================
revision		data		author		commit
  0.1		2019/11/16	  deamonyang	draft
****************************************************************/
`include "isa.h"
`include "cpu.h"

module exe_stage#(
		parameter WORD_DATA_WIDTH 	= 32,
		parameter WORD_ADDR_WIDTH 	= 30,
		parameter MEM_OP_BUS		= 2 ,
		parameter CTRL_OP_BUS	 	= 2 ,
		parameter REG_ADDR_BUS		= 5 ,
		parameter ALU_OP_BUS		= 4
		parameter ISA_EXP_BUS		= 3
	)(
		input	wire							clk_i				,
		input	wire							rst_n_i				,	
		/*pipline state*/	
		input	wire 							stall_i				,
		input	wire 							flush_i				,
		input	wire 							int_detect_i		,//interrupt detect
		
		output	logic	[WORD_DATA_WIDTH-1:0]	fwd_data_o			,
		
		/*ID->EXE*/	
		input	wire 	[WORD_ADDR_WIDTH-1:0]	id_pc_i				,
		input	wire 							id_en_i				,
		input	wire	[ALU_OP_BUS-1:0]		id_alu_op_i			,
		input	wire	[WORD_DATA_WIDTH-1:0]	id_alu_in_0_i	,
		input	wire	[WORD_DATA_WIDTH-1:0]	id_alu_in_1_i	,
		input	wire 							id_br_flag_i		,
		input	wire 	[MEM_OP_BUS-1:0]		id_mem_op_i			,
		input	wire 	[WORD_DATA_WIDTH-1:0]	id_mem_wr_data_i	,
		input	wire 	[CTRL_OP_BUS-1:0]		id_ctrl_op_i		,
		input	wire 	[REG_ADDR_BUS-1:0]		id_dst_addr_i		,
		input	wire 							id_gpr_wre_i		,
		input	wire 	[ISA_EXP_BUS-1:0]		id_exp_code_i		,

		/*EXE->MEM*/
		output 	logic 	[WORD_ADDR_WIDTH-1:0]	exe_pc_o			,
		output 	logic 							exe_en_o			,
		output 	logic 							exe_br_flag_o		,
		output 	logic 	[MEM_OP_BUS-1:0]		exe_mem_op_o		,
		output 	logic 	[WORD_DATA_WIDTH-1:0]	exe_mem_wr_data_o	,
		output 	logic 	[CTRL_OP_BUS-1:0]		exe_ctrl_op_o		,
		output 	logic 	[REG_ADDR_BUS-1:0]		exe_dst_addr_o		,
		output 	logic 							exe_gpr_wre_o		,
		output 	logic 	[ISA_EXP_BUS-1:0]		exe_exp_code_o		,
		output 	logic 	[WORD_DATA_WIDTH-1:0]	exe_out_o			
		
	);
		logic	[WORD_DATA_WIDTH-1:0]	alu_out;
		logic							alu_of;

	alu#(
		.ALU_DAT_WIDTH 	(WORD_DATA_WIDTH),
		.ALU_OP_BUS		(ALU_OP_BUS		)
	)alu_inst1(
		.in_0_i			(id_alu_in_0_i	),
		.in_1_i			(id_alu_in_1_i	),	
		.op_i			(id_alu_op_i	),
		.out_o			(alu_out		),
		.of_o			(alu_of			),//overflow flag
	);

	exe_reg#(
		.WORD_DATA_WIDTH	(WORD_DATA_WIDTH	),
		.WORD_ADDR_WIDTH	(WORD_ADDR_WIDTH	),
		.MEM_OP_BUS			(MEM_OP_BUS			),
		.CTRL_OP_BUS		(CTRL_OP_BUS		),
		.REG_ADDR_BUS		(REG_ADDR_BUS		),
		.ISA_EXP_BUS		(ISA_EXP_BUS		)
	)exe_reg_inst1(
		.clk_i				(clk_i				),
		.rst_n_i			(rst_n_i			),
		/*alu output data*/	
		.alu_out_i			(alu_out			),
		.alu_of_i			(alu_of				),
		/*pipline state*/	                                  
		.stall_i			(stall_i			),
		.flush_i			(flush_i			),
		.int_detect_i		(int_detect_i		),//interrupt detect
		/*ID->EXE*/	                                          
		.id_pc_i			(id_pc_i			),
		.id_en_i			(id_en_i			),
		.id_br_flag_i		(id_br_flag_i		),
		.id_mem_op_i		(id_mem_op_i		),
		.id_mem_wr_data_i	(id_mem_wr_data_i	),
		.id_ctrl_op_i		(id_ctrl_op_i		),
		.id_dst_addr_i		(id_dst_addr_i		),
		.id_gpr_wre_i		(id_gpr_wre_i		),
		.id_exp_code_i		(id_exp_code_i		),
		/*EXE->MEM*/                                       
		.exe_pc_o			(exe_pc_o			),
		.exe_en_o			(exe_en_o			),
		.exe_br_flag_o		(exe_br_flag_o		),
		.exe_mem_op_o		(exe_mem_op_o		),
		.exe_mem_wr_data_o	(exe_mem_wr_data_o	),
		.exe_ctrl_op_o		(exe_ctrl_op_o		),
		.exe_dst_addr_o		(exe_dst_addr_o		),
		.exe_gpr_wre_o		(exe_gpr_wre_o		),
		.exe_exp_code_o		(exe_exp_code_o		),
		.exe_out_o			(exe_out_o			)
	);



endmodule

