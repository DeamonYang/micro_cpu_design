`timescale 1ns/1ps

module bus#(
		parameter DAT_WIDTH = 32,
		parameter ADD_WIDTH = 32
	)(
		input	wire					clk_i,
		input	wire					rst_n_i,
		
		/*Master common signal*/
		output	logic	[DAT_WIDTH-1:0]	m_rd_data_o,
		output	logic					m_rdy_o
		
		/*interface of master 0*/
		input	wire					m0_req_i,		//request for bus
		input	wire	[ADD_WIDTH-1:0] m0_addr_i,		//address
		input	wire					m0_addr_cs_i,	//address valid
		input	wire					m0_rw_i,		//read/write
		input	wire	[DAT_WIDTH-1:0] m0_wr_data_i,	//write data
		output	logic					m0_grnt_o,		//grant the bus
	
		/*interface of master 1*/
		input	wire					m1_req_i,		//request for bus
		input	wire	[ADD_WIDTH-1:0] m1_addr_i,		//address
		input	wire					m1_addr_cs_i,	//address valid
		input	wire					m1_rw_i,		//read/write
		input	wire	[DAT_WIDTH-1:0] m1_wr_data_i,	//write data
		output	logic					m1_grnt_o,		//grant the bus	
		
		/*interface of master 2*/
		input	wire					m2_req_i,		//request for bus
		input	wire	[ADD_WIDTH-1:0] m2_addr_i,		//address
		input	wire					m2_addr_cs_i,	//address valid
		input	wire					m2_rw_i,		//read/write
		input	wire	[DAT_WIDTH-1:0] m2_wr_data_i,	//write data
		output	logic					m2_grnt_o,		//grant the bus	
		
		/*interface of master 3*/
		input	wire					m3_req_i,		//request for bus
		input	wire	[ADD_WIDTH-1:0] m3_addr_i,		//address
		input	wire					m3_addr_cs_i,	//address valid
		input	wire					m3_rw_i,		//read/write
		input	wire	[DAT_WIDTH-1:0] m3_wr_data_i,	//write data
		output	logic					m3_grnt_o,		//grant the bus	
		
		/*common signal for slaver*/
		output	logic	[ADD_WIDTH-1:0]	s_addr_o,
		output	logic					s_addr_cs_o,
		output	logic					s_rw_o,
		output	logic	[DAT_WIDTH-1:0] s_data_o,	
		
		
		/*interface of slaver 0*/
		input	wire	[DAT_WIDTH-1:0]	s0_rd_data_i,	//read data bus
		input	wire					s0_rdy_i,		//slave ready for output data
		output	logic					s0_cs_o,		//chip select for slaver
		
		/*interface of slaver 1*/
		input	wire	[DAT_WIDTH-1:0]	s1_rd_data_i,	//read data bus
		input	wire					s1_rdy_i,		//slave ready for output data
		output	logic					s1_cs_o,		//chip select for slaver
		
		/*interface of slaver 0*/
		input	wire	[DAT_WIDTH-1:0]	s2_rd_data_i,	//read data bus
		input	wire					s2_rdy_i,		//slave ready for output data
		output	logic					s2_cs_o,		//chip select for slaver
		
		/*interface of slaver 0*/
		input	wire	[DAT_WIDTH-1:0]	s3_rd_data_i,	//read data bus
		input	wire					s3_rdy_i,		//slave ready for output data
		output	logic					s3_cs_o,		//chip select for slaver
		
		/*interface of slaver 0*/
		input	wire	[DAT_WIDTH-1:0]	s4_rd_data_i,	//read data bus
		input	wire					s4_rdy_i,		//slave ready for output data
		output	logic					s4_cs_o,		//chip select for slaver
		
		/*interface of slaver 0*/
		input	wire	[DAT_WIDTH-1:0]	s5_rd_data_i,	//read data bus
		input	wire					s5_rdy_i,		//slave ready for output data
		output	logic					s5_cs_o,		//chip select for slaver
		
		/*interface of slaver 0*/
		input	wire	[DAT_WIDTH-1:0]	s6_rd_data_i,	//read data bus
		input	wire					s6_rdy_i,		//slave ready for output data
		output	logic					s6_cs_o,		//chip select for slaver
		
		/*interface of slaver 0*/
		input	wire	[DAT_WIDTH-1:0]	s7_rd_data_i,	//read data bus
		input	wire					s7_rdy_i,		//slave ready for output data
		output	logic					s7_cs_o,		//chip select for slaver
	);
	
	
	bus_master_mux#(
		.BUS_ADD_WIDTH(DAT_WIDTH),
		.BUS_DAT_WIDTH(ADD_WIDTH)
	)bus_master_mux_ins(
		.m0_addr_i		(m0_addr_i		),		//master address bus
		.m0_addr_cs_i	(m0_addr_cs_i	),		//address chip select
		.m0_rw_i		(m0_rw_i		),		//read/write
		.m0_wr_data_i	(m0_wr_data_i	),		//data bus
		.m0_grnt_i		(m0_grnt_i		),		//grant bus signal generate from arbiter
		.m1_addr_i		(m1_addr_i		),		//master address bus
		.m1_addr_cs_i	(m1_addr_cs_i	),		//address chip select
		.m1_rw_i		(m1_rw_i		),		//read/write
		.m1_wr_data_i	(m1_wr_data_i	),		//data bus
		.m1_grnt_i		(m1_grnt_i		),		//grant bus signal generate from arbiter
		.m2_addr_i		(m2_addr_i		),		//master address bus
		.m2_addr_cs_i	(m2_addr_cs_i	),		//address chip select
		.m2_rw_i		(m2_rw_i		),		//read/write
		.m2_wr_data_i	(m2_wr_data_i	),		//data bus
		.m2_grnt_i		(m2_grnt_i		),		//grant bus signal generate from arbiter
		.m3_addr_i		(m3_addr_i		),		//master address bus
		.m3_addr_cs_i	(m3_addr_cs_i	),		//address chip select
		.m3_rw_i		(m3_rw_i		),		//read/write
		.m3_wr_data_i	(m3_wr_data_i	),		//data bus
		.m3_grnt_i		(m3_grnt_i		),		//grant bus signal generate from arbiter
		
		.s_addr_o		(s_addr_o		),		//master address bus
		.s_addr_cs_o	(s_addr_cs_o	),		//address chip select
		.s_rw_o			(s_rw_o			),			//read/write
		.s_data_o		(s_data_o		)		//data bus
	);
	
	
	bus_slave_mux#(
		.DATA_BUS_WIDTH(DAT_WIDTH)
	)bus_slave_mux_inst(
		.s0_cs_i		(s0_cs_o		),
		.s1_cs_i		(s1_cs_o		),
		.s2_cs_i		(s2_cs_o		),
		.s3_cs_i		(s3_cs_o		),
		.s4_cs_i		(s4_cs_o		),
		.s5_cs_i		(s5_cs_o		),
		.s6_cs_i		(s6_cs_o		),
		.s7_cs_i		(s7_cs_o		),		
		.s0_rd_data_i	(s0_rd_data_i	),
		.s0_rdy_i		(s0_rdy_i		),		
		.s1_rd_data_i	(s1_rd_data_i	),
		.s1_rdy_i		(s1_rdy_i		),			
		.s2_rd_data_i	(s2_rd_data_i	),
		.s2_rdy_i		(s2_rdy_i		),			
		.s3_rd_data_i	(s3_rd_data_i	),
		.s3_rdy_i		(s3_rdy_i		),			
		.s4_rd_data_i	(s4_rd_data_i	),
		.s4_rdy_i		(s4_rdy_i		),			
		.s5_rd_data_i	(s5_rd_data_i	),
		.s5_rdy_i		(s5_rdy_i		),			
		.s6_rd_data_i	(s6_rd_data_i	),
		.s6_rdy_i		(s6_rdy_i		),			
		.s7_rd_data_i	(s7_rd_data_i	),
		.s7_rdy_i		(s7_rdy_i		),		
		.m_rd_data_o	(m_rd_data_o	),
		.m_rdy_o		(m_rdy_o		)	
	);
	
	bus_addr_dec#(
		.ADDR_WIDTH		(ADD_WIDTH)
		.ADDR_IDX_WIDTH	(3)
	)bus_addr_dec_ins(
		.s_addr_i	(s_addr_o	),
		.s0_cs_o	(s0_cs_o	),
		.s1_cs_o	(s1_cs_o	),
		.s2_cs_o	(s2_cs_o	),
		.s3_cs_o	(s3_cs_o	),
		.s4_cs_o	(s4_cs_o	),
		.s5_cs_o	(s5_cs_o	),
		.s6_cs_o	(s6_cs_o	),
		.s7_cs_o	(s7_cs_o	)
	);
	
endmodule
