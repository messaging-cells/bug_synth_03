
`include "hglobal.v"

`default_nettype	none

module nd_1to2
#(parameter 
	OPER_1=`NS_GT_OP, 
	REF_VAL_1=0, 
	IS_RANGE=`NS_FALSE, 
	OPER_2=`NS_GT_OP, 
	REF_VAL_2=0, 
	
	FSZ=`NS_1to2_FSZ, 
	ASZ=`NS_ADDRESS_SIZE, 
	DSZ=`NS_DATA_SIZE, 
	RSZ=`NS_REDUN_SIZE
)(
	input wire i_clk,
	input wire out_clk,
	input wire reset,
	output wire ready,
	
	`NS_DECLARE_OUT_CHNL(snd0),
	`NS_DECLARE_IN_CHNL(rcv0),
	
	`NS_DECLARE_DBG_CHNL(dbg)
);
	`NS_DECLARE_REG_DBG(rg_dbg)
	reg [DSZ-1:0] out0_ck_dat = 15;
	reg [0:0] out0_did_ck = 0;
	
	reg [0:0] rg_rdy = `NS_OFF;

	// out1 regs
	`NS_DECLARE_REG_MSG(rgo0)
	reg [0:0] rgo0_req = `NS_OFF;
	reg [0:0] rgo0_busy = `NS_OFF;
	reg [0:0] rgo0_added_hd = `NS_OFF;

	// inp regs
	reg [0:0] rgi0_ack = `NS_OFF;

	// fifos
	`NS_DECLARE_FIFO(bf0)

	always @(posedge i_clk)
	begin
		if(reset) begin
			rg_rdy <= `NS_OFF;
		end
		if(! reset && ! rg_rdy) begin
			rg_rdy <= `NS_ON;
			
			`NS_REG_MSG_INIT(rgo0)
			rgo0_req <= `NS_OFF;
			rgo0_busy = `NS_OFF;
			rgo0_added_hd = `NS_OFF;
			
			rgi0_ack <= `NS_OFF;
			
			`NS_FIFO_INIT(bf0)
		end
		if(! reset && rg_rdy) begin
			if(rcv0_req && (! rgi0_ack)) begin
				//`NS_FIFO_TRY_ADD_HEAD(bf0, rcv0, rgo0_added_hd);
				//if((REF_VAL_1) > (rcv0_dst)) begin
				//if(`NS_RANGE_CMP_OP(IS_RANGE, OPER_1, REF_VAL_1, rcv0_dst, OPER_2, REF_VAL_2, rcv0_dst)) begin
				if(`NS_CMP_OP(OPER_1, REF_VAL_1, rcv0_dst)) begin
					`NS_FIFO_TRY_ADD_HEAD(bf0, rcv0, rgo0_added_hd);
				end 
				else begin
					rg_dbg_leds[1:1] <= 1;
				end
			end
			
			`NS_FIFO_ACK_ADDED_HEAD(bf0, rgi0_ack, rgo0_added_hd)
			
			`NS_FIFO_TRY_SET_OUT(bf0, rgo0, snd0_ack, rgo0_req, rgo0_busy);
			
			
			if(rgo0_busy && ! out0_did_ck && (rg_dbg_leds[0:0] == 0)) begin 
				out0_did_ck <= 1;
				if(out0_ck_dat == 15) begin
					out0_ck_dat <= rgo0_dat;
				end
				else begin
					if(out0_ck_dat == rgo0_dat) begin
						rg_dbg_leds[0:0] = 1;
						rg_dbg_disp0 <= out0_ck_dat[3:0];
						rg_dbg_disp1 <= rgo0_dat[3:0];
					end
					else begin
						out0_ck_dat <= rgo0_dat;
					end
				end
			end
			if(! rgo0_busy && out0_did_ck) begin
				out0_did_ck <= 0;
			end
			
			if((! rcv0_req) && rgi0_ack) begin
				rgi0_ack <= `NS_OFF;
			end
		end
	end

	/*
	always @(posedge out_clk)
	begin
		if(i0_req && (! inp0_ack)) begin
			inp0_ack <= `NS_ON;
		end
		//else
		if((! i0_req) && inp0_ack) begin
			inp0_ack <= `NS_OFF;
		end
	end
	*/
	
	assign ready = rg_rdy;
	
	//out1
	`NS_ASSIGN_OUT_MSG(snd0, rgo0)
	assign snd0_req = rgo0_req;

	//inp0
	assign rcv0_ack = rgi0_ack;

	`NS_ASSIGN_OUT_DBG(dbg, rg_dbg)
	
endmodule

