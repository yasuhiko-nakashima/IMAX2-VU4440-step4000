//------------------------------------------------------------------------------
// BUFF_578bxnW MODEL
//------------------------------------------------------------------------------
// BUFF_578bxnw モジュール
// (1) BUFF
//------------------------------------------------------------------------------
// Revision 00
// Level    01
//------------------------------------------------------------------------------
// File           : buff_578bxnw.v
// Module         : BUFF_578BXNW
//------------------------------------------------------------------------------
// Rev.Level     Date    Cause Coded        Contents
// 00.01     2020/05/31     00              F.T)O.Aihara
//------------------------------------------------------------------------------
// 00.01     2020/05/31                     F.T)O.Aihara new

`timescale 1 ps / 1 ps

module BUFF_578BXNW # (
					parameter	BUFF_WORD		=	8,	// 
					parameter	CNT_BIT			=	3	// 
				) (
					RST_N,								// 
					CLK,								// 
					WREN,								// 
					WDATA,								// 
					RDEN,								// 
					RDATA,								// 
					CNT									// 
	);


//------------------------------------------------------------------------------
// I/O signals
//------------------------------------------------------------------------------
	input					RST_N;						// 
	input					CLK;						// 
	input					WREN;						// 
	input	[577:0]			WDATA;						// 
	input					RDEN;						// 
	output	[577:0]			RDATA;						// 
	output	[CNT_BIT:0]		CNT;						// 


//------------------------------------------------------------------------------
// wires
//------------------------------------------------------------------------------
	wire	[577:0]			s_rdata;					// 


//------------------------------------------------------------------------------
// reges
//------------------------------------------------------------------------------
	(* ram_style = "register" *)	reg	[577:0]	sr_data0[0:31];// 
	(* ram_style = "register" *)	reg	[577:0]	sr_data1[0:31];// 
	(* ram_style = "register" *)	reg	[577:0]	sr_data2[0:31];// 
	(* ram_style = "register" *)	reg	[577:0]	sr_data3[0:31];// 
	(* ram_style = "register" *)	reg	[577:0]	sr_data4[0:31];// 
	(* ram_style = "register" *)	reg	[577:0]	sr_data5[0:31];// 
	(* ram_style = "register" *)	reg	[577:0]	sr_data6[0:31];// 
	(* ram_style = "register" *)	reg	[577:0]	sr_data7[0:31];// 
	reg		[CNT_BIT-1:0]	sr_wcnt;					// 
	reg		[CNT_BIT-1:0]	sr_rcnt;					// 
	reg		[CNT_BIT:0]		sr_cnt;						// 


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
	assign		RDATA[577:0]			=		s_rdata[577:0];
	assign		CNT[CNT_BIT:0]			=		sr_cnt[CNT_BIT:0];


//------------------------------------------------------------------------------
// ライトBUFF制御部
//------------------------------------------------------------------------------

	always@( posedge CLK or negedge RST_N )begin
		if( RST_N == 1'b0 )begin
			for (bc=0;bc<31;bc=bc+1) begin
				sr_data0[bc]		=		578'd0;
				sr_data1[bc]		=		578'd0;
				sr_data2[bc]		=		578'd0;
				sr_data3[bc]		=		578'd0;
				sr_data4[bc]		=		578'd0;
				sr_data5[bc]		=		578'd0;
				sr_data6[bc]		=		578'd0;
				sr_data7[bc]		=		578'd0;
			end
		end else if( BUFF_WORD == 8 )begin
			if( WREN == 1'b1 )begin
				sr_data0[{2'd0, sr_wcnt[2:0]}]	<=		WDATA[577:0];
			end
		end else if( BUFF_WORD == 16 )begin
			if( WREN == 1'b1 )begin
				sr_data0[{1'd0, sr_wcnt[3:0]}]	<=		WDATA[577:0];
			end
		end else if( BUFF_WORD == 32 )begin
			if( WREN == 1'b1 )begin
				sr_data0[sr_wcnt[4:0]]			<=		WDATA[577:0];
			end
		end else if( BUFF_WORD == 64 )begin
			if( WREN == 1'b1 )begin
				if( sr_wcnt[5] == 1'b0 )begin
					sr_data0[sr_wcnt[4:0]]			<=		WDATA[577:0];
				end else begin
					sr_data1[sr_wcnt[4:0]]			<=		WDATA[577:0];
				end
			end
		end else if( BUFF_WORD == 128 )begin
			if( WREN == 1'b1 )begin
				if( sr_wcnt[6:5] == 2'b00 )begin
					sr_data0[sr_wcnt[4:0]]			<=		WDATA[577:0];
				end else if( sr_wcnt[6:5] == 2'b01 )begin
					sr_data1[sr_wcnt[4:0]]			<=		WDATA[577:0];
				end else if( sr_wcnt[6:5] == 2'b10 )begin
					sr_data2[sr_wcnt[4:0]]			<=		WDATA[577:0];
				end else begin
					sr_data3[sr_wcnt[4:0]]			<=		WDATA[577:0];
				end
			end
		end else if( BUFF_WORD == 256 )begin
			if( WREN == 1'b1 )begin
				if( sr_wcnt[7:5] == 3'b000 )begin
					sr_data0[sr_wcnt[4:0]]			<=		WDATA[577:0];
				end else if( sr_wcnt[7:5] == 3'b001 )begin
					sr_data1[sr_wcnt[4:0]]			<=		WDATA[577:0];
				end else if( sr_wcnt[7:5] == 3'b010 )begin
					sr_data2[sr_wcnt[4:0]]			<=		WDATA[577:0];
				end else if( sr_wcnt[7:5] == 3'b011 )begin
					sr_data3[sr_wcnt[4:0]]			<=		WDATA[577:0];
				end else if( sr_wcnt[7:5] == 3'b100 )begin
					sr_data4[sr_wcnt[4:0]]			<=		WDATA[577:0];
				end else if( sr_wcnt[7:5] == 3'b100 )begin
					sr_data5[sr_wcnt[4:0]]			<=		WDATA[577:0];
				end else if( sr_wcnt[7:5] == 3'b110 )begin
					sr_data6[sr_wcnt[4:0]]			<=		WDATA[577:0];
				end else begin
					sr_data7[sr_wcnt[4:0]]			<=		WDATA[577:0];
				end
			end
		end
	end

	always@( posedge CLK or negedge RST_N )begin
		if( RST_N == 1'b0 )begin
			sr_wcnt[CNT_BIT-1:0]		<=		{CNT_BIT{1'b0}};
		end else if( WREN == 1'b1 )begin
			sr_wcnt[CNT_BIT-1:0]		<=		sr_wcnt[CNT_BIT-1:0] + { {CNT_BIT-1{1'b0}}, {1{1'b1}} };
		end
	end



//------------------------------------------------------------------------------
// リードFIFO制御部
//------------------------------------------------------------------------------

	assign		s_rdata[577:0]			=		( BUFF_WORD ==  8  ) ? sr_data0[{2'd0, sr_rcnt[2:0]}]                      :
												( BUFF_WORD == 16  ) ? sr_data0[{1'd0, sr_rcnt[3:0]}]                      :
												( BUFF_WORD == 32  ) ? sr_data0[sr_rcnt[4:0]]                              :
												( BUFF_WORD == 64  ) ? ( sr_rcnt[5]   == 1'b0   ? sr_data0[sr_rcnt[4:0]]   :
																								  sr_data1[sr_rcnt[4:0]] ) :
												( BUFF_WORD == 128 ) ? ( sr_rcnt[6:5] == 2'b00  ? sr_data0[sr_rcnt[4:0]]   :
																		 sr_rcnt[6:5] == 2'b01  ? sr_data1[sr_rcnt[4:0]]   :
																		 sr_rcnt[6:5] == 2'b10  ? sr_data2[sr_rcnt[4:0]]   :
																								  sr_data3[sr_rcnt[4:0]] ) :
												( BUFF_WORD == 256 ) ? ( sr_rcnt[7:5] == 3'b000 ? sr_data0[sr_rcnt[4:0]]   :
																		 sr_rcnt[7:5] == 3'b001 ? sr_data1[sr_rcnt[4:0]]   :
																		 sr_rcnt[7:5] == 3'b010 ? sr_data2[sr_rcnt[4:0]]   :
																		 sr_rcnt[7:5] == 3'b011 ? sr_data3[sr_rcnt[4:0]]   :
																		 sr_rcnt[7:5] == 3'b100 ? sr_data4[sr_rcnt[4:0]]   :
																		 sr_rcnt[7:5] == 3'b101 ? sr_data5[sr_rcnt[4:0]]   :
																		 sr_rcnt[7:5] == 3'b110 ? sr_data6[sr_rcnt[4:0]]   :
																								  sr_data7[sr_rcnt[4:0]] ) : 578'd0;

	always@( posedge CLK or negedge RST_N )begin
		if( RST_N == 1'b0 )begin
			sr_rcnt[CNT_BIT-1:0]		<=		{CNT_BIT{1'b0}};
		end else if( RDEN == 1'b1 )begin
			sr_rcnt[CNT_BIT-1:0]		<=		sr_rcnt[CNT_BIT-1:0] + { {CNT_BIT-1{1'b0}}, {1{1'b1}} };
		end
	end

	always@( posedge CLK or negedge RST_N )begin
		if( RST_N == 1'b0 )begin
			sr_cnt[CNT_BIT:0]			<=		{CNT_BIT+1{1'b0}};
		end else if( WREN == 1'b1 && RDEN == 1'b0 )begin
			sr_cnt[CNT_BIT:0]			<=		sr_cnt[CNT_BIT:0] + { {CNT_BIT{1'b0}}, {1{1'b1}} };
		end else if( WREN == 1'b0 && RDEN == 1'b1 )begin
			sr_cnt[CNT_BIT:0]			<=		sr_cnt[CNT_BIT:0] - { {CNT_BIT{1'b0}}, {1{1'b1}} };
		end
	end



endmodule

