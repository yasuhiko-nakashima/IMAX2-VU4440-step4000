
/* 行列計算を使った,spu精度テスト                      */
/*                        Copyright (C) 2013- by NAIST */
/*                         Primary writer: Y.Nakashima */
/*                                nakashim@is.naist.jp */

#ifndef UTYPEDEF
#define UTYPEDEF
typedef unsigned char      Uchar;
typedef unsigned short     Ushort;
typedef unsigned int       Uint;
typedef unsigned long long Ull;
typedef long long int      Sll;
#if __AARCH64EL__ == 1
typedef long double Dll;
#else
typedef struct {Ull u[2];} Dll;
#endif
#endif

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <fcntl.h>
#include <math.h>
#ifndef ARMSIML
#include <unistd.h>
#include <sys/times.h>
#include <sys/mman.h>
#include <sys/resource.h>
#include <pthread.h>
#include <X11/Xlib.h>
#include <X11/Xatom.h>
#include <X11/Xutil.h>
#include <X11/cursorfont.h>
#include <X11/extensions/Xdbe.h>
#endif

#if !defined(ARMSIML)
/***********/
/* for X11 */
/***********/
Display              *disp;          /* display we're sending to */
int                  scrn;           /* screen we're sending to */

typedef struct {
  unsigned int  width;  /* width of image in pixels */
  unsigned int  height; /* height of image in pixels */
  unsigned char *data;  /* data rounded to full byte for each row */
} Image;

typedef struct {
  Display  *disp;       /* destination display */
  int       scrn;       /* destination screen */
  int       depth;      /* depth of drawable we want/have */
  int       dpixlen;    /* bitsPerPixelAtDepth */
  Drawable  drawable;   /* drawable to send image to */
  Colormap  cmap;       /* colormap used for image */
  GC        gc;         /* cached gc for sending image */
  XImage   *ximage;     /* ximage structure */
} XImageInfo;

union {
  XEvent              event;
  XAnyEvent           any;
  XButtonEvent        button;
  XExposeEvent        expose;
  XMotionEvent        motion;
  XResizeRequestEvent resize;
  XClientMessageEvent message;
} event;

unsigned int          redvalue[256], greenvalue[256], bluevalue[256];
XImageInfo            ximageinfo;
Image                 imageinfo;  /* image that will be sent to the display */
unsigned int          bitsPerPixelAtDepth();
void                  imageInWindow();
void                  bestVisual();

#define TRUE_RED(PIXVAL)      (((PIXVAL) & 0xff0000) >> 16)
#define TRUE_GREEN(PIXVAL)    (((PIXVAL) &   0xff00) >>  8)
#define TRUE_BLUE(PIXVAL)     (((PIXVAL) &     0xff)      )

void x11_open(int width, int height, int screen_wd, int screen_ht)
{
  if (!(disp = XOpenDisplay(NULL))) {
    printf("%s: Cannot open display\n", XDisplayName(NULL));
    exit(1);
  }
  scrn = DefaultScreen(disp);
  imageinfo.width = width*screen_wd;
  imageinfo.height= height*screen_ht;
  /*imageinfo.data  = malloc(sizeof(Uint)*imageinfo.width*imageinfo.height);*/
  imageInWindow(&ximageinfo, disp, scrn, &imageinfo);
}

void x11_update()
{
  XPutImage(ximageinfo.disp, ximageinfo.drawable, ximageinfo.gc,
            ximageinfo.ximage, 0, 0, 0, 0, imageinfo.width, imageinfo.height);
}

int x11_checkevent()
{
  static int stop = 0;

  x11_update();
  while (XPending(disp)) {
    XNextEvent(disp, &event.event);
    switch (event.any.type) {
    case KeyPress:
      stop = 1-stop;
      if   (stop) printf("//-stopped- (type any key to continue)\n");
      else        printf("//-running-\n");
      break;
    default:
      break;
    }
  }
  return (stop);
}

void x11_close()
{
  XCloseDisplay(disp);
}

void imageInWindow(ximageinfo, disp, scrn, image)
     XImageInfo   *ximageinfo;
     Display      *disp;
     int           scrn;
     Image        *image;
{
  Window                ViewportWin;
  Visual               *visual;
  unsigned int          depth;
  unsigned int          dpixlen;
  XSetWindowAttributes  swa_view;
  XSizeHints            sh;
  unsigned int pixval;
  unsigned int redcolors, greencolors, bluecolors;
  unsigned int redstep, greenstep, bluestep;
  unsigned int redbottom, greenbottom, bluebottom;
  unsigned int redtop, greentop, bluetop;
  XColor        xcolor;
  unsigned int  a;
  XGCValues gcv;

  bestVisual(disp, scrn, &visual, &depth);
  dpixlen = (bitsPerPixelAtDepth(disp, depth) + 7) / 8;

  ximageinfo->disp    = disp;
  ximageinfo->scrn    = scrn;
  ximageinfo->depth   = depth;
  ximageinfo->dpixlen = dpixlen;
  ximageinfo->drawable= None;
  ximageinfo->gc      = NULL;
  ximageinfo->ximage  = XCreateImage(disp, visual, depth, ZPixmap, 0,
                                     NULL, image->width, image->height,
                                     8, 0);
  ximageinfo->ximage->data= (char*)malloc(image->width * image->height * dpixlen);
  ximageinfo->ximage->byte_order= MSBFirst; /* trust me, i know what
                                             * i'm talking about */

  if (visual == DefaultVisual(disp, scrn))
    ximageinfo->cmap= DefaultColormap(disp, scrn);
  else
    ximageinfo->cmap= XCreateColormap(disp, RootWindow(disp, scrn), visual, AllocNone);

  redcolors= greencolors= bluecolors= 1;
  for (pixval= 1; pixval; pixval <<= 1) {
    if (pixval & visual->red_mask)
      redcolors <<= 1;
    if (pixval & visual->green_mask)
      greencolors <<= 1;
    if (pixval & visual->blue_mask)
      bluecolors <<= 1;
  }

  redtop   = 0;
  greentop = 0;
  bluetop  = 0;
  redstep  = 256 / redcolors;
  greenstep= 256 / greencolors;
  bluestep = 256 / bluecolors;
  redbottom= greenbottom= bluebottom= 0;
  for (a= 0; a < visual->map_entries; a++) {
    if (redbottom < 256)
      redtop= redbottom + redstep;
    if (greenbottom < 256)
      greentop= greenbottom + greenstep;
    if (bluebottom < 256)
      bluetop= bluebottom + bluestep;

    xcolor.flags= DoRed | DoGreen | DoBlue;
    xcolor.red  = (redtop - 1) << 8;
    xcolor.green= (greentop - 1) << 8;
    xcolor.blue = (bluetop - 1) << 8;
    XAllocColor(disp, ximageinfo->cmap, &xcolor);

    while ((redbottom < 256) && (redbottom < redtop))
      redvalue[redbottom++]= xcolor.pixel & visual->red_mask;
    while ((greenbottom < 256) && (greenbottom < greentop))
      greenvalue[greenbottom++]= xcolor.pixel & visual->green_mask;
    while ((bluebottom < 256) && (bluebottom < bluetop))
      bluevalue[bluebottom++]= xcolor.pixel & visual->blue_mask;
  }

  swa_view.background_pixel= WhitePixel(disp,scrn);
  swa_view.backing_store= WhenMapped;
  swa_view.cursor= XCreateFontCursor(disp, XC_watch);
  swa_view.event_mask= ButtonPressMask | Button1MotionMask | KeyPressMask |
    StructureNotifyMask | EnterWindowMask | LeaveWindowMask | ExposureMask;
  swa_view.save_under= False;
  swa_view.bit_gravity= NorthWestGravity;
  swa_view.save_under= False;
  swa_view.colormap= ximageinfo->cmap;
  swa_view.border_pixel= 0;
  ViewportWin= XCreateWindow(disp, RootWindow(disp, scrn), 0, 0,
                             image->width, image->height, 0,
                             DefaultDepth(disp, scrn), InputOutput,
                             DefaultVisual(disp, scrn),
                             CWBackingStore | CWBackPixel |
                             CWEventMask | CWSaveUnder,
                             &swa_view);
  ximageinfo->drawable= ViewportWin;

  gcv.function= GXcopy;
  ximageinfo->gc= XCreateGC(ximageinfo->disp, ximageinfo->drawable, GCFunction, &gcv);

  sh.width= image->width;
  sh.height= image->height;
  sh.min_width= image->width;
  sh.min_height= image->height;
  sh.max_width= image->width;
  sh.max_height= image->height;
  sh.width_inc= 1;
  sh.height_inc= 1;
  sh.flags= PMinSize | PMaxSize | PResizeInc | PSize;
  XSetNormalHints(disp, ViewportWin, &sh);

  XStoreName(disp, ViewportWin, "rsim");
  XMapWindow(disp, ViewportWin);
  XSync(disp,False);
}

void bestVisual(disp, scrn, rvisual, rdepth)
     Display       *disp;
     int            scrn;
     Visual       **rvisual;
     unsigned int  *rdepth;
{
  unsigned int  depth, a;
  Screen       *screen;
  XVisualInfo template, *info;
  int nvisuals;

  /* figure out the best depth the server supports.  note that some servers
   * (such as the HP 11.3 server) actually say they support some depths but
   * have no visuals that support that depth.  seems silly to me....
   */
  depth = 0;
  screen= ScreenOfDisplay(disp, scrn);
  for (a= 0; a < screen->ndepths; a++) {
    if (screen->depths[a].nvisuals &&
        ((!depth ||
          ((depth < 24) && (screen->depths[a].depth > depth)) ||
          ((screen->depths[a].depth >= 24) &&
           (screen->depths[a].depth < depth)))))
      depth= screen->depths[a].depth;
  }
  template.screen= scrn;
  template.class= TrueColor;
  template.depth= depth;
  if (! (info= XGetVisualInfo(disp, VisualScreenMask | VisualClassMask | VisualDepthMask, &template, &nvisuals)))
    *rvisual= NULL; /* no visuals of this depth */
  else {
    *rvisual= info->visual;
    XFree((char *)info);
  }
  *rdepth= depth;
}

unsigned int bitsPerPixelAtDepth(disp, depth)
     Display      *disp;
     unsigned int  depth;
{
  XPixmapFormatValues *xf;
  unsigned int nxf, a;

  xf = XListPixmapFormats(disp, (int *)&nxf);
  for (a = 0; a < nxf; a++)
    if (xf[a].depth == depth)
      return(xf[a].bits_per_pixel);

  fprintf(stderr, "bitsPerPixelAtDepth: Can't find pixmap depth info!\n");
  exit(1);
}
#endif

Uchar* membase;

sysinit(memsize, alignment) Uint memsize, alignment;
{
  membase = (void*)malloc(memsize+alignment);
  if ((int)membase & (alignment-1))
    membase = (void*)(((int)membase & ~(alignment-1))+alignment);
}

/* LMM:16KB, RMM:64KB: M/NCHIP=124 M/NCHIP/RMGRP=31 */
/*#define M 4096*/
#define M 224
#define RMGRP 1
/*#define NCHIP 4*/
#define NCHIP 1
/*#define W 1*/
#define H 1
Uchar *A;   /*[M][M];*/
Uchar *B;   /*[M][M];*/
Uchar *C;   /*[M][M];*/
int top, blk, h;
int count0, count1, count2;

#define MAXINT (~(1<<(sizeof(int)*8-1)))
#define ERRTH  (2.0E-2)
#define TH1 0x2
#define TH2 0xff
#define TH3 0xfff

#define abs(a)     ((a)>  0 ? (a) :-(a)    )
#define sub0(a, b) ((a)<=(b)? (0) : (a)-(b))
#define max(a, b)  ((a)>=(b)? (a) : (b)    )

#define  WD      M
#define  HT      M
#define  BITMAP  (WD*HT)
#define  SCRWD   4
#define  SCRHT   2

void BGR_to_X(int id, Uint *from)
{
  int i, j;
  Uint *to;

  to = (Uint*)(ximageinfo.ximage->data)+BITMAP*SCRWD*(id/SCRWD)+WD*(id%SCRWD);
  for (i=0; i<HT; i++,to+=WD*(SCRWD-1)) {
    for (j=0; j<WD; j++)
      *to++ = *from++;
  }
}

/******************************************************************************************************************************************/
/*** SPU **********************************************************************************************************************************/
/******************************************************************************************************************************************/

Ull urand(int no)
{
  static Ull urand_seed[8]
    = {0xc3c3c3c3a5a5a5a5LL, 0x123456789abcdef0LL, 0xe1e1e1e1d4d4d4d4LL, 0x8888777766665555LL,
       0x8787878796969696LL, 0xfedcba9876543210LL, 0x5a5a5a5a3c3c3c3cLL, 0xbbbbccccddddeeeeLL};
  Ull retval = urand_seed[no];

//urand_seed = urand_seed * 1103515245LL + 12345LL;

  urand_seed[no] ^= (urand_seed[no]<<29);
  urand_seed[no] ^= (urand_seed[no]>>27);
  urand_seed[no] ^= (urand_seed[no]<<37);
  return (retval);
}

int softu64(int stage, Ull *o1, Ull *o2, Uchar *o3, Uchar r1, Ull r2, Ull r3, Uint r4) /* o <- s1 + s2 * s3 */
     /* stage:1 stage_2 in EXEC:  r2*r3 64bit*2  -> *o1 32bit*8 b mult     */
     /* stage:2 stage_3 in EXEC:  *o1,r4 32bit*8 -> *o2 8bit+8bit count up */
     /* stage:3 stage_4 in EXEC:  r1 + *o2Σ     -> *o3 8bit               */
{
  int i, j;
  Ull u[8];
  Ull ss[8];
  Ull s2[8], s3[8];
  int pc, nc; /* number of 1 */
  int os, oc;

//#define SPU_DATA_BITS 31
//#define SPU_DATA_DIST 2
//#define SPU_COUT_BITS 31
#define SPU_DATA_BITS 15
#define SPU_DATA_DIST 4
#define SPU_COUT_BITS 12

  switch (stage) {
  case 1: /* stage2 */
    for (i=0; i<8; i++) /* s2 * s3 -> ad2 */
      u[i] = urand(i);
    for (i=0; i<8; i++) { /* s2 * s3 -> ad2 */
      ss[i] = (r2>>(i*8+7))&1 ^ (r3>>(i*8+7))&1;
  int s2e   = (r2>>(i*8))&0x7f; s2e = s2e<SPU_DATA_BITS?s2e:SPU_DATA_BITS;
  int s3e   = (r3>>(i*8))&0x7f; s3e = s3e<SPU_DATA_BITS?s3e:SPU_DATA_BITS;
      // 乱数をSPU_DATA_WIDTH bit毎に使用.入力値の6bitがほとんど15以下であることを利用(63近くなると誤差が出るはず)
      s2[i] = 0LL;
      s3[i] = 0LL;
      for (j=0; j<SPU_COUT_BITS; j++) {
	int k = j * SPU_DATA_DIST; /* SPU_DATA_BITS=15なら4bit毎 */
	s2[i] |= ((u[(i+0)%8]>>k&SPU_DATA_BITS)<=s2e)<<j;
	s3[i] |= ((u[(i+1)%8]>>k&SPU_DATA_BITS)<=s3e)<<j;
      }
      //printf("%08.8x_%08.8x %08.8x_%08.8x %d:%08.8x %d:%08.8x\n", (Uint)(u2>>32), (Uint)u2, (Uint)(u3>>32), (Uint)u3, s2e, (Uint)s2[i], s3e, (Uint)s3[i]);
      // s2*s3 各要素のstochastic乗算
      o1[i] = s2[i] & s3[i];                         // 1*1=1になる 実際は上位SPU_DATA_BITSのみAND
      o1[i] = ss[i]<<63|(o1[i]&0x7fffffffffffffffLL);// stage2の出力は(先頭符号bit|SPU_DATA_BITS bit) * 8
    }
    break;
  case 2: /* stage3 */
    pc = 0;
    nc = 0;
    // 正数/負数グループごとに，下位部分をスナップショット
    for (j=0; j<SPU_COUT_BITS; j++) {
      for (i=0; i<8; i++) { /* s2 * s3 -> ad2 */
	if (!(o1[i]>>63)) pc += (o1[i] & (1LL<<j))!=0;
	else              nc += (o1[i] & (1LL<<j))!=0;
      }
    }
    pc = pc>>r4; // r4=3 for MNIST/CIFAR10
    nc = nc>>r4; // r4=2 for test021
    *o2 = (Ull)(pc&0xffff)<<32 | (Ull)(nc&0xffff);
    break;
  case 3: /* stage4 */
    pc = *o2>>32&0xffff; /* high */
    nc = *o2    &0xffff; /* low */
    // s1をさらに加算
    if (!(r1&0x80)) pc += (r1&0x7f); /* merge pos s1 s1.eは最大7bit */
    else            nc += (r1&0x7f); /* merge neg s1 s1.eは最大7bit */
    // 正数と負数の加算(s1:7bit + s2*s3:6bit->7bit)
    if (pc >= nc) {
      os = 0x00; /* pos */
      oc = pc-nc; /* # of 1 */
    }
    else {
      os = 0x80; /* neg */
      oc = nc-pc; /* # of 1 */
    }
    if (oc >= 128) oc = 127;
    *o3 = os|oc;
    break;
  }

  return (0);
}

int main(int argc, char **argv)
{
  int i, j, k;
  int testbench = 0;

  for(argc--,argv++;argc;argc--,argv++){
    if(**argv == '-'){
      switch(*(*argv+1)){
      case 't':
	testbench = 1;
	break;
      default:
	fprintf(stderr, "Usage: ./fpu                 ... w/o testbench\n");
	fprintf(stderr, "       ./fpu -t > tb_fpu.dat ... w/  testbench\n");
	exit(1);
	break;
      }
    }
  }

  sysinit(M*M
         +M*M
         +M*M,32);
  printf("//membase: %08.8x\n", (Uint)membase);
  A   = (Uchar*)membase;
  B   = (Uchar*)A + M*M;
  C   = (Uchar*)B + M*M;
  printf("//A   : %08.8x\n", A);
  printf("//B   : %08.8x\n", B);
  printf("//C   : %08.8x\n", C);

  x11_open(WD, HT, SCRWD, SCRHT); /*sh_video->disp_w, sh_video->disp_h, # rows of output_screen*/

  for (i=0; i<M; i++) {
    for (k=0; k<M; k++) {
      if (k<M/2)
	A[i*M+k] = 1;
      else
	A[i*M+k] = 0x81;
    }
  }

  for (j=0; j<M; j++) {
    for (k=0; k<M; k++) {
      if (j<M/2)
	B[j*M+k] = 1;
      else
	B[j*M+k] = 0x81;
    }
  }

  for (i=0; i<M; i++) {
    for (j=0; j<M; j++) {
      if (i<M/2)
	C[i*M+j] = 0x00|(i/2);
      else
	C[i*M+j] = 0x80|((i-M/2)/2);
    }
  }

  for (i=0; i<M; i++) {
    for (j=0; j<M; j++) {
      for (k=0; k<M; k+=8) {
	Uchar r1 = C[i*M+j];
	Ull   r2 = (Ull)A[i*M+k+7]<<56|(Ull)A[i*M+k+6]<<48|(Ull)A[i*M+k+5]<<40|(Ull)A[i*M+k+4]<<32|(Ull)A[i*M+k+3]<<24|(Ull)A[i*M+k+2]<<16|(Ull)A[i*M+k+1]<<8|(Ull)A[i*M+k];
	Ull   r3 = (Ull)B[j*M+k+7]<<56|(Ull)B[j*M+k+6]<<48|(Ull)B[j*M+k+5]<<40|(Ull)B[j*M+k+4]<<32|(Ull)B[j*M+k+3]<<24|(Ull)B[j*M+k+2]<<16|(Ull)B[j*M+k+1]<<8|(Ull)B[j*M+k];
	Uint  r4 = 2;
	Ull   ex1_outd_sfma[8];
	Ull   ex2_outd;
	softu64(1, ex1_outd_sfma, NULL,      NULL,    r1, r2, r3, r4);
	softu64(2, ex1_outd_sfma, &ex2_outd, NULL,    r1, r2, r3, r4);
	softu64(3, NULL,          &ex2_outd, C+i*M+j, r1, r2, r3, r4);
	if (testbench) {
	  printf("CHECK_SPU(8'h%02.2x,64'h%08.8x%08.8x,64'h%08.8x%08.8x,8'h%02.2x,8'h%02.2x);\n", (Uint)r1, (Uint)(r2>>32), (Uint)r2, (Uint)(r3>>32), (Uint)r3, (Uint)r4, C[i*M+j]);
	}
      }
    }
  }

  Uint X[M*M];
  for (i=0; i<M*M; i++) X[i] = A[i]<<16;
  BGR_to_X(0, X); /* oginal 32bit input */
  for (i=0; i<M*M; i++) X[i] = B[i]<<16;
  BGR_to_X(1, X); /* oginal  8bit input */
  for (i=0; i<M*M; i++) {
    if      ((C[i]&0x7f) < 0)
      X[i] = 0x00000000;
    else if ((C[i]&0x7f) < 4)
      X[i] = 0x80000000;
    else if ((C[i]&0x7f) < 8)
      X[i] = 0xff000000;
    else if ((C[i]&0x7f) < 12)
      X[i] = 0x00008000;
    else if ((C[i]&0x7f) < 16)
      X[i] = 0x0000ff00;
    else if ((C[i]&0x7f) < 20)
      X[i] = 0x80008000;
    else if ((C[i]&0x7f) < 24)
      X[i] = 0xff00ff00;
    else if ((C[i]&0x7f) < 28)
      X[i] = 0x00800000;
    else if ((C[i]&0x7f) < 32)
      X[i] = 0x00ff0000;
    else if ((C[i]&0x7f) < 36)
      X[i] = 0x00808000;
    else if ((C[i]&0x7f) < 40)
      X[i] = 0x00ffff00;
    else if ((C[i]&0x7f) < 44)
      X[i] = 0x80800000;
    else if ((C[i]&0x7f) < 48)
      X[i] = 0xc0c00000;
    else if ((C[i]&0x7f) < 52)
      X[i] = 0xffff0000;
    else if ((C[i]&0x7f) < 56)
      X[i] = 0x80808000;
    else if ((C[i]&0x7f) < 60)
      X[i] = 0xc0c0c000;
    else
      X[i] = 0xffffff00;
  }
  BGR_to_X(2, X); /* 32bit FMA */

  fprintf(stderr, "==== Normal end. Type any in ImageWin ====\n");
  while (!x11_checkevent());
}
