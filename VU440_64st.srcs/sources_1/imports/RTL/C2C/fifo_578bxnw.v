//------------------------------------------------------------------------------
// FIFO_578bxNw MODEL
//------------------------------------------------------------------------------
// FIFO モジュール
// (1) FIFO__578bxNw
//------------------------------------------------------------------------------
// Revision 00
// Level    01
//------------------------------------------------------------------------------
// File           : fifo_578bxnw.v
// Module         : FIFO_578BXNW
//------------------------------------------------------------------------------
// Rev.Level     Date    Cause Coded        Contents
// 00.01     2020/08/31     00              F.T)O.Aihara
//------------------------------------------------------------------------------
// 00.01     2020/08/31                     F.T)O.Aihara new

`timescale 1 ps / 1 ps

module FIFO_578BXNW # (
					parameter	FIFO_WORD		=	8	// 
				) (
					RST_N,								// 
					WCLK,								// 
					WREN,								// 
					WDATA,								// 
					FULL,								// 
					RCLK,								// 
					RDEN,								// 
					RDATA,								// 
					EMPTY								// 
	);


//------------------------------------------------------------------------------
// I/O signals
//------------------------------------------------------------------------------
	input					RST_N;						// 
	input					WCLK;						// 
	input					WREN;						// 
	input	[577:0]			WDATA;						// 
	output					FULL;						// 
	input					RCLK;						// 
	input					RDEN;						// 
	output	[577:0]			RDATA;						// 
	output					EMPTY;						// 


//------------------------------------------------------------------------------
// wires
//------------------------------------------------------------------------------
	wire					s_full;						// 
	wire	[FIFO_WORD-1:0]	s_set_flg_rstn;				// 
	wire					s_empty;					// 
	wire	[FIFO_WORD-1:0]	s_clr_flg_rstn;				// 
	wire	[577:0]			s_rdata;					// 


//------------------------------------------------------------------------------
// reges
//------------------------------------------------------------------------------
	(* ram_style = "register" *)	reg	[577:0]	sr_wdata0[0:7];// 
	(* ram_style = "register" *)	reg	[577:0]	sr_wdata1[0:7];// 
	(* ram_style = "register" *)	reg	[577:0]	sr_wdata2[0:7];// 
	(* ram_style = "register" *)	reg	[577:0]	sr_wdata3[0:7];// 
	(* ram_style = "register" *)	reg	[577:0]	sr_wdata4[0:7];// 
	(* ram_style = "register" *)	reg	[577:0]	sr_wdata5[0:7];// 
	(* ram_style = "register" *)	reg	[577:0]	sr_wdata6[0:7];// 
	(* ram_style = "register" *)	reg	[577:0]	sr_wdata7[0:7];// 
	reg		[5:0]			sr_wcnt;					// 
	reg		[FIFO_WORD-1:0]	sr_wr_flg;					// 
	reg		[FIFO_WORD-1:0]	sr_set_flg;					// 
	reg		[FIFO_WORD-1:0]	sr_clr_sync;				// 
	reg		[FIFO_WORD-1:0]	sr_clr;						// 
	reg		[5:0]			sr_rcnt;					// 
	reg		[FIFO_WORD-1:0]	sr_rd_flg;					// 
	reg		[FIFO_WORD-1:0]	sr_clr_flg;					// 
	reg		[FIFO_WORD-1:0]	sr_set_sync;				// 
	reg		[FIFO_WORD-1:0]	sr_set;						// 


//------------------------------------------------------------------------------
// integer
//------------------------------------------------------------------------------
	integer					bc;


//------------------------------------------------------------------------------
// define
//------------------------------------------------------------------------------
// Not Used


//------------------------------------------------------------------------------
// Call Submodule
//------------------------------------------------------------------------------
// Not Used


//------------------------------------------------------------------------------
// Logic
//------------------------------------------------------------------------------
	assign		FULL					=		s_full;

	assign		RDATA[577:0]			=		s_rdata[577:0];
	assign		EMPTY					=		s_empty;


//------------------------------------------------------------------------------
// ライトFIFO制御部
//------------------------------------------------------------------------------

	assign		s_full					=		( sr_wr_flg[FIFO_WORD-1:0] == {FIFO_WORD{1'b1}} ) ? 1'b1 : 1'b0;

	always@( posedge WCLK or negedge RST_N )begin
		if( RST_N == 1'b0 )begin
			for (bc=0;bc<8;bc=bc+1) begin
				sr_wdata0[bc]		=		578'd0;
				sr_wdata1[bc]		=		578'd0;
				sr_wdata2[bc]		=		578'd0;
				sr_wdata3[bc]		=		578'd0;
				sr_wdata4[bc]		=		578'd0;
				sr_wdata5[bc]		=		578'd0;
				sr_wdata6[bc]		=		578'd0;
				sr_wdata7[bc]		=		578'd0;
			end
		end else if( FIFO_WORD == 4 )begin
			if( WREN == 1'b1 )begin
				sr_wdata0[{1'b0, sr_wcnt[1:0]}]	<=		WDATA[577:0];
			end
		end else if( FIFO_WORD == 8 )begin
			if( WREN == 1'b1 )begin
				sr_wdata0[sr_wcnt[2:0]]			<=		WDATA[577:0];
			end
		end else if( FIFO_WORD == 16 )begin
			if( WREN == 1'b1 )begin
				if( sr_wcnt[3] == 1'b0 )begin
					sr_wdata0[sr_wcnt[2:0]]			<=		WDATA[577:0];
				end else begin
					sr_wdata1[sr_wcnt[2:0]]			<=		WDATA[577:0];
				end
			end
		end else if( FIFO_WORD == 32 )begin
			if( WREN == 1'b1 )begin
				if( sr_wcnt[4:3] == 2'b00 )begin
					sr_wdata0[sr_wcnt[2:0]]			<=		WDATA[577:0];
				end else if( sr_wcnt[4:3] == 2'b01 )begin
					sr_wdata1[sr_wcnt[2:0]]			<=		WDATA[577:0];
				end else if( sr_wcnt[4:3] == 2'b10 )begin
					sr_wdata2[sr_wcnt[2:0]]			<=		WDATA[577:0];
				end else begin
					sr_wdata3[sr_wcnt[2:0]]			<=		WDATA[577:0];
				end
			end
		end else if( FIFO_WORD == 64 )begin
			if( WREN == 1'b1 )begin
				if( sr_wcnt[5:3] == 3'b000 )begin
					sr_wdata0[sr_wcnt[2:0]]			<=		WDATA[577:0];
				end else if( sr_wcnt[5:3] == 3'b001 )begin
					sr_wdata1[sr_wcnt[2:0]]			<=		WDATA[577:0];
				end else if( sr_wcnt[5:3] == 3'b010 )begin
					sr_wdata2[sr_wcnt[2:0]]			<=		WDATA[577:0];
				end else if( sr_wcnt[5:3] == 3'b011 )begin
					sr_wdata3[sr_wcnt[2:0]]			<=		WDATA[577:0];
				end else if( sr_wcnt[5:3] == 3'b100 )begin
					sr_wdata4[sr_wcnt[2:0]]			<=		WDATA[577:0];
				end else if( sr_wcnt[5:3] == 3'b101 )begin
					sr_wdata5[sr_wcnt[2:0]]			<=		WDATA[577:0];
				end else if( sr_wcnt[5:3] == 3'b110 )begin
					sr_wdata6[sr_wcnt[2:0]]			<=		WDATA[577:0];
				end else begin
					sr_wdata7[sr_wcnt[2:0]]			<=		WDATA[577:0];
				end
			end
		end
	end

	always@( posedge WCLK or negedge RST_N )begin
		if( RST_N == 1'b0 )begin
			sr_wcnt[5:0]		<=		6'b00_0000;
		end else if( WREN == 1'b1 )begin
			sr_wcnt[5:0]		<=		sr_wcnt[5:0] + 6'b00_0001;
		end
	end


	generate
		genvar	wr;
		for( wr=0; wr<FIFO_WORD; wr=wr+1 )begin

			always@( posedge WCLK or negedge RST_N )begin
				if( RST_N == 1'b0 )begin
					sr_wr_flg[wr]		<=		1'b0;
				end else if( FIFO_WORD == 4  && WREN == 1'b1 && sr_wcnt[1:0] == wr )begin
					sr_wr_flg[wr]		<=		1'b1;
				end else if( FIFO_WORD == 8  && WREN == 1'b1 && sr_wcnt[2:0] == wr )begin
					sr_wr_flg[wr]		<=		1'b1;
				end else if( FIFO_WORD == 16 && WREN == 1'b1 && sr_wcnt[3:0] == wr )begin
					sr_wr_flg[wr]		<=		1'b1;
				end else if( FIFO_WORD == 32 && WREN == 1'b1 && sr_wcnt[4:0] == wr )begin
					sr_wr_flg[wr]		<=		1'b1;
				end else if( FIFO_WORD == 64 && WREN == 1'b1 && sr_wcnt[5:0] == wr )begin
					sr_wr_flg[wr]		<=		1'b1;
				end else if(sr_clr[wr] == 1'b1 )begin
					sr_wr_flg[wr]		<=		1'b0;
				end
			end

			assign	s_set_flg_rstn[wr]	=	( RST_N == 1'b0 || sr_set[wr] == 1'b1 ) ? 1'b0 : 1'b1;

			always@( posedge WCLK or negedge s_set_flg_rstn[wr] )begin
				if( s_set_flg_rstn[wr] == 1'b0 )begin
					sr_set_flg[wr]		<=		1'b0;
				end else if( FIFO_WORD ==  4 && WREN == 1'b1 && sr_wcnt[1:0] == wr )begin
					sr_set_flg[wr]		<=		1'b1;
				end else if( FIFO_WORD ==  8 && WREN == 1'b1 && sr_wcnt[2:0] == wr )begin
					sr_set_flg[wr]		<=		1'b1;
				end else if( FIFO_WORD == 16 && WREN == 1'b1 && sr_wcnt[3:0] == wr )begin
					sr_set_flg[wr]		<=		1'b1;
				end else if( FIFO_WORD == 32 && WREN == 1'b1 && sr_wcnt[4:0] == wr )begin
					sr_set_flg[wr]		<=		1'b1;
				end else if( FIFO_WORD == 64 && WREN == 1'b1 && sr_wcnt[5:0] == wr )begin
					sr_set_flg[wr]		<=		1'b1;
				end
			end

			always@( negedge WCLK or negedge RST_N )begin
				if( RST_N == 1'b0 )begin
					sr_clr_sync[wr]		<=		1'b0;
				end else if( sr_clr[wr] == 1'b1 )begin
					sr_clr_sync[wr]		<=		1'b0;
				end else begin
					sr_clr_sync[wr]		<=		sr_clr_flg[wr];
				end
			end

			always@( posedge WCLK or negedge RST_N )begin
				if( RST_N == 1'b0 )begin
					sr_clr[wr]		<=		1'b0;
				end else if( sr_clr_sync[wr] == 1'b1 && sr_clr[wr] == 1'b0 )begin
					sr_clr[wr]		<=		1'b1;
				end else begin
					sr_clr[wr]		<=		1'b0;
				end
			end

		end
	endgenerate



//------------------------------------------------------------------------------
// リードFIFO制御部
//------------------------------------------------------------------------------

	assign		s_empty					=		( sr_rd_flg[FIFO_WORD-1:0] == {FIFO_WORD{1'b0}} ) ? 1'b1 : 1'b0;

	assign		s_rdata[577:0]			=		( FIFO_WORD ==  4 ) ? sr_wdata0[{1'b0, sr_rcnt[1:0]}]                      :
												( FIFO_WORD ==  8 ) ? sr_wdata0[sr_rcnt[2:0]]                              :
												( FIFO_WORD == 16 ) ? ( sr_rcnt[3]   == 1'b0   ? sr_wdata0[sr_rcnt[2:0]]   :
																								 sr_wdata1[sr_rcnt[2:0]] ) :
												( FIFO_WORD == 32 ) ? ( sr_rcnt[4:3] == 2'b00  ? sr_wdata0[sr_rcnt[2:0]]   :
																		sr_rcnt[4:3] == 2'b01  ? sr_wdata1[sr_rcnt[2:0]]   :
																		sr_rcnt[4:3] == 2'b10  ? sr_wdata2[sr_rcnt[2:0]]   :
																								 sr_wdata3[sr_rcnt[2:0]] ) :
												( FIFO_WORD == 64 ) ? ( sr_rcnt[5:3] == 3'b000 ? sr_wdata0[sr_rcnt[2:0]]   :
																		sr_rcnt[5:3] == 3'b001 ? sr_wdata1[sr_rcnt[2:0]]   :
																		sr_rcnt[5:3] == 3'b010 ? sr_wdata2[sr_rcnt[2:0]]   :
																		sr_rcnt[5:3] == 3'b011 ? sr_wdata3[sr_rcnt[2:0]]   :
																		sr_rcnt[5:3] == 3'b100 ? sr_wdata4[sr_rcnt[2:0]]   :
																		sr_rcnt[5:3] == 3'b101 ? sr_wdata5[sr_rcnt[2:0]]   :
																		sr_rcnt[5:3] == 3'b110 ? sr_wdata6[sr_rcnt[2:0]]   :
																								 sr_wdata7[sr_rcnt[2:0]] ) : 578'd0;


	always@( posedge RCLK or negedge RST_N )begin
		if( RST_N == 1'b0 )begin
			sr_rcnt[5:0]		<=		6'b00_0000;
		end else if( RDEN == 1'b1 )begin
			sr_rcnt[5:0]		<=		sr_rcnt[5:0] + 6'b00_0001;
		end
	end


	generate
		genvar	rd;
		for( rd=0; rd<FIFO_WORD; rd=rd+1 )begin

			always@( posedge RCLK or negedge RST_N )begin
				if( RST_N == 1'b0 )begin
					sr_rd_flg[rd]		<=		1'b0;
				end else if(sr_set[rd] == 1'b1 )begin
					sr_rd_flg[rd]		<=		1'b1;
				end else if( FIFO_WORD ==  4 && RDEN == 1'b1 && sr_rcnt[1:0] == rd )begin
					sr_rd_flg[rd]		<=		1'b0;
				end else if( FIFO_WORD ==  8 && RDEN == 1'b1 && sr_rcnt[2:0] == rd )begin
					sr_rd_flg[rd]		<=		1'b0;
				end else if( FIFO_WORD == 16 && RDEN == 1'b1 && sr_rcnt[3:0] == rd )begin
					sr_rd_flg[rd]		<=		1'b0;
				end else if( FIFO_WORD == 32 && RDEN == 1'b1 && sr_rcnt[4:0] == rd )begin
					sr_rd_flg[rd]		<=		1'b0;
				end else if( FIFO_WORD == 64 && RDEN == 1'b1 && sr_rcnt[5:0] == rd )begin
					sr_rd_flg[rd]		<=		1'b0;
				end
			end

			assign	s_clr_flg_rstn[rd]	=	( RST_N == 1'b0 || sr_clr[rd] == 1'b1 ) ? 1'b0 : 1'b1;

			always@( posedge RCLK or negedge s_clr_flg_rstn[rd] )begin
				if( s_clr_flg_rstn[rd] == 1'b0 )begin
					sr_clr_flg[rd]		<=		1'b0;
				end else if( FIFO_WORD ==  4 && RDEN == 1'b1 && sr_rcnt[1:0] == rd )begin
					sr_clr_flg[rd]		<=		1'b1;
				end else if( FIFO_WORD ==  8 && RDEN == 1'b1 && sr_rcnt[2:0] == rd )begin
					sr_clr_flg[rd]		<=		1'b1;
				end else if( FIFO_WORD == 16 && RDEN == 1'b1 && sr_rcnt[3:0] == rd )begin
					sr_clr_flg[rd]		<=		1'b1;
				end else if( FIFO_WORD == 32 && RDEN == 1'b1 && sr_rcnt[4:0] == rd )begin
					sr_clr_flg[rd]		<=		1'b1;
				end else if( FIFO_WORD == 64 && RDEN == 1'b1 && sr_rcnt[5:0] == rd )begin
					sr_clr_flg[rd]		<=		1'b1;
				end
			end

			always@( negedge RCLK or negedge RST_N )begin
				if( RST_N == 1'b0 )begin
					sr_set_sync[rd]		<=		1'b0;
				end else if( sr_set[rd] == 1'b1 )begin
					sr_set_sync[rd]		<=		1'b0;
				end else begin
					sr_set_sync[rd]		<=		sr_set_flg[rd];
				end
			end

			always@( posedge RCLK or negedge RST_N )begin
				if( RST_N == 1'b0 )begin
					sr_set[rd]		<=		1'b0;
				end else if( sr_set_sync[rd] == 1'b1 && sr_set[rd] == 1'b0 )begin
					sr_set[rd]		<=		1'b1;
				end else begin
					sr_set[rd]		<=		1'b0;
				end
			end

		end
	endgenerate



endmodule

