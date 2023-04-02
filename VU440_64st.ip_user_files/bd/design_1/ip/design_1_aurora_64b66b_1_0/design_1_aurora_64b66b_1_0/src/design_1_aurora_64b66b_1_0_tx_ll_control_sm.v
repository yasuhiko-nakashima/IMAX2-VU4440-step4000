 ///////////////////////////////////////////////////////////////////////////////
 //
 // Project:  Aurora 64B/66B
 // Company:  Xilinx
 //
 //
 //
 // (c) Copyright 2008 - 2009 Xilinx, Inc. All rights reserved.
 //
 // This file contains confidential and proprietary information
 // of Xilinx, Inc. and is protected under U.S. and
 // international copyright and other intellectual property
 // laws.
 //
 // DISCLAIMER
 // This disclaimer is not a license and does not grant any
 // rights to the materials distributed herewith. Except as
 // otherwise provided in a valid license issued to you by
 // Xilinx, and to the maximum extent permitted by applicable
 // law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
 // WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
 // AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
 // BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
 // INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
 // (2) Xilinx shall not be liable (whether in contract or tort,
 // including negligence, or under any other theory of
 // liability) for any loss or damage of any kind or nature
 // related to, arising under or in connection with these
 // materials, including for any direct, or any indirect,
 // special, incidental, or consequential loss or damage
 // (including loss of data, profits, goodwill, or any type of
 // loss or damage suffered as a result of any action brought
 // by a third party) even if such damage or loss was
 // reasonably foreseeable or Xilinx had been advised of the
 // possibility of the same.
 //
 // CRITICAL APPLICATIONS
 // Xilinx products are not designed or intended to be fail-
 // safe, or for use in any application requiring fail-safe
 // performance, such as life-support or safety devices or
 // systems, Class III medical devices, nuclear facilities,
 // applications related to the deployment of airbags, or any
 // other applications that could lead to death, personal
 // injury, or severe property or environmental damage
 // (individually and collectively, "Critical
 // Applications"). Customer assumes the sole risk and
 // liability of any use of Xilinx products in Critical
 // Applications, subject only to applicable laws and
 // regulations governing limitations on product liability.
 //
 // THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
 // PART OF THIS FILE AT ALL TIMES.
 
 //
 ///////////////////////////////////////////////////////////////////////////////
 //
 //  TX_LL_CONTROL_SM
 //
 //
 //  Description: This module provides the transmitter state machine
 //               control logic to connect the LocalLink interface to
 //               the Aurora Channel
 //
 //
 //
 //
 ///////////////////////////////////////////////////////////////////////////////
 `timescale 1 ns / 10 ps
 
(* DowngradeIPIdentifiedWarnings="yes" *)
 module  design_1_aurora_64b66b_1_0_TX_LL_CONTROL_SM
 (
     // LocalLink Interface
     TX_SRC_RDY_N,
     TX_SOF_N,
     TX_EOF_N,
     TX_REM,
     TX_REM_TO_DATAPATH,
     TX_DST_RDY_N,

 
     
     // Clock Compensation Interface
     DO_CC,
 
     // Global Logic Interface
     CHANNEL_UP,
 
     // TX_LL Control Module Interface
 
 
     // Aurora Lane Interface
     GEN_SEP,
     GEN_SEP7,
     SEP_NB,
     GEN_CC,
 
 
 
 
     // GTX Interface
     TXDATAVALID_IN,
 
     // System Interface
     USER_CLK
 
 );
 
 `define DLY #1
 
 
 
 //***********************************Port Declarations*******************************
 
 
     // LocalLink Interface
       input                    TX_SRC_RDY_N; 
       input                    TX_SOF_N; 
       input                    TX_EOF_N; 
       input         [0:5]      TX_REM; 
       output        [0:5]      TX_REM_TO_DATAPATH; 
       output                   TX_DST_RDY_N; 
 
 
 
 
 
     // Clock Compensation Interface
       input                    DO_CC; 
 
 
     // Global Logic Interface
       input                    CHANNEL_UP; 
 
     // TX_LL Control Module Interface
 
     // Aurora Lane Interface
       output        [0:7]      GEN_SEP; 
       output        [0:7]      GEN_SEP7; 
       output        [0:23]     SEP_NB; 
       output        [0:7]      GEN_CC; 
 
     // GTX Interface
       input                    TXDATAVALID_IN; 
     // System Interface
       input                    USER_CLK; 
 
 
 
 //**************************External Register Declarations****************************
 
       reg           [0:7]      GEN_SEP; 
       reg           [0:7]      GEN_SEP7; 
       reg           [0:23]     SEP_NB; 
 
 
 
 
 //**************************Internal Register Declarations****************************
 
       reg                      do_cc_r = 1'b0; 
       reg                      do_cc_r2 = 1'b0; 
       reg                      extend_cc_r;
 
       reg                      tx_dst_rdy_n_r; 
       reg           [0:5]      tx_rem_r; 
       reg                      gen_cc_r; 
 
     // Data state registers
       reg                      idle_r; 
       reg                      sof_to_data_r; 
       reg                      data_r; 
       reg                      data_to_eof_1_r; 
       reg                      data_to_eof_2_r; 
       reg                      eof_r; 
       reg                      sof_to_eof_1_r; 
       reg                      sof_to_eof_2_r; 
       reg                      sof_and_eof_r; 
 
       reg           [0:23]     gen_sep_nb_r; 
       reg           [0:7]      gen_sep_r; 
       reg           [0:7]      gen_sep7_r; 
       reg           [0:23]     gen_sep_nb_c; 
     
 
 
       reg                      datavalid_in_r; 
       reg                      datavalid_in_r2; 
     reg                      txeof_txdv_coincide_r;
 //*********************************Wire Declarations**********************************
 
       wire                     next_idle_c; 
       wire                     next_sof_to_data_c; 
       wire                     next_data_c; 
       wire                     next_data_to_eof_1_c; 
       wire                     next_data_to_eof_2_c; 
       wire                     next_eof_c; 
       wire                     next_sof_to_eof_1_c; 
       wire                     next_sof_to_eof_2_c; 
       wire                     next_sof_and_eof_c; 
       wire          [0:5]      gen_sep_nb_comb; 
 
 
       wire                     tx_dst_rdy_n_c; 
       wire                     do_sof_c; 
       wire                     do_eof_c; 
       wire                     channel_full_c; 
       wire                     pdu_ok_c; 
       wire          [0:7]      gen_sep_c; 
       wire          [0:7]      gen_sep7_c; 
       wire                     eof_with_datavalid_c; 
 
       wire          [0:5]      tx_rem_c; 
 //*********************************Main Body of Code**********************************
 
 
     //___________________________Clock Compensation________________________________
 
 
     // DO_CC signal has to be extended for one more cycle when TXDATAVALID_IN  
     // coincides with DO_CC occurance
     // extend_cc_r extends the pulse by one cycle during TXDATAVALID_IN cycle
 
     always @(posedge USER_CLK)
         if(!TXDATAVALID_IN & DO_CC)
               extend_cc_r <=  `DLY    1'b1;
         else if(!DO_CC)
               extend_cc_r <=  `DLY    1'b0;
 
     always @(posedge USER_CLK)
               do_cc_r <=  `DLY    DO_CC | extend_cc_r;
 
     always @(posedge USER_CLK)
               do_cc_r2 <= `DLY do_cc_r;
 
     // SOF requests are valid when TX_SRC_RDY_N, TX_DST_RDY_N and TX_SOF_N are all asserted
     assign  do_sof_c                =   !TX_SRC_RDY_N &
                                         !TX_DST_RDY_N &
                                         !TX_SOF_N;
 
     // EOF requests are valid when TX_SRC_RDY_N, TX_DST_RDY_N and TX_EOF_N are all asserted
     assign  do_eof_c                =   !TX_SRC_RDY_N &
                                         !TX_DST_RDY_N &
                                         !TX_EOF_N;

     // Freeze the Control state machine when CC. NFCs & UFCs must also be handled here.  
     assign  pdu_ok_c                =   !do_cc_r; 
     
 
     // The aurora channel is 'full' if there is more than enough data to fit into
     // a channel that is already carrying an SOF and an EOF character.
     assign  channel_full_c          =   (!TX_EOF_N & (tx_rem_c == 6'h0));
     //_____________________________Control State Machine__________________________________
 
     // The Control state machine handles the encapsulation and transmission of user
     // data.  It can use the channel when there is no CC, NFC message, UFC header,
     // UFC message or remote NFC request. 
 
     // State Registers
     always @(posedge USER_CLK)
         if(!CHANNEL_UP)
         begin
             idle_r              <=  `DLY    1'b1;
             sof_to_data_r       <=  `DLY    1'b0;
             data_r              <=  `DLY    1'b0;
             data_to_eof_1_r     <=  `DLY    1'b0;
             data_to_eof_2_r     <=  `DLY    1'b0;
             eof_r               <=  `DLY    1'b0;
             sof_to_eof_1_r      <=  `DLY    1'b0;
             sof_to_eof_2_r      <=  `DLY    1'b0;
             sof_and_eof_r       <=  `DLY    1'b0;
         end
         else if(pdu_ok_c)
         begin
             idle_r              <=  `DLY    next_idle_c;
             sof_to_data_r       <=  `DLY    next_sof_to_data_c;
             data_r              <=  `DLY    next_data_c;
             data_to_eof_1_r     <=  `DLY    next_data_to_eof_1_c;
             data_to_eof_2_r     <=  `DLY    next_data_to_eof_2_c;
             eof_r               <=  `DLY    next_eof_c;
             sof_to_eof_1_r      <=  `DLY    next_sof_to_eof_1_c;
             sof_to_eof_2_r      <=  `DLY    next_sof_to_eof_2_c;
             sof_and_eof_r       <=  `DLY    next_sof_and_eof_c;
         end
 
 
 
     // Next State Logic
 
     // Default state. Remains in idle_r till TX_SOF_N is asserted along with
     // TX_SRC_RDY_N & TX_DST_RDY_N
     // When no frame is available to the channel, the states return back to
     // this state
     assign  next_idle_c             =   (idle_r & !do_sof_c) |
                                         (data_to_eof_2_r & !do_sof_c) |
                                         (eof_r & !do_sof_c )             |
                                         (sof_to_eof_2_r & !do_sof_c)     |
                                         (sof_and_eof_r & !do_sof_c);
 
     // sof_to_data_r state is set when TX_SOF_N from LocalLink interface is asserted
     // and TX_EOF_N is not asserted
     assign  next_sof_to_data_c      =   (idle_r & do_sof_c & !do_eof_c) |
                                         (data_to_eof_2_r & do_sof_c & !do_eof_c) |
                                         (eof_r & do_sof_c & !do_eof_c) |
                                         (sof_to_eof_2_r & do_sof_c & !do_eof_c) |
                                         (sof_and_eof_r & do_sof_c & !do_eof_c);
 
     // data_r state is set when only data is being given through the LocalLink
     // during this state the frame data does not have both TX_SOF_N & TX_EOF_N
     // deasserted
     assign  next_data_c             =   (sof_to_data_r & !do_eof_c) |
                                         (data_r & !do_eof_c);
 
     // data_to_eof_1_r state is set when the incoming data beat has TX_EOF_N
     // asserted and data beat is completely filled with data
     // i.e TX_EOF_N is asserted & TX_REM is all 0's indicating all 8 bytes of
     // data are valid
     assign  next_data_to_eof_1_c    =   (sof_to_data_r & do_eof_c & channel_full_c)|
                                         (data_r & do_eof_c & channel_full_c);
 
     // data_to_eof_2_r state is a registered state of data_to_eof_1_r
     assign  next_data_to_eof_2_c    =   data_to_eof_1_r;
 
     // eof_r state is set when the incoming data has data which is < 8bytes
     // i.e TX_REM > 0 & TX_EOF_N asserted
     assign  next_eof_c              =   (sof_to_data_r & do_eof_c & !channel_full_c)|
                                         (data_r & do_eof_c & !channel_full_c);
 
     // sof_to_eof_1_r state is set when the incoming frame is a single cycle frame
     // In a single cycle frame both TX_SOF_N & TX_EOF_N are asserted
     // Also the channel should be full TX_REM = 0
     assign  next_sof_to_eof_1_c     =   (idle_r & do_sof_c & do_eof_c & channel_full_c)|
                                         (data_to_eof_2_r & do_sof_c & do_eof_c & channel_full_c)|
                                         (eof_r & do_sof_c & do_eof_c & channel_full_c)|
                                         (sof_to_eof_2_r & do_sof_c & do_eof_c & channel_full_c)|
                                         (sof_and_eof_r & do_sof_c & do_eof_c & channel_full_c);
 
     // sof_to_eof_2_r is a registered state of sof_to_eof_1_r
     assign  next_sof_to_eof_2_c     =   sof_to_eof_1_r;
 
     // sof_and_eof_r state is set when the incoming frame is a single cycle frame
     // In a single cycle frame both TX_SOF_N & TX_EOF_N are asserted
     // Here the channel is not full TX_REM > 0
     // TX_REM > 0 is the key difference between the previous state & this state
     assign  next_sof_and_eof_c      =   (idle_r & do_sof_c & do_eof_c & !channel_full_c)|
                                         (data_to_eof_2_r & do_sof_c & do_eof_c & !channel_full_c)|
                                         (eof_r & do_sof_c & do_eof_c & !channel_full_c)|
                                         (sof_to_eof_2_r & do_sof_c & do_eof_c & !channel_full_c)|
                                         (sof_and_eof_r & do_sof_c & do_eof_c & !channel_full_c);
 
 
     // TXDATAVALID_IN signal is registered for delay in the data flow 
     always @(posedge USER_CLK)
     begin
           datavalid_in_r     <=  `DLY  TXDATAVALID_IN;
           datavalid_in_r2    <=  `DLY  datavalid_in_r;
     end

     //  TX_DST_RDY  is the critical path in this module.  It must be deasserted 
     // whenever an event occurs that prevents the pdu state machine from using the
     // Aurora channel to transmit PDUs.
     assign  tx_dst_rdy_n_c  =   (next_data_to_eof_1_c & pdu_ok_c) |
                                 DO_CC | do_cc_r  |
                                 (next_sof_to_eof_1_c & pdu_ok_c) |
                                 
                                 (sof_to_eof_1_r & !pdu_ok_c)|
 			        (data_to_eof_1_r & !pdu_ok_c);
 
     always @(posedge USER_CLK)
       gen_cc_r <= `DLY |(GEN_CC);
 
     always @(posedge USER_CLK)
         if(!CHANNEL_UP)     tx_dst_rdy_n_r    <=  `DLY    1'b1;
         else                tx_dst_rdy_n_r    <=  `DLY    tx_dst_rdy_n_c  |!TXDATAVALID_IN |txeof_txdv_coincide_r | (gen_cc_r & |(gen_sep_c)) | (((|gen_sep_c)|(|gen_sep7_c)) & !datavalid_in_r);
 
     assign TX_DST_RDY_N = tx_dst_rdy_n_r  ;
 
     // logic to extend tx_dst_rdy when eof coincides with TXDV
     always @(posedge USER_CLK)
         if(!CHANNEL_UP) 
            txeof_txdv_coincide_r <= `DLY 1'b0;
         else if(!TX_EOF_N & !TXDATAVALID_IN & (TX_REM == 6'h0))
            txeof_txdv_coincide_r <= `DLY 1'b1;
         else
            txeof_txdv_coincide_r <= `DLY 1'b0;
 
 
     // Drive the GEN_SEP/GEN_SEP7 signal when in an EOF state with the PDU state machine active.
     always @(posedge USER_CLK)
         if(!CHANNEL_UP)
         begin     
                        GEN_SEP [0]     <=  `DLY    8'b0;
                        GEN_SEP7[0]     <=  `DLY    8'b0;
         end
         else if (gen_sep_c[0] & !datavalid_in_r)
                        GEN_SEP [0]     <=  `DLY    gen_sep_c[0];
         else if(gen_sep_r[0] & !datavalid_in_r2)
                        GEN_SEP [0]     <=  `DLY    gen_sep_r[0];
     // Additional states to latch GEN_SEP when datavalid  & CC coincides
         else if(gen_sep_r[0] & |GEN_CC)
                        GEN_SEP [0]     <=  `DLY    gen_sep_r[0];
 
         else if(GEN_SEP [0] & ( (|GEN_CC)))
                        GEN_SEP [0]     <=  `DLY    GEN_SEP[0];
 
         else if (gen_sep7_c[0] & !datavalid_in_r)
                        GEN_SEP7[0]     <=  `DLY gen_sep7_c[0];
         else if (gen_sep7_r[0] & !datavalid_in_r2)
                        GEN_SEP7[0]     <=  `DLY gen_sep7_r[0];
         else
         begin
                        GEN_SEP [0]     <=  `DLY    gen_sep_c[0];
                        GEN_SEP7[0]     <=  `DLY    gen_sep7_c[0];
         end
     always @(posedge USER_CLK)
         if(!CHANNEL_UP)
         begin     
                        GEN_SEP [1]     <=  `DLY    8'b0;
                        GEN_SEP7[1]     <=  `DLY    8'b0;
         end
         else if (gen_sep_c[1] & !datavalid_in_r)
                        GEN_SEP [1]     <=  `DLY    gen_sep_c[1];
         else if(gen_sep_r[1] & !datavalid_in_r2)
                        GEN_SEP [1]     <=  `DLY    gen_sep_r[1];
     // Additional states to latch GEN_SEP when datavalid  & CC coincides
         else if(gen_sep_r[1] & |GEN_CC)
                        GEN_SEP [1]     <=  `DLY    gen_sep_r[1];
 
         else if(GEN_SEP [1] & ( (|GEN_CC)))
                        GEN_SEP [1]     <=  `DLY    GEN_SEP[1];
 
         else if (gen_sep7_c[1] & !datavalid_in_r)
                        GEN_SEP7[1]     <=  `DLY gen_sep7_c[1];
         else if (gen_sep7_r[1] & !datavalid_in_r2)
                        GEN_SEP7[1]     <=  `DLY gen_sep7_r[1];
         else
         begin
                        GEN_SEP [1]     <=  `DLY    gen_sep_c[1];
                        GEN_SEP7[1]     <=  `DLY    gen_sep7_c[1];
         end
     always @(posedge USER_CLK)
         if(!CHANNEL_UP)
         begin     
                        GEN_SEP [2]     <=  `DLY    8'b0;
                        GEN_SEP7[2]     <=  `DLY    8'b0;
         end
         else if (gen_sep_c[2] & !datavalid_in_r)
                        GEN_SEP [2]     <=  `DLY    gen_sep_c[2];
         else if(gen_sep_r[2] & !datavalid_in_r2)
                        GEN_SEP [2]     <=  `DLY    gen_sep_r[2];
     // Additional states to latch GEN_SEP when datavalid  & CC coincides
         else if(gen_sep_r[2] & |GEN_CC)
                        GEN_SEP [2]     <=  `DLY    gen_sep_r[2];
 
         else if(GEN_SEP [2] & ( (|GEN_CC)))
                        GEN_SEP [2]     <=  `DLY    GEN_SEP[2];
 
         else if (gen_sep7_c[2] & !datavalid_in_r)
                        GEN_SEP7[2]     <=  `DLY gen_sep7_c[2];
         else if (gen_sep7_r[2] & !datavalid_in_r2)
                        GEN_SEP7[2]     <=  `DLY gen_sep7_r[2];
         else
         begin
                        GEN_SEP [2]     <=  `DLY    gen_sep_c[2];
                        GEN_SEP7[2]     <=  `DLY    gen_sep7_c[2];
         end
     always @(posedge USER_CLK)
         if(!CHANNEL_UP)
         begin     
                        GEN_SEP [3]     <=  `DLY    8'b0;
                        GEN_SEP7[3]     <=  `DLY    8'b0;
         end
         else if (gen_sep_c[3] & !datavalid_in_r)
                        GEN_SEP [3]     <=  `DLY    gen_sep_c[3];
         else if(gen_sep_r[3] & !datavalid_in_r2)
                        GEN_SEP [3]     <=  `DLY    gen_sep_r[3];
     // Additional states to latch GEN_SEP when datavalid  & CC coincides
         else if(gen_sep_r[3] & |GEN_CC)
                        GEN_SEP [3]     <=  `DLY    gen_sep_r[3];
 
         else if(GEN_SEP [3] & ( (|GEN_CC)))
                        GEN_SEP [3]     <=  `DLY    GEN_SEP[3];
 
         else if (gen_sep7_c[3] & !datavalid_in_r)
                        GEN_SEP7[3]     <=  `DLY gen_sep7_c[3];
         else if (gen_sep7_r[3] & !datavalid_in_r2)
                        GEN_SEP7[3]     <=  `DLY gen_sep7_r[3];
         else
         begin
                        GEN_SEP [3]     <=  `DLY    gen_sep_c[3];
                        GEN_SEP7[3]     <=  `DLY    gen_sep7_c[3];
         end
     always @(posedge USER_CLK)
         if(!CHANNEL_UP)
         begin     
                        GEN_SEP [4]     <=  `DLY    8'b0;
                        GEN_SEP7[4]     <=  `DLY    8'b0;
         end
         else if (gen_sep_c[4] & !datavalid_in_r)
                        GEN_SEP [4]     <=  `DLY    gen_sep_c[4];
         else if(gen_sep_r[4] & !datavalid_in_r2)
                        GEN_SEP [4]     <=  `DLY    gen_sep_r[4];
     // Additional states to latch GEN_SEP when datavalid  & CC coincides
         else if(gen_sep_r[4] & |GEN_CC)
                        GEN_SEP [4]     <=  `DLY    gen_sep_r[4];
 
         else if(GEN_SEP [4] & ( (|GEN_CC)))
                        GEN_SEP [4]     <=  `DLY    GEN_SEP[4];
 
         else if (gen_sep7_c[4] & !datavalid_in_r)
                        GEN_SEP7[4]     <=  `DLY gen_sep7_c[4];
         else if (gen_sep7_r[4] & !datavalid_in_r2)
                        GEN_SEP7[4]     <=  `DLY gen_sep7_r[4];
         else
         begin
                        GEN_SEP [4]     <=  `DLY    gen_sep_c[4];
                        GEN_SEP7[4]     <=  `DLY    gen_sep7_c[4];
         end
     always @(posedge USER_CLK)
         if(!CHANNEL_UP)
         begin     
                        GEN_SEP [5]     <=  `DLY    8'b0;
                        GEN_SEP7[5]     <=  `DLY    8'b0;
         end
         else if (gen_sep_c[5] & !datavalid_in_r)
                        GEN_SEP [5]     <=  `DLY    gen_sep_c[5];
         else if(gen_sep_r[5] & !datavalid_in_r2)
                        GEN_SEP [5]     <=  `DLY    gen_sep_r[5];
     // Additional states to latch GEN_SEP when datavalid  & CC coincides
         else if(gen_sep_r[5] & |GEN_CC)
                        GEN_SEP [5]     <=  `DLY    gen_sep_r[5];
 
         else if(GEN_SEP [5] & ( (|GEN_CC)))
                        GEN_SEP [5]     <=  `DLY    GEN_SEP[5];
 
         else if (gen_sep7_c[5] & !datavalid_in_r)
                        GEN_SEP7[5]     <=  `DLY gen_sep7_c[5];
         else if (gen_sep7_r[5] & !datavalid_in_r2)
                        GEN_SEP7[5]     <=  `DLY gen_sep7_r[5];
         else
         begin
                        GEN_SEP [5]     <=  `DLY    gen_sep_c[5];
                        GEN_SEP7[5]     <=  `DLY    gen_sep7_c[5];
         end
     always @(posedge USER_CLK)
         if(!CHANNEL_UP)
         begin     
                        GEN_SEP [6]     <=  `DLY    8'b0;
                        GEN_SEP7[6]     <=  `DLY    8'b0;
         end
         else if (gen_sep_c[6] & !datavalid_in_r)
                        GEN_SEP [6]     <=  `DLY    gen_sep_c[6];
         else if(gen_sep_r[6] & !datavalid_in_r2)
                        GEN_SEP [6]     <=  `DLY    gen_sep_r[6];
     // Additional states to latch GEN_SEP when datavalid  & CC coincides
         else if(gen_sep_r[6] & |GEN_CC)
                        GEN_SEP [6]     <=  `DLY    gen_sep_r[6];
 
         else if(GEN_SEP [6] & ( (|GEN_CC)))
                        GEN_SEP [6]     <=  `DLY    GEN_SEP[6];
 
         else if (gen_sep7_c[6] & !datavalid_in_r)
                        GEN_SEP7[6]     <=  `DLY gen_sep7_c[6];
         else if (gen_sep7_r[6] & !datavalid_in_r2)
                        GEN_SEP7[6]     <=  `DLY gen_sep7_r[6];
         else
         begin
                        GEN_SEP [6]     <=  `DLY    gen_sep_c[6];
                        GEN_SEP7[6]     <=  `DLY    gen_sep7_c[6];
         end
     always @(posedge USER_CLK)
         if(!CHANNEL_UP)
         begin     
                        GEN_SEP [7]     <=  `DLY    8'b0;
                        GEN_SEP7[7]     <=  `DLY    8'b0;
         end
         else if (gen_sep_c[7] & !datavalid_in_r)
                        GEN_SEP [7]     <=  `DLY    gen_sep_c[7];
         else if(gen_sep_r[7] & !datavalid_in_r2)
                        GEN_SEP [7]     <=  `DLY    gen_sep_r[7];
     // Additional states to latch GEN_SEP when datavalid  & CC coincides
         else if(gen_sep_r[7] & |GEN_CC)
                        GEN_SEP [7]     <=  `DLY    gen_sep_r[7];
 
         else if(GEN_SEP [7] & ( (|GEN_CC)))
                        GEN_SEP [7]     <=  `DLY    GEN_SEP[7];
 
         else if (gen_sep7_c[7] & !datavalid_in_r)
                        GEN_SEP7[7]     <=  `DLY gen_sep7_c[7];
         else if (gen_sep7_r[7] & !datavalid_in_r2)
                        GEN_SEP7[7]     <=  `DLY gen_sep7_r[7];
         else
         begin
                        GEN_SEP [7]     <=  `DLY    gen_sep_c[7];
                        GEN_SEP7[7]     <=  `DLY    gen_sep7_c[7];
         end
 
     assign eof_with_datavalid_c  =  (!datavalid_in_r & !TX_EOF_N & !TX_DST_RDY_N);      
 
 
     assign tx_rem_c = TX_REM;
 
     assign TX_REM_TO_DATAPATH = (!TX_EOF_N) ? tx_rem_c : 6'd0;
 
     always @(posedge USER_CLK)
     begin
         if(!TX_EOF_N & !TX_DST_RDY_N)
            tx_rem_r <= `DLY tx_rem_c;
     end
 
     assign gen_sep_c[0]  =  ((next_eof_c |next_sof_and_eof_c) 
                                                           & pdu_ok_c & (tx_rem_c >= {6{1'b0}}  & (tx_rem_c[3:5] < {3{1'b1}} && ((tx_rem_c <= 6'd7) & (tx_rem_c >= 6'd0))))) |((data_to_eof_1_r | sof_to_eof_1_r)
                                                           & pdu_ok_c & (tx_rem_r >= {6{1'b0}}  & (tx_rem_r[3:5] < {3{1'b1}} && ((tx_rem_r <= 6'd7) & (tx_rem_r >= 6'd0))))) |
                                  (eof_with_datavalid_c & (gen_sep_nb_c != {8{3'h7}}));
 
     assign gen_sep7_c[0] =  ((next_eof_c | next_sof_and_eof_c) & pdu_ok_c &  (tx_rem_c[3:5] == {3{1'b1}} &&  ((tx_rem_c <= 6'd7) & (tx_rem_c >= 6'd0)))) | 
                                     //((data_to_eof_1_r | sof_to_eof_2_r) & pdu_ok_c &  (tx_rem_r[3:5] == {3{1'b1}} &&  ((tx_rem_r <= 6'd7) & (tx_rem_r >= 6'd0)))) |
                                     (eof_with_datavalid_c & (gen_sep_nb_c == {1{3'h7}}));
 
     assign gen_sep_c[1]  =  ((next_eof_c |next_sof_and_eof_c) 
                                                           & pdu_ok_c & (tx_rem_c >= {6{1'b0}}  & (tx_rem_c[3:5] < {3{1'b1}} && ((tx_rem_c <= 6'd15) & (tx_rem_c >= 6'd8))))) |((data_to_eof_1_r | sof_to_eof_1_r)
                                                           & pdu_ok_c & (tx_rem_r >= {6{1'b0}}  & (tx_rem_r[3:5] < {3{1'b1}} && ((tx_rem_r <= 6'd15) & (tx_rem_r >= 6'd8))))) |
                                  (eof_with_datavalid_c & (gen_sep_nb_c != {8{3'h7}}));
 
     assign gen_sep7_c[1] =  ((next_eof_c | next_sof_and_eof_c) & pdu_ok_c &  (tx_rem_c[3:5] == {3{1'b1}} &&  ((tx_rem_c <= 6'd15) & (tx_rem_c >= 6'd8)))) | 
                                     //((data_to_eof_1_r | sof_to_eof_2_r) & pdu_ok_c &  (tx_rem_r[3:5] == {3{1'b1}} &&  ((tx_rem_r <= 6'd15) & (tx_rem_r >= 6'd8)))) |
                                     (eof_with_datavalid_c & (gen_sep_nb_c == {1{3'h7}}));
 
     assign gen_sep_c[2]  =  ((next_eof_c |next_sof_and_eof_c) 
                                                           & pdu_ok_c & (tx_rem_c >= {6{1'b0}}  & (tx_rem_c[3:5] < {3{1'b1}} && ((tx_rem_c <= 6'd23) & (tx_rem_c >= 6'd16))))) |((data_to_eof_1_r | sof_to_eof_1_r)
                                                           & pdu_ok_c & (tx_rem_r >= {6{1'b0}}  & (tx_rem_r[3:5] < {3{1'b1}} && ((tx_rem_r <= 6'd23) & (tx_rem_r >= 6'd16))))) |
                                  (eof_with_datavalid_c & (gen_sep_nb_c != {8{3'h7}}));
 
     assign gen_sep7_c[2] =  ((next_eof_c | next_sof_and_eof_c) & pdu_ok_c &  (tx_rem_c[3:5] == {3{1'b1}} &&  ((tx_rem_c <= 6'd23) & (tx_rem_c >= 6'd16)))) | 
                                     //((data_to_eof_1_r | sof_to_eof_2_r) & pdu_ok_c &  (tx_rem_r[3:5] == {3{1'b1}} &&  ((tx_rem_r <= 6'd23) & (tx_rem_r >= 6'd16)))) |
                                     (eof_with_datavalid_c & (gen_sep_nb_c == {1{3'h7}}));
 
     assign gen_sep_c[3]  =  ((next_eof_c |next_sof_and_eof_c) 
                                                           & pdu_ok_c & (tx_rem_c >= {6{1'b0}}  & (tx_rem_c[3:5] < {3{1'b1}} && ((tx_rem_c <= 6'd31) & (tx_rem_c >= 6'd24))))) |((data_to_eof_1_r | sof_to_eof_1_r)
                                                           & pdu_ok_c & (tx_rem_r >= {6{1'b0}}  & (tx_rem_r[3:5] < {3{1'b1}} && ((tx_rem_r <= 6'd31) & (tx_rem_r >= 6'd24))))) |
                                  (eof_with_datavalid_c & (gen_sep_nb_c != {8{3'h7}}));
 
     assign gen_sep7_c[3] =  ((next_eof_c | next_sof_and_eof_c) & pdu_ok_c &  (tx_rem_c[3:5] == {3{1'b1}} &&  ((tx_rem_c <= 6'd31) & (tx_rem_c >= 6'd24)))) | 
                                     //((data_to_eof_1_r | sof_to_eof_2_r) & pdu_ok_c &  (tx_rem_r[3:5] == {3{1'b1}} &&  ((tx_rem_r <= 6'd31) & (tx_rem_r >= 6'd24)))) |
                                     (eof_with_datavalid_c & (gen_sep_nb_c == {1{3'h7}}));
 
     assign gen_sep_c[4]  =  ((next_eof_c |next_sof_and_eof_c) 
                                                           & pdu_ok_c & (tx_rem_c >= {6{1'b0}}  & (tx_rem_c[3:5] < {3{1'b1}} && ((tx_rem_c <= 6'd39) & (tx_rem_c >= 6'd32))))) |((data_to_eof_1_r | sof_to_eof_1_r)
                                                           & pdu_ok_c & (tx_rem_r >= {6{1'b0}}  & (tx_rem_r[3:5] < {3{1'b1}} && ((tx_rem_r <= 6'd39) & (tx_rem_r >= 6'd32))))) |
                                  (eof_with_datavalid_c & (gen_sep_nb_c != {8{3'h7}}));
 
     assign gen_sep7_c[4] =  ((next_eof_c | next_sof_and_eof_c) & pdu_ok_c &  (tx_rem_c[3:5] == {3{1'b1}} &&  ((tx_rem_c <= 6'd39) & (tx_rem_c >= 6'd32)))) | 
                                     //((data_to_eof_1_r | sof_to_eof_2_r) & pdu_ok_c &  (tx_rem_r[3:5] == {3{1'b1}} &&  ((tx_rem_r <= 6'd39) & (tx_rem_r >= 6'd32)))) |
                                     (eof_with_datavalid_c & (gen_sep_nb_c == {1{3'h7}}));
 
     assign gen_sep_c[5]  =  ((next_eof_c |next_sof_and_eof_c) 
                                                           & pdu_ok_c & (tx_rem_c >= {6{1'b0}}  & (tx_rem_c[3:5] < {3{1'b1}} && ((tx_rem_c <= 6'd47) & (tx_rem_c >= 6'd40))))) |((data_to_eof_1_r | sof_to_eof_1_r)
                                                           & pdu_ok_c & (tx_rem_r >= {6{1'b0}}  & (tx_rem_r[3:5] < {3{1'b1}} && ((tx_rem_r <= 6'd47) & (tx_rem_r >= 6'd40))))) |
                                  (eof_with_datavalid_c & (gen_sep_nb_c != {8{3'h7}}));
 
     assign gen_sep7_c[5] =  ((next_eof_c | next_sof_and_eof_c) & pdu_ok_c &  (tx_rem_c[3:5] == {3{1'b1}} &&  ((tx_rem_c <= 6'd47) & (tx_rem_c >= 6'd40)))) | 
                                     //((data_to_eof_1_r | sof_to_eof_2_r) & pdu_ok_c &  (tx_rem_r[3:5] == {3{1'b1}} &&  ((tx_rem_r <= 6'd47) & (tx_rem_r >= 6'd40)))) |
                                     (eof_with_datavalid_c & (gen_sep_nb_c == {1{3'h7}}));
 
     assign gen_sep_c[6]  =  ((next_eof_c |next_sof_and_eof_c) 
                                                           & pdu_ok_c & (tx_rem_c >= {6{1'b0}}  & (tx_rem_c[3:5] < {3{1'b1}} && ((tx_rem_c <= 6'd55) & (tx_rem_c >= 6'd48))))) |((data_to_eof_1_r | sof_to_eof_1_r)
                                                           & pdu_ok_c & (tx_rem_r >= {6{1'b0}}  & (tx_rem_r[3:5] < {3{1'b1}} && ((tx_rem_r <= 6'd55) & (tx_rem_r >= 6'd48))))) |
                                  (eof_with_datavalid_c & (gen_sep_nb_c != {8{3'h7}}));
 
     assign gen_sep7_c[6] =  ((next_eof_c | next_sof_and_eof_c) & pdu_ok_c &  (tx_rem_c[3:5] == {3{1'b1}} &&  ((tx_rem_c <= 6'd55) & (tx_rem_c >= 6'd48)))) | 
                                     //((data_to_eof_1_r | sof_to_eof_2_r) & pdu_ok_c &  (tx_rem_r[3:5] == {3{1'b1}} &&  ((tx_rem_r <= 6'd55) & (tx_rem_r >= 6'd48)))) |
                                     (eof_with_datavalid_c & (gen_sep_nb_c == {1{3'h7}}));
 
     assign gen_sep_c[7]  =  ((next_eof_c |next_sof_and_eof_c) 
                                                           & pdu_ok_c & (tx_rem_c >= {6{1'b0}}  & (tx_rem_c[3:5] < {3{1'b1}} && ((tx_rem_c <= 6'd63) & (tx_rem_c >= 6'd56))))) |((data_to_eof_1_r | sof_to_eof_1_r)
                                                           & pdu_ok_c & (tx_rem_r >= {6{1'b0}}  & (tx_rem_r[3:5] < {3{1'b1}} && ((tx_rem_r <= 6'd63) & (tx_rem_r >= 6'd56))))) |
                                  (eof_with_datavalid_c & (gen_sep_nb_c != {8{3'h7}}));
 
     assign gen_sep7_c[7] =  ((next_eof_c | next_sof_and_eof_c) & pdu_ok_c &  (tx_rem_c[3:5] == {3{1'b1}} &&  ((tx_rem_c <= 6'd63) & (tx_rem_c >= 6'd56)))) | 
                                     //((data_to_eof_1_r | sof_to_eof_2_r) & pdu_ok_c &  (tx_rem_r[3:5] == {3{1'b1}} &&  ((tx_rem_r <= 6'd63) & (tx_rem_r >= 6'd56)))) |
                                     (eof_with_datavalid_c & (gen_sep_nb_c == {1{3'h7}}));
 
 
     assign  gen_sep_nb_comb   =  (eof_r & (TX_REM == {1{6'h0}}) & channel_full_c) ? 6'h0 : 
                                  (eof_with_datavalid_c) ? TX_REM : 
                                  (!TX_DST_RDY_N) ? TX_REM : 
6'h0;
 
     // We generate the gen_sep_nb_c signal based on the REM signal and the EOF signal.
     always @(gen_sep_nb_comb)
     begin
         case(gen_sep_nb_comb[0:2])
         3'b000  : gen_sep_nb_c = {gen_sep_nb_comb[3:5],{7{3'h0}}};
         3'b001  : gen_sep_nb_c = {3'h0,gen_sep_nb_comb[3:5],{6{3'h0}}};
         3'b010  : gen_sep_nb_c = {{2{3'h0}},gen_sep_nb_comb[3:5],{5{3'h0}}};
         3'b011  : gen_sep_nb_c = {{3{3'h0}},gen_sep_nb_comb[3:5],{4{3'h0}}};
         3'b100  : gen_sep_nb_c = {{4{3'h0}},gen_sep_nb_comb[3:5],{3{3'h0}}};
         3'b101  : gen_sep_nb_c = {{5{3'h0}},gen_sep_nb_comb[3:5],{2{3'h0}}};          
         3'b110  : gen_sep_nb_c = {{6{3'h0}},gen_sep_nb_comb[3:5],3'h0};
         3'b111  : gen_sep_nb_c = {{7{3'h0}},gen_sep_nb_comb[3:5]};
         default   gen_sep_nb_c = {8{3'h0}};
         endcase
     end
 
     always @(posedge USER_CLK)
     begin
         if(datavalid_in_r & datavalid_in_r2 & !(|GEN_CC))
             gen_sep_r   <= `DLY 1'b0;
         else if(!datavalid_in_r)
             gen_sep_r   <= `DLY gen_sep_c;
     end
 
     always @(posedge USER_CLK)
     begin
             gen_sep_nb_r <= `DLY gen_sep_nb_c;
     end
 
     always @(posedge USER_CLK)
     begin
         if(!datavalid_in_r2)
             gen_sep7_r   <= `DLY gen_sep7_r;
         else
             gen_sep7_r   <= `DLY gen_sep7_c;
     end
 
 
     // Assign gen_sep_nb to SEP_NB port
     always @(posedge USER_CLK)
     begin
         if(!datavalid_in_r)
             SEP_NB   <=  `DLY    gen_sep_nb_r;
         else
             SEP_NB   <=  `DLY    gen_sep_nb_c;
     end      
 
 
     // The flops for the GEN_CC signal are replicated for timing and instantiated to allow us
     // to set their value reliably on powerup.
     FDR gen_cc_flop_0_i
     (
         .D(do_cc_r),
         .C(USER_CLK),
         .R(~CHANNEL_UP),
         .Q(GEN_CC [0])
     );
     FDR gen_cc_flop_1_i
     (
         .D(do_cc_r),
         .C(USER_CLK),
         .R(~CHANNEL_UP),
         .Q(GEN_CC [1])
     );
     FDR gen_cc_flop_2_i
     (
         .D(do_cc_r),
         .C(USER_CLK),
         .R(~CHANNEL_UP),
         .Q(GEN_CC [2])
     );
     FDR gen_cc_flop_3_i
     (
         .D(do_cc_r),
         .C(USER_CLK),
         .R(~CHANNEL_UP),
         .Q(GEN_CC [3])
     );
     FDR gen_cc_flop_4_i
     (
         .D(do_cc_r),
         .C(USER_CLK),
         .R(~CHANNEL_UP),
         .Q(GEN_CC [4])
     );
     FDR gen_cc_flop_5_i
     (
         .D(do_cc_r),
         .C(USER_CLK),
         .R(~CHANNEL_UP),
         .Q(GEN_CC [5])
     );
     FDR gen_cc_flop_6_i
     (
         .D(do_cc_r),
         .C(USER_CLK),
         .R(~CHANNEL_UP),
         .Q(GEN_CC [6])
     );
     FDR gen_cc_flop_7_i
     (
         .D(do_cc_r),
         .C(USER_CLK),
         .R(~CHANNEL_UP),
         .Q(GEN_CC [7])
     );
 
 
 
  
 
 
 
 endmodule
 
