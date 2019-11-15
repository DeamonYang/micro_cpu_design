`timaecale 1ns/1ps
/****************************************************************
@file name	: decoder.sv
@description: instruction decoder
=================================================================
revision		data		author		commit
  0.1		2019/11/13	  deamonyang	draft
****************************************************************/
`include "cpu.h"
`include "isa.h"
module decoder#(
		parameter DE_ADD_WIDTH = 30,
		parameter DE_DAT_WIDTH = 32,
		parameter REG_ADD_WIDTH = 5,
		parameter MEM_OP_BUS = 2,
		parameter CPU_EXE_MODE = 1,
		parameter ALU_OP_BUS = 4,
		parameter CTRL_OP_BUS = 2,
		parameter ISA_EXP_BUS = 3
	)(
		input	wire	[DE_ADD_WIDTH-1:0]		if_pc_i,	//pc pointer
		input	wire	[DE_DAT_WIDTH-1:0]		if_insn_i,	//instruction code
		input	wire							if_en_i,	//instruction valid
		
		/*gpr interface*/
		input	wire	[DE_DAT_WIDTH-1:0]		gpr_rd_data_0_i,
		input	wire	[DE_DAT_WIDTH-1:0]		gpr_rd_data_1_i,
		output	logic	[REG_ADD_WIDTH-1:0]		gpr_rd_addr_0_o,
		output	logic	[REG_ADD_WIDTH-1:0]		gpr_rd_addr_1_o,
		
		/*signals transfered from ID stage*/
		input	wire							id_en_i,
		input	wire	[REG_ADD_WIDTH-1:0]		id_dst_addr,	//write address
		input	wire							id_gpr_wre_i,	//wire enable
		input	wire	[MEM_OP_BUS-1:0]		id_mem_op_i,	//memory operator
		
		/*signals transfered from EX stage*/
		input	wire							exe_en_i,
		input	wire	[REG_ADD_WIDTH-1:0]		exe_dst_addr_i,
		input	wire							exe_gpr_wre_i,
		input	wire	[DE_DAT_WIDTH-1:0]		exe_fwd_data_i,
		
		input	wire	[DE_DAT_WIDTH-1:0]		mem_fwd_data_i,
		
		/*control register signal*/
		input	wire	[CPU_EXE_MODE-1:0]		exe_mode_i,
		input	wire	[DE_DAT_WIDTH-1:0]		creg_rd_data_i,
		output	logic	[REG_ADD_WIDTH-1:0]		creg_rd_addr_o,
		
		output	logic	[ALU_OP_BUS-1:0]		alu_op_o,		//ALU operation code
		output	logic	[DE_DAT_WIDTH-1:0]		alu_in_0_o,		
		output	logic	[DE_DAT_WIDTH-1:0]		alu_in_1_o,
		output	logic	[DE_ADD_WIDTH-1:0]		br_addr_o,
		output	logic							br_taken_o,
		output	logic							br_flag_o,
		output	logic	[MEM_OP_BUS-1:0]		mem_op_o,
		output	logic	[DE_DAT_WIDTH-1:0]		mem_wr_data_o,
		output	logic	[CTRL_OP_BUS-1:0]		ctrl_op_o,
		output	logic	[REG_ADD_WIDTH-1:0]		dst_addr_o,
		output	logic							gpr_wre_o,
		output	logic	[ISA_EXP_BUS-1:0]		exp_code_o,
		output	logic							ld_hzazrd_o	//load race
	);
	
	parameter	ISA_OP_BUS = 6;
	parameter	ISA_IMM_BUS = 16;

	/*instruction sub-port*/
	logic	[ISA_OP_BUS-1:0]		op 		= if_insn_i[`IsaOpLoc];		//operation code
	logic	[REG_ADD_WIDTH-1:0]		ra_addr = if_insn_i[`IsaRaAddrLoc];	//ra address
	logic	[REG_ADD_WIDTH-1:0]		rb_addr = if_insn_i[`IsaRbAddrLoc];	//rb address
	logic	[REG_ADD_WIDTH-1:0]		rc_addr = if_insn_i[`IsaRcAddrLoc];	//rc address	
	logic	[ISA_IMM_BUS-1:0]		imm		= if_insn_i[`IsaImmLoc];	//immediate data

	/*symbol bit extension of immediate data*/
	logic	[DE_DAT_WIDTH-1:0]		imm_s = {{(DE_DAT_WIDTH-ISA_IMM_BUS){imm[ISA_IMM_BUS-1]}},imm}; //signed data
	logic	[DE_DAT_WIDTH-1:0]		imm_u = {{(DE_DAT_WIDTH-ISA_IMM_BUS){1'b0}},imm};//unsigned data

	logic unsigned	[DE_DAT_WIDTH-1:0]		ra_data;
	logic signed	[DE_DAT_WIDTH-1:0]		s_ra_data = $signed(ra_data);
	logic unsigned	[DE_DAT_WIDTH-1:0]		rb_data;
	logic signed	[DE_DAT_WIDTH-1:0]		s_rb_data = $signed(rb_data);

	/*address generate*/
	logic	[DE_ADD_WIDTH-1:0]		ret_addr = if_pc_i + 1'b1;//return address
	logic	[DE_ADD_WIDTH-1:0]		br_target = if_pc_i + imm_s[ISA_IMM_BUS-1];//break address
	logic	[DE_ADD_WIDTH-1:0]		jr_target = ra_data[31:2];

	/*address of register*/
	assign gpr_rd_addr_0_o = ra_addr;
	assign gpr_rd_addr_1_o = rb_addr;
	assign creg_rd_addr_o = ra_addr;
	
	always_comb@(*)begin
		if((id_en_i & id_gpr_wre_i)&&(id_dst_addr == ra_addr))
			ra_data = exe_fwd_data_i;	//read data from exe stage
		else if((id_en_i & id_gpr_wre_i)&&(exe_dst_addr_i == ra_addr))
			ra_data = mem_fwd_data_i;	//read data from mem stage
		else
			ra_data = gpr_rd_data_0_i;	//read data from register
	end

	always_comb@(*)begin
		if((id_en_i & id_gpr_wre_i)&&(id_dst_addr == rb_addr))
			rb_data = exe_fwd_data_i;	//read data from exe stage
		else if((id_en_i & id_gpr_wre_i)&&(exe_dst_addr_i == rb_addr))
			rb_data = mem_fwd_data_i;	//read data from mem stage
		else
			rb_data = gpr_rd_data_0_i;	//read data from register
	end
	
	/*check load hzazrd*/
	always_comb@(*)begin
		if((id_en_i)&&(id_mem_op_i) && ((id_dst_addr == ra_addr) || (id_dst_addr == rb_addr) ))
			ld_hzazrd_o = 1'b1;
		else
			ld_hzazrd_o = 1'b0;
		
	end
	
	/*decode*/

	always_comb@(*)begin
		alu_op_o = `ALU_OP_NOP;
		alu_in_0_o = ra_data;
		alu_in_1_o = rb_data;
		br_taken_o = 1'b0;
		br_flag_o = 1'b0;
		br_addr_o = 'd0;
		mem_op_o = `MEM_OP_NOP;
		ctrl_op_o = `CTRL_OP_NOP;
		dst_addr_o = rb_addr;
		gpr_wre_o = 1'b0;
		exp_code_o = `ISA_EXP_NO_EXP;
		if(if_en_i) begin
			case(op)
				/*logical operation*/
				`ISA_OP_ANDR	:begin //ANDR =  reg & reg 
					alu_op = `ALU_OP_AND; 
					dst_addr_o = rc_addr;
					gpr_wre_o = 1'b1;
				end	 
				
				`ISA_OP_ANDI    :begin //ANDI = reg & imm
					alu_op = `ALU_OP_AND;
					alu_in_1_o = imm_u;
					gpr_wre_o = 1'b1;
				end
				
				`ISA_OP_ORR	    :begin  //ORR = reg | reg
					alu_op = `ALU_OP_OR;
					dst_addr_o = rc_addr;
					gpr_wre_o = 1'b1;
				end
				
				`ISA_OP_ORI	    :begin //ORI = reg | imm_u
					alu_op = `ALU_OP_OR; 
					alu_in_1_o = imm_u;
					gpr_wre_o = 1'b1;
				end
				`ISA_OP_XORR	:begin //XORR = reg ^ reg
					alu_op = `ALU_OP_XOR; 
					dst_addr_o = rc_addr;
					gpr_wre_o = 1'b1;
				end
				`ISA_OP_XORI	:begin //XORI = reg ^ immu
					alu_op = `ALU_OP_XOR; 
					alu_in_1_o = imm_u; 
					gpr_wre_o = 1'b1; 
				end
				
				/*arithmetic operation*/
				`ISA_OP_ADDSR   :begin // ADDSR  = reg + reg (signed op)
					alu_op = `ALU_OP_ADDS; 
					dst_addr_o = rc_addr;
					gpr_wre_o = 1'b1; 
				end
				
				`ISA_OP_ADDSI   :begin //ADDSI = reg + imm_s (signed op)
					alu_op = `ALU_OP_ADDS;
					alu_in_1_o = imm_s;
					gpr_wre_o = 1'b1; 
				end
				
				`ISA_OP_ADDUR   :begin //ADDUR = reg + reg (unsigned op)
					alu_op = `ALU_OP_ADDU; 
					dst_addr_o = rc_addr;					
					gpr_wre_o = 1'b1; 
				end
				
				`ISA_OP_ADDUI   :begin //ADDSI = reg + imm_u (unsigned op)
					alu_op = `ALU_OP_ADDU;
					alu_in_1_o = imm_u;
					gpr_wre_o = 1'b1; 
				end

				`ISA_OP_SUBSR   :begin //SUBSR = reg - reg (signed op)
					alu_op = `ALU_OP_SUBS;
					dst_addr_o = rc_addr;
					gpr_wre_o = 1'b1; 
				end

				`ISA_OP_SUBUR   :begin //SUBUR = reg - imm_u (unsigned op)
					alu_op = `ALU_OP_SUBU;
					dst_addr_o = rc_addr;
					gpr_wre_o = 1'b1; 
				end
				
				/*shift operation*/
				`ISA_OP_SHRLR   :begin 
					alu_op = `ALU_OP_SHRL; //register logic shifted right
					dst_addr_o = rc_addr;
					gpr_wre_o = 1'b1; 
				end

				`ISA_OP_SHRLI   :begin 	//reg logic shifted right with imm_u
					alu_op = `ALU_OP_SHRL;
					alu_in_1_o = imm_u;
					gpr_wre_o = 1'b1; 
				end

				`ISA_OP_SHLLR   :begin //register logic shifted left
					alu_op = `ALU_OP_SHLL; 
					dst_addr_o = rc_addr;
					gpr_wre_o = 1'b1; 
				end

				`ISA_OP_SHLLI   :begin //reg logic shifted left with imm_u
					alu_op = `ALU_OP_SHLL;
					alu_in_1_o = imm_u;
					gpr_wre_o = 1'b1;
				end

				/*branch instruction*/
				`ISA_OP_BE	    :begin // ra == rb
					br_addr_o = br_target;
					br_taken_o = (ra_data == rb_data)? 1'b1 : 1'b0;
					br_flag_o = 1'b1;
				end

				`ISA_OP_BNE	    :begin 
					br_addr_o = br_target;
					br_taken_o = (ra_data != rb_data)? 1'b1 : 1'b0;
					br_flag_o = 1'b1;
				end

				`ISA_OP_BSGT	:begin 	//sra < srb
					br_addr_o = br_target;
					br_taken_o = (s_ra_data < s_rb_data)? 1'b1 : 1'b0;
					br_flag_o = 1'b1;
				end

				`ISA_OP_BUGT	:begin 
					br_addr_o = br_target;
					br_taken_o = (ra_data < rb_data)? 1'b1 : 1'b0;
					br_flag_o = 1'b1;
				end

				`ISA_OP_JMP	    :begin 
					br_addr_o = jr_target;
					br_taken_o = 1'b1;
					br_flag_o = 1'b1;
				end

				`ISA_OP_CALL	:begin 
					alu_in_0_o = {ret_addr,{(DE_DAT_WIDTH-DE_ADD_WIDTH){1'b0}}};
					br_addr_o = jr_target;
					br_taken_o = 1'b1;
					br_flag_o = 1'b1;
					dst_addr_o = 'd31;
					gpr_wre_o = 1'b1;
				end
				
				/*memory access*/
				`ISA_OP_LDW	    :begin 
					alu_op = `ALU_OP_ADDU;
					alu_in_1_o = imm_s;
					mem_op_o = `MEM_OP_LDW;
					gpr_wre_o = 1'b1;
				end

				`ISA_OP_STW	    :begin 
					alu_op = `ALU_OP_ADDU;
					alu_in_1_o = imm_s;
					mem_op_o = `MEM_OP_STW;
				end
				
				/*system call*/
				`ISA_OP_TRAP	:begin 
					exp_code = `ISA_EXP_TRAP;
				end
				
				/*super instruction*/
				`ISA_OP_RDCR	:begin //read control register
					if(exe_mode_i == `CPU_KERNEL_MODE)begin
						alu_in_0_o = creg_rd_data_i;
						gpr_wre_o = 1'b1;
					end else begin
						exp_code = `ISA_EXP_PRV_VIO;
					end
				end

				`ISA_OP_WRCR	:begin //write control reg
					if(exe_mode_i == `CPU_KERNEL_MODE)
						ctrl_op_o = `CTRL_OP_WRCR;
					else
						ctrl_op_o = `ISA_EXP_PRV_VIO;
				end

				`ISA_OP_EXRT	:begin 
					if(exe_mode_i == `CPU_KERNEL_MODE)
						ctrl_op_o = `CTRL_OP_EXPT;
					else
						exp_code = `ISA_EXP_PRV_VIO;
				end
		end
	end
	

endmodule 

































