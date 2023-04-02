//------------------------------------------------------------------------------
// FIFO_16bxNw MODEL
//------------------------------------------------------------------------------
// FIFO モジュール
// (1) FIFO_16bxNw
//------------------------------------------------------------------------------
// Revision 00
// Level    01
//------------------------------------------------------------------------------
// File           : fifo_16bxnw.v
// Module         : FIFO_16BXNW
//------------------------------------------------------------------------------
// Rev.Level     Date    Cause Coded        Contents
// 00.01     2020/08/31     00              F.T)O.Aihara
//------------------------------------------------------------------------------
// 00.01     2020/08/31                     F.T)O.Aihara new

`timescale 1 ps / 1 ps

module FIFO_16BXNW # (
					parameter	FIFO_WORD		=	8	// 
				) (
					RST_N,								// 
					CLK,								// 
					WREN,								// 
					WDATA,								// 
					FULL,								// 
					RDEN,								// 
					RDATA,								// 
					EMPTY								// 
	);


//------------------------------------------------------------------------------
// I/O signals
//------------------------------------------------------------------------------
	input					RST_N;						// 
	input					CLK;						// 
	input					WREN;						// 
	input	[15:0]			WDATA;						// 
	output					FULL;						// 
	input					RDEN;						// 
	output	[15:0]			RDATA;						// 
	output					EMPTY;						// 


//------------------------------------------------------------------------------
// wires
//------------------------------------------------------------------------------
	wire					s_full;						// 
	wire					s_empty;					// 
	wire	[15:0]			s_rdata;					// 


//------------------------------------------------------------------------------
// reges
//------------------------------------------------------------------------------
	(* ram_style = "register" *)	reg	[15:0]	sr_wdata0[0:7];// 
	(* ram_style = "register" *)	reg	[15:0]	sr_wdata1[0:7];// 
	(* ram_style = "register" *)	reg	[15:0]	sr_wdata2[0:7];// 
	(* ram_style = "register" *)	reg	[15:0]	sr_wdata3[0:7];// 
	(* ram_style = "register" *)	reg	[15:0]	sr_wdata4[0:7];// 
	(* ram_style = "register" *)	reg	[15:0]	sr_wdata5[0:7];// 
	(* ram_style = "register" *)	reg	[15:0]	sr_wdata6[0:7];// 
	(* ram_style = "register" *)	reg	[15:0]	sr_wdata7[0:7];// 
	reg		[6:0]			sr_wcnt;					// 
	reg		[6:0]			sr_rcnt;					// 


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

	assign		RDATA[15:0]				=		s_rdata[15:0];
	assign		EMPTY					=		s_empty;


//------------------------------------------------------------------------------
// ライトFIFO制御部
//------------------------------------------------------------------------------

	assign		s_full					=		( FIFO_WORD ==  4 ) ? ( sr_wcnt[2] != sr_rcnt[2] && sr_wcnt[1:0] == sr_rcnt[1:0] ) :
												( FIFO_WORD ==  8 ) ? ( sr_wcnt[3] != sr_rcnt[3] && sr_wcnt[2:0] == sr_rcnt[2:0] ) :
												( FIFO_WORD == 16 ) ? ( sr_wcnt[4] != sr_rcnt[4] && sr_wcnt[3:0] == sr_rcnt[3:0] ) :
												( FIFO_WORD == 32 ) ? ( sr_wcnt[5] != sr_rcnt[5] && sr_wcnt[4:0] == sr_rcnt[4:0] ) :
												( FIFO_WORD == 64 ) ? ( sr_wcnt[6] != sr_rcnt[6] && sr_wcnt[5:0] == sr_rcnt[5:0] ) : 1'b0;


	always@( posedge CLK or negedge RST_N )begin
		if( RST_N == 1'b0 )begin
			for (bc=0;bc<8;bc=bc+1) begin
				sr_wdata0[bc]		=		16'd0;
				sr_wdata1[bc]		=		16'd0;
				sr_wdata2[bc]		=		16'd0;
				sr_wdata3[bc]		=		16'd0;
				sr_wdata4[bc]		=		16'd0;
				sr_wdata5[bc]		=		16'd0;
				sr_wdata6[bc]		=		16'd0;
				sr_wdata7[bc]		=		16'd0;
			end
		end else if( FIFO_WORD == 4 )begin
			if( WREN == 1'b1 )begin
				sr_wdata0[{1'b0, sr_wcnt[1:0]}]	<=		WDATA[15:0];
			end
		end else if( FIFO_WORD == 8 )begin
			if( WREN == 1'b1 )begin
				sr_wdata0[sr_wcnt[2:0]]			<=		WDATA[15:0];
			end
		end else if( FIFO_WORD == 16 )begin
			if( WREN == 1'b1 )begin
				if( sr_wcnt[3] == 1'b0 )begin
					sr_wdata0[sr_wcnt[2:0]]			<=		WDATA[15:0];
				end else begin
					sr_wdata1[sr_wcnt[2:0]]			<=		WDATA[15:0];
				end
			end
		end else if( FIFO_WORD == 32 )begin
			if( WREN == 1'b1 )begin
				if( sr_wcnt[4:3] == 2'b00 )begin
					sr_wdata0[sr_wcnt[2:0]]			<=		WDATA[15:0];
				end else if( sr_wcnt[4:3] == 2'b01 )begin
					sr_wdata1[sr_wcnt[2:0]]			<=		WDATA[15:0];
				end else if( sr_wcnt[4:3] == 2'b10 )begin
					sr_wdata2[sr_wcnt[2:0]]			<=		WDATA[15:0];
				end else begin
					sr_wdata3[sr_wcnt[2:0]]			<=		WDATA[15:0];
				end
			end
		end else if( FIFO_WORD == 64 )begin
			if( WREN == 1'b1 )begin
				if( sr_wcnt[5:3] == 3'b000 )begin
					sr_wdata0[sr_wcnt[2:0]]			<=		WDATA[15:0];
				end else if( sr_wcnt[5:3] == 3'b001 )begin
					sr_wdata1[sr_wcnt[2:0]]			<=		WDATA[15:0];
				end else if( sr_wcnt[5:3] == 3'b010 )begin
					sr_wdata2[sr_wcnt[2:0]]			<=		WDATA[15:0];
				end else if( sr_wcnt[5:3] == 3'b011 )begin
					sr_wdata3[sr_wcnt[2:0]]			<=		WDATA[15:0];
				end else if( sr_wcnt[5:3] == 3'b100 )begin
					sr_wdata4[sr_wcnt[2:0]]			<=		WDATA[15:0];
				end else if( sr_wcnt[5:3] == 3'b101 )begin
					sr_wdata5[sr_wcnt[2:0]]			<=		WDATA[15:0];
				end else if( sr_wcnt[5:3] == 3'b110 )begin
					sr_wdata6[sr_wcnt[2:0]]			<=		WDATA[15:0];
				end else begin
					sr_wdata7[sr_wcnt[2:0]]			<=		WDATA[15:0];
				end
			end
		end
	end

	always@( posedge CLK or negedge RST_N )begin
		if( RST_N == 1'b0 )begin
			sr_wcnt[6:0]		<=		7'b000_0000;
		end else if( WREN == 1'b1 )begin
			sr_wcnt[6:0]		<=		sr_wcnt[6:0] + 7'b000_0001;
		end
	end



//------------------------------------------------------------------------------
// リードFIFO制御部
//------------------------------------------------------------------------------

	assign		s_empty					=		( FIFO_WORD ==  4 ) ? ( sr_wcnt[2] == sr_rcnt[2] && sr_wcnt[1:0] == sr_rcnt[1:0] ) :
												( FIFO_WORD ==  8 ) ? ( sr_wcnt[3] == sr_rcnt[3] && sr_wcnt[2:0] == sr_rcnt[2:0] ) :
												( FIFO_WORD == 16 ) ? ( sr_wcnt[4] == sr_rcnt[4] && sr_wcnt[3:0] == sr_rcnt[3:0] ) :
												( FIFO_WORD == 32 ) ? ( sr_wcnt[5] == sr_rcnt[5] && sr_wcnt[4:0] == sr_rcnt[4:0] ) :
												( FIFO_WORD == 64 ) ? ( sr_wcnt[6] == sr_rcnt[6] && sr_wcnt[5:0] == sr_rcnt[5:0] ) : 1'b1;

	assign		s_rdata[15:0]			=		( FIFO_WORD ==  4 ) ? sr_wdata0[{1'b0, sr_rcnt[1:0]}]                      :
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
																								 sr_wdata7[sr_rcnt[2:0]] ) : 16'h0000;


	always@( posedge CLK or negedge RST_N )begin
		if( RST_N == 1'b0 )begin
			sr_rcnt[6:0]		<=		7'b000_0000;
		end else if( RDEN == 1'b1 )begin
			sr_rcnt[6:0]		<=		sr_rcnt[6:0] + 7'b000_0001;
		end
	end



endmodule

