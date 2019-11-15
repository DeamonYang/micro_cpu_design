`timaecale 1ns/1ps
/****************************************************************
@file name	: bus_if.sv
@description: system bus interface control CPU access bus
=================================================================
revision		data		author		commit
  0.1		2019/11/13	  deamonyang	draft
****************************************************************/

module bus_if#(
		parameter BUS_ADD_WIDTH = 30,
		parameter BUS_DAT_WIDTH = 32,
		parameter BUS_SLAV_WIDTH = 3
	)(
		input	wire						clk_i,
		input	wire						rst_n_i,
				
		/*pipline state signal*/		
		input	wire						pip_stall_i,
		input	wire						pip_flush_i,
		output	logic						pip_busy_o,
		
		/*cpu interface*/
		input	wire	[BUS_ADD_WIDTH-1:0]	cpu_addr_i,		//address bus
		input	wire						cpu_acs_i,		//address selsct
		input	wire						cpu_rw_i,	
		input	wire	[BUS_DAT_WIDTH-1:0]	cpu_wr_data_i,	//write data input
		output	logic	[BUS_DAT_WIDTH-1:0]	cpu_rd_data_o,	//output data port
		
		/*SPM interface*/
		input	wire	[BUS_DAT_WIDTH-1:0]	spm_rd_data_i,
		output	logic	[BUS_ADD_WIDTH-1:0]	spm_addr_o,
		output	logic						spm_as_o,
		output	logic						spm_rw_o,
		output	logic	[BUS_DAT_WIDTH-1:0]	spm_wr_data_o,
		
		/*system bus interface*/
		input	wire	[BUS_DAT_WIDTH-1:0]	bus_rd_data_i,
		input	wire						bus_rdy_i,
		input	wire						bus_grnt_i,
		output	logic						bus_req_o,
		output	logic	[BUS_ADD_WIDTH-1:0]	bus_addr_o,
		output 	logic						bus_as_o,
		output 	logic						bus_rw_o,		//bus read == 1'b1 / write == 1'b0 
		output	logic	[BUS_DAT_WIDTH-1:0]	bus_wr_data_o
	);
	
	localparam	ST_IDEL = 2'b00;
	localparam	ST_REQ	= 2'b01;
	localparam	ST_ACC	= 2'b10;
	localparam	ST_DLY	= 2'b11;
	
	localparam	BUS_SLAVE_NO1 = 3'd1;//SMP
	
	
	logic	[BUS_SLAV_WIDTH-1:0] 	slava_index;
	logic	[1:0]					state;
	logic	[BUS_DAT_WIDTH-1:0]		rd_buf;
	
	/*decode for slave id*/
	assign slava_index = cpu_addr_i[BUS_ADD_WIDTH-1:BUS_ADD_WIDTH-BUS_SLAV_WIDTH];
	
	always_ff@(posedge clk_i or negedge rst_n_i)
	if(!rst_n_i)begin
		state <= ST_IDEL;
		bus_req_o <= 1'b0;
		bus_addr_o <= 'd0;
		bus_as_o <= 1'b0;
		bus_rw_o <= 1'b1; //read
		bus_wr_data_o <= 'd0;
		rd_buf <= 'd0;
	end else begin
		case(state)
			ST_IDEL	:begin
				if((~pip_flush_i) && (cpu_acs_i)&&(slava_index != BUS_SLAVE_NO1))begin//except slave 1
					state <= ST_REQ;
					bus_req_o <= 1'b1;
					bus_addr_o <= cpu_addr_i;
					bus_rw_o <= cpu_rw_i;
					bus_wr_data_o <= cpu_wr_data_i;
				end
			end
			
			ST_REQ	:begin
				if(bus_grnt_i)begin //grant the bus
					state <= ST_ACC;
					bus_as_o <= 1'b1;
				end
			end
			
			ST_ACC	:begin
				bus_as_o <= 1'b1;
				if(bus_rdy_i)begin
					bus_req_o <= 1'b0;
					bus_addr_o <= 1'b0;
					bus_rw_o <= 1'b1;
					bus_wr_data_o <= 'd0;
					
					if(bus_rw_o)begin
						rd_buf <= bus_rd_data_i;
					end
					
					if(pip_stall_i)
						state <= ST_DLY;
					else
						state <= ST_IDEL;
				end
			end
			ST_DLY	:begin
				if(!pip_stall_i)
					state <= ST_IDEL;
				else
					state <= state;
			end
			
		endcase
	end
	
	always_comb@(*)begin
		cpu_rd_data_o = 'd0;
		spm_as_o = 1'b0;
		pip_busy_o = 1'b0;
		
		case(state)
			ST_IDEL:begin
				if((~pip_flush_i) && (cpu_acs_i))begin
					if(slava_index == BUS_SLAVE_NO1)begin //access spm 
						if(~pip_stall_i)begin
							spm_as_o = 1'b1;
							if(cpu_rw_i)
								cpu_rd_data_o = spm_rd_data_i;
						end
					end else begin
						pip_busy_o = 1'b1;
					end
				end
			end
			
			ST_REQ	:begin
				pip_busy_o = 1'b1;
			end
			
			ST_ACC	:begin
				if(bus_rdy_i)begin
					if(cpu_rw_i)begin
						cpu_rd_data_o = bus_rd_data_i;
					end
				end else begin
					pip_busy_o = 1'b1;
				end
			end
			
			ST_DLY	:begin
				if(cpu_rw_i)begin
					cpu_rd_data_o = rd_buf;
				end
			end
		endcase
	
	end
	
	
	

endmodule
