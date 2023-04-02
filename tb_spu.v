/*------------------------------------------*/
/*  Test bench for SPU                      */
/*              Y.Nakashima 2020/2/10       */
/*------------------------------------------*/

`timescale 1ns/1ns

`include "stage2.v"
`include "stage3.v"
`include "stage4.v"
       
module tb_spu;
   reg  [9:0] 		         system_cycle;
   reg [15:0] 			 error;
   reg 				 ACLK;
   reg 				 RSTN;
   reg 				 exec;
   reg [7:0] 			 ex1;
   reg [63:0] 			 ex2;
   reg [63:0] 			 ex3;
   reg [7:0] 			 ex4;
   wire [15:0]			 ex2d_sfma0;
   wire [15:0]			 ex2d_sfma1;
   wire [15:0]			 ex2d_sfma2;
   wire [15:0]			 ex2d_sfma3;
   wire [15:0]			 ex2d_sfma4;
   wire [15:0]			 ex2d_sfma5;
   wire [15:0]			 ex2d_sfma6;
   wire [15:0]			 ex2d_sfma7;
   wire [31:0]			 ex3d;
   wire [7:0] 			 exd;
   
   spu1 spu1
     (
      .ACLK               (ACLK             ),
      .RSTN               (RSTN             ),
      .exec               (exec             ),
      .fold               (1'b0             ),
      .ex2                (ex2[63:0]        ),
      .ex3                (ex3[63:0]        ),
      .sfma0              (ex2d_sfma0[15:0] ),
      .sfma1              (ex2d_sfma1[15:0] ),
      .sfma2              (ex2d_sfma2[15:0] ),
      .sfma3              (ex2d_sfma3[15:0] ),
      .sfma4              (ex2d_sfma4[15:0] ),
      .sfma5              (ex2d_sfma5[15:0] ),
      .sfma6              (ex2d_sfma6[15:0] ),
      .sfma7              (ex2d_sfma7[15:0] )
      );

   spu2 spu2
     (
      .ACLK               (ACLK                         ),
      .RSTN               (RSTN                         ),
      .sfma0              (ex2d_sfma0[15:0] ),
      .sfma1              (ex2d_sfma1[15:0] ),
      .sfma2              (ex2d_sfma2[15:0] ),
      .sfma3              (ex2d_sfma3[15:0] ),
      .sfma4              (ex2d_sfma4[15:0] ),
      .sfma5              (ex2d_sfma5[15:0] ),
      .sfma6              (ex2d_sfma6[15:0] ),
      .sfma7              (ex2d_sfma7[15:0] ),
      .ex4                (ex4[2:0]         ),
      .so                 (ex3d[31:0]       )
      );

   spu3 spu3 /* normalize, no register slice, just combination logic */
     (
      .s1          (ex1[7:0]         ),
      .si          (ex3d[31:0]       ),
      .so          (exd[7:0]         )
      );

   parameter TIC1G        = 10;      // CPU CYCLE TIME
   parameter SDELAY       = 1;       // CLK変化から少し待つ
   
   always #(TIC1G/2) ACLK = ~ACLK;

   task WAIT_CYCLE;
      input   [15:0]  wait_cycle;
      reg     [15:0]  timer;
      begin
        timer[15:0] = 16'h0000;
        while( timer[15:0] != wait_cycle[15:0] ) begin
          #(TIC1G*1);
          timer[15:0] = timer[15:0] + 16'h0001;
        end
      end
   endtask

   task CHECK_SPU;
      input [7:0]  ex1in;
      input [63:0] ex2in;
      input [63:0] ex3in;
      input [7:0]  ex4in;
      input [7:0]  exdin;
      begin
	exec = 1'b1;
	ex1 = ex1in;
	ex2 = ex2in;
	ex3 = ex3in;
	ex4 = ex4in;
	#(SDELAY);      // ->stage2
	@(posedge ACLK);//
	exec = 1'b0;
	#(SDELAY);      // ->stage3
	@(posedge ACLK);//
	exec = 1'b0;
	#(SDELAY);      // ->stage4
        if (exd != exdin) begin
	  $display("[%t] ----- ERROR ex1=%h ex2=%h ex3=%h ex4=%h exd=%h should be %h -----",$time, ex1in, ex2in, ex3in, ex4in, exd, exdin);
	  error = error +16'h1;
	end
      end
   endtask

   initial begin

     system_cycle = 16'h0000;
     error        = 16'h0000;
     ACLK = 1'b0;
     RSTN = 1'b0;
     $display("[%t] ----- Global Reset -----",$time);
     WAIT_CYCLE(16'h0004);
     RSTN = 1'b1;
     WAIT_CYCLE(16'h0004);
     
`include "tb_spu.dat"

     if (error == 16'h0000)
       $display("======== OK ^^/========\n");
     else
       $display("======== NG ;_;========\n");
     $stop;
   end
endmodule
