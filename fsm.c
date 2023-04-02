siml_lmring_axi(cid, trace) Uint cid, trace;
{
  int    i, k;
  int    bro_ful2, bro_av;
  struct lmring_br *bro[LMRING_MUX]; /* wire */

  if (bro_ful2 && bro[0]->rw==1) { /* WR¤ÏÌµ¾ò·ï¤Ëdequeue */
    /* write¤Î¾ì¹ç,UNITËè¤ËreqnÉüµ¢.¸åÃÊ¤òÂÔ¤¿¤Ê¤¤ */
    axiif[cid].deq_wait = 0; /* ¾åÎ®axi¤Ë¤è¤ëdeq-OK */
    axiif[cid].reqn--;
    axiif[cid].axi_rvalid = 0; /* ¾åÎ®axi¤ÏreadÉÔ²Ä */
¡úºÑif (cid < EMAX_NCHIP-1)                   ¡Ú¡ú¡ú¡ú£Â¡ú¡ú¡ú¡Û
¡úºÑ  axiif[cid+1].axi_rready = 0; /* ²¼Î®axi¤«¤é¤Î¼õ¼èÉÔ²Ä */
    if (!bro_av)
      printf("%03.3d:BRO WR no unit covers ty=%x adr=%08.8x(%08.8x) (maybe out-of-order/speculative load)\n", cid, bro[0]->ty, bro[0]->a, bro[0]->a-reg_ctrl.i[cid].adtr);
  }
  else if (bro_ful2 && bro[0]->rw==0) { /* lmring¤ËRDÍ×µáÍ­¤ê */¡Ú¡ú¡ú¡ú£Ã¡ú¡ú¡ú¡Û
¡úºÑif (!axiif[cid].axi_rready) { /* ¾åÎ®¤¬¶õ¤¤¤Æ¤¤¤Ê¤¤ */¡Ú¡ú¡ú¡ú£Ã¡ú¡ú¡ú¡Û
      axiif[cid].deq_wait = 1; /* ¾åÎ®axi¤Ë¤è¤ëdeq-ÉÔ²Ä */
      axiif[cid].axi_rvalid = 0; /* ¾åÎ®axi¤ÏreadÉÔ²Ä */
¡úºÑ  if (cid < EMAX_NCHIP-1)
¡úºÑ	axiif[cid+1].axi_rready = 0; /* ²¼Î®axi¤«¤é¤Î¼õ¼èÉÔ²Ä */
    }
¡úºÑelse if (cid < EMAX_NCHIP-1 && !axiif[cid+1].axi_rvalid) { /* ²¼Î®¤«¤é²¿¤â¤Ê¤· */¡Ú¡ú¡ú¡ú£Ã¡ú¡ú¡ú¡Û
      printf("%03.3d:BRO waiting for next IMAX[%d]\n", cid, cid+1);
      axiif[cid].deq_wait = 1; /* ¾åÎ®axi¤Ë¤è¤ëdeq-ÉÔ²Ä */
      axiif[cid].axi_rvalid = 0; /* ¾åÎ®axi¤ÏreadÉÔ²Ä */
¡úºÑ  axiif[cid+1].axi_rready = 1; /* ¼õ¿®²ÄÇ½¤ËÊÑ¹¹ */
    }
    else { /* ²¼Î®¤«¤é¼õ¼è */¡Ú¡ú¡ú¡ú£Ã¡ú¡ú¡ú¡Û
      for (k=0; k<UNIT_WIDTH; k++) {
¡úºÑ	if (cid < EMAX_NCHIP-1)
¡úºÑ	  axiif[cid].axi_rdata[k] = axiif[cid+1].axi_rdata[k];
	else
¡úºÑ	  axiif[cid].axi_rdata[k] = 0LL;
	for (i=0; i<LMRING_MUX; i++) {
	  if (bro[i]->av)
	    axiif[cid].axi_rdata[k] |= bro[i]->d[k];
	}
      }
      axiif[cid].deq_wait = 0; /* ¾åÎ®axi¤Ë¤è¤ëdeq-OK */
      axiif[cid].reqn--;
      axiif[cid].axi_rvalid = 1; /* ¾åÎ®axi¤Ïread-OK */
¡úºÑ  if (cid < EMAX_NCHIP-1)¡Ú¡ú¡ú¡ú£Ã¡ú¡ú¡ú¡Û
¡úºÑ	axiif[cid+1].axi_rready = 1;
      if (!bro_av)
	printf("%03.3d:BRO RD no unit covers ty=%x adr=%08.8x(%08.8x) (maybe out-of-order/speculative load)\n", cid, bro[0]->ty, bro[0]->a, bro[0]->a-reg_ctrl.i[cid].adtr);
    }
  }
  else if (axiif[cid].creg) { /* RD control regs */
    /* CREG¤Ï¸åÃÊIMAX¤ËÁ÷¿®¤·¤Ê¤¤¡¥ÀèÆ¬¤Î¤ß±þÅú */
    for (k=0; k<UNIT_WIDTH; k++)
      axiif[cid].axi_rdata[k] = *((Ull*)((Uchar*)&reg_ctrl.i[cid]+(axiif[cid].sadr-REG_BASE2_PHYS))+k);
    axiif[cid].axi_rvalid = 1; /* ¾åÎ®axi¤Ïread-OK */
    axiif[cid].creg = 0; /* reset RD control regs */
  }
  else {
    axiif[cid].deq_wait = 1; /* ¾åÎ®axi¤Ë¤è¤ëdeq-ÉÔ²Ä */
    axiif[cid].axi_rvalid = 0; /* ¾åÎ®axi¤ÏreadÉÔ²Ä */
¡úºÑif (cid < EMAX_NCHIP-1)¡Ú¡ú¡ú¡ú£Ã¡ú¡ú¡ú¡Û
¡úºÑ  axiif[cid+1].axi_rready = 0; /* ²¼Î®axi¤«¤é¤Î¼õ¼èÉÔ²Ä */
  }

  return (0);
}

siml_axi_lmring(cid, trace) Uint cid, trace;
{
  int    i, k, mask;
  int    bri_ful2 = axiif[cid].axring_ful2;
  struct axring_br *bri = &axiif[cid].axring_br[axiif[cid].axring_b_top]; /* AXI->EMAXÂ¦ */
¡úºÑaxiif[cid].axi_arready = (bri_ful2 < AXRING_BR_BUF && !axiif[cid].radr_recv && (cid == EMAX_NCHIP-1 || axiif[cid+1].axi_arready));
¡úºÑaxiif[cid].axi_awready = (bri_ful2 < AXRING_BR_BUF && !axiif[cid].wadr_recv && (cid == EMAX_NCHIP-1 || axiif[cid+1].axi_awready));
¡úºÑaxiif[cid].axi_wready  = (bri_ful2 < AXRING_BR_BUF                          && (cid == EMAX_NCHIP-1 || axiif[cid+1].axi_wready));

  if (axiif[cid].axi_arvalid && axiif[cid].axi_arready) { /* new read_req starts */
    axiif[cid].radr_recv = 1; /* fin */
    axiif[cid].srw  = 0; /* read */
    axiif[cid].sadr = axiif[cid].axi_araddr;
    axiif[cid].slen = axiif[cid].axi_arlen;
    axiif[cid].sreq = 0;
¡úºÑif (cid < EMAX_NCHIP-1) {¡Ú¡ú¡ú¡ú£Ç¡ú¡ú¡ú¡Û
¡úºÑ  axiif[cid+1].axi_araddr   = axiif[cid].axi_araddr;
¡úºÑ  axiif[cid+1].axi_arlen    = axiif[cid].axi_arlen;
¡úºÑ  axiif[cid+1].axi_arvalid  = 1; /* on */
    }
  }
  else if (axiif[cid].radr_recv) {
    Uint a;
¡úºÑif (cid < EMAX_NCHIP-1 && axiif[cid+1].axi_arvalid && axiif[cid+1].axi_arready)¡Ú¡ú¡ú¡ú£È¡ú¡ú¡ú¡Û
¡úºÑ  axiif[cid+1].axi_arvalid = 0; /* off */
    a = axiif[cid].sadr;
    if (a < REG_BASE2_PHYS+REG_CONF_OFFS) { /* control space ... ¸ÇÄê°ÌÃÖ *//* ËÜÍè¤Ïbri_ful2¤Î±Æ¶Á¤ò¼õ¤±¤Ê¤¤¤¬,Åý°ì´ÉÍý¤Î¤¿¤á¤Ëbri_ful2¤ò»ÈÍÑ */
      axiif[cid].radr_recv = 0; /* reset */
      axiif[cid].creg = 1; /* set RD control regs */
    }
    else if (axiif[cid].sreq <= axiif[cid].slen) { /* (burst 256bit_LMM -> 256bit_AXI_read (256bit*256count = 8KB)) */
      if (bri_ful2 < AXRING_BR_BUF) {
	if (axiif[cid].sreq == axiif[cid].slen)
	  axiif[cid].radr_recv = 0; /* reset */
	bri->rw   = 0; /* read */
	bri->ty   = ( a              >=LMM_BASE2_PHYS) ? 4 : /* lmm  */
                    ((a&REG_AREA_MASK)>=REG_LDDM_OFFS) ? 3 : /* lddm */
                    ((a&REG_AREA_MASK)>=REG_ADDR_OFFS) ? 2 : /* addr */
                    ((a&REG_AREA_MASK)>=REG_BREG_OFFS) ? 1 : /* breg */
                                                       0 ; /* conf */
	bri->col  = reg_ctrl.i[cid].csel; /* logical col# for target lmm */
	bri->sq   = axiif[cid].sreq; /* from axiif[cid].axi_awlen to 0 */
	bri->av   = 0; /* initial */
	bri->a    = a + ((bri->ty==4)?reg_ctrl.i[cid].adtr:0) + axiif[cid].sreq*sizeof(Ull)*UNIT_WIDTH;
	bri->d[0] = 0;
	bri->d[1] = 0;
	bri->d[2] = 0;
	bri->d[3] = 0;
	axiif[cid].reqn++;
	axiif[cid].sreq++;
	axiif[cid].axring_ful2++;
	axiif[cid].axring_b_top = (axiif[cid].axring_b_top + 1)%AXRING_BR_BUF;
      }
    }
  }
  else if (axiif[cid].axi_awvalid && axiif[cid].axi_awready) {
    axiif[cid].wadr_recv = 1; /* fin */
    axiif[cid].srw  = 1; /* write */
    axiif[cid].sadr = axiif[cid].axi_awaddr;
    axiif[cid].slen = axiif[cid].axi_awlen;
    axiif[cid].sreq = 0;
¡úºÑif (cid < EMAX_NCHIP-1) {¡Ú¡ú¡ú¡ú£Æ¡ú¡ú¡ú¡Û
¡úºÑ  axiif[cid+1].axi_awaddr   = axiif[cid].axi_awaddr;
¡úºÑ  axiif[cid+1].axi_awlen    = axiif[cid].axi_awlen;
¡úºÑ  axiif[cid+1].axi_awvalid  = 1; /* on */
    }
  }
  else if (axiif[cid].wadr_recv) {
    Uint a;
¡úºÑif (cid < EMAX_NCHIP-1 && axiif[cid+1].axi_awvalid && axiif[cid+1].axi_awready)
¡úºÑ  axiif[cid+1].axi_awvalid = 0; /* off */
    a = axiif[cid].sadr;
    if (a < REG_BASE2_PHYS+REG_CONF_OFFS) { /* control space ... ¸ÇÄê°ÌÃÖ *//* ËÜÍè¤Ïbri_ful2¤Î±Æ¶Á¤ò¼õ¤±¤Ê¤¤¤¬,Åý°ì´ÉÍý¤Î¤¿¤á¤Ëbri_ful2¤ò»ÈÍÑ */
      if (axiif[cid].axi_wvalid && axiif[cid].axi_wready) {
        axiif[cid].wadr_recv = 0; /* reset */
        if      (axiif[cid].axi_wstrb & 0x000000ff) { k=0; mask=axiif[cid].axi_wstrb     & 0xff; }
        else if (axiif[cid].axi_wstrb & 0x0000ff00) { k=1; mask=axiif[cid].axi_wstrb>> 8 & 0xff; }
        else if (axiif[cid].axi_wstrb & 0x00ff0000) { k=2; mask=axiif[cid].axi_wstrb>>16 & 0xff; }
        else if (axiif[cid].axi_wstrb & 0xff000000) { k=3; mask=axiif[cid].axi_wstrb>>24 & 0xff; }
        if (mask & 0x0f)
¡úºÑ      *((Uint*)((Ull*)((Uchar*)&reg_ctrl.i[cid]+(a-REG_BASE2_PHYS))+k)  ) = axiif[cid].axi_wdata[k];¡Ú¡ú¡ú¡ú£Ä¡ú¡ú¡ú¡Û
        if (mask & 0xf0)
¡úºÑ      *((Uint*)((Ull*)((Uchar*)&reg_ctrl.i[cid]+(a-REG_BASE2_PHYS))+k)+1) = axiif[cid].axi_wdata[k]>>32;
¡úºÑ    if (cid < EMAX_NCHIP-1) {
¡úºÑ      axiif[cid+1].axi_wstrb    = axiif[cid].axi_wstrb    | (a==REG_BASE2_PHYS?0x00f00000:0x00000000); /* set cid=0,1,2,3 */;
¡úºÑ      axiif[cid+1].axi_wdata[0] = axiif[cid].axi_wdata[0];
¡úºÑ      axiif[cid+1].axi_wdata[1] = axiif[cid].axi_wdata[1];
¡úºÑ      axiif[cid+1].axi_wdata[2] = axiif[cid].axi_wdata[2] + (a==REG_BASE2_PHYS?0x100000000LL:0x000000000LL); /* set cid=0,1,2,3 */
¡úºÑ      axiif[cid+1].axi_wdata[3] = axiif[cid].axi_wdata[3];
¡úºÑ      axiif[cid+1].axi_wvalid   = 1; /* on */
¡úºÑ      axiif[cid+1].axi_wlast    = 1; /* on */
        }
        switch (reg_ctrl.i[cid].cmd) {
        case CMD_RESET:
        case CMD_SCON:  /* scon */
        case CMD_EXEC:  /* exec */
          if (!exring[cid].cmd_busy) {
            printf("%03.3d:ES %08.8x_%08.8x cycle=%08.8x_%08.8x ---EMAX6 CMD(%x) START---\n", cid,
                   (Uint)(t[cid].total_steps>>32), (Uint)t[cid].total_steps,
                   (Uint)(t[cid].total_cycle>>32), (Uint)t[cid].total_cycle, reg_ctrl.i[cid].cmd);
            exring[cid].cmd_busy = 1;
          }
          break;
        }
      }
      else {
¡úºÑ    if (cid < EMAX_NCHIP-1)
¡úºÑ      axiif[cid+1].axi_wvalid   = 0; /* off */
      }
    }
    else if (axiif[cid].sreq <= axiif[cid].slen) { /* 0-3:conf/breg/addr/lddm, 4:lmm (burst 256bit_AXI_write -> 256bit_LMM (256bit*256count = 8KB)) */
      if (axiif[cid].axi_wvalid && axiif[cid].axi_wready) {
        if (axiif[cid].sreq == axiif[cid].slen)
          axiif[cid].wadr_recv = 0; /* reset */
        bri->rw   = 1; /* write */
        bri->ty   = ( a              >=LMM_BASE2_PHYS) ? 4 : /* lmm  */
                    ((a&REG_AREA_MASK)>=REG_LDDM_OFFS) ? 3 : /* lddm */
                    ((a&REG_AREA_MASK)>=REG_ADDR_OFFS) ? 2 : /* addr */
                    ((a&REG_AREA_MASK)>=REG_BREG_OFFS) ? 1 : /* breg */
                                                         0 ; /* conf */
        bri->col  = reg_ctrl.i[cid].csel;   /* logical col# for target lmm */
        bri->sq   = axiif[cid].sreq; /* from 0 to axiif[cid].axi_awlen */
        bri->av   = 0; /* initial */
        bri->a    = a + ((bri->ty==4)?reg_ctrl.i[cid].adtr:0) + axiif[cid].sreq*sizeof(Ull)*UNIT_WIDTH;
        bri->dm   = axiif[cid].axi_wstrb;
        bri->d[0] = axiif[cid].axi_wdata[0];
        bri->d[1] = axiif[cid].axi_wdata[1];
        bri->d[2] = axiif[cid].axi_wdata[2];
        bri->d[3] = axiif[cid].axi_wdata[3];
        axiif[cid].reqn++;
        axiif[cid].sreq++;
        axiif[cid].axring_ful2++;
        axiif[cid].axring_b_top = (axiif[cid].axring_b_top + 1)%AXRING_BR_BUF;
¡úºÑ    if (cid < EMAX_NCHIP-1) {
¡úºÑ      axiif[cid+1].axi_wstrb    = axiif[cid].axi_wstrb;¡Ú¡ú¡ú¡ú£Å¡ú¡ú¡ú¡Û
¡úºÑ      axiif[cid+1].axi_wdata[0] = axiif[cid].axi_wdata[0];
¡úºÑ      axiif[cid+1].axi_wdata[1] = axiif[cid].axi_wdata[1];
¡úºÑ      axiif[cid+1].axi_wdata[2] = axiif[cid].axi_wdata[2];
¡úºÑ      axiif[cid+1].axi_wdata[3] = axiif[cid].axi_wdata[3];
¡úºÑ      axiif[cid+1].axi_wvalid   = 1; /* on */
          if (axiif[cid].sreq == axiif[cid].slen)
¡úºÑ        axiif[cid+1].axi_wlast  = 1; /* on */
          else
¡úºÑ        axiif[cid+1].axi_wlast  = 0; /* off */
        }
      }
      else {
¡úºÑ    if (cid < EMAX_NCHIP-1)
¡úºÑ      axiif[cid+1].axi_wvalid   = 0; /* off */
      }
    }
  }
  else {
¡ú¡úif (cid < EMAX_NCHIP-1)
¡ú¡ú  axiif[cid+1].axi_wvalid   = 0; /* off */
    if (reg_ctrl.i[cid].cmd == CMD_RESET) {
      axiif[cid].wadr_recv      = 0;
      axiif[cid].radr_recv      = 0;
      axiif[cid].reqn           = 0;
      axiif[cid].creg           = 0;
      axiif[cid].srw            = 0;
      axiif[cid].sadr           = 0;
      axiif[cid].slen           = 0;
      axiif[cid].sreq           = 0;
      axiif[cid].axring_ful2    = 0;
      axiif[cid].axring_b_top   = 0;
      axiif[cid].axring_b_bot   = 0;
      axiif[cid].exring_deq_wait= 0;
    }
    if ((exring[cid].cycle & 3) == 3) {
      reg_ctrl.i[cid].cmd = CMD_NOP;
      exring[cid].cmd_busy = 0;
    }
  }

  if (bri_ful2 && !axiif[cid].exring_deq_wait) { /* dequeued for next cycle */
    axiif[cid].axring_ful2--;
    axiif[cid].axring_b_bot = (axiif[cid].axring_b_bot + 1)%AXRING_BR_BUF;
  }

  if ((exring[cid].cycle & 3) == 3 && reg_ctrl.i[cid].cmd == CMD_RESET)
    exring[cid].cycle = 0;
  else
    exring[cid].cycle++;

  return (0);
}
