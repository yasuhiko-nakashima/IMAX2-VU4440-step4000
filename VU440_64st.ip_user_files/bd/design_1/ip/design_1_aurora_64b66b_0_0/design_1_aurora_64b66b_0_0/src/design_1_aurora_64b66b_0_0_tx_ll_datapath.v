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
 //  TX_LL_DATAPATH
 //
 //
 //  Description: This module pipelines the data path in compliance
 //               with Local Link protocol. Provides data to Aurora Lane
 //               in the required format
 //
 ///////////////////////////////////////////////////////////////////////////////
 
 
 `timescale 1 ns / 10 ps
 
(* DowngradeIPIdentifiedWarnings="yes" *)
 module design_1_aurora_64b66b_0_0_TX_LL_DATAPATH
 (
     // LocalLink Interface
     TX_D,
     TX_SRC_RDY_N,
     TX_SOF_N,
     TX_EOF_N,
     TX_REM_TO_DATAPATH,
     // TX_LL Control Module Interface
     TX_DST_RDY_N,
 
 
 
     // Aurora Lane Interface
     TX_PE_DATA_V,
     TX_PE_DATA,
 
 
     // System Interface
     CHANNEL_UP,
     USER_CLK
 
 );
 
 `define DLY #1
 
 
 //***********************************Port Declarations*******************************
 
 
     // LocalLink Interface
       input     [0:511]    TX_D; 
       input                TX_SRC_RDY_N; 
       input                TX_SOF_N; 
       input                TX_EOF_N; 
       input     [0:5]      TX_REM_TO_DATAPATH; 
     // TX_LL Control Module Interface
       input                TX_DST_RDY_N; 

 
 
     // Aurora Lane Interface
       output    [0:7]      TX_PE_DATA_V; 
       output    [0:511]    TX_PE_DATA; 
 
     // System Interface
       input                CHANNEL_UP; 
       input                USER_CLK; 
 
 //**************************External Register Declarations****************************
 
       reg       [0:511]    TX_PE_DATA; 
       reg       [0:7]      TX_PE_DATA_V; 
 
 //**************************Internal Register Declarations****************************
 
       reg                  in_frame_r; 
 
 //******************************Internal Wire Declarations****************************
 
       wire                 in_frame_c; 
       wire                 ll_valid_c; 
 
 
       wire      [0:511]    tx_pe_data_c; 
       wire      [0:7]      tx_pe_data_v_c; 
 //*********************************Main Body of Code**********************************
 
     // LocalLink input is only valid when TX_SRC_RDY_N and TX_DST_RDY_N are both asserted
     assign ll_valid_c           =   !TX_SRC_RDY_N && !TX_DST_RDY_N;
 
 
     // Data must only be read if it is within a frame. If the frame will last multiple
     // cycles, assert in_frame_r until the frame ends
     always @(posedge USER_CLK)
         if(!CHANNEL_UP)    
            in_frame_r    <=  `DLY    1'b0;
         else if(ll_valid_c)
         begin
           if(!TX_SOF_N && TX_EOF_N )    in_frame_r    <=  `DLY    1'b1;
            else if(!TX_EOF_N)           in_frame_r    <=  `DLY    1'b0; 
         end
 
     assign in_frame_c   =   ll_valid_c  && (in_frame_r  || !TX_SOF_N);
 
     assign  tx_pe_data_c =  TX_D;
 
     //Assign tx_pe_data_v_c based on Protocol rules
     //IN SA=1 Following rules are followed
     //1. Lanes higher than SEP can't have data
     //2. UFCH is sent only on the last lane
     assign tx_pe_data_v_c[0] = 
                                ((ll_valid_c & (in_frame_r  || !TX_SOF_N)) & !TX_EOF_N & (TX_REM_TO_DATAPATH >= 6'd1)  ) ? 1'b1 :                                
                                (ll_valid_c & (in_frame_r  || !TX_SOF_N) & (TX_REM_TO_DATAPATH == 6'd0)) ?1'b1:                                                              
                                1'b0 ;
 
     assign tx_pe_data_v_c[1] = 
                                ((ll_valid_c & (in_frame_r  || !TX_SOF_N)) & !TX_EOF_N & (TX_REM_TO_DATAPATH >= 6'd9)  ) ? 1'b1 :                                
                                (ll_valid_c & (in_frame_r  || !TX_SOF_N) & (TX_REM_TO_DATAPATH == 6'd0)) ?1'b1:                                                              
                                1'b0 ;
 
     assign tx_pe_data_v_c[2] = 
                                ((ll_valid_c & (in_frame_r  || !TX_SOF_N)) & !TX_EOF_N & (TX_REM_TO_DATAPATH >= 6'd17)  ) ? 1'b1 :                                
                                (ll_valid_c & (in_frame_r  || !TX_SOF_N) & (TX_REM_TO_DATAPATH == 6'd0)) ?1'b1:                                                              
                                1'b0 ;
 
     assign tx_pe_data_v_c[3] = 
                                ((ll_valid_c & (in_frame_r  || !TX_SOF_N)) & !TX_EOF_N & (TX_REM_TO_DATAPATH >= 6'd25)  ) ? 1'b1 :                                
                                (ll_valid_c & (in_frame_r  || !TX_SOF_N) & (TX_REM_TO_DATAPATH == 6'd0)) ?1'b1:                                                              
                                1'b0 ;
 
     assign tx_pe_data_v_c[4] = 
                                ((ll_valid_c & (in_frame_r  || !TX_SOF_N)) & !TX_EOF_N & (TX_REM_TO_DATAPATH >= 6'd33)  ) ? 1'b1 :                                
                                (ll_valid_c & (in_frame_r  || !TX_SOF_N) & (TX_REM_TO_DATAPATH == 6'd0)) ?1'b1:                                                              
                                1'b0 ;
 
     assign tx_pe_data_v_c[5] = 
                                ((ll_valid_c & (in_frame_r  || !TX_SOF_N)) & !TX_EOF_N & (TX_REM_TO_DATAPATH >= 6'd41)  ) ? 1'b1 :                                
                                (ll_valid_c & (in_frame_r  || !TX_SOF_N) & (TX_REM_TO_DATAPATH == 6'd0)) ?1'b1:                                                              
                                1'b0 ;
 
     assign tx_pe_data_v_c[6] = 
                                ((ll_valid_c & (in_frame_r  || !TX_SOF_N)) & !TX_EOF_N & (TX_REM_TO_DATAPATH >= 6'd49)  ) ? 1'b1 :                                
                                (ll_valid_c & (in_frame_r  || !TX_SOF_N) & (TX_REM_TO_DATAPATH == 6'd0)) ?1'b1:                                                              
                                1'b0 ;
 
     assign tx_pe_data_v_c[7] = 
                                ((ll_valid_c & (in_frame_r  || !TX_SOF_N)) & !TX_EOF_N & (TX_REM_TO_DATAPATH >= 6'd57)  ) ? 1'b1 :                                
                                (ll_valid_c & (in_frame_r  || !TX_SOF_N) & (TX_REM_TO_DATAPATH == 6'd0)) ?1'b1:                                                              
                                1'b0 ;
 
 
     // Implement the data out register.
     always @(posedge USER_CLK)
     begin
         TX_PE_DATA      <=  `DLY    tx_pe_data_c;
         TX_PE_DATA_V    <=  `DLY    tx_pe_data_v_c;
     end
 
 endmodule
