`timaecale 1ns/1ps
/****************************************************************
@file name	: id_stage.sv
@description: instruction decoder top warpper
=================================================================
revision		data		author		commit
  0.1		2019/11/16	  deamonyang	draft
****************************************************************/

module id_stage#(
		parameter ALU_OP_BUS = 4,
		parameter ID_DAT_WIDTH = 32,
		parameter ID_ADD_WIDTH = 30,
		parameter MEM_OP_BUS = 2,
		parameter CTRL_OP_BUS = 2,
		parameter REG_ADD_BUS = 5,
		parameter CPU_EXE_MODE = 1,
		parameter ISA_EXP_BUS = 3
	)(
		input	wire							clk_i,
		input	wire							rst_n_i,
		/*gpr data signal*/
		input	wire	[ID_DAT_WIDTH-1:0]		gpr_rd_data_0_i,
		input	wire	[ID_DAT_WIDTH-1:0]		gpr_rd_data_1_i,
		output	logic 	[ID_ADD_WIDTH-1:0]		gpr_rd_addr_0_o,
		output	logic 	[ID_ADD_WIDTH-1:0]		gpr_rd_addr_1_o,
		/*exe input data directly*/						
		input 	wire 							exe_en_i,
		input 	wire 	[ID_DAT_WIDTH-1:0]		exe_fwd_data_i,
		input 	wire 	[REG_ADD_BUS-1:0]		exe_dst_addr_i,
		input 	wire 							exe_gpr_wre_i,
		/*mem forward data*/
		input	wire	[ID_DAT_WIDTH-1:0]		mem_fwd_data_i,
		/*control reg port*/
		input	wire	[CPU_EXE_MODE-1:0]		exe_mode_i,
		input	wire	[ID_DAT_WIDTH-1:0]		creg_rd_data_i,
		output	wire	[REG_ADD_BUS-1:0]		creg_rd_addr_o,
		/*pipline control signal*/
		input	wire							stall_i,
		input	wire							flush_i,
		output	logic	[ID_ADD_WIDTH-1:0]		br_addr_o,
		output	logic							br_taken_o,
		output	logic							ld_hzazrd_o,
		
		/*IF->ID*/
		input	wire	[ID_ADD_WIDTH-1:0]		if_pc_i,
		input	wire	[ID_DAT_WIDTH-1:0]		if_insn_i,
		input	wire							if_en_i,
		
		/*ID -> EX*/
		output	logic	[ID_ADD_WIDTH-1:0]		id_pc_o,
		output	logic							id_en_o,
		output	logic	[ALU_OP_BUS-1:0]		id_alu_op_o,
		output	logic	[ID_DAT_WIDTH-1:0]		id_alu_in_0_o,
		output	logic	[ID_DAT_WIDTH-1:0]		id_alu_in_1_o,
		output	logic							id_br_flag_o,
		output	logic	[MEM_OP_BUS-1:0]		id_mem_op_o,
		output	logic	[ID_DAT_WIDTH-1:0]		id_mem_wr_data_o,
		output	logic	[CTRL_OP_BUS-1:0]		id_ctrl_op_o,
		output	logic	[REG_ADD_BUS-1:0]		id_dst_addr_o,
		output	logic							id_gpr_wre_o,
		output	logic	[ISA_EXP_BUS-1:0]		id_exp_code_o		
	);

		logic	alu_op_o  			;
		logic	alu_in_0_o   		;		
		logic	alu_in_1_o   		;
		logic	br_flag_o   		;
		logic	mem_op_o   			;
		logic	mem_wr_data_o   	;
		logic	ctrl_op_o   		;
		logic	dst_addr_o   		;
		logic	gpr_wre_o   		;
		logic	exp_code_o   		;



	decoder#(
		.DE_ADD_WIDTH 	(ID_ADD_WIDTH	),
		.DE_DAT_WIDTH 	(ID_DAT_WIDTH	),
		.REG_ADD_WIDTH 	(REG_ADD_BUS	),
		.MEM_OP_BUS 	(MEM_OP_BUS		),
		.CPU_EXE_MODE 	(CPU_EXE_MODE	),
		.ALU_OP_BUS 	(ALU_OP_BUS		),
		.CTRL_OP_BUS 	(CTRL_OP_BUS	),
		.ISA_EXP_BUS 	(ISA_EXP_BUS	)
	)decoder_inst(
		.if_pc_i			(if_pc_i			),	//pc pointer
		.if_insn_i			(if_insn_i			),	//instruction code
		.if_en_i			(if_en_i			),	//instruction valid
		
		/*gpr interface*/
		.gpr_rd_data_0_i	(gpr_rd_data_0_i	),
		.gpr_rd_data_1_i	(gpr_rd_data_1_i	),
		.gpr_rd_addr_0_o	(gpr_rd_addr_0_o	),
		.gpr_rd_addr_1_o	(gpr_rd_addr_1_o	),
		
		/*signals transfered from ID stage*/
		.id_en_i			(id_en_o			),
		.id_dst_addr		(id_dst_addr_o		),	//write address
		.id_gpr_wre_i		(id_gpr_wre_o		),	//wire enable
		.id_mem_op_i		(id_mem_op_o		),	//memory operator
		
		/*signals transfered from EX stage*/
		.exe_en_i			(exe_en_i			),
		.exe_dst_addr_i		(exe_dst_addr_i		),
		.exe_gpr_wre_i		(exe_gpr_wre_i		),
		.exe_fwd_data_i		(exe_fwd_data_i		),
		.mem_fwd_data_i		(mem_fwd_data_i		),
		
		/*control register signal*/
		.exe_mode_i			(exe_mode_i			),
		.creg_rd_data_i		(creg_rd_data_i		),
		.creg_rd_addr_o		(creg_rd_addr_o		),
		
		.alu_op_o			(alu_op_o			),		//ALU operation code
		.alu_in_0_o			(alu_in_0_o			),		
		.alu_in_1_o			(alu_in_1_o			),
		.br_addr_o			(br_addr_o			),
		.br_taken_o			(br_taken_o			),
		.br_flag_o			(br_flag_o			),
		.mem_op_o			(mem_op_o			),
		.mem_wr_data_o		(mem_wr_data_o		),
		.ctrl_op_o			(ctrl_op_o			),
		.dst_addr_o			(dst_addr_o			),
		.gpr_wre_o			(gpr_wre_o			),
		.exp_code_o			(exp_code_o			),
		.ld_hzazrd_o		(ld_hzazrd_o)	//load race
	);

module #(
		.ALU_OP_BUS 	(ALU_OP_BUS		),
		.ID_DAT_WIDTH 	(ID_DAT_WIDTH	),
		.ID_ADD_WIDTH 	(ID_ADD_WIDTH	),
		.MEM_OP_BUS 	(MEM_OP_BUS		),
		.CTRL_OP_BUS 	(CTRL_OP_BUS 	),
		.REG_ADD_BUS 	(REG_ADD_BUS 	),
		.ISA_EXP_BUS 	(ISA_EXP_BUS 	)
	)(
		.clk_i				(clk_i				),
		.rst_n_i			(rst_n_i			),
		/*decode result input port*/
		.alu_op_i			(alu_op_o			),
		.alu_in_0_i			(alu_in_0_o			),
		.alu_in_1_i			(alu_in_1_o			),
		.br_flag_i			(br_flag_o			),
		.mem_op_i			(mem_op_o			),
		.mem_wr_data_i		(mem_wr_data_o		),
		.ctrl_op_i			(ctrl_op_o			),
		.dst_addr_i			(dst_addr_o			),
		.gpr_wre_i			(gpr_wre_o			),
		.exp_code_i			(exp_code_o			),
		/*pipline control signal*/
		.stall_i			(stall_i			),
		.flush_i			(flush_i			),
		/*IF->ID pipline reg*/
		.if_pc_i			(if_pc_i			),
		.if_en_i			(if_en_i			),
		/*ID->EX*/	
		.id_pc_o			(id_pc_o			),
		.id_en_o			(id_en_o			),
		.id_alu_op_o		(id_alu_op_o		),
		.id_alu_in_0_o		(id_alu_in_0_o		),
		.id_alu_in_1_o		(id_alu_in_1_o		),
		.id_br_flag_o		(id_br_flag_o		),
		.id_mem_op_o		(id_mem_op_o		),
		.id_mem_wr_data_o	(id_mem_wr_data_o	),
		.id_ctrl_op_o		(id_ctrl_op_o		),
		.id_dst_addr_o		(id_dst_addr_o		),
		.id_gpr_wre_o		(id_gpr_wre_o		),
		.id_exp_code_o		(id_exp_code_o		)
	);
endmodule

