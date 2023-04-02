/*-----------------------------------------------------------------------------*/
/*  Common header for saxi2maxi.v                                              */
/*-----------------------------------------------------------------------------*/

/*---- DEBUG-MODE ----*/
//`define			DEBUG_EN

/*---- Master AXI I/F ----*/
`define			M_ENABLE
`define			M_ID_BITS				16			// 4=AXI3, 8=AXI4
`define			M_ADR_BITS				40			// 32/64
`define			M_LEN_BITS				 8			// 4=AXI3, 8=AXI4
`define			M_DATA_BITS			   256			// 32/64/128/256/512
`define			MLT_OUT_EN				 0			// Multiple Outstanding Enable 0:Diseable 1:Enable

/*---- Slave AXI I/F ----*/
`define			S_ENABLE
`define			S_ID_BITS				16			// 4=AXI3, 8=AXI4
`define			S_ADR_BITS				40			// 32/64
`define			S_LEN_BITS				 8			// 4=AXI3, 8=AXI4
`define			S_DATA_BITS			   256			// 32/64/128/256/512

/*---- Aurora AXI I/F ----*/
`define			A_LANE_BITS			     8			// 1/2/3/4/8
`define			A_DATA_BITS			   512			// 16/32/48/64/128/192/256/512

/*---- FIFO I/F ----*/
`define			ADR_FIFO_WORD			 8			// 4/8/16/32/64
`define			DAT_FIFO_WORD			 8			// 4/8/16/32/64

/*---- BUFF I/F ----*/
`define			LEN_WORD				 8			// 8/16/32/64/128/256
`define			LEN_CNT_BIT				 3			// 3/ 4/ 5/ 6/  7/  8
`define			BUFF_WORD			   128			// 8/16/32/64/128/256
`define			BUFF_CNT_BIT			 7			// 3/ 4/ 5/ 6/  7/  8

/*---- READ/WRITE ACCESS ----*/
`define			RW_ORDER				 1			// 0:Diseable 1:Enable



