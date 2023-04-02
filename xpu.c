
/* ¹ÔÎó·×»»¤ò»È¤Ã¤¿,fpu/spu/npuÈæ³Ó                      */
/*                          Copyright (C) 2013- by NAIST */
/*                           Primary writer: Y.Nakashima */
/*                                  nakashim@is.naist.jp */

/* 1<= PEXT <= 23 */
#define PEXT 1
//#define PEXT 23

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

Ull nanosec_sav;
Ull nanosec;
reset_nanosec()
{
  int i;
  nanosec = 0;
  struct timespec ts;
  clock_gettime(0, &ts); /*CLOCK_REALTIME*/
  nanosec_sav = 1000000000*ts.tv_sec + ts.tv_nsec;
}
get_nanosec(int class)
{
  Ull nanosec_now;
  struct timespec ts;
  clock_gettime(0, &ts); /*CLOCK_REALTIME*/
  nanosec_now = 1000000000*ts.tv_sec + ts.tv_nsec;
  nanosec += nanosec_now - nanosec_sav;
  nanosec_sav = nanosec_now;
}
show_nanosec()
{
  printf("nanosec: ARM:%llu\n", nanosec);
}

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
      if   (stop) printf("-stopped- (type any key to continue)\n");
      else        printf("-running-\n");
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

struct f32bit {
  Uint  frac : 23;
  Uint  exp  :  8;
  Uint  s    :  1;
};

struct f8bit {
  Uint  frac : 4;
  Uint  exp  : 3;
  Uint  s    : 1;
};

float *A;
float *B;
float *C;
float *D;
float *E;

#define MAXINT (~(1<<(sizeof(int)*8-1)))
#define ERRTH  (2.0E-2)
#define TH1 0x2
#define TH2 0xff
#define TH3 0xfff

#define abs(a)     ((a)>  0 ? (a) :-(a)    )
#define sub0(a, b) ((a)<=(b)? (0) : (a)-(b))
#define max(a, b)  ((a)>=(b)? (a) : (b)    )

int soft32(Uint, float, float, float, float *);
int hard32(Uint, float, float, float, float *, Uint);
int soft64(Uint, float, float, float, float *);
int hard64(Uint, float, float, float, float *);
char softbuf32[1024];
char hardbuf32[1024];
char softbuf64[1024];
char hardbuf64[1024];

int softf8(float, float, float, float *);
int hards32(Uint, Uint, Uint, Uint *);
int convf32tof8tof32(float, float *);
int convf32tof8(float, struct f8bit *);
int convf8tof32(struct f8bit in_f8, float *);

#define  WD      256
#define  HT      256
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

int main(int argc, char **argv)
{
  int epoch, i, j, k;
  
  sysinit(BITMAP*sizeof(float)
         +BITMAP*sizeof(float)
         +BITMAP*sizeof(float)
         +BITMAP*sizeof(float)
         +BITMAP*sizeof(float), 32);
  A   = (float*)membase;
  B   = (float*)((Uchar*)A  + BITMAP*sizeof(float));
  C   = (float*)((Uchar*)B  + BITMAP*sizeof(float));
  D   = (float*)((Uchar*)C  + BITMAP*sizeof(float));
  E   = (float*)((Uchar*)D  + BITMAP*sizeof(float));

  x11_open(WD, HT, SCRWD, SCRHT); /*sh_video->disp_w, sh_video->disp_h, # rows of output_screen*/

  try_fixed_point();

  while (x11_checkevent());

  try_floating_point();
}

/******************************************************************************************************************************************/
/*** Fixed point               ************************************************************************************************************/
/******************************************************************************************************************************************/

try_fixed_point()
{
  int EPOCH=256;
  int epoch, i, j, k;

  /* repeat test w/ visual */
  while (1) {
    for (epoch=1; epoch<EPOCH; epoch++) {
      for (i=0; i<HT; i++) {
	for (j=0; j<WD; j++) {
	  ((Uint*)A)[i*WD+j] = i<<16|j<<8;
	  ((Uint*)B)[i*WD+j] = i<<16|j<<8;
	}
      }

      for (i=0; i<HT; i++) {
	for (j=0; j<WD; j++) {
	  ((Uint*)C)[i*WD+j] = 0;
	  ((Uint*)D)[i*WD+j] = 0;
	  ((Uint*)C)[i*WD+j] = ((Uint*)C)[i*WD+j]+((Uint*)A)[i*WD+j]*((Uint*)A)[i*WD+j];
	  hards32(((Uint*)D)[i*WD+j], ((Uint*)A)[i*WD+j], ((Uint*)A)[i*WD+j], &((Uint*)D)[i*WD+j]);
	}
      }

      BGR_to_X(0, (Uint*)A); /* oginal 32bit input */
      BGR_to_X(1, (Uint*)B); /* oginal  8bit input */
      BGR_to_X(2, (Uint*)C); /* 32bit FMA */
      BGR_to_X(3, (Uint*)D); /*  8bit FMA */
      if (x11_checkevent()) goto fixed_point_exit;
    }
  }

fixed_point_exit:
  return 0;
}

/******************************************************************************************************************************************/
/*** Floating point            ************************************************************************************************************/
/******************************************************************************************************************************************/

try_floating_point()
{
  int EPOCH=256;
  int epoch, i, j, k;

  /* repeat test w/ visual */
  while (1) {
    for (epoch=1; epoch<EPOCH; epoch++) {
      for (i=0; i<HT; i++) {
	for (j=0; j<WD; j++) {
	  A[i*WD+j] = ((float)epoch/EPOCH+(float)i/HT+(float)j/WD)/4.0;
	  convf32tof8tof32(A[i*WD+j], &B[i*WD+j]);
	}
      }

      for (i=0; i<HT; i++) {
	for (j=0; j<WD; j++) {
	  C[i*WD+j] = 0;
	  D[i*WD+j] = 0;
	  //soft32(0, C[i*WD+j], A[i*WD+j], A[i*WD+j], &C[i*WD+j]);
	  C[i*WD+j] = C[i*WD+j]+A[i*WD+j]*A[i*WD+j];
	  softf8(D[i*WD+j], A[i*WD+j], A[i*WD+j], &D[i*WD+j]);
	  *(Uint*)&A[i*WD+j] &= 0xffff0000; /* delete BG[R] */
	  *(Uint*)&C[i*WD+j] &= 0xffff0000; /* delete BG[R] */
	}
      }

      BGR_to_X(0, (Uint*)A); /* oginal 32bit input */
      BGR_to_X(1, (Uint*)B); /* oginal  8bit input */
      BGR_to_X(2, (Uint*)C); /* 32bit FMA */
      BGR_to_X(3, (Uint*)D); /*  8bit FMA */
      if (x11_checkevent()) goto floating_point_exit;
    }
  }

floating_point_exit:
  return 0;
}

/******************************************************************************************************************************************/
/*** Memory System             ************************************************************************************************************/
/******************************************************************************************************************************************/

/*                                                          ´ûÂ¸¥á¥â¥ê¤ËÀÜÂ³,addr/data¤Î¥¿¥¤¥ß¥ó¥°¤Ï½¾ÍèÄÌ¤ê.³°Éô¤Ëserial I/OÄÉ²Ã         */
/*     IMAX/IMAX2                                  SMAX                                                                                   */
/*     EA1 EA0  EA1 EA0  EA1 EA0  EA1 EA0          EA[0:31] <A0><A1><A2><A3><A4><A5><A6>....<A63>                                         */
/*                                                 RD[0:31]     <D0><D1><D2><D3><D4><D5><D6>....<D63> DP²¾Äê                              */
/*       LMM      LMM      LMM      LMM            lmm0.0           <R0======================================>                            */
/*     32bit*8  32bit*8  32bit*8  32bit*8bit       lmm0.1               <R1======================================>                        */
/*                                                 lmm0.2                   <R2======================================>                    */
/*       EXE      EXE      EXE      EXE            lmm0.31                                         <R63==================================>*/
/*      FMA*2    FMA*2    FMA*2    FMA*2           exe0                 <E0==========================================>                    */
/*                                                 exe1                     <E1==========================================>                */
/*       LMM      LMM      LMM      LMM            lmm2.0                           <W0===========================================>       */
/*     32bit*8  32bit*8  32bit*8  32bit*8bit       lmm2.1                               <W1===========================================>   */
/*                                                                                                                                        */
/*     32bit * 8port                                                               32bit * 32port                                         */
/*                                                  <W0=====              W0  >----+++++++++++++++...++++  + <+    ADR latch*64É¬Í×       */
/*                                                      <W1=====          W1  >----+++++++++++++++...++++  |  |                           */
/*                                                          <W2=====      W2  >----+++++++++++++++...++++  V  |                           */
/*             ++++++++++++++++++....+++++                      <W31===== W31 >----+++++++++++++++...++++  +--+                           */
/*             ||||||||||||||||||....|||||                                         |||||||||||||||...||||                                 */
/*            +-------peak:256bit/¦Ó------+                                       +----peak:32bit/¦Ó-----+                                */
/* addr=10bit/|   typical:32bit*2/¦Ó(DP)  | 4¦Ó¤Ç32bit*8¤Îlatency      addr=13bit/|typical:32bit*2/¦Ó(DP)| 4¦Ó¤Ç32bit*8¤Îthroughput       */
/* 1024 32KB \|                           |32¦Ó¤Ç32bit*64              8192 32KB \|                      |32¦Ó¤Ç32bit*64                  */
/*            +---------------------------+                                       +----------------------+                                */
/*             ||||||||||||||||||....||||| DP                                      |||||||||||||||...||||   32*DP                         */
/*             ++++++++++++++++++....+++++ R0                                +> +  +++++++++++++++...++++----> R0  <R0=====               */
/*             ++++++++++++++++++....+++++ R1                                |  |  +++++++++++++++...++++----> R1      <R1=====           */
/*                                                                           |  V  +++++++++++++++...++++----> R2          <R2=====       */
/*                                                                           +--+  +++++++++++++++...++++----> R63             <R63=====  */
/*                                                                                                                                        */
/*     ±é»»À­Ç½¤Î´ÑÅÀ¤«¤é¤Ï,32¦Ó¤Ç32op (1 parallel±é»»´ï)              ±é»»À­Ç½¤Î´ÑÅÀ¤«¤é¤Ï,32¦Ó+32¦Ó¤Ç32op (32 bit-serial±é»»´ï)         */
/*         _______                                                      ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___   */
/*         \_____/                                                      \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/   */
/*            |                                                          |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |    */
/*     t=0 31====0                                                     00=   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =    */
/*     t=1 31====0                                                     01=   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =    */
/*     t=2 31====0                                                       :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :    */
/*     t=3 31====0                                                     31=   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =    */
/*                                                     ¡ú¤¿¤À¤·,¼¡ÃÊ¤È¤ÎÀÜÂ³¤Ë 32:1-selector * 32¤¬É¬Í×: ±é»»´ï°Ê³°¤¬Âç¤­¤¤.¸µ¤ÎÌÛ°¤Ìï¡ú  */

/* ¡üÂ¿¿ô¥·¥ê¥¢¥ë¤ÎÅý¹ç¤Ï½ÐÆþ¸ý¥»¥ì¥¯¥¿¤Î¥ª¡¼¥Ð¥Ø¥Ã¥ÉÂç,¥×¥í¥°¥é¥Þ¥Ö¥ë¤ËÉÔ¸þ¤­                                                            */
/* ¡ü¸·Ì©/Èó¸·Ì©Åý¹ç¤ÏIMAX¤ÎLMM¥·¥¹¥Æ¥à¤ËfloatÈó¸·Ì©·×»»ÄÉ²Ã¤¬¥Ù¥¹¥È¤ÈÈ½ÃÇ.¿ôÃÍÀºÅÙ¤Ï8bit-float¤ò»ÈÍÑ¤·¶á»÷¾è»»¤¹¤ë.                      */
/* ¡ü¼çÄó°Æ:Â¿¿ôstage¤ò»ÈÍÑ¤¹¤ë½¾ÍèÀÑÏÂ±é»»(Á´·ë¹çÁØ)¤ò¶á»÷¾è»»¤Ç²¿¤È¤«¤¹¤ë                                                               */
/*   sgemm00:¥Ç¡¼¥¿¤Ï½¾Íè°ÌÃÖ¤ËÊ¬»¶.·Á¼°¤Ï32bit->8bit.LDUB¤ÇA¤òSIMD¤Ë8copy,B/C¤Î±¦¤º¤ì¤òSIMD²½¤·ÍøÍÑ.¥Ç¡¼¥¿ÎÌºï¸º,C¤ÎÉýÊ¬¹âÂ®²½           */
/*     +------+------+   +-10-+   +-10-+                 +----------------+----------------+                                              */
/*     |a01234|      |   |b0->|   |c0->|                 |a0          LMM |  b0->      LMM |                                              */
/*     |a56789|      |   |b1->|   |c5->|                 +----------------+----------------+                                              */
/*     |      |      |   |b2->|   |cx->|                   =               = = = = = = = =                                                */
/*   100      |      |   |b3->| 100cy->|                  a0a0a0a0a0a0a0 * 8 8 8 8 8 8 8 8   4Îó¤Ç·× 8wordÀÑÏÂ/¦Ó                         */
/*     |      |      |   |b4->|   |cz->|                                   | | | | | | | |   4Îó¤Ç·×32byteÀÑÏÂ/¦Ó (256bit/¦Ó)             */
/*     +------+------+   +----+   +----+                  a1a1a1a1a1a1a1 * 8 8 8 8 8 8 8 8                                                */
/*                       |    |                                            | | | | | | | |                                                */
/*                       |    |a¤Ï°Ý»ý¤·¤Æ                a2a2a2a2a2a2a2 * 8 8 8 8 8 8 8 8                                                */
/*                       |    |b¤òÆþ¤ì´¹¤¨                                 | | | | | | | |                                                */
/*                       |    |                                        ½¾Íè:³Æ¡¹½ÄÊý¸þ¤Ë½ç¼¡Îß»» -> MemcapNW»È¤¨¤ë¡© ³°ÉÕ¤±¤Ë¤¹¤ë¡©       */
/*                       |    |                                        ¿·µ¬:½Ä¤Î¤Þ¤Þ¤Ç¤Ï¥á¥ê¥Ã¥ÈÌµ.¿åÊ¿Êý¸þ¤ËÉôÊ¬Îß»»¤Ç¤­¤ì¤ÐÃÊ¿ôÃ»½Ì¡ú   */
/*                       +----+                                             Âè5¤Î±é»»¥Ñ¥¿¡¼¥ó¤È¤·¤Æ¿·SIMDÌ¿Îá(ÉôÊ¬Îß»»)¤òÄÉ²Ã¡©           */
/*                                                                                                                                        */
/*   1. LDQA        LDQB        LDQC                             5. LDQA        LDQB        LDQC          (approximate FMA)               */
/*      LDQA  FMA4  LDQB  FMA4  LDQC  FMA4        FMA4 STQD         LDQA  AMA4  LDQB  AMA4  LDQC  AMA4        AMA4 STQD                   */
/*            FMA4        FMA4        FMA4        FMA4 STQD               AMA4        AMA4        AMA4        AMA4 STQD                   */
/*                                                                                                                                        */
/*   2. LDA1        LDA1        LDB1        LDB1                          A.8bit + ¦²[31:0](B.8bit[i] * C.8bit[i]) -> D.8bit              */
/*      LDA2  FMA   LDA2  FMA   LDB2  FMA   LDB2  FMA                                                                                     */
/*      LDA3  FMA   LDA3  FMA   LDB3  FMA   LDB3  FMA                                                                                     */
/*      LDA4  FMA   LDA4  FMA   LDB4  FMA   LDB4  FMA                                                                                     */
/*            FMA   STC   FMA   STC   FMA   STC   FMA   STC                                                                               */
/*                                                                                                                                        */
/*   3. LD    FMA   LD    FMA   LD    FMA   LD    FMA                                                                                     */
/*                  ST          ST          ST          ST                                                                                */
/*                                                                                                                                        */
/*   4. LD FMA(acc) LD FMA(acc) LD FMA(acc) LD FMA(acc)                                                                                   */
/*                  ST(same ad) ST(same ad) ST(same ad) ST(same ad)                                                                       */

/******************************************************************************************************************************************/
/*** Fixed point               ************************************************************************************************************/
/******************************************************************************************************************************************/

/*  ¡ß¡Ú¸µÁÄ¥¹¥È¥«¥¹¥Æ¥£¥Ã¥¯¡Û                                                                                                            */
/*     in: 5 out: 0 0 1 1 1 1 1 1 0 0/1¤ÎÍð¿ôÎó                                                                                           */
/*                                                                                                                                        */

/*  ¡ß¡ÚÂ¿ÃÍ¥¹¥È¥«¥¹¥Æ¥£¥Ã¥¯¡Û                                                                                                            */
/*     in: 5 out: 5 2 9 8 4 5 6 9 0 Â¿ÃÍ¤ÎÍð¿ôÎó                                                                                          */
/*                                                                                                                                        */

/*  ¡ß¡Ú³Æ16¿Ê¤ÏMSB-LSB,³Æ·å¤ÏSerial¡Û                                                                                                    */
/*     in: 0x00000000 out: 0000 0000 0000 0000 0000 0000 0000 0000 ¤³¤ì¤Ê¤éÉáÄÌ¤Î4bit-adder                                               */
/*     in: 0x00000001 out: 0000 0000 0000 0000 0000 0000 0000 0001 ¤·¤«¤·°µ½Ì¤Ï¤Ç¤­¤Ê¤¤                                                   */
/*     in: 0x0000000f out: 0000 0000 0000 0000 0000 0000 0000 1111 Á´²Ã»»´ï¤È¡¤4bit-incrementor¤Î¤É¤Á¤é¤¬Âç¤­¤¤?                          */
/*     in: 0x00000010 out: 0000 0000 0000 0000 0000 0000 0001 0000                                                                        */
/*     in: 0xffffffff out: 1111 1111 1111 1111 1111 1111 1111 1111                                                                        */
/*                                                                                                                                        */

/*  ¡ß¡Ú³Æ10¿Ê¤ÏMSB-LSB,½ªÃ¼ÉÕ²ÄÊÑÄ¹¡Û1111¤¬½ªÃ¼ 4(10/16) 7(100/128) 10(1000/1024)                                                        */
/*     in: 0x00000000(0)   out:                          1111 0000 10¿Êadder¤ÏÊ£»¨                                                        */
/*     in: 0x00000001(1)   out:                          1111 0001 °µ½Ì¤â¤Ç¤­¤ë                                                           */
/*     in: 0x0000000f(15)  out:                     1111 0001 0101                                                                        */
/*     in: 0x00000100(256) out:                1111 0010 0101 0110                                                                        */
/*                                                                                                                                        */

/*  ¡ß¡Ú32bit¥Ç¡¼¥¿¤Ï16spike*8frame¤ÇÉ½¸½¡Û                                                                                               */
/*     in: 31 30 29 28 ... 7  6  5  4  3  2  1  0                                                                                         */
/*         ~~V~~~~~~~~     ~~~~~~~~~V  ~~~~~~~V~~                                                                                         */
/*     out: 15 0 .............     15 0      15 0 ->                                                                                      */
/*        T    0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  T                                                           */
/*    0: ____/~~\____                                                                                                                     */
/*    1: ____/~~\/~~\____                                                                                                                 */
/*   15: ____/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\____                                                         */
/*     in: 0x00000000 out: 0101010101010101                 16bit                                                                         */
/*     in: 0x00000001 out: 01010101010101011                17bit                                                                         */
/*     in: 0x0000000f out: 0101010101010101111111111111111  31bit                                                                         */
/*     in: 0x00000010 out: 01010101010101101                17bit                                                                         */
/*     in: 0xffffffff out: 01111111111111111_01111111111111111_....01111111111111111 17*8=136bit                                          */
/*                                                                                                                                        */
/*   1. addr(24bit)->M_AD 24bit:1ËÜ (ºÇÂç 96¦Ó/1ËÜ,½¾Íè1¦Ó/24ËÜ)                                                                          */
/*   2. data(32bit)->M_AD 32bit:1ËÜ (ºÇÂç128¦Ó/1ËÜ,½¾Íè1¦Ó/32ËÜ)                                                                          */
/*   3. mem 4bit->16spike(ÀèÆ¬¤Ï´ð½à°ÌÃÖ)/de/ex/write (Serial RAM)                                                                        */
/*     /~~\/~~\/~~\/~~\/~~\/~~\____/~~\____/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\____                                               */
/*                              5       0                                              10                                                 */
/*   4. ¥¹¥Ñ¥¤¥¯¿ô¤ÎÁý¸ºÊýË¡¤Ï¡¤ÆÃµöÊý¼°(¶á»÷·×»»ÍÑ¶¯À©0/1)°Ê³°¤Ë¸·Ì©Áý¸º¤¬É¬Í×¤À¤¬¡¤·ë¶É¥«¥¦¥ó¥¿¤Ëµ¢·ë                                   */
/*      0: ____/~~\________/                2: ____/~~\/~~\/~~\____/            2: ____/~~\/~~\/~~\________/                              */
/*    + 1: ____/~~\/~~\____/              + 1: ____/~~\/~~\________/          + 3: ____/~~\/~~\/~~\/~~\____/                              */
/*    AND: ____/~~\________/              AND: ____/~~\/~~\________/          AND: ____/~~\/~~\/~~\________/                              */
/*     OR: ____/~~\/~~\__*_/               OR: ____/~~\/~~\/~~\__*_/           OR: ____/~~\/~~\/~~\/~~\__*_/                              */
/*     CK: ~\_/~\_/~\_/~\_/~               CK: ~\_/~\_/~\_/~\_/~\_/~           CK: ~\_/~\_/~\_/~\_/~\_/~\_/~                              */
/*  count: X===X===X===X===X            count: X===X===X===X===X===X===X    count: X===X===X===X===X===X===X===X===X                      */
/*  count:          rst  0E|                            rst  1   1   0E|                    rst  1   2   2   1   0E|                      */
/*    sum: ________/~~\/~~\____           sum: ________/~~\/~~\/~~\/~~\____   sum: ________/~~\/~~\/~~\/~~\/~~\/~~\____(OR=1|count>0:1)   */
/*                   0   1   1                           0   1   2   3   3                   0   1   2   3   4   5   5                    */
/*                                                                                                                                        */
/*   5. 4bit¥°¥ë¡¼¥×´Ö¤Î·å¾å¤²                                                                                                            */
/*     15: ____/~~\/~~\..../~~\____/¼¡·å                                                                                                  */
/*    +15: ____/~~\/~~\..../~~\____/                                                                                                      */
/*    AND: ____/~~\/~~\..../~~\____/                                                                                                      */
/*     OR: ____/~~\/~~\..../~~\__*_/                                                                                                      */
/*     CK: ~\_/~\_/~\_/....~\_/~\_/~\_/~\_/....~\_/~\_/                                                                                   */
/*  count: X===X===X===....X===X===X===X===....X===X===                                                                                   */
/*  count:          rst  1  14  15  14  13 ....  1   0E                                                                                   */
/*    sum: ________/~~\..../~~\/~~\/~~\/~~\..../~~\/~~\____(OR=1|count>0:1)                                                               */
/*                  *0  *1 *14 *15   0   1 .... 13  14  14 ¡ú¡ú                                                                           */
/*   sumRestart: __________________/~~\____________________                                                                               */
/*   Cout: ________________________/~~\____________________ carry                                                                         */
/*   TrueSum:                      /~~\/~~\..../~~\/~~\____(OR=1|count>0:1)                                                               */
/*                                                                                                                                        */
/*         case 15+15:     15: ____/~~\/~~\..../~~\____/                                                                                  */
/*                        +15: ____/~~\/~~\..../~~\____/                                                                                  */
/*                        AND: ____/~~\/~~\..../~~\____/                                                                                  */
/*                         OR: ____/~~\/~~\..../~~\__*_/                                                                                  */
/*                        Cin: ____/~~\                                                                                                   */
/*                         CK: ~\_/~\_/~\_/....~\_/~\_/~\_/~\_/~\_/~\_/....~\_/~\_/                                                       */
/*                      count: X===X===X===....X===X===X===X===X===X===....X===X===                                                       */
/*                      count:          Cin  2  13  14  15  16  15  14       1   0E    (Cin=1¤Î¤¿¤á1¦ÓÃÙ±ä)                               */
/*                        sum: ________/~~\..../~~\/~~\/~~\/~~\/~~\/~~\..../~~\/~~\____(OR=1|count>0:1)                                   */
/*                                      *0  *1 *12 *13 *14 *15   0   1      14  15  15 ¡ú¡ú²¼°Ì·å¤è¤êÃÙ¤¤ OK                              */
/*                     sumRestart: ____________________________/~~\____________________                                                   */
/*                       Cout: ________________________________/~~\____________________ carry                                             */
/*                       TrueSum:                              /~~\/~~\..../~~\/~~\____(OR=1|count>0:1)                                   */
/*                                                                                                                                        */
/*                     in: 0x000000ff out: 0101010101_01_01111111111111111_01111111111111111  46bit                                       */
/*                    +in: 0x000000ff out: 0101010101_01_01111111111111111_01111111111111111  46bit                                       */
/*                    ----------------------------------------------------------------------                                              */
/*    sum: 0101010101_011_011111111111111111111111111111111_01111111111111111111111111111111  46+16+16bit                                 */
/*    rst:                                X                                X  ¡úRst¤Î¤¿¤á¤Ë2ËÜÉ¬Í×                                        */
/*    sum: 0101010101_011_01111111111111111                 0111111111111111  46bit                                                       */
/*                                                                                                                                        */
/*    sum:  0101010101_01_011111111111111111111111111111111_01111111111111111111111111111111  46+16+16bit ¡ú·å¾å¤²¤ÏÅÁÈÂ.³Æ·å¤Ï           */
/*                                                                                                        ºÇÂç{31}1¤ò¤½¤Î¤Þ¤ÞÅÁÈÂ.        */
/*                                                                                                        ¼¡ÃÊÆþÎÏ¤ÇÀè¹Ô{16}1¤ò¥«¥Ã¥È     */
/*         case 0+0:        0: ____/~~\____/                                                                                              */
/*                         +0: ____/~~\____/                                                                                              */
/*                        AND: ____/~~\____/                                                                                              */
/*                         OR: ____/~~\__*_/                                                                                              */
/*                        Cin: ____/~~\                                                                                                   */
/*                         CK: ~\_/~\_/~\_/~\_/                                                                                           */
/*                      count: X===X===X===X===                                                                                           */
/*                      count:          Cin  0E    (Cin=1¤Î¤¿¤á1¦ÓÃÙ±ä)                                                                   */
/*                        sum: ________/~~\/~~\____(OR=1|count>0:1)                                                                       */
/*                                       0   1   1 ¡ú¡ú²¼°Ì·å¤è¤êÁá¤¤ NG                                                                  */
/*                     SumRestart: ________________                                                                                       */
/*                       Cout: ____________________                                                                                       */
/*                       TrueSum:      /~~\/~~\____(OR=1|count>0:1)                                                                       */
/*                                                                                                                                        */
/*                     in: 0x0000000f out: 010101010101_01_01111111111111111  31bit                                                       */
/*                    +in: 0x0000000f out: 010101010101_01_01111111111111111  31bit                                                       */
/*                    ------------------------------------------------------                                                              */
/*                    sum: 010101010101_011_01111111111111111111111111111111  31+16bit                                                    */
/*                    rst:                                 X                                                                              */
/*                    sum: 010101010101_011_0111111111111111  31bit                                                                       */
/*                                                                                                                                        */
/*   6. AND/OR/XOR¤Ê¤É¡¤bit´Ö¤Ë°ÍÂ¸¤¬¤Ê¤¤¤â¤Î¤ÏÃ±½ãserial¤È¤·¤Æ°·¤¦                                                                       */

/*  ¡û¡Ú³Æ16¿Ê¤ÏMSB-LSB,lastÉÕ²ÄÊÑÄ¹¡Û                                                                                                    */
/*     in: 0x00000000 out:                                    0000 ÉáÄÌ¤Î4bit-adder                                                       */
/*                    last                                    1    °µ½Ì¤â¤Ç¤­¤ë                                                           */
/*     in: 0x00000001 out:                                    0001 1bit-serial  +1bit¤Î¾ì¹ç¡¤2ËÜÉ¬Í×                                      */
/*                    last                                    1    4bit-parallel+1bit¤Î¾ì¹ç¡¤5ËÜÉ¬Í×                                      */
/*     in: 0x0000000f out:                                    1111                                                                        */
/*                    last                                    1                                                                           */
/*     in: 0x00000100 out:                          0001 0000 0000                                                                        */
/*                    last                          1                                                                                     */
/*     in: 0xffffffff out: 1111 1111 1111 1111 1111 1111 1111 1111                                                                        */
/*                    last 1                                                                                                              */
/*                                                                                                                                        */
/*   last: ____________/~~\       last: ____________/~~\       last: ____________/~~\                                                     */
/*      0: ________________          2: ____/~~\________          2: ____/~~\________                                                     */
/*   last: ____________/~~\       last: ____________/~~\       last: ____________/~~\                                                     */
/*    + 1: /~~\____________        + 1: /~~\____________        + 3: /~~\/~~\________                                                     */
/*   cout: ________________       cout: ________________       cout: ____/~~\________                                                     */
/*     CK: ~\_/~\_/~\_/~\_/         CK: ~\_/~\_/~\_/~\_/         CK: ~\_/~\_/~\_/~\_/                                                     */
/*    cin: ________________        cin: ________________        cin: ________/~~\____                                                     */
/*   last: ____________/~~\       last: ____________/~~\       last: ____________/~~\                                                     */
/*    sum: /~~\____________        sum: /~~\/~~\________        sum: /~~\____/~~\____                                                     */
/*           1   0   0   0                1   1   0   0                1   0   1   0                                                      */
/*                                                                                                                                        */
/*     case 0xff + 0xff                                                                                                                   */
/*   last: ____________________________/~~\                                                                                               */
/*     15: /~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\                                                                                               */
/*   last: ____________________________/~~\                                                                                               */
/*    +15: /~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\                                                                                               */
/*   cout: /~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\                                                                                               */
/*     CK: ~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/                                                                                           */
/*    cin: ____/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\                                                                                           */
/*   last: ________________________________/~~\                                                                                           */
/*    sum: ____/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\                                                                                           */
/*           0   1   1   1   1   1   1   1 Cout                                                                                           */
/*                                                                                                                                        */
/*     case 0x0f + 0x0f                                                                                                                   */
/*   last: ____________________________/~~\                                                                                               */
/*      0: /~~\/~~\/~~\/~~\________________                                                                                               */
/*   last: ____________________________/~~\                                                                                               */
/*     +0: /~~\/~~\/~~\/~~\________________                                                                                               */
/*   cout: /~~\/~~\/~~\/~~\________________                                                                                               */
/*     CK: ~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/                                                                                               */
/*    cin: ____/~~\/~~\/~~\/~~\____________                                                                                               */
/*   last: ____________________________/~~\                                                                                               */
/*    sum: ____/~~\/~~\/~~\/~~\____________                                                                                               */
/*           0   1   1   1   1   0   0   0                                                                                                */

/*  ¡ý¡Ú³Æ16¿Ê¤ÏMSB-LSB,5bit»ÈÍÑ¥¿¥¤¥×,ready/valid¤Ê¤·¡Û                                                                                  */
/*     in: 0x00000000 out:                                           10000 ÉáÄÌ¤Î4bit-adder                                               */
/*     in: 0x00000001 out:                                           10001                                                                */
/*     in: 0x0000000f out:                                           11111                                                                */
/*     in: 0x00000100 out:                               10001 00000 00000                                                                */
/*     in: 0xffffffff out: 11111 01111 01111 01111 01111 01111 01111 01111                                                                */
/*                                                                                                                                        */
/*     CK: ~\_/~\_/~\_/~\_/~\_/     CK: ~\_/~\_/~\_/~\_/~\_/     CK: ~\_/~\_/~\_/~\_/~\_/                                                 */
/*      0: ________________/~T\      2: ____/~~\________/~T\      2: ____/~~\________/~T\                                                 */
/*    + 1: /~~\____________/~T\    + 1: /~~\____________/~T\    + 3: /~~\/~~\________/~T\                                                 */
/*   cout: ____________________   cout: ____________________   cout: ____/~~\____________                                                 */
/*    cin: ____________________    cin: ____________________    cin: ________/~~\________                                                 */
/*   beat: ________________/~~\   beat: ________________/~~\   beat: ________________/~~\                                                 */
/*    sum: /~~\____________/~~\    sum: /~~\/~~\________/~~\    sum: /~~\____/~~\____/~~\                                                 */
/*           1   0   0   0   T            1   1   0   0   T            1   0   1   0   T                                                  */
/*                                                                                                                                        */
/*     case 0xff + 0xff                                                                                                                   */
/*     CK: ~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/                                                                   */
/*    255: /~~\/~~\/~~\/~~\__C_/~~\/~~\/~~\/~~\/~T\................V T¤òÊÝÂ¸¤·½ÐÎÏ                                                        */
/*   +255: /~~\/~~\/~~\/~~\__C_/~~\/~~\/~~\/~~\/~T\................V                                                                      */
/*   cout: /~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\................                                                                       */
/*    cin: ____/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\________________ cout¤ò1¦ÓÃÙ±ä                                                     */
/*   beat: ________________/~~\________________/~~\________________/~~\                                                                   */
/*    sum: ____/~~\/~~\/~~\____/~~\/~~\/~~\/~~\____/~~\____________/~~\ xor(i1,i2,cin,beat)                                               */
/*           0   1   1   1   C   1   1   1   1   C   1   0   0   0   T                                                                    */
/*                                                                                                                                        */
/*     case 0x0f + 0x0f                                                                                                                   */
/*     CK: ~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/                                                                                       */
/*     15: /~~\/~~\/~~\/~~\/~T\________________V T¤òÊÝÂ¸¤·½ÐÎÏ                                                                            */
/*    +15: /~~\/~~\/~~\/~~\/~T\________________V                                                                                          */
/*   cout: /~~\/~~\/~~\/~~\/~~\____________________                                                                                       */
/*    cin: ____/~~\/~~\/~~\/~~\/~~\________________ cout¤ò1¦ÓÃÙ±ä                                                                         */
/*   beat: ________________/~~\________________/~~\                                                                                       */
/*    sum: ____/~~\/~~\/~~\____/~~\____________/~~\ xor(i1,i2,cin,beat)                                                                   */
/*           0   1   1   1   C   1   0   0   0   T                                                                                        */
/*                                                                                                                                        */
/*     case 0xff + 0x0f  ¡Úready/valid¤¬¤Ê¤¤¹½À®¤Ç¤Ï¡ß¡Û                                                                                  */
/*     CK: ~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/                                                                   */
/*    255: /~~\/~~\/~~\/~~\__C_/~~\/~~\/~~\/~~\/~T\................V T¤òÊÝÂ¸¤·½ÐÎÏ                                                        */
/*    +15: /~~\/~~\/~~\/~~\/~T\....................................V                                                                      */
/*   cout: /~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\................                                                                       */
/*    cin: ____/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\________________ cout¤ò1¦ÓÃÙ±ä                                                     */
/*   beat: ________________/~~\________________/~~\________________/~~\                                                                   */
/*    sum: ____/~~\/~~\/~~\/~~\____________________________________/~~\ xor(i1,i2,cin,beat)                                               */
/*           0   1   1   1  ??   0   0   0   0   C   1   0   0   0   T                                                                    */

/*  ¡ý¡Ú³Æ16¿Ê¤ÏMSB-LSB,5bit»ÈÍÑ¥¿¥¤¥×,ready/valid¤¢¤ê¡Û                                                                                  */
/*    ¡úÁªÂò»è1: 4b4b, last/valid/ready»ÈÍÑ                                                                                               */
/*                                                                                                                                        */
/*    ¡úÁªÂò»è2: 4b5b, valid/ready»ÈÍÑ                                                                                                    */
/*     case 0xff + 0x0f                                                                                                                   */
/*     CK: ~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~                                                                      */
/*    255: /~~\/~~\/~~\/~~\__C_/~~\/~~\/~~\/~~\/~T\................V T¤òÊÝÂ¸¤·½ÐÎÏ                                                        */
/*    vld: /~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\_________________                                                                      */
/*    rdy: /~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\_________________                                                                      */
/*    +15: /~~\/~~\/~~\/~~\/~T\....................................V                                                                      */
/*    vld: /~~~~~~~~~~~~~~~~~~\_____________________________________                                                                      */
/*    rdy: /~~~~~~~~~~~~~~~~~~\_____________________________________                                                                      */
/*   cout: /~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\................                                                                       */
/*    cin: ____/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\________________ cout¤ò1¦ÓÃÙ±ä                                                     */
/*   beat: ________________/~~\________________/~~\________________/~~\                                                                   */
/*    sum: ____/~~\/~~\/~~\/~~\____________________________________/~~\ xor(i1,i2,cin,beat)                                               */
/*           0   1   1   1  ??   0   0   0   0   C   1   0   0   0   T                                                                    */
/*                                                                                                                                        */
/*    ¡úÁªÂò»è3: 4b4b, valid/ready»ÈÍÑ                                                                                                    */
/*     case 0xff + 0x0f                                                                                                                   */
/*         <-ry0             FF      <-+ <-ry1                                                                                            */
/*         ->255 +                     |                                                                                                  */
/*         ->vl1 |                     |                                                                                                  */
/*         -> 15 +--> sum -> FF -> out | ->                                                                                               */
/*         ->vl2 |    vli -> FF -> vlo + ->                                                                                               */
/*        +->cin +--> cout-> FF -+                                                                                                        */
/*        |                      |                                                                                                        */
/*        +----------------------+                                                                                                        */
/*     CK: ~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/                                                               */
/* 2  ry0: ________/~~~~~~~\___________________________________________/~~~ if (ry1) ry0 <= 1 elif (vli) ry0 <= 0                         */
/*    255: ____________/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\____________________ ry0¤¬°ìÃ¶Íî¤Á¤ÆÌá¤ë¤Þ¤ÇÂÔµ¡                                   */
/* 3  vl1: ____________/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\____________________ if (ry0) vl1<=1(src¤Ë¤Æcountdown¤·0¤ØÁ«°Ü) elif               */
/*    +15: ____________/~~\/~~\/~~\/~~\____________________________________                                                               */
/* 3  vl2: ____________/~~~~~~~~~~~~~~\____________________________________ if (ry0) vl2<=1(src¤Ë¤Æcountdown¤·0¤ØÁ«°Ü) elif               */
/*    cin: ________________/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\________________ cout¤ò1¦ÓÃÙ±ä                                                 */
/*   cout: ____________/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\____________________                                                               */
/*    sum: ________________/~~\/~~\/~~\________________/~~\________________ xor(i1,i2,cin)                                                */
/* 3  vli: ____________/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\________________ or(vl1,vl2,sum)                                               */
/*     CK: ~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/                                                               */
/* 1  ry1: ____/~~~~~~~~~~~~~~~\___________________________________/~~~~~~~ if (ry2) ry1 <= 1 elif (vlo) ry1 <= 0                         */
/*    out: ____________________/~~\/~~\/~~\________________/~~\____________ sum¤ò1¦ÓÃÙ±ä                                                  */
/*                           0   1   1   1   0   0   0   0   1                                                                            */
/* 4  vlo: ________________/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\___________ vli¤ò1¦ÓÃÙ±ä                                                  */
/*                                                                                                                                        */
/*     case 0xf0 + 0x0f                                                                                                                   */
/*         <-ry0             FF      <-+ <-ry1                                                                                            */
/*         ->255 +                     |                                                                                                  */
/*         ->vl1 |                     |                                                                                                  */
/*         -> 15 +--> sum -> FF -> out | ->                                                                                               */
/*         ->vl2 |    vli -> FF -> vlo + ->                                                                                               */
/*        +->cin +--> cout-> FF -+                                                                                                        */
/*        |                      |                                                                                                        */
/*        +----------------------+                                                                                                        */
/*     CK: ~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/                                                                   */
/* 2  ry0: ________/~~~~~~~\_______________________________________/~~~ if (ry1) ry0 <= 1 elif (vli) ry0 <= 0                             */
/*    240: ____________________________/~~\/~~\/~~\/~~\________________ ry0¤¬°ìÃ¶Íî¤Á¤ÆÌá¤ë¤Þ¤ÇÂÔµ¡                                       */
/* 3  vl1: ____________/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\________________ if (ry0) vl1<=1(src¤Ë¤Æcountdown¤·0¤ØÁ«°Ü) elif                   */
/*    +15: ____________/~~\/~~\/~~\/~~\________________________________                                                                   */
/* 3  vl2: ____________/~~~~~~~~~~~~~~\________________________________ if (ry0) vl2<=1(src¤Ë¤Æcountdown¤·0¤ØÁ«°Ü) elif                   */
/*    cin: ____________________________________________________________ cout¤ò1¦ÓÃÙ±ä                                                     */
/*   cout: ____________________________________________________________                                                                   */
/*    sum: ____________/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\________________ xor(i1,i2,cin)                                                    */
/* 3  vli: ____________/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\________________ or(vl1,vl2,sum)                                                   */
/*     CK: ~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/                                                                   */
/* 1  ry1: ____/~~~~~~~~~~~~~~~\_______________________________/~~~~~~~ if (ry2) ry1 <= 1 elif (vlo) ry1 <= 0                             */
/*    out: ________________/~~\/~~\/~~\/~~\/~~\/~~\/~~\/~~\____________ sum¤ò1¦ÓÃÙ±ä                                                      */
/*                           1   1   1   1   1   1   1   1                                                                                */
/* 4  vlo  ________________/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\___________ vli¤ò1¦ÓÃÙ±ä                                                      */

int hards32(Uint s1, Uint s2, Uint s3, Uint *o)
{
  Uint in1_s32, in2_s32, in3_s32, out_s32;
}

/******************************************************************************************************************************************/
/*** Floating point            ************************************************************************************************************/
/******************************************************************************************************************************************/

/* Fixed_point number (0.0-16.0)                                                                                                          */
/* up/low     0000  0001 0010 0011 0100 0101 0110 0111 1000 1001 1010 1011 1100 1101 1110 1111                                            */
/* 0000       0.000 0.0625                                                                0.9375                                          */
/* 0001       1.000 1.0625                                                                1.9375                                          */
/* 0010       2.000 2.0625                                                                2.9375                                          */
/* 0011       3.000 3.0625                                                                3.9375                                          */
/* 0100       4.000 4.0625                                                                4.9375                                          */
/* 0101       5.000 5.0625                                                                5.9375                                          */
/* 0110       6.000 6.0625                                                                6.9375                                          */
/* 0111       7.000 7.0625                                                                7.9375                                          */
/* 1111       15.00 15.062                                                                15.938                                          */

/* Floating_point number (0.0-16.0) Traditional_8bit:s+3exp+4frac                                                                         */
/*       subnormal 2^(-2) 0.250 * 0.0000 - 0.1111 0.250*(               0.0625       )=0.015625                                           */
/*                                                0.250*(0.5+0.25+0.125+0.0625=0.9375)=0.234375                                           */
/*       normal    2^(exp-3)    * 1.0000 - 1.1111 0.250*(1.0                         )=0.250000                                           */
/*                                                8.000*(1.5+0.25+0.125+0.0625=1.9375)=15.50000                                           */
/*       infinite  s1110000     nan       s111xxxx                                                                                        */
/*       frac=0000  0001 0010 0011 0100 0101 0110 0111 1000 1001 1010 1011 1100 1101 1110 1111                                            */
/* exp=0(sub) zero  0.0156                                                                0.234                                           */
/* exp=1      0.250                                                                       0.484                                           */
/* exp=2      0.500                                                                       0.969                                           */
/* exp=3      1.000                1.25                                                   1.938                                           */
/* exp=4      2.000                                                                       3.875                                           */
/* exp=5      4.000                                                                       7.750                                           */
/* exp=6      8.000                10.0                                                   15.50                                           */
/* exp=7      inf   nan  nan  nan  nan  nan  nan  nan  nan  nan  nan  nan  nan  nan  nan  nan                                             */

/* Traditional pipelined FPU (32bit s-8exp-23frac)                                                                                        */
/* FPGAclk 150MHz __/~T0~~\_____/~~T1~\_____/~T2~~\_____/~T3~~\_____/~T0~~\_____/~~~~~\_____/~~~~~\_____                                  */
/* FPU-in123:     ==V>----------------------------------------------------------------------------------                                  */
/* FPU-st1:       ---<==REGsel==V>----------------------------------------------------------------------                                  */
/* FPU-st2:       ---------------<==32bit*3=V>----------------------------------------------------------                                  */
/* FPU-st3:       ---------------------------<==32bit*1=V>----------------------------------------------                                  */
/* FPU-st4:       ---------------------------------------<==32bit*1=V>----------------------------------                                  */
/* FPU-out:       ---------------------------------------------------<==32bit*1=V>----------------------                                  */

/* in¤¬digital-spike(0/1¤Î¤ß)¤Î¾ì¹ç,inÈ¿Å¾²ÄÇ½.pat39¥Ñ¥¿¡¼¥ó¥Þ¥Ã¥Á¥ó¥°(conv_forward))¤ËÅ¬                                                 */
/* in0+ _/~\_____/~\_/~\_________/~\_/~\                                                                                                  */
/* in0- _____/~\_________/~\_/~\________ w-> _____/~\_________/~\_/~\_  \                                                                 */
/* in1+ _/~\_/~\_/~\____________________ w+> _/~\_/~\_/~\_____________  |\    2   3   2   1   2   2                                       */
/* in1- _____________/~\_/~\_/~\_/~\_/~\                                | > _/~\_/~\_/~\_____/~\_/~\_                                     */
/* in2+ _________________________/~\_/~\                                |/                                                                */
/* in2- _/~\_/~\_/~\_/~\_/~\_/~\________ w-> _/~\_/~\_/~\_/~\_/~\_/~\_  /                                                                 */

/* Floating_point number (0.0-2.0) Modified_8bit:s+3exp+4frac                                                                             */
/*       subnormal 2^(-6) 0.01562 * 0.0000 - 0.1111 0.01562*(               0.0625       )=0.000976                                       */
/*                                                  0.01562*(0.5+0.25+0.125+0.0625=0.9375)=0.014643                                       */
/*       normal  2^(-7) 0.0078125 * 1.0000 - 1.1111 0.0078125*(1.0+         0.0625       )=0.008301                                       */
/*                                                0.0078125*(1.5+0.25+0.125+0.0625=1.9375)=0.015137                                       */
/*       normal    2^(exp-7)      * 1.0000 - 1.1111 0.01562*(1.0                         )=0.015625                                       */
/*                                                  1.00000*(1.5+0.25+0.125+0.0625=1.9375)=1.937500                                       */
/*       frac=0000  0001 0010 0011 0100 0101 0110 0111 1000 1001 1010 1011 1100 1101 1110 1111                                            */
/* exp=0(sub) zero  0.0009766                                                             0.0146                                          */
/* exp=0(nor) zero  0.008301                                                              0.0151                                          */
/* exp=1      0.015625                                                                    0.0303                                          */
/* exp=2      0.03125                                                                     0.0605                                          */
/* exp=3      0.0625                        1.5*0.0625=0.09375                            0.1211                                          */
/* exp=4      0.125                                                                       0.2422                                          */
/* exp=5      0.250                                                                       0.4844                                          */
/* exp=6      0.500                                                                       0.9688                                          */
/* exp=7      1.000                1.25           1.44                                    1.9375                                          */

/* ½¾Íè¤Îstochastic(³ÎÎ¨)¤È¤âspiking(¥Ñ¥ë¥¹¶¯ÅÙ)¤È¤â°Û¤Ê¤ë, serial-bus-computation(HPC)¤Î»ÅÁÈ¤ß¤ò¹Í¤¨¤ë                                   */
/* Mult in.exp*w.exp(000,  001,  010,  011,  100,  101,  110,  111)                                                                       */
/*                   x.007 x.015 x.03  x.06  x.125 x.25  x.5   x1                                                                         */
/*                                            x.5(110):pass-counter                                                                       */
/*                  0   1   2   3   4   5   6  cut1.pass6  0   1   2   3   4   5   6                                                      */
/*                _/~\_/~\_/~\_/~\_/~\_/~\_/~\    ->     _/~\_/~\_/~\_/~\_/~\_/~\_/~\_                                                    */
/*     w.exp:6 .5 _____/~~~~~~~~~~~~~~~~~~~~~\           _/~~~~~~~~~~~~~~~~~~~~~\_____                                                    */
/* in zero e:0    ____________________________    -> out _____________________________                                                    */
/*    0.06 e:3    _/~\_/~\_/~\________________    ->     _/~\_/~\_____________________                                                    */
/*    0.50 e:6    _/~\_/~\_/~\_/~\_/~\_/~\____    ->     _/~\_/~\_/~\_/~\_/~\_________                                                    */
/*                                                                                                                                        */
/* Mult in.frac*w.frac(0000, 0001, 0010, 0011, 0100, 0101, 0110, 0111, 1000, 1001, 1010, 1011, 1100, 1101, 1110, 1111)                    */
/*                     1.00  1.06  1.12  1.18  1.24  1.30  1.36  1.42  1.48  1.54  1.60  1.66  1.72  1.78  1.84  1.90                     */
/*                                                                                                                                        */
/*                     1.00 * 1.00 = 1.00      1.99 * 1.00 = 1.99      1.99 * 1.99 = 3.96  0-2¤ÎÈÏ°Ï¤Ê¤é                                  */
/*                     0000 + 0000 = 0000      1111 + 0000 = 1111      1111 + 1111 = 11110    ¾è»»->²Ã»»                                  */
/*                        0 +    0 =    0      0.99 +    0 = 0.99      0.99 + 0.99 = 1.98                                                 */
/*                       +1     +1     +1        +1     +1     +1        +1     +1     +1 ¾¯¤·¾®¤µ¤¤¤¬²Ä                                  */
/*                                             1.25 * 1.25 = 1.5625    1.50 * 1.50 = 2.25                                                 */
/*                                             0100 + 0100 = 1000      1000 + 1000 = 10000                                                */
/*                                             0.25 + 0.25 = 0.50      0.50 + 0.50 = 1.00                                                 */
/*                                               +1     +1     +1        +1     +1     +1                                                 */
/*                                          |                                                                                             */
/*                                       4.0+         *  Àµ²ò 1.99*1.99=3.96                                                              */
/*                                          |        *                                                                                    */
/*                                          |        *                                                                                    */
/*                                       3.0+       *  * ¶á»÷ (1).99+(1).99=(1)1.98 (= 2.98)                                              */
/*                                          |       * *                                                                                   */
/*                                          |      * *                                                                                    */
/*                                       2.0+      **                                                                                     */
/*                                          |     **                                                                                      */
/*                                          |     *                                                                                       */
/*                                       1.0+    *       Àµ²ò 1.00*1.00=1.00                                                              */
/*                                          |            ¶á»÷ (1).00+(1).00=(1).00                                                        */
/*                                          |                                                                                             */
/*                                          +----+----+----+----+---                                                                      */
/*                                          0  1.00 1.99                                                                                  */

/* ¦²(im=in*ww) f:Éä¹æÂÐ±þ(¸º»»)¤¬É¬Í×                                                                                                    */
/* ¤Þ¤È¤á .. f:0.00-1.99¤ÎÈÏ°Ï¤Ê¤Î¤Ç,¾è»»->²Ã»»¤ÇÂåÍÑ                                                                                     */
/*  0*0.71 + 0.0775*0.71 - 0.62*0.71 = -0.385 ¡úÀµ²ò                                                                                      */
/*           0   1   2   3   4   5   6             0   1   2   3   .................   e   f          0                                   */
/*         _/~\_/~\_/~\_/~\_/~\_/~\_/~\          _/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\       _/~\                                  */
/*   w0.e:6_____/~~~~~~~~~~~~~~~~~~~~~\    w0.f:7_/~\_/~\_/~\_/~\_/~\_/~\_/~\___________1.42_ w0.s:0____                                  */
/*                                                                                                                                        */
/*  in0.e:0____________________________   in0.f:0____________________________________________                                             */
/*  *w0 (0+6-7)=0                         in0.f:0_______________________________________0.00_                                             */
/*  ou0.e:0______.___.___.___.___._____                                                                                                   */
/*  e0.0000*f0.00        eºÇÂç¤È¤Îº¹ >  5           spike¿ô1/32¤Ë                            in0.s:0____                                  */
/*                                   |                                                                                                    */
/*  in1.e:3_/~\_/~\_/~\________________   in1.f:4_/~\_____/~\_____/~\_____/~\___________1.24_                                             */
/*  *w0 (3+6-7=2)                         in1.f:12  7+4¤ÇÂåÍÑ /~\_/~\_/~\_/~\_/~\_/~\_/~1.76_(1.66)                                       */
/*  ou1.e:2_____/~\_/~\__.___.___._____             w1.42*in1.24=1.76                                                                     */
/*  e0.0625*f1.24        eºÇÂç¤È¤Îº¹ >  3           spike¿ô1/8¤Ë 11/8 = 0.0625 /8 = 0        in1.s:0____                                  */
/*                                                  spike¿ô¤Î±¦¥·¥Õ¥ÈÊý¼°¤ÏÍ×¸¡Æ¤(Ê¬¼þ´ï¤Ç²ÄÇ½?)                                          */
/*                                   |                                                                                                    */
/*  in2.e:6_/~\_/~\_/~\_/~\_/~\_/~\____   in2.f:4_/~\_____/~\_____/~\_____/~\___________1.24_                                             */
/*  *w0 (6+6-7=5)                         in2.f:12  7+4¤ÇÂåÍÑ /~\_/~\_/~\_/~\_/~\_/~\_/~1.76_(1.66)                                       */
/*  ou2.e:5_____/~\_/~\_/~\_/~\_/~\____             w1.42*in1.24=1.76                                                                     */
/*  e0.5000*f1.24        eºÇÂç¤¬´ð½à >  0                       1.76/1 = 1.66                in2.s:1_/~\                                  */
/*                                   |                                                                                                    */
/*  max.e:5_____/~\_/~\_/~\_/~\_/~\__5_                                   sum:f:pulse¿ô¤Ï 0+0-11 = -1.66                                  */
/*                                                  ·ë²Ì¤Ï, 0.25* -1.66 = -0.415 ¡ú¶á»÷                                                   */

int convf32tof8(float in, struct f8bit *out_f8) /* in_f -> in_s */
{
  struct f32bit in_f32;

  *(float*)&in_f32 = in;

  out_f8->s    = in_f32.s;
  out_f8->exp  = (in_f32.exp < 120) ? 0 : (in_f32.exp <= 127) ? in_f32.exp - 120  :   7; /* min=0, max=1.9375 */
  out_f8->frac = (in_f32.exp < 120) ? 0 : (in_f32.exp <= 127) ? in_f32.frac >> 19 : 0xf; /* min=0, max=1.9375 */
  //printf("%x_%02.2x_%06.6x -> %x%01.1x%01.1x\n", in_f32.s, in_f32.exp, in_f32.frac<<1, out_f8->s, out_f8->exp, out_f8->frac);
}

int convf8tof32(struct f8bit in_f8, float *out) /* out_s -> out_f */
{
  struct f32bit out_f32;

  out_f32.s   = in_f8.s;
  if (in_f8.exp == 0 && in_f8.frac == 0) {
    out_f32.exp  = 0;
    out_f32.frac = 0;
  }
  else {
    out_f32.exp  = in_f8.exp + 120;
    out_f32.frac = in_f8.frac << 19;
  }
  //printf("%x%01.1x%01.1x -> %x_%02.2x_%06.6x\n", in_f8.s, in_f8.exp, in_f8.frac, out_f32.s, out_f32.exp, out_f32.frac);

  *out = *(float*)&out_f32;
}

int convf32tof8tof32(float in_f32, float *out_f32)
{
  struct f8bit in_f8;

  convf32tof8(in_f32, &in_f8); /* accumulate */
  convf8tof32(in_f8, out_f32);
  //printf("%6.5f(%08.8x)->%x%x%x->%6.5f\n", f, *((Uint*)&f)<<1, in_f8.s, in_f8.exp, in_f8.frac, *(float*)&out_f32);
}

/* 0 000 0001 (subnormal) + 0 000 0001 (subnormal) * 0 111 0000 (1.0) */
/*                               00001             *      10000       */
/*                               pp[ 0]=110 ps[ 0]=0                  */
/*                               pp[ 1]=300 ps[ 1]=0                  */
/*                               pp[ 2]=c00 ps[ 2]=0                  */
/*                                 sum:1010                           */
/*                               fadd_s1: 0 01 00000001               */
/*                                 csa_s: 0 01 01fff701               */
/*                                 csa_c: 0 01 00000200               */

int softf8(float f1, float f2, float f3, float *o) /* f1 + f2 * f3 -> o */
{
  struct f32bit in1_f32, in2_f32, in3_f32;
  struct f8bit  in1_f8, in2_f8, in3_f8, out_f8;

  struct {
    Uint  frac : 7; /* 5.999 4bit+4bit+4bit */
    Uint  exp  : 4;
    Uint  s    : 1;
  } ad1_s, ad2_s, sum_s;

  *(float*)&in1_f32 = f1;
  *(float*)&in2_f32 = f2;
  *(float*)&in3_f32 = f3;

  convf32tof8(f1, &in1_f8); /* accumulate */
  convf32tof8(f2, &in2_f8); /* weight */
  convf32tof8(f3, &in3_f8); /* in     */
  //printf("%6.5f %x_%02.2x_%06.6x->%1x%1x%1x ", f2, in2_f32.s, in2_f32.exp, in2_f32.frac<<1, in2_f8.s, in2_f8.exp, in2_f8.frac);

  /* f2 * f3 -> ad2 */
  if ((in2_f8.exp == 0 && in2_f8.frac == 0) || (in3_f8.exp == 0 && in3_f8.frac == 0)) {
    ad2_s.s    = in2_f8.s ^ in3_f8.s;
    ad2_s.exp  = 0;
    ad2_s.frac = 0;
  }
  else {
    ad2_s.s    = in2_f8.s ^ in3_f8.s;
    ad2_s.exp  = in3_f8.exp + in2_f8.exp;
    ad2_s.frac = 0x10 + in2_f8.frac + in3_f8.frac; /* 1.0ÊäÀµ 4bit+4bit mul->add */
  //ad2_s.frac = 0x08 + in2_f8.frac + in3_f8.frac; /* 0.5ÊäÀµ 4bit+4bit mul->add */

    if (ad2_s.frac & 0x20) /* ¾è»»¤Î¾ì¹ç,     1.99 *   1.99 =       3.96  3.96 */
                           /* ²Ã»» 1.0ÊäÀµ, (1).99 + (1).99 = (1+1) 1.98  3.98 */
                           /*      0.5ÊäÀµ  (1).99 + (1).99 = (1+.5)1.98  3.48 */
                           /* ¾è»»¤Î¾ì¹ç,     1.00 *   1.00 =       1.00  1.00 */
                           /* ²Ã»» 1.0ÊäÀµ  (1).00 + (1).00 = (1+1) 0.00  2.00 */
                           /*      0.5ÊäÀµ, (1).00 + (1).00 = (1+.5)0.00  1.50 */
                             { ad2_s.exp += 1; ad2_s.frac >>=    1; }
    if      (ad2_s.exp <  7) { ad2_s.exp  = 0; ad2_s.frac   =    0; }
    else if (ad2_s.exp < 15) { ad2_s.exp -= 7;                      }
    else                     { ad2_s.exp  = 7; ad2_s.frac   = 0x1f; } /*ºÇÂçÃÍ*/
  }
  //printf("->%x%1x_%02.2x ", ad2_s.s, ad2_s.exp, ad2_s.frac);

  /* f1 + ad2 -> o */
  ad1_s.s      = in1_f8.s;
  ad1_s.exp    = in1_f8.exp;
  if (in1_f8.exp == 0 && in1_f8.frac == 0)
    ad1_s.frac = 0;
  else
    ad1_s.frac = 0x10 | in1_f8.frac;

  sum_s.exp    = max (ad1_s.exp, ad2_s.exp);
  ad1_s.frac >>= sub0(sum_s.exp, ad1_s.exp);
  ad2_s.frac >>= sub0(sum_s.exp, ad2_s.exp);
  sum_s.s      = (ad1_s.s   == ad2_s.s)    ? ad1_s.s :
                 (ad1_s.frac > ad2_s.frac) ? ad1_s.s :
                                             ad2_s.s ;
  sum_s.frac   = (ad1_s.s   == ad2_s.s)    ? ad1_s.frac + ad2_s.frac :
                 (ad1_s.frac > ad2_s.frac) ? ad1_s.frac - ad2_s.frac :
                                             ad2_s.frac - ad1_s.frac ;

  if      (sum_s.frac ==   0) { sum_s.exp  = 0; sum_s.frac =   0; }
  else if (sum_s.frac & 0x40) {
    if    (sum_s.exp  >=   6) { sum_s.exp  = 7; sum_s.frac = 0xf; }
    else                      { sum_s.exp += 2; sum_s.frac >>= 2; }
  }
  else if (sum_s.frac & 0x20) {
    if    (sum_s.exp  >=   7) { sum_s.exp  = 7; sum_s.frac = 0xf; }
    else                      { sum_s.exp += 1; sum_s.frac >>= 1; }
  }
  else if (sum_s.frac & 0x10) { sum_s.exp -= 0; sum_s.frac <<= 0; }
  else if (sum_s.frac & 0x08) {
    if    (sum_s.exp  >    1) { sum_s.exp -= 1; sum_s.frac <<= 1; }
    else                      { sum_s.exp  = 0; sum_s.frac   = 0; }
  }
  else if (sum_s.frac & 0x04) {
    if    (sum_s.exp  >    2) { sum_s.exp -= 2; sum_s.frac <<= 2; }
    else                      { sum_s.exp  = 0; sum_s.frac   = 0; }
  }
  else if (sum_s.frac & 0x02) {
    if    (sum_s.exp  >    3) { sum_s.exp -= 3; sum_s.frac <<= 3; }
    else                      { sum_s.exp  = 0; sum_s.frac   = 0; }
  }
  else if (sum_s.frac & 0x01) {
    if    (sum_s.exp  >    4) { sum_s.exp -= 4; sum_s.frac <<= 4; }
    else                      { sum_s.exp  = 0; sum_s.frac   = 0; }
  }

  out_f8.s    = sum_s.s;
  out_f8.exp  = sum_s.exp;
  out_f8.frac = sum_s.frac; /* lower 4bit */
  //printf("[%x%1x%1x] ", out_f8.s, out_f8.exp, out_f8.frac);

  convf8tof32(out_f8, o);
  //printf("%6.5f-%6.5f %6.5f\n", f1+f2*f3, *o, abs(f1+f2*f3-*o));

  return(0);
}

/******************************************************************************************************************************************/
/*** IEEE Floating point            *******************************************************************************************************/
/******************************************************************************************************************************************/

union fpn {
  struct raw {
    Uint w;
  } raw;
  struct flo {
    float w;
  } flo;
  struct base {
    Uint  frac : 23;
    Uint  exp  :  8;
    Uint  s    :  1;
  } base;
} in1, in2, in3, out, org;

radix4(Uint *pp, Uint *ps, Uint a, Uint b)
{
  switch (b) {
  case 0:  *pp =   0;                   *ps = 0; break;
  case 1:  *pp =   a    & 0x1ffffff;    *ps = 0; break;
  case 2:  *pp =   a    & 0x1ffffff;    *ps = 0; break;
  case 3:  *pp =   a<<1 & 0x1ffffff;    *ps = 0; break;
  case 4:  *pp = ~(a<<1)& 0x1ffffff;    *ps = 1; break;
  case 5:  *pp =  ~a    & 0x1ffffff;    *ps = 1; break;
  case 6:  *pp =  ~a    & 0x1ffffff;    *ps = 1; break;
  default: *pp =  ~0    & 0x1ffffff;    *ps = 1; break;
  }
}

partial_product(Uint *pp, Uint *ps, Uint a, Uint b, Uint pos)
{
  /* switch (pos) */
  /* case 0:    "~s  s  s 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0" */
  /* case 1-10: "    1 ~s 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0" */
  /* case 11:   "      ~s 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0" */
  /* case 12:   "         24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0" */
  Uint tp, ts;

  radix4(&tp, &ts, a, b);
  switch (pos) {
  case  0: *pp = ((~ts&1)<<27)|(ts<<26)|(  ts   <<25)|tp; *ps = ts; break;
  case  1: case  2: case  3: case  4: case  5: case  6: case  7: case  8: case  9:
  case 10: *pp =               ( 1<<26)|((~ts&1)<<25)|tp; *ps = ts; break;
  case 11: *pp =                        ((~ts&1)<<25)|tp; *ps = ts; break;
  default: *pp =                                      tp; *ps = ts; break;
  }
}

csa_line(Ull *co, Ull *s, Ull a, Ull b, Ull c)
{
  *s  = a ^ b ^ c;
  *co = ((a & b)|(b & c)|(c & a))<<1;
}

soft32(Uint info, float i1, float i2, float i3, float *o)
{
  int op = 3;
  in1.flo.w = i1;
  in2.flo.w = i2;
  in3.flo.w = i3;

  /* op=1:fmul, 2:fadd, 3:fma3 */
  struct src {
    Uint nan  :  1;
    Uint inf  :  1;
    Uint zero :  1;
    Uint frac : 24;
    Uint exp  :  8;
    Uint s    :  1;
  } s1, s2, s3;

  struct fmul_s {
    Uint nan  :  1;
    Uint inf  :  1;
    Uint zero :  1;
    Uint frac : 24;
    Uint exp  :  8;
    Uint s    :  1;
  } fmul_s1, fmul_s2;

  struct fmul_d {
    Uint nan  :  1;
    Uint inf  :  1;
    Uint zero :  1;
    Ull  frac : 48; /* send upper 25bit to the next stage */
    Uint exp  :  9;
    Uint s    :  1;
  } fmul_d;

  struct fadd_s {
    Uint nan  :  1;
    Uint inf  :  1;
    Uint zero :  1;
    Ull  frac : 25+PEXT; /* aligned to fmul_d */
    Uint exp  :  9;
    Uint s    :  1;
  } fadd_s1, fadd_s2;

  struct fadd_w {
    Uint exp_comp  :  1;
    Uint exp_diff  :  9;
    Uint align_exp :  9;
    Ull  s1_align_frac : 25+PEXT;
    Ull  s2_align_frac : 25+PEXT;
  } fadd_w;

  struct fadd_d {
    Uint nan  :  1;
    Uint inf  :  1;
    Uint zero :  1;
    Ull  frac : 26+PEXT;
    Uint exp  :  9;
    Uint s    :  1;
  } fadd_d;

  struct ex1_d {
    Uint nan  :  1;
    Uint inf  :  1;
    Uint zero :  1;
    Ull  frac : 26+PEXT;
    Uint exp  :  9;
    Uint s    :  1;
  } ex1_d;

  struct ex2_w {
    Uint lzc  :  6;
  } ex2_w;

  struct ex2_d {
    Uint frac : 23;
    Uint exp  :  8;
    Uint s    :  1;
  } ex2_d;

  s1.s    = (op==1)?0:in1.base.s;
  s1.exp  = (op==1)?0:in1.base.exp;
  s1.frac = (op==1)?0:(in1.base.exp==  0)?(0<<23)|in1.base.frac:(1<<23)|in1.base.frac;
  s1.zero = (op==1)?1:(in1.base.exp==  0) && (in1.base.frac==0);
  s1.inf  = (op==1)?0:(in1.base.exp==255) && (in1.base.frac==0);
  s1.nan  = (op==1)?0:(in1.base.exp==255) && (in1.base.frac!=0);
  s2.s    = in2.base.s;
  s2.exp  = in2.base.exp;
  s2.frac = (in2.base.exp==  0)?(0<<23)|in2.base.frac:(1<<23)|in2.base.frac;
  s2.zero = (in2.base.exp==  0) && (in2.base.frac==0);
  s2.inf  = (in2.base.exp==255) && (in2.base.frac==0);
  s2.nan  = (in2.base.exp==255) && (in2.base.frac!=0);
  s3.s    = (op==2)?0      :in3.base.s;
  s3.exp  = (op==2)?127    :in3.base.exp;
  s3.frac = (op==2)?(1<<23):(in3.base.exp==  0)?(0<<23)|in3.base.frac:(1<<23)|in3.base.frac;
  s3.zero = (op==2)?0      :(in3.base.exp==  0) && (in3.base.frac==0);
  s3.inf  = (op==2)?0      :(in3.base.exp==255) && (in3.base.frac==0);
  s3.nan  = (op==2)?0      :(in3.base.exp==255) && (in3.base.frac!=0);

  org.flo.w = in1.flo.w+in2.flo.w*in3.flo.w;
  if (info) {
    printf("//--soft32--\n");
    printf("//s1: %08.8x %f\n", in1.raw.w, in1.flo.w);
    printf("//s2: %08.8x %f\n", in2.raw.w, in2.flo.w);
    printf("//s3: %08.8x %f\n", in3.raw.w, in3.flo.w);
    printf("//d : %08.8x %f\n", org.raw.w, org.flo.w);
  }

  fmul_s1.s    = s2.s;
  fmul_s1.exp  = s2.exp;
  fmul_s1.frac = s2.frac;
  fmul_s1.zero = s2.zero;
  fmul_s1.inf  = s2.inf;
  fmul_s1.nan  = s2.nan;
  fmul_s2.s    = s3.s;
  fmul_s2.exp  = s3.exp;
  fmul_s2.frac = s3.frac;
  fmul_s2.zero = s3.zero;
  fmul_s2.inf  = s3.inf;
  fmul_s2.nan  = s3.nan;

  /* nan  * any  -> nan */
  /* inf  * zero -> nan */
  /* inf  * (~zero & ~nan) -> inf */
  /* zero * (~inf  & ~nan) -> zero */
  fmul_d.s    = fmul_s1.s ^ fmul_s2.s;
  fmul_d.exp  = ((0<<8)|fmul_s1.exp) + ((0<<8)|fmul_s2.exp) < 127 ? 0 :
                ((0<<8)|fmul_s1.exp) + ((0<<8)|fmul_s2.exp) - 127;
  fmul_d.frac = (Ull)fmul_s1.frac * (Ull)fmul_s2.frac;
  fmul_d.zero = (fmul_s1.zero && !fmul_s2.inf && !fmul_s2.nan) || (fmul_s2.zero && !fmul_s1.inf && !fmul_s1.nan);
  fmul_d.inf  = (fmul_s1.inf && !fmul_s2.zero && !fmul_s2.nan) || (fmul_s2.inf && !fmul_s1.zero && !fmul_s1.nan);
  fmul_d.nan  = fmul_s1.nan || fmul_s2.nan || (fmul_s1.inf && fmul_s2.zero) || (fmul_s2.inf && fmul_s1.zero);

  if (info) {
    printf("//fmul_s1: %x %x %x\n", fmul_s1.s, fmul_s1.exp, fmul_s1.frac);
    printf("//fmul_s2: %x %x %x\n", fmul_s2.s, fmul_s2.exp, fmul_s2.frac);
    printf("//fmul_d:  %x %x %08.8x_%08.8x\n", fmul_d.s, fmul_d.exp, (Uint)(fmul_d.frac>>32), (Uint)fmul_d.frac);
  }

  fadd_s1.s    = s1.s;
  fadd_s1.exp  = (0<s1.exp&&s1.exp<255)?(s1.exp-1):s1.exp;
  fadd_s1.frac = (0<s1.exp&&s1.exp<255)?(Ull)s1.frac<<(PEXT+1):(Ull)s1.frac<<PEXT;
  fadd_s1.zero = s1.zero;
  fadd_s1.inf  = s1.inf;
  fadd_s1.nan  = s1.nan;
  fadd_s2.s    = fmul_d.s;
  fadd_s2.exp  = fmul_d.exp;
  fadd_s2.frac = fmul_d.frac>>(23-PEXT); //¡ú¡ú¡ú¥¬¡¼¥ÉÂÐ±þÉ¬Í×
  fadd_s2.zero = fmul_d.zero;
  fadd_s2.inf  = fmul_d.inf;
  fadd_s2.nan  = fmul_d.nan;

  /* nan  + any  -> nan */
  /* inf  + -inf -> nan */
  /* inf  + (~-inf & ~nan) -> inf */
  /* -inf + (~inf  & ~nan) -> inf */
  fadd_w.exp_comp      = fadd_s1.exp>fadd_s2.exp?1:0;
  fadd_w.exp_diff      = fadd_w.exp_comp?(fadd_s1.exp-fadd_s2.exp):(fadd_s2.exp-fadd_s1.exp);
  if (fadd_w.exp_diff>25+PEXT) fadd_w.exp_diff=25+PEXT;
  fadd_w.align_exp     = fadd_w.exp_comp?fadd_s1.exp:fadd_s2.exp;
  fadd_w.s1_align_frac = fadd_s1.frac>>(fadd_w.exp_comp?0:fadd_w.exp_diff);
  fadd_w.s2_align_frac = fadd_s2.frac>>(fadd_w.exp_comp?fadd_w.exp_diff:0);

  if (info) {
    printf("//fadd_s1: %x %x %08.8x_%08.8x (%x)-> %x %08.8x_%08.8x\n", fadd_s1.s, fadd_s1.exp, (Uint)((Ull)fadd_s1.frac>>32), (Uint)fadd_s1.frac, fadd_w.exp_diff, fadd_w.align_exp, (Uint)((Ull)fadd_w.s1_align_frac>>32), (Uint)fadd_w.s1_align_frac);
    printf("//fadd_s2: %x %x %08.8x_%08.8x (%x)-> %x %08.8x_%08.8x\n", fadd_s2.s, fadd_s2.exp, (Uint)((Ull)fadd_s2.frac>>32), (Uint)fadd_s2.frac, fadd_w.exp_diff, fadd_w.align_exp, (Uint)((Ull)fadd_w.s2_align_frac>>32), (Uint)fadd_w.s2_align_frac);
  }

  fadd_d.s           = (fadd_s1.s==fadd_s2.s) ? fadd_s1.s : (fadd_w.s1_align_frac>fadd_w.s2_align_frac) ? fadd_s1.s : fadd_s2.s;
  fadd_d.exp         = fadd_w.align_exp;
  fadd_d.frac        = (fadd_s1.s == fadd_s2.s)                    ? (Ull)fadd_w.s1_align_frac+(Ull)fadd_w.s2_align_frac :
                       (fadd_w.s1_align_frac>fadd_w.s2_align_frac) ? (Ull)fadd_w.s1_align_frac-(Ull)fadd_w.s2_align_frac :
                                                                     (Ull)fadd_w.s2_align_frac-(Ull)fadd_w.s1_align_frac ;
  fadd_d.zero        = fadd_d.frac==0;
  fadd_d.inf         = (!fadd_s1.s && fadd_s1.inf && !(fadd_s2.s && fadd_s2.inf) && !fadd_s2.nan) || (fadd_s1.s && fadd_s1.inf && !(!fadd_s2.s && fadd_s2.inf) && !fadd_s2.nan) ||
                       (!fadd_s2.s && fadd_s2.inf && !(fadd_s1.s && fadd_s1.inf) && !fadd_s1.nan) || (fadd_s2.s && fadd_s2.inf && !(!fadd_s1.s && fadd_s1.inf) && !fadd_s1.nan) ;
  fadd_d.nan         = fadd_s1.nan || fadd_s2.nan;

  ex1_d.s            = fadd_d.s;
  ex1_d.exp          = fadd_d.exp;
  ex1_d.frac         = fadd_d.frac;
  ex1_d.zero         = fadd_d.zero;
  ex1_d.inf          = fadd_d.inf;
  ex1_d.nan          = fadd_d.nan;

#define FLOAT_PZERO 0x00000000
#define FLOAT_NZERO 0x80000000
#define FLOAT_PINF  0x7f800000
#define FLOAT_NINF  0xff800000
#define FLOAT_NAN   0xffc00000

  /* normalize */

#if 1
  ex2_w.lzc          = (ex1_d.frac & 0x2000000LL<<PEXT)?62 :
                       (ex1_d.frac & 0x1000000LL<<PEXT)?63 :
                       (ex1_d.frac & 0x0800000LL<<PEXT)? 0 :
                       (ex1_d.frac & 0x0400000LL<<PEXT)? 1 :
                       (ex1_d.frac & 0x0200000LL<<PEXT)? 2 :
                       (ex1_d.frac & 0x0100000LL<<PEXT)? 3 :
                       (ex1_d.frac & 0x0080000LL<<PEXT)? 4 :
                       (ex1_d.frac & 0x0040000LL<<PEXT)? 5 :
                       (ex1_d.frac & 0x0020000LL<<PEXT)? 6 :
                       (ex1_d.frac & 0x0010000LL<<PEXT)? 7 :
                       (ex1_d.frac & 0x0008000LL<<PEXT)? 8 :
                       (ex1_d.frac & 0x0004000LL<<PEXT)? 9 :
                       (ex1_d.frac & 0x0002000LL<<PEXT)?10 :
                       (ex1_d.frac & 0x0001000LL<<PEXT)?11 :
                       (ex1_d.frac & 0x0000800LL<<PEXT)?12 :
                       (ex1_d.frac & 0x0000400LL<<PEXT)?13 :
                       (ex1_d.frac & 0x0000200LL<<PEXT)?14 :
                       (ex1_d.frac & 0x0000100LL<<PEXT)?15 :
                       (ex1_d.frac & 0x0000080LL<<PEXT)?16 :
                       (ex1_d.frac & 0x0000040LL<<PEXT)?17 :
                       (ex1_d.frac & 0x0000020LL<<PEXT)?18 :
                       (ex1_d.frac & 0x0000010LL<<PEXT)?19 :
                       (ex1_d.frac & 0x0000008LL<<PEXT)?20 :
                       (ex1_d.frac & 0x0000004LL<<PEXT)?21 :
                       (ex1_d.frac & 0x0000002LL<<PEXT)?22 :
                       (ex1_d.frac & 0x0000001LL<<PEXT)?23 :
#if (PEXT>= 1)
                       (ex1_d.frac & 0x0000001LL<<PEXT- 1)?24 :
#endif
#if (PEXT>= 2)
                       (ex1_d.frac & 0x0000001LL<<PEXT- 2)?25 :
#endif
#if (PEXT>= 3)
                       (ex1_d.frac & 0x0000001LL<<PEXT- 3)?26 :
#endif
#if (PEXT>= 4)
                       (ex1_d.frac & 0x0000001LL<<PEXT- 4)?27 :
#endif
#if (PEXT>= 5)
                       (ex1_d.frac & 0x0000001LL<<PEXT- 5)?28 :
#endif
#if (PEXT>= 6)
                       (ex1_d.frac & 0x0000001LL<<PEXT- 6)?29 :
#endif
#if (PEXT>= 7)
                       (ex1_d.frac & 0x0000001LL<<PEXT- 7)?30 :
#endif
#if (PEXT>= 8)
                       (ex1_d.frac & 0x0000001LL<<PEXT- 8)?31 :
#endif
#if (PEXT>= 9)
                       (ex1_d.frac & 0x0000001LL<<PEXT- 9)?32 :
#endif
#if (PEXT>=10)
                       (ex1_d.frac & 0x0000001LL<<PEXT-10)?33 :
#endif
#if (PEXT>=11)
                       (ex1_d.frac & 0x0000001LL<<PEXT-11)?34 :
#endif
#if (PEXT>=12)
                       (ex1_d.frac & 0x0000001LL<<PEXT-12)?35 :
#endif
#if (PEXT>=13)
                       (ex1_d.frac & 0x0000001LL<<PEXT-13)?36 :
#endif
#if (PEXT>=14)
                       (ex1_d.frac & 0x0000001LL<<PEXT-14)?37 :
#endif
#if (PEXT>=15)
                       (ex1_d.frac & 0x0000001LL<<PEXT-15)?38 :
#endif
#if (PEXT>=16)
                       (ex1_d.frac & 0x0000001LL<<PEXT-16)?39 :
#endif
#if (PEXT>=17)
                       (ex1_d.frac & 0x0000001LL<<PEXT-17)?40 :
#endif
#if (PEXT>=18)
                       (ex1_d.frac & 0x0000001LL<<PEXT-18)?41 :
#endif
#if (PEXT>=19)
                       (ex1_d.frac & 0x0000001LL<<PEXT-19)?42 :
#endif
#if (PEXT>=20)
                       (ex1_d.frac & 0x0000001LL<<PEXT-20)?43 :
#endif
#if (PEXT>=21)
                       (ex1_d.frac & 0x0000001LL<<PEXT-21)?44 :
#endif
#if (PEXT>=22)
                       (ex1_d.frac & 0x0000001LL<<PEXT-22)?45 :
#endif
#if (PEXT>=23)
                       (ex1_d.frac & 0x0000001LL<<PEXT-22)?46 :
#endif
                                                       24+PEXT;
  if (info) {
    printf("//ex1:%x %x %08.8x_%08.8x ", ex1_d.s, ex1_d.exp, (Uint)((Ull)ex1_d.frac>>32), (Uint)ex1_d.frac);
  }

  if (ex1_d.nan) {
    ex2_d.s    = 1;
    ex2_d.frac = 0x400000;
    ex2_d.exp  = 0xff;

  }
  else if (ex1_d.inf) {
    ex2_d.s    = ex1_d.s;
    ex2_d.frac = 0x000000;
    ex2_d.exp  = 0xff;
  }
  else if (ex2_w.lzc == 62) {
    if (info) {
      printf("lzc==%d\n", ex2_w.lzc);
    }
    if (ex1_d.exp >= 253) {
      ex2_d.s    = ex1_d.s;
      ex2_d.frac = 0x000000;
      ex2_d.exp  = 0xff;
    }
    else {
      ex2_d.s    = ex1_d.s;
      ex2_d.frac = ex1_d.frac>>(2+PEXT); //¡ú¡ú¡ú¥¬¡¼¥ÉÂÐ±þÉ¬Í×
      ex2_d.exp  = ex1_d.exp + 2;
    }
  }
  else if (ex2_w.lzc == 63) {
    if (info) {
      printf("lzc==%d\n", ex2_w.lzc);
    }
    if (ex1_d.exp >= 254) {
      ex2_d.s    = ex1_d.s;
      ex2_d.frac = 0x000000;
      ex2_d.exp  = 0xff;
    }
    else {
      ex2_d.s    = ex1_d.s;
      ex2_d.frac = ex1_d.frac>>(1+PEXT); //¡ú¡ú¡ú¥¬¡¼¥ÉÂÐ±þÉ¬Í×
      ex2_d.exp  = ex1_d.exp + 1;
    }
  }
  else if (ex2_w.lzc <= (23+PEXT)) {
    if (info) {
      printf("lzc==%d\n", ex2_w.lzc);
    }
    if (ex1_d.exp >= ex2_w.lzc + 255) {
      ex2_d.s    = ex1_d.s;
      ex2_d.frac = 0x000000;
      ex2_d.exp  = 0xff;
    }
    else if (ex1_d.exp <= ex2_w.lzc) { /* subnormal num */
      ex2_d.s    = ex1_d.s;
      ex2_d.frac = (ex1_d.frac<<ex1_d.exp)>>PEXT;
      ex2_d.exp  = 0x00;
    }
    else { /* normalized num */
      ex2_d.s    = ex1_d.s;
      ex2_d.frac = (ex1_d.frac<<ex2_w.lzc)>>PEXT;
      ex2_d.exp  = ex1_d.exp - ex2_w.lzc;
    }
#define NO_GUARD_BITS
#ifndef NO_GUARD_BITS
    int f_ulp = (ex1_d.frac<<ex2_w.lzc)>> PEXT   &1;
    int f_g   = (ex1_d.frac<<ex2_w.lzc)>>(PEXT-1)&1;
    int f_r   = (ex1_d.frac<<ex2_w.lzc)>>(PEXT-2)&1;
    int f_s   =((ex1_d.frac<<ex2_w.lzc)&(0xfffffffffffLL>>(46-PEXT))!=0;
    switch (f_ulp<<3|f_g<<2|f_r<<1|f_s) {
    case 0: case 1: case 2: case 3: case 4: /* ulp|G|R|S */
    case 8: case 9: case 10: case 11:
      break;
    case 5: case 6: case 7: /* ulp++ */
    case 12: case 13: case 14: case 15: default:
      if (info)
	printf("//ex2:%x %x %x++ -> ", ex2_d.s, ex2_d.exp, ex2_d.frac);
      ex2_d.frac++;
      if (info)
	printf("%x\n", ex2_d.frac);
      break;
    }
#endif
  }
  else { /* zero */
    if (info) {
      printf("zero\n");
    }
    ex2_d.s    = 0;
    ex2_d.frac = 0x000000;
    ex2_d.exp  = 0x00;
  }
#endif

  if (info) {
    printf("//ex2:%x %x %x\n", ex2_d.s, ex2_d.exp, ex2_d.frac);
  }

  out.raw.w  = (ex2_d.s<<31)|(ex2_d.exp<<23)|(ex2_d.frac);
  org.flo.w  = i1+i2*i3;
  Uint diff = out.raw.w>org.raw.w ? out.raw.w-org.raw.w : org.raw.w-out.raw.w;

  if (!info)
    sprintf(softbuf32, "%8.8e:%08.8x %8.8e:%08.8x %8.8e:%08.8x ->%8.8e:%08.8x (%8.8e:%08.8x) %08.8x %s%s%s",
           in1.flo.w, in1.raw.w, in2.flo.w, in2.raw.w, in3.flo.w, in3.raw.w, out.flo.w, out.raw.w, org.flo.w, org.raw.w, diff,
           diff>=TH1 ? "S":"",
           diff>=TH2 ? "S":"",
           diff>=TH3 ? "S":""
           );
  *o = out.flo.w;
  return(diff);
}

/* radix-4 modified booth (unsigned A[23:0]*B[23:0] -> C[47:1]+S[46:0] */
/*                             0 0 B[23:................................0] 0 */
/*                                                                  B[ 1:-1] */
/*                                                               B[ 3: 1]    */
/*                                                            B[ 5: 3]       */
/*                                                         B[ 7: 5]          */
/*                                                      B[ 9: 7]             */
/*                                                   B[11: 9]                */
/*                                                B[13:11]                   */
/*                                             B[15:13]                      */
/*                                          B[17:15]                         */
/*                                       B[19:17]                            */
/*                                    B[21:19]                               */
/*                                 B[23:21]                                  */
/*                              B[25:23]                                     */
/*         switch (B[2j+1:2j-1])                                             */
/*         case 0: pp[j][47:2j] =   0;  ... single=0;double=0;neg=0          */
/*         case 1: pp[j][47:2j] =   A;  ... single=1;double=0;neg=0          */
/*         case 2: pp[j][47:2j] =   A;  ... single=1;double=0;neg=0          */
/*         case 3: pp[j][47:2j] =  2A;  ... single=0;double=1;neg=0          */
/*         case 4: pp[j][47:2j] = -2A;  ... single=0;double=1;neg=1          */
/*         case 5: pp[j][47:2j] =  -A;  ... single=1;double=0;neg=1          */
/*         case 6: pp[j][47:2j] =  -A;  ... single=1;double=0;neg=1          */
/*         case 7: pp[j][47:2j] =   0;  ... single=0;double=0;neg=1          */
/*            j= 0¤Î¾ì¹ç, pp[ 0][47: 0] Éä¹æ³ÈÄ¥                             */
/*            j=12¤Î¾ì¹ç, pp[12][47:24](Éä¹æ³ÈÄ¥ÉÔÍ×)                        */
/*                                   single = B[2j] ^ B[2j-1];               */
/*                                   double = ~(single | ~(B[2j+1] ^ B[2j]));*/
/*                                   s(neg) = B[2j+1];                       */
/*                                   pp[j+1][2j]= s(neg);                    */
/*                                   j= 0¤Î¾ì¹ç, pp[ 1][ 0]¤Ës               */
/*                                   j=11¤Î¾ì¹ç, pp[12][22]¤Ës               */

/*  --stage-1 (13in)---------------------------------------------------------------------------------------------------------------------------------------*/
/*  pp[ 0]                                                             ~s  s  s 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0 */
/*  pp[ 1]                                                           1 ~s 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2     s */
/*  pp[ 2]                                                     1 ~s 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4     s       */
/*                                                             |  | HA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA HA FA HA HA *//* HA,24FA,HA,FA,2HA */
/*  S1[0]                                                     30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0 */
/*  C1[0]                                                        29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1    */
/*                                                                                                                                                         */
/*  pp[ 3]                                               1 ~s 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6     s             */
/*  pp[ 4]                                         1 ~s 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8     s     |             */
/*  pp[ 5]                                   1 ~s 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10     s           |             */
/*                                           |  | HA HA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA HA FA HA HA     |             *//* 2HA,23FA,HA,FA,2HA */
/*  S1[1]                                   36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4             */
/*  C1[1]                                      35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7                      */
/*                                                                                                                                                         */
/*  pp[ 6]                             1 ~s 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12     s                               */
/*  pp[ 7]                       1 ~s 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14     s     |                               */
/*  pp[ 8]                 1 ~s 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16     s           |                               */
/*                         |  | HA HA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA HA FA HA HA     |                               *//* 2HA,23FA,HA,FA,2HA */
/*  S1[2]                 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10                               */
/*  C1[2]                    41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13                                        */
/*                                                                                                                                                         */
/*  pp[ 9]           1 ~s 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18     s                                                 */
/*  pp[10]     1 ~s 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20     s     |                                                 */
/*  pp[11] ~s 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22     s           |                                                 */
/*          | HA HA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA HA FA HA HA     |                                                 *//* 2HA,23FA,HA,FA,2HA */
/*  S1[3]  47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16                                                 */
/*  C1[3]  47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19                                                          */
/*                                                                                                                                                         */
/*  pp[12] 47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24     s                                                                   */
/*  -------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*  --stage-2 (9in)----------------------------------------------------------------------------------------------------------------------------------------*/
/*  S1[0]                                                     30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0 */
/*  C1[0]                                                        29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  | */
/*  S1[1]                                   36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4*          | */
/*                                           |  |  |  |  |  | HA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA HA HA HA  | *//* HA,26FA,3HA */
/*  S2[0]                                   36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0 */
/*  C2[0]                                                  31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2       */
/*                                                                                                                                                         */
/*  C1[1]                                      35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7                      */
/*  S1[2]                 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10* |  |  |                      */
/*  C1[2]                  | 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13           |  |  |                      */
/*                         | HA HA HA HA HA HA FA FA FA FA FA FA fA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA HA HA HA  |  |  |                      *//* 6HA,22FA,3HA */
/*  S2[1]                 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7                      */
/*  C2[1]                 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11                                  */
/*                                                                                                                                                         */
/*  S1[3]  47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16*                                                */
/*  C1[3]  47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19  |  |  |                                                 */
/*  pp[12] 47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24     s*          |  |  |                                                 */
/*         FA FA FA FA FA fA FA FA FA FA FA FA FA FA FA FA FA FA fA FA FA FA FA FA HA FA HA HA HA  |  |  |                                                 *//* 22FA,HA,FA,3HA */
/*  S2[2]  47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16                                                 */
/*  C2[2]  47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20                                                             */
/*  -------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*  --stage-3 (6in)----------------------------------------------------------------------------------------------------------------------------------------*/
/*  S2[0]                                   36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0 */
/*  C2[0]                                                  31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  |  | */
/*  S2[1]                 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7                 |  | */
/*                         |  |  |  |  |  | HA HA HA HA HA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA HA HA HA HA HA  |  | *//* 5HA,25FA,5HA */
/*  S3[0]                 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0 */
/*  C3[0]                                37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3          */
/*                                                                                                                                                         */
/*  C2[1]                 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11                                  */
/*  S2[2]  47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16  |  |  |  |  |                                  */
/*  C2[2]  47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20              |  |  |  |  |                                  */
/*         HA HA HA HA HA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA HA HA HA HA  |  |  |  |  |                                  *//* 5HA,23FA,4HA */
/*  S3[1]  47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11                                  */
/*  C3[1]  47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17                                                    */
/*  -------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*  --stage-4 (4in)----------------------------------------------------------------------------------------------------------------------------------------*/
/*  S3[0]                 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0 */
/*  C3[0]                                37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  |  |  | */
/*  S3[1]  47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11                          |  |  | */
/*          |  |  |  |  | HA HA HA HA HA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA HA HA HA HA HA HA HA HA  |  |  | *//* 5HA,27FA,8HA */
/*  S4     47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0 */
/*  C4                 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4             */
/*                                                                                                                                                         */
/*  C3[1]  47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17                                                    */
/*  -------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*  --stage-5 (3in)----------------------------------------------------------------------------------------------------------------------------------------*/
/*  S4     47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0 */
/*  C4                 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  |  |  |  | */
/*  C3[1]  47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17                                         |  |  |  | */
/*         HA HA HA HA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA HA HA HA HA HA HA HA HA HA HA HA HA HA  |  |  |  | *//* 4HA,27FA,13HA */
/*  S5     47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0 */
/*  C5     47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5                */
/*  -------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*  --stage-6 (2in+fadd) ¥·¥Õ¥ÈÄ´À°¸å----------------------------------------------------------------------------------------------------------------------*/
/*  S5     47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0 */
/*  C5     47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  |  |  |  |  | */
/*  AD     47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24                                                           |  |  |  |  | */
/*         FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA HA HA HA HA HA HA HA HA HA HA HA HA HA HA HA HA HA HA HA  |  |  |  |  | *//* 24FA,19HA */
/*  S6     47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0 */
/*  C6     47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6                   */
/*  -------------------------------------------------------------------------------------------------------------------------------------------------------*/

hard32(Uint info, float i1, float i2, float i3, float *o, Uint testbench)
{
  int op = 3;
  in1.flo.w = i1;
  in2.flo.w = i2;
  in3.flo.w = i3;
  /* op=1:fmul (0.0 + s2 *  s3)  */
  /* op=2:fadd (s1  + s2 * 1.0) */
  /* op=3:fma3 (s1  + s2 *  s3)  */

  /* op=1:fmul, 2:fadd, 3:fma3 */
  struct src {
    Uint nan  :  1;
    Uint inf  :  1;
    Uint zero :  1;
    Uint frac : 24;
    Uint exp  :  8;
    Uint s    :  1;
  } s1, s2, s3; /* s1 + s2 * s3 */

  Uint tp;
  Uint ps[13]; /* partial_sign */
  Ull  pp[13]; /* partial_product */
  Ull  S1[4];  /* stage-1 */
  Ull  C1[4];  /* stage-1 */
  Ull  S2[3];  /* stage-2 */
  Ull  C2[3];  /* stage-2 */
  Ull  S3[2];  /* stage-3 */
  Ull  C3[2];  /* stage-3 */
  Ull  S4;     /* stage-4 */
  Ull  C4;     /* stage-4 */
  Ull  S5;     /* stage-5 */
  Ull  C5;     /* stage-5 */
  Ull  S6[3];  /* stage-6 */
  Ull  C6[3];  /* stage-6 */
  Ull  S7[3];  /* stage-6 */
  Ull  C7[3];  /* stage-6 */

  struct ex1_d {
    Uint nan  :  1;
    Uint inf  :  1;
    Uint zero :  1;
    Ull  csa_s: 25+PEXT; //¢£¢£¢£
    Ull  csa_c: 25+PEXT; //¢£¢£¢£
    Uint exp  :  9;
    Uint s    :  1;
  } ex1_d; /* csa */

  struct fadd_s {
    Uint nan  :  1;
    Uint inf  :  1;
    Uint zero :  1;
    Ull  frac : 25+PEXT; /* ¢£¢£¢£aligned to ex1_d */
    Uint exp  :  9;
    Uint s    :  1;
  } fadd_s1;

  struct fadd_w {
    Uint exp_comp  :  1;
    Uint exp_diff  :  9;
    Uint align_exp :  9;
    Ull  s1_align_frac : 25+PEXT; //¢£¢£¢£
    Ull  s2_align_frac : 25+PEXT; //¢£¢£¢£
    Ull  s3_align_frac : 25+PEXT; //¢£¢£¢£
  } fadd_w;

  struct ex2_d {
    Uint nan  :  1;
    Uint inf  :  1;
    Uint zero :  1;
    Ull  frac0: 26+PEXT; /* 26bit */ //¢£¢£¢£
    Ull  frac1: 25+PEXT; /* 25bit */ //¢£¢£¢£
    Ull  frac2: 26+PEXT; /* 26bit */ //¢£¢£¢£
    Ull  frac : 26+PEXT; /* 26bit */ //¢£¢£¢£
    Uint exp  :  9;
    Uint s    :  1;
  } ex2_d;

  struct ex3_w {
    Uint lzc  :  6;
  } ex3_w;

  struct ex3_d {
    Uint frac : 23;
    Uint exp  :  8;
    Uint s    :  1;
  } ex3_d;

  s1.s    = (op==1)?0:in1.base.s;
  s1.exp  = (op==1)?0:in1.base.exp;
  s1.frac = (op==1)?0:(in1.base.exp==  0)?(0<<23)|in1.base.frac:(1<<23)|in1.base.frac;
  s1.zero = (op==1)?1:(in1.base.exp==  0) && (in1.base.frac==0);
  s1.inf  = (op==1)?0:(in1.base.exp==255) && (in1.base.frac==0);
  s1.nan  = (op==1)?0:(in1.base.exp==255) && (in1.base.frac!=0);
  s2.s    = in2.base.s;
  s2.exp  = in2.base.exp;
  s2.frac = (in2.base.exp==  0)?(0<<23)|in2.base.frac:(1<<23)|in2.base.frac;
  s2.zero = (in2.base.exp==  0) && (in2.base.frac==0);
  s2.inf  = (in2.base.exp==255) && (in2.base.frac==0);
  s2.nan  = (in2.base.exp==255) && (in2.base.frac!=0);
  s3.s    = (op==2)?0      :in3.base.s;
  s3.exp  = (op==2)?127    :in3.base.exp;
  s3.frac = (op==2)?(1<<23):(in3.base.exp==  0)?(0<<23)|in3.base.frac:(1<<23)|in3.base.frac;
  s3.zero = (op==2)?0      :(in3.base.exp==  0) && (in3.base.frac==0);
  s3.inf  = (op==2)?0      :(in3.base.exp==255) && (in3.base.frac==0);
  s3.nan  = (op==2)?0      :(in3.base.exp==255) && (in3.base.frac!=0);

  org.flo.w = in1.flo.w+in2.flo.w*in3.flo.w;
  if (info) {
    printf("//--hard32--\n");
    printf("//s1: %08.8x %f\n", in1.raw.w, in1.flo.w);
    printf("//s2: %08.8x %f\n", in2.raw.w, in2.flo.w);
    printf("//s3: %08.8x %f\n", in3.raw.w, in3.flo.w);
    printf("//d : %08.8x %f\n", org.raw.w, org.flo.w);
  }

  /* nan  * any  -> nan */
  /* inf  * zero -> nan */
  /* inf  * (~zero & ~nan) -> inf */
  /* zero * (~inf  & ~nan) -> zero */
  ex1_d.s    = s2.s ^ s3.s;
  ex1_d.exp  = ((0<<8)|s2.exp) + ((0<<8)|s3.exp) < 127 ? 0 :
               ((0<<8)|s2.exp) + ((0<<8)|s3.exp) - 127;

  /**************************************************************************************************************/
  /***  partial product  ****************************************************************************************/
  /**************************************************************************************************************/
  /*ex1_d.frac = (Ull)s2.frac * (Ull)s3.frac;*/
  partial_product(&tp, &ps[ 0], s2.frac, (s3.frac<< 1)&7,  0); pp[ 0] =  (Ull)tp;                        //if (info) {printf("pp[ 0]=%04.4x_%08.8x ps[ 0]=%d\n", (Uint)(pp[ 0]>>32), (Uint)pp[ 0], ps[ 0]);} /*1,0,-1*/
  partial_product(&tp, &ps[ 1], s2.frac, (s3.frac>> 1)&7,  1); pp[ 1] = ((Ull)tp<< 2)| (Ull)ps[ 0];      //if (info) {printf("pp[ 1]=%04.4x_%08.8x ps[ 1]=%d\n", (Uint)(pp[ 1]>>32), (Uint)pp[ 1], ps[ 1]);} /*3,2, 1*/
  partial_product(&tp, &ps[ 2], s2.frac, (s3.frac>> 3)&7,  2); pp[ 2] = ((Ull)tp<< 4)|((Ull)ps[ 1]<< 2); //if (info) {printf("pp[ 2]=%04.4x_%08.8x ps[ 2]=%d\n", (Uint)(pp[ 2]>>32), (Uint)pp[ 2], ps[ 2]);} /*5,4, 3*/
  partial_product(&tp, &ps[ 3], s2.frac, (s3.frac>> 5)&7,  3); pp[ 3] = ((Ull)tp<< 6)|((Ull)ps[ 2]<< 4); //if (info) {printf("pp[ 3]=%04.4x_%08.8x ps[ 3]=%d\n", (Uint)(pp[ 3]>>32), (Uint)pp[ 3], ps[ 3]);} /*7,6, 5*/
  partial_product(&tp, &ps[ 4], s2.frac, (s3.frac>> 7)&7,  4); pp[ 4] = ((Ull)tp<< 8)|((Ull)ps[ 3]<< 6); //if (info) {printf("pp[ 4]=%04.4x_%08.8x ps[ 4]=%d\n", (Uint)(pp[ 4]>>32), (Uint)pp[ 4], ps[ 4]);} /*9,8, 7*/
  partial_product(&tp, &ps[ 5], s2.frac, (s3.frac>> 9)&7,  5); pp[ 5] = ((Ull)tp<<10)|((Ull)ps[ 4]<< 8); //if (info) {printf("pp[ 5]=%04.4x_%08.8x ps[ 5]=%d\n", (Uint)(pp[ 5]>>32), (Uint)pp[ 5], ps[ 5]);} /*11,10,9*/
  partial_product(&tp, &ps[ 6], s2.frac, (s3.frac>>11)&7,  6); pp[ 6] = ((Ull)tp<<12)|((Ull)ps[ 5]<<10); //if (info) {printf("pp[ 6]=%04.4x_%08.8x ps[ 6]=%d\n", (Uint)(pp[ 6]>>32), (Uint)pp[ 6], ps[ 6]);} /*13,12,11*/
  partial_product(&tp, &ps[ 7], s2.frac, (s3.frac>>13)&7,  7); pp[ 7] = ((Ull)tp<<14)|((Ull)ps[ 6]<<12); //if (info) {printf("pp[ 7]=%04.4x_%08.8x ps[ 7]=%d\n", (Uint)(pp[ 7]>>32), (Uint)pp[ 7], ps[ 7]);} /*15,14,13*/
  partial_product(&tp, &ps[ 8], s2.frac, (s3.frac>>15)&7,  8); pp[ 8] = ((Ull)tp<<16)|((Ull)ps[ 7]<<14); //if (info) {printf("pp[ 8]=%04.4x_%08.8x ps[ 8]=%d\n", (Uint)(pp[ 8]>>32), (Uint)pp[ 8], ps[ 8]);} /*17,16,15*/
  partial_product(&tp, &ps[ 9], s2.frac, (s3.frac>>17)&7,  9); pp[ 9] = ((Ull)tp<<18)|((Ull)ps[ 8]<<16); //if (info) {printf("pp[ 9]=%04.4x_%08.8x ps[ 9]=%d\n", (Uint)(pp[ 9]>>32), (Uint)pp[ 9], ps[ 9]);} /*19,18,17*/
  partial_product(&tp, &ps[10], s2.frac, (s3.frac>>19)&7, 10); pp[10] = ((Ull)tp<<20)|((Ull)ps[ 9]<<18); //if (info) {printf("pp[10]=%04.4x_%08.8x ps[10]=%d\n", (Uint)(pp[10]>>32), (Uint)pp[10], ps[10]);} /*21,20,19*/
  partial_product(&tp, &ps[11], s2.frac, (s3.frac>>21)&7, 11); pp[11] = ((Ull)tp<<22)|((Ull)ps[10]<<20); //if (info) {printf("pp[11]=%04.4x_%08.8x ps[11]=%d\n", (Uint)(pp[11]>>32), (Uint)pp[11], ps[11]);} /**23,22,21*/
  partial_product(&tp, &ps[12], s2.frac, (s3.frac>>23)&7, 12); pp[12] = ((Ull)tp<<24)|((Ull)ps[11]<<22); //if (info) {printf("pp[12]=%04.4x_%08.8x ps[12]=%d\n", (Uint)(pp[12]>>32), (Uint)pp[12], ps[12]);} /*25,24,*23*/

  Ull x1 = (pp[0]+pp[1]+pp[2]+pp[3]+pp[4]+pp[5]+pp[6]+pp[7]+pp[8]+pp[9]+pp[10]+pp[11]+pp[12]);
  if (info) { printf("//x1(sum of pp)=%08.8x_%08.8x ->>23 %08.8x\n", (Uint)(x1>>32), (Uint)x1, (Uint)(x1>>23));}
  Ull x2 = (Ull)s2.frac * (Ull)s3.frac;
  if (info) { printf("//x2(s2 * s3)  =%08.8x_%08.8x ->>23 %08.8x\n", (Uint)(x2>>32), (Uint)x2, (Uint)(x2>>23));}

  /**************************************************************************************************************/
  /***  csa tree  ***********************************************************************************************/
  /**************************************************************************************************************/
  csa_line(&C1[0], &S1[0], pp[ 0], pp[ 1], pp[ 2]);
  csa_line(&C1[1], &S1[1], pp[ 3], pp[ 4], pp[ 5]);
  csa_line(&C1[2], &S1[2], pp[ 6], pp[ 7], pp[ 8]);
  csa_line(&C1[3], &S1[3], pp[ 9], pp[10], pp[11]);

  csa_line(&C2[0], &S2[0], S1[ 0], C1[ 0], S1[ 1]);
  csa_line(&C2[1], &S2[1], C1[ 1], S1[ 2], C1[ 2]);
  csa_line(&C2[2], &S2[2], S1[ 3], C1[ 3], pp[12]);

  csa_line(&C3[0], &S3[0], S2[ 0], C2[ 0], S2[ 1]);
  csa_line(&C3[1], &S3[1], C2[ 1], S2[ 2], C2[ 2]);

  csa_line(&C4,    &S4,    S3[ 0], C3[ 0], S3[ 1]);
  csa_line(&C5,    &S5,    S4,     C4,     C3[ 1]);

  ex1_d.csa_s = S5>>(23-PEXT); // sum   ¢£¢£¢£¥¬¡¼¥ÉÂÐ±þÉ¬Í×
  ex1_d.csa_c = C5>>(23-PEXT); // carry ¢£¢£¢£¥¬¡¼¥ÉÂÐ±þÉ¬Í×

  ex1_d.zero = (s2.zero && !s3.inf && !s3.nan) || (s3.zero && !s2.inf && !s2.nan);
  ex1_d.inf  = (s2.inf && !s3.zero && !s3.nan) || (s3.inf && !s2.zero && !s2.nan);
  ex1_d.nan  = s2.nan || s3.nan || (s2.inf && s3.zero) || (s3.inf && s2.zero);

  if (info) {
    printf("//S5           =%08.8x_%08.8x\n", (Uint)(S5>>32), (Uint)S5);
    printf("//C5           =%08.8x_%08.8x\n", (Uint)(C5>>32), (Uint)C5);
    printf("//++(48bit)    =%08.8x_%08.8x\n", (Uint)((C5+S5)>>32), (Uint)(C5+S5));
    printf("//csa_s        =%08.8x_%08.8x\n", (Uint)((Ull)ex1_d.csa_s>>32), (Uint)ex1_d.csa_s);
    printf("//csa_c        =%08.8x_%08.8x\n", (Uint)((Ull)ex1_d.csa_c>>32), (Uint)ex1_d.csa_c);
    printf("//ex1_d: %x %02.2x +=%08.8x_%08.8x\n", ex1_d.s, ex1_d.exp, (Uint)((Ull)(ex1_d.csa_c+ex1_d.csa_s)>>32), (Uint)(ex1_d.csa_c+ex1_d.csa_s));
  }

  /**************************************************************************************************************/
  /***  3in-csa  ************************************************************************************************/
  /**************************************************************************************************************/
  fadd_s1.s    = s1.s;
  fadd_s1.exp  = (0<s1.exp&&s1.exp<255)?(s1.exp-1):s1.exp; //¢£¢£¢£
  fadd_s1.frac = (0<s1.exp&&s1.exp<255)?(Ull)s1.frac<<(PEXT+1):(Ull)s1.frac<<PEXT; //¢£¢£¢£
  fadd_s1.zero = s1.zero;
  fadd_s1.inf  = s1.inf;
  fadd_s1.nan  = s1.nan;

  /* nan  + any  -> nan */
  /* inf  + -inf -> nan */
  /* inf  + (~-inf & ~nan) -> inf */
  /* -inf + (~inf  & ~nan) -> inf */
  fadd_w.exp_comp      = fadd_s1.exp>ex1_d.exp?1:0;
  fadd_w.exp_diff      = fadd_w.exp_comp?(fadd_s1.exp-ex1_d.exp):(ex1_d.exp-fadd_s1.exp);
  if (fadd_w.exp_diff>(25+PEXT)) fadd_w.exp_diff=(25+PEXT); //¢£¢£¢£
  fadd_w.align_exp     = fadd_w.exp_comp?fadd_s1.exp:ex1_d.exp;
  fadd_w.s1_align_frac = fadd_s1.frac>>(fadd_w.exp_comp?0:fadd_w.exp_diff);
  fadd_w.s2_align_frac = ex1_d.csa_s >>(ex1_d.zero?(25+PEXT):fadd_w.exp_comp?fadd_w.exp_diff:0);
  fadd_w.s3_align_frac = ex1_d.csa_c >>(ex1_d.zero?(25+PEXT):fadd_w.exp_comp?fadd_w.exp_diff:0);

  if (info) {
    printf("//fadd_s1: %x %02.2x %08.8x_%08.8x (%x)-> %x %08.8x_%08.8x\n", fadd_s1.s, fadd_s1.exp, (Uint)((Ull)fadd_s1.frac>>32), (Uint)fadd_s1.frac, fadd_w.exp_diff, fadd_w.align_exp, (Uint)((Ull)fadd_w.s1_align_frac>>32), (Uint)fadd_w.s1_align_frac);
    printf("//csa_s: %x %02.2x %08.8x_%08.8x (%x)-> %x %08.8x_%08.8x\n", ex1_d.s, ex1_d.exp, (Uint)((Ull)ex1_d.csa_s>>32), (Uint)ex1_d.csa_s, fadd_w.exp_diff, fadd_w.align_exp, (Uint)((Ull)fadd_w.s2_align_frac>>32), (Uint)fadd_w.s2_align_frac);
    printf("//csa_c: %x %02.2x %08.8x_%08.8x (%x)-> %x %08.8x_%08.8x\n", ex1_d.s, ex1_d.exp, (Uint)((Ull)ex1_d.csa_c>>32), (Uint)ex1_d.csa_c, fadd_w.exp_diff, fadd_w.align_exp, (Uint)((Ull)fadd_w.s3_align_frac>>32), (Uint)fadd_w.s3_align_frac);
  }

  /*ex2_d.frac0       =  fadd_w.s1_align_frac+ (fadd_w.s2_align_frac+fadd_w.s3_align_frac);                        */
  /*ex2_d.frac1       =  fadd_w.s1_align_frac+~(fadd_w.s2_align_frac+fadd_w.s3_align_frac)+1;                      */
  /*ex2_d.frac2       = ~fadd_w.s1_align_frac+ (fadd_w.s2_align_frac+fadd_w.s3_align_frac)+1;                      */
  /*ex2_d.frac        = (fadd_s1.s==ex1_d.s) ? ex2_d.frac0 : (ex2_d.frac2 & 0x2000000) ? ex2_d.frac1 : ex2_d.frac2;*/
  /*printf("ex2d.frac0: %08.8x\n", ex2_d.frac0);*/
  /*printf("ex2d.frac1: %08.8x\n", ex2_d.frac1);*/
  /*printf("ex2d.frac2: %08.8x\n", ex2_d.frac2);*/
  /*printf("ex2d.frac:  %08.8x\n", ex2_d.frac );*/
  csa_line(&C6[0], &S6[0],  fadd_w.s1_align_frac,  fadd_w.s2_align_frac,  fadd_w.s3_align_frac);
  csa_line(&C6[1], &S6[1],  fadd_w.s1_align_frac, ~(Ull)fadd_w.s2_align_frac, ~(Ull)fadd_w.s3_align_frac);
  csa_line(&C7[1], &S7[1],  C6[1]|1LL,             S6[1],                 1LL);
  csa_line(&C6[2], &S6[2], ~(Ull)fadd_w.s1_align_frac,  fadd_w.s2_align_frac,  fadd_w.s3_align_frac);
  csa_line(&C7[2], &S7[2],  C6[2]|1LL,             S6[2],                 0LL);

  if (info) {
    printf("//C6[0]=%08.8x_%08.8x(a+c+s)\n",   (Uint)(C6[0]>>32), (Uint)C6[0]);
    printf("//S6[0]=%08.8x_%08.8x(a+c+s)\n",   (Uint)(S6[0]>>32), (Uint)S6[0]);
    printf("//C6[1]=%08.8x_%08.8x(a-c-s)\n",   (Uint)(C6[1]>>32), (Uint)C6[1]);
    printf("//S6[1]=%08.8x_%08.8x(a-c-s)\n",   (Uint)(S6[1]>>32), (Uint)S6[1]);
    printf("//C7[1]=%08.8x_%08.8x(c6+s6+2)\n", (Uint)(C7[1]>>32), (Uint)C7[1]);
    printf("//S7[1]=%08.8x_%08.8x(c6+s6+2)\n", (Uint)(S7[1]>>32), (Uint)S7[1]);
    printf("//C6[2]=%08.8x_%08.8x(c+s-a)\n",   (Uint)(C6[2]>>32), (Uint)C6[2]);
    printf("//S6[2]=%08.8x_%08.8x(c+s-a)\n",   (Uint)(S6[2]>>32), (Uint)S6[2]);
    printf("//C7[2]=%08.8x_%08.8x(c6+s6+1)\n", (Uint)(C7[2]>>32), (Uint)C7[2]);
    printf("//S7[2]=%08.8x_%08.8x(c6+s6+1)\n", (Uint)(S7[2]>>32), (Uint)S7[2]);
  }

  /**************************************************************************************************************/
  /***  2in-add  ************************************************************************************************/
  /**************************************************************************************************************/
  ex2_d.frac0       =  C6[0]+S6[0]; /* 26bit */
  ex2_d.frac1       =  C7[1]+S7[1]; /* 25bit */
  ex2_d.frac2       =  C7[2]+S7[2]; /* 26bit */

  if (info) {
    printf("//ex2_d.frac0=%08.8x_%08.8x(a+c+s)\n", (Uint)((Ull)ex2_d.frac0>>32), (Uint)ex2_d.frac0);
    printf("//ex2_d.frac1=%08.8x_%08.8x(a-c-s)\n", (Uint)((Ull)ex2_d.frac1>>32), (Uint)ex2_d.frac1);
    printf("//ex2_d.frac2=%08.8x_%08.8x(c+s-a)\n", (Uint)((Ull)ex2_d.frac2>>32), (Uint)ex2_d.frac2);
  }
  
  ex2_d.s           = (fadd_s1.s==ex1_d.s) ? fadd_s1.s   : (ex2_d.frac2 & (0x2000000LL<<PEXT)) ? fadd_s1.s : ex1_d.s; //¢£¢£¢£
  ex2_d.exp         = fadd_w.align_exp;
  ex2_d.frac        = (fadd_s1.s==ex1_d.s) ? ex2_d.frac0 : (ex2_d.frac2 & (0x2000000LL<<PEXT)) ? ex2_d.frac1 : ex2_d.frac2 & (0xffffffffffffLL>>(23-PEXT)); /* 26bit */ //¢£¢£¢£
  ex2_d.zero        = ex2_d.frac==0;
  ex2_d.inf         = (!fadd_s1.s && fadd_s1.inf && !( ex1_d.s   && ex1_d.inf)   && !ex1_d.nan)
                   || ( fadd_s1.s && fadd_s1.inf && !(!ex1_d.s   && ex1_d.inf)   && !ex1_d.nan)
                   || (!ex1_d.s   && ex1_d.inf   && !( fadd_s1.s && fadd_s1.inf) && !fadd_s1.nan)
                   || ( ex1_d.s   && ex1_d.inf   && !(!fadd_s1.s && fadd_s1.inf) && !fadd_s1.nan) ;
  ex2_d.nan         = fadd_s1.nan || ex1_d.nan;

  if (info) {
    printf("//ex2_d.frac =%08.8x_%08.8x(a+c+s)\n", (Uint)((Ull)ex2_d.frac>>32), (Uint)ex2_d.frac);
  }

#define FLOAT_PZERO 0x00000000
#define FLOAT_NZERO 0x80000000
#define FLOAT_PINF  0x7f800000
#define FLOAT_NINF  0xff800000
#define FLOAT_NAN   0xffc00000

  /**************************************************************************************************************/
  /***  normalize  **********************************************************************************************/
  /**************************************************************************************************************/
#if 1
  ex3_w.lzc          = (ex2_d.frac & 0x2000000LL<<PEXT)?62 :
                       (ex2_d.frac & 0x1000000LL<<PEXT)?63 :
                       (ex2_d.frac & 0x0800000LL<<PEXT)? 0 :
                       (ex2_d.frac & 0x0400000LL<<PEXT)? 1 :
                       (ex2_d.frac & 0x0200000LL<<PEXT)? 2 :
                       (ex2_d.frac & 0x0100000LL<<PEXT)? 3 :
                       (ex2_d.frac & 0x0080000LL<<PEXT)? 4 :
                       (ex2_d.frac & 0x0040000LL<<PEXT)? 5 :
                       (ex2_d.frac & 0x0020000LL<<PEXT)? 6 :
                       (ex2_d.frac & 0x0010000LL<<PEXT)? 7 :
                       (ex2_d.frac & 0x0008000LL<<PEXT)? 8 :
                       (ex2_d.frac & 0x0004000LL<<PEXT)? 9 :
                       (ex2_d.frac & 0x0002000LL<<PEXT)?10 :
                       (ex2_d.frac & 0x0001000LL<<PEXT)?11 :
                       (ex2_d.frac & 0x0000800LL<<PEXT)?12 :
                       (ex2_d.frac & 0x0000400LL<<PEXT)?13 :
                       (ex2_d.frac & 0x0000200LL<<PEXT)?14 :
                       (ex2_d.frac & 0x0000100LL<<PEXT)?15 :
                       (ex2_d.frac & 0x0000080LL<<PEXT)?16 :
                       (ex2_d.frac & 0x0000040LL<<PEXT)?17 :
                       (ex2_d.frac & 0x0000020LL<<PEXT)?18 :
                       (ex2_d.frac & 0x0000010LL<<PEXT)?19 :
                       (ex2_d.frac & 0x0000008LL<<PEXT)?20 :
                       (ex2_d.frac & 0x0000004LL<<PEXT)?21 :
                       (ex2_d.frac & 0x0000002LL<<PEXT)?22 :
                       (ex2_d.frac & 0x0000001LL<<PEXT)?23 :
#if (PEXT>= 1)
                       (ex2_d.frac & 0x0000001LL<<PEXT- 1)?24 :
#endif
#if (PEXT>= 2)
                       (ex2_d.frac & 0x0000001LL<<PEXT- 2)?25 :
#endif
#if (PEXT>= 3)
                       (ex2_d.frac & 0x0000001LL<<PEXT- 3)?26 :
#endif
#if (PEXT>= 4)
                       (ex2_d.frac & 0x0000001LL<<PEXT- 4)?27 :
#endif
#if (PEXT>= 5)
                       (ex2_d.frac & 0x0000001LL<<PEXT- 5)?28 :
#endif
#if (PEXT>= 6)
                       (ex2_d.frac & 0x0000001LL<<PEXT- 6)?29 :
#endif
#if (PEXT>= 7)
                       (ex2_d.frac & 0x0000001LL<<PEXT- 7)?30 :
#endif
#if (PEXT>= 8)
                       (ex2_d.frac & 0x0000001LL<<PEXT- 8)?31 :
#endif
#if (PEXT>= 9)
                       (ex2_d.frac & 0x0000001LL<<PEXT- 9)?32 :
#endif
#if (PEXT>=10)
                       (ex2_d.frac & 0x0000001LL<<PEXT-10)?33 :
#endif
#if (PEXT>=11)
                       (ex2_d.frac & 0x0000001LL<<PEXT-11)?34 :
#endif
#if (PEXT>=12)
                       (ex2_d.frac & 0x0000001LL<<PEXT-12)?35 :
#endif
#if (PEXT>=13)
                       (ex2_d.frac & 0x0000001LL<<PEXT-13)?36 :
#endif
#if (PEXT>=14)
                       (ex2_d.frac & 0x0000001LL<<PEXT-14)?37 :
#endif
#if (PEXT>=15)
                       (ex2_d.frac & 0x0000001LL<<PEXT-15)?38 :
#endif
#if (PEXT>=16)
                       (ex2_d.frac & 0x0000001LL<<PEXT-16)?39 :
#endif
#if (PEXT>=17)
                       (ex2_d.frac & 0x0000001LL<<PEXT-17)?40 :
#endif
#if (PEXT>=18)
                       (ex2_d.frac & 0x0000001LL<<PEXT-18)?41 :
#endif
#if (PEXT>=19)
                       (ex2_d.frac & 0x0000001LL<<PEXT-19)?42 :
#endif
#if (PEXT>=20)
                       (ex2_d.frac & 0x0000001LL<<PEXT-20)?43 :
#endif
#if (PEXT>=21)
                       (ex2_d.frac & 0x0000001LL<<PEXT-21)?44 :
#endif
#if (PEXT>=22)
                       (ex2_d.frac & 0x0000001LL<<PEXT-22)?45 :
#endif
                                                       24+PEXT;
  if (info) {
    printf("//ex2:%x %x %08.8x_%08.8x ", ex2_d.s, ex2_d.exp, (Uint)((Ull)ex2_d.frac>>32), (Uint)ex2_d.frac);
  }

  if (ex2_d.nan) {
    ex3_d.s    = 1;
    ex3_d.frac = 0x400000;
    ex3_d.exp  = 0xff;

  }
  else if (ex2_d.inf) {
    ex3_d.s    = ex2_d.s;
    ex3_d.frac = 0x000000;
    ex3_d.exp  = 0xff;
  }
  else if (ex3_w.lzc == 62) {
    if (info) {
      printf("lzc==%d\n", ex3_w.lzc);
    }
    if (ex2_d.exp >= 253) {
      ex3_d.s    = ex2_d.s;
      ex3_d.frac = 0x000000;
      ex3_d.exp  = 0xff;
    }
    else {
      ex3_d.s    = ex2_d.s;
      ex3_d.frac = ex2_d.frac>>(2+PEXT); //¢£¢£¢£¥¬¡¼¥ÉÂÐ±þÉ¬Í×
      ex3_d.exp  = ex2_d.exp + 2;
    }
  }
  else if (ex3_w.lzc == 63) {
    if (info) {
      printf("lzc==%d\n", ex3_w.lzc);
    }
    if (ex2_d.exp >= 254) {
      ex3_d.s    = ex2_d.s;
      ex3_d.frac = 0x000000;
      ex3_d.exp  = 0xff;
    }
    else {
      ex3_d.s    = ex2_d.s;
      ex3_d.frac = ex2_d.frac>>(1+PEXT); //¢£¢£¢£¥¬¡¼¥ÉÂÐ±þÉ¬Í×
      ex3_d.exp  = ex2_d.exp + 1;
    }
  }
  else if (ex3_w.lzc <= (23+PEXT)) { //¢£¢£¢£
    if (info) {
      printf("lzc==%d\n", ex3_w.lzc);
    }
    if (ex2_d.exp >= ex3_w.lzc + 255) {
      ex3_d.s    = ex2_d.s;
      ex3_d.frac = 0x000000;
      ex3_d.exp  = 0xff;
    }
    else if (ex2_d.exp <= ex3_w.lzc) { /* subnormal num */
      ex3_d.s    = ex2_d.s;
      ex3_d.frac = (ex2_d.frac<<ex2_d.exp)>>PEXT; //¢£¢£¢£
      ex3_d.exp  = 0x00;
    }
    else { /* normalized num */
      ex3_d.s    = ex2_d.s;
      ex3_d.frac = (ex2_d.frac<<ex3_w.lzc)>>PEXT; //¢£¢£¢£
      ex3_d.exp  = ex2_d.exp - ex3_w.lzc;
    }
#define NO_GUARD_BITS
#ifndef NO_GUARD_BITS
    int f_ulp = (ex2_d.frac<<ex3_w.lzc)>> PEXT   &1;
    int f_g   = (ex2_d.frac<<ex3_w.lzc)>>(PEXT-1)&1;
    int f_r   = (ex2_d.frac<<ex3_w.lzc)>>(PEXT-2)&1;
    int f_s   =((ex2_d.frac<<ex3_w.lzc)&(0xfffffffffffLL>>(46-PEXT))!=0;
    switch (f_ulp<<3|f_g<<2|f_r<<1|f_s) {
    case 0: case 1: case 2: case 3: case 4: /* ulp|G|R|S */
    case 8: case 9: case 10: case 11:
      break;
    case 5: case 6: case 7: /* ulp++ */
    case 12: case 13: case 14: case 15: default:
      if (info)
	printf("//ex3:%x %x %x++ -> ", ex3_d.s, ex3_d.exp, ex3_d.frac);
      ex3_d.frac++;
      if (info)
	printf("%x\n", ex3_d.frac);
      break;
    }
#endif
  }
  else { /* zero */
    if (info) {
      printf("zero\n");
    }
    ex3_d.s    = 0;
    ex3_d.frac = 0x000000;
    ex3_d.exp  = 0x00;
  }
#endif

  if (info) {
    printf("//ex3:%x %x %x\n", ex3_d.s, ex3_d.exp, ex3_d.frac);
  }

  out.raw.w  = (ex3_d.s<<31)|(ex3_d.exp<<23)|(ex3_d.frac);
  org.flo.w  = i1+i2*i3;
  Uint diff = out.raw.w>org.raw.w ? out.raw.w-org.raw.w : org.raw.w-out.raw.w;

  if (!info)
    sprintf(hardbuf32, "%8.8e:%08.8x %8.8e:%08.8x %8.8e:%08.8x ->%8.8e:%08.8x (%8.8e:%08.8x) %08.8x %s%s%s",
           in1.flo.w, in1.raw.w, in2.flo.w, in2.raw.w, in3.flo.w, in3.raw.w, out.flo.w, out.raw.w, org.flo.w, org.raw.w, diff,
           diff>=TH1 ? "H":"",
           diff>=TH2 ? "H":"",
           diff>=TH3 ? "H":""
           );
  *o = out.flo.w;

  if (testbench) {
    printf("CHECK_FPU(32'h%08.8x,32'h%08.8x,32'h%08.8x,32'h%08.8x);\n", in1.raw.w, in2.raw.w, in3.raw.w, out.raw.w);
  }

  return(diff);
}

soft64(Uint info, float i1, float i2, float i3, float *o)
{
  int op = 3;
  in1.flo.w = i1;
  in2.flo.w = i2;
  in3.flo.w = i3;

  /* op=1:fmul, 2:fadd, 3:fma3 */
  struct src {
    Uint nan  :  1;
    Uint inf  :  1;
    Uint zero :  1;
    Uint frac : 24;
    Uint exp  :  8;
    Uint s    :  1;
  } s1, s2, s3;

  struct fmul_s {
    Uint nan  :  1;
    Uint inf  :  1;
    Uint zero :  1;
    Uint frac : 24;
    Uint exp  :  8;
    Uint s    :  1;
  } fmul_s1, fmul_s2;

  struct fmul_d {
    Uint nan  :  1;
    Uint inf  :  1;
    Uint zero :  1;
    Ull  frac : 48; /* send upper 25bit to the next stage */
    Uint exp  :  9;
    Uint s    :  1;
  } fmul_d;

  struct fadd_s {
    Uint nan  :  1;
    Uint inf  :  1;
    Uint zero :  1;
    Ull  frac : 48; /* aligned to fmul_d *///¡ú¡ú¡ú25->48 s1¤Ï24bit<<23¤Ê¤Î¤Ç¼ÂºÝ¤Ï47bitÊ¬
    Uint exp  :  9;
    Uint s    :  1;
  } fadd_s1, fadd_s2;

  struct fadd_w {
    Uint exp_comp  :  1;
    Uint exp_diff  :  9;
    Uint align_exp :  9;
    Ull  s1_align_frac : 48;//¡ú¡ú¡ú25->48 s1¤Ï24bit<<23¤Ê¤Î¤Ç¼ÂºÝ¤Ï47bitÊ¬
    Ull  s2_align_frac : 48;//¡ú¡ú¡ú25->48 s2¤Ï48bitÊ¬¤¢¤ë
  } fadd_w;

  struct fadd_d {
    Uint nan  :  1;
    Uint inf  :  1;
    Uint zero :  1;
    Ull  frac : 49;//¡ú¡ú¡ú26->49
    Uint exp  :  9;
    Uint s    :  1;
  } fadd_d;

  struct ex1_d {
    Uint nan  :  1;
    Uint inf  :  1;
    Uint zero :  1;
    Ull  frac : 49;//¡ú¡ú¡ú26->49
    Uint exp  :  9;
    Uint s    :  1;
  } ex1_d;

  struct ex2_w {
    Uint lzc  :  6;//¡ú¡ú¡ú5->6
  } ex2_w;

  struct ex2_d {
    Uint frac : 23;
    Uint exp  :  8;
    Uint s    :  1;
  } ex2_d;

  s1.s    = (op==1)?0:in1.base.s;
  s1.exp  = (op==1)?0:in1.base.exp;
  s1.frac = (op==1)?0:(in1.base.exp==  0)?(0<<23)|in1.base.frac:(1<<23)|in1.base.frac;
  s1.zero = (op==1)?1:(in1.base.exp==  0) && (in1.base.frac==0);
  s1.inf  = (op==1)?0:(in1.base.exp==255) && (in1.base.frac==0);
  s1.nan  = (op==1)?0:(in1.base.exp==255) && (in1.base.frac!=0);
  s2.s    = in2.base.s;
  s2.exp  = in2.base.exp;
  s2.frac = (in2.base.exp==  0)?(0<<23)|in2.base.frac:(1<<23)|in2.base.frac;
  s2.zero = (in2.base.exp==  0) && (in2.base.frac==0);
  s2.inf  = (in2.base.exp==255) && (in2.base.frac==0);
  s2.nan  = (in2.base.exp==255) && (in2.base.frac!=0);
  s3.s    = (op==2)?0      :in3.base.s;
  s3.exp  = (op==2)?127    :in3.base.exp;
  s3.frac = (op==2)?(1<<23):(in3.base.exp==  0)?(0<<23)|in3.base.frac:(1<<23)|in3.base.frac;
  s3.zero = (op==2)?0      :(in3.base.exp==  0) && (in3.base.frac==0);
  s3.inf  = (op==2)?0      :(in3.base.exp==255) && (in3.base.frac==0);
  s3.nan  = (op==2)?0      :(in3.base.exp==255) && (in3.base.frac!=0);

  org.flo.w = in1.flo.w+in2.flo.w*in3.flo.w;
  if (info) {
    printf("//--soft64--\n");
    printf("//s1: %08.8x %f\n", in1.raw.w, in1.flo.w);
    printf("//s2: %08.8x %f\n", in2.raw.w, in2.flo.w);
    printf("//s3: %08.8x %f\n", in3.raw.w, in3.flo.w);
    printf("//d : %08.8x %f\n", org.raw.w, org.flo.w);
  }

  fmul_s1.s    = s2.s;
  fmul_s1.exp  = s2.exp;
  fmul_s1.frac = s2.frac;
  fmul_s1.zero = s2.zero;
  fmul_s1.inf  = s2.inf;
  fmul_s1.nan  = s2.nan;
  fmul_s2.s    = s3.s;
  fmul_s2.exp  = s3.exp;
  fmul_s2.frac = s3.frac;
  fmul_s2.zero = s3.zero;
  fmul_s2.inf  = s3.inf;
  fmul_s2.nan  = s3.nan;

  /* nan  * any  -> nan */
  /* inf  * zero -> nan */
  /* inf  * (~zero & ~nan) -> inf */
  /* zero * (~inf  & ~nan) -> zero */
  fmul_d.s    = fmul_s1.s ^ fmul_s2.s;
  fmul_d.exp  = ((0<<8)|fmul_s1.exp) + ((0<<8)|fmul_s2.exp) < 127 ? 0 :
                ((0<<8)|fmul_s1.exp) + ((0<<8)|fmul_s2.exp) - 127;
  fmul_d.frac = (Ull)fmul_s1.frac * (Ull)fmul_s2.frac;
  fmul_d.zero = (fmul_s1.zero && !fmul_s2.inf && !fmul_s2.nan) || (fmul_s2.zero && !fmul_s1.inf && !fmul_s1.nan);
  fmul_d.inf  = (fmul_s1.inf && !fmul_s2.zero && !fmul_s2.nan) || (fmul_s2.inf && !fmul_s1.zero && !fmul_s1.nan);
  fmul_d.nan  = fmul_s1.nan || fmul_s2.nan || (fmul_s1.inf && fmul_s2.zero) || (fmul_s2.inf && fmul_s1.zero);

  if (info) {
    printf("//fmul_s1: %x %x %x\n", fmul_s1.s, fmul_s1.exp, fmul_s1.frac);
    printf("//fmul_s2: %x %x %x\n", fmul_s2.s, fmul_s2.exp, fmul_s2.frac);
    printf("//fmul_d:  %x %x %08.8x_%08.8x\n", fmul_d.s, fmul_d.exp, (Uint)(fmul_d.frac>>32), (Uint)fmul_d.frac);
  }

  fadd_s1.s    = s1.s;
  fadd_s1.exp  = (0<s1.exp&&s1.exp<255)?(s1.exp-1):s1.exp;
  fadd_s1.frac = (0<s1.exp&&s1.exp<255)?(Ull)s1.frac<<(23+1):(Ull)s1.frac<<23;
  fadd_s1.zero = s1.zero;
  fadd_s1.inf  = s1.inf;
  fadd_s1.nan  = s1.nan;
  fadd_s2.s    = fmul_d.s;
  fadd_s2.exp  = fmul_d.exp;
  fadd_s2.frac = fmul_d.frac; //¡ú¡ú¡ú¥¬¡¼¥ÉÂÐ±þÉ¬Í× >>23Ìµ¤·¤Ê¤éÉÔÍ×
  fadd_s2.zero = fmul_d.zero;
  fadd_s2.inf  = fmul_d.inf;
  fadd_s2.nan  = fmul_d.nan;

  /* nan  + any  -> nan */
  /* inf  + -inf -> nan */
  /* inf  + (~-inf & ~nan) -> inf */
  /* -inf + (~inf  & ~nan) -> inf */
  fadd_w.exp_comp      = fadd_s1.exp>fadd_s2.exp?1:0;
  fadd_w.exp_diff      = fadd_w.exp_comp?(fadd_s1.exp-fadd_s2.exp):(fadd_s2.exp-fadd_s1.exp);
  if (fadd_w.exp_diff>48) fadd_w.exp_diff=48;//¡ú¡ú¡ú25->48
  fadd_w.align_exp     = fadd_w.exp_comp?fadd_s1.exp:fadd_s2.exp;
  fadd_w.s1_align_frac = fadd_s1.frac>>(fadd_w.exp_comp?0:fadd_w.exp_diff);
  fadd_w.s2_align_frac = fadd_s2.frac>>(fadd_w.exp_comp?fadd_w.exp_diff:0);

  if (info) {
    printf("//fadd_s1: %x %x %08.8x_%08.8x (%x)-> %x %08.8x_%08.8x\n", fadd_s1.s, fadd_s1.exp, (Uint)((Ull)fadd_s1.frac>>32), (Uint)fadd_s1.frac, fadd_w.exp_diff, fadd_w.align_exp, (Uint)((Ull)fadd_w.s1_align_frac>>32), (Uint)fadd_w.s1_align_frac);
    printf("//fadd_s2: %x %x %08.8x_%08.8x (%x)-> %x %08.8x_%08.8x\n", fadd_s2.s, fadd_s2.exp, (Uint)((Ull)fadd_s2.frac>>32), (Uint)fadd_s2.frac, fadd_w.exp_diff, fadd_w.align_exp, (Uint)((Ull)fadd_w.s2_align_frac>>32), (Uint)fadd_w.s2_align_frac);
  }

  fadd_d.s           = (fadd_s1.s==fadd_s2.s) ? fadd_s1.s : (fadd_w.s1_align_frac>fadd_w.s2_align_frac) ? fadd_s1.s : fadd_s2.s;
  fadd_d.exp         = fadd_w.align_exp;
  fadd_d.frac        = (fadd_s1.s == fadd_s2.s)                    ? (Ull)fadd_w.s1_align_frac+(Ull)fadd_w.s2_align_frac :
                       (fadd_w.s1_align_frac>fadd_w.s2_align_frac) ? (Ull)fadd_w.s1_align_frac-(Ull)fadd_w.s2_align_frac :
                                                                     (Ull)fadd_w.s2_align_frac-(Ull)fadd_w.s1_align_frac ;
  fadd_d.zero        = fadd_d.frac==0;
  fadd_d.inf         = (!fadd_s1.s && fadd_s1.inf && !(fadd_s2.s && fadd_s2.inf) && !fadd_s2.nan) || (fadd_s1.s && fadd_s1.inf && !(!fadd_s2.s && fadd_s2.inf) && !fadd_s2.nan) ||
                       (!fadd_s2.s && fadd_s2.inf && !(fadd_s1.s && fadd_s1.inf) && !fadd_s1.nan) || (fadd_s2.s && fadd_s2.inf && !(!fadd_s1.s && fadd_s1.inf) && !fadd_s1.nan) ;
  fadd_d.nan         = fadd_s1.nan || fadd_s2.nan;

  ex1_d.s            = fadd_d.s;
  ex1_d.exp          = fadd_d.exp;
  ex1_d.frac         = fadd_d.frac;
  ex1_d.zero         = fadd_d.zero;
  ex1_d.inf          = fadd_d.inf;
  ex1_d.nan          = fadd_d.nan;

#define FLOAT_PZERO 0x00000000
#define FLOAT_NZERO 0x80000000
#define FLOAT_PINF  0x7f800000
#define FLOAT_NINF  0xff800000
#define FLOAT_NAN   0xffc00000

  /* normalize */

#if 1
  ex2_w.lzc          = (ex1_d.frac & 0x1000000000000LL)?62 :
                       (ex1_d.frac & 0x0800000000000LL)?63 :
                       (ex1_d.frac & 0x0400000000000LL)? 0 :
                       (ex1_d.frac & 0x0200000000000LL)? 1 :
                       (ex1_d.frac & 0x0100000000000LL)? 2 :
                       (ex1_d.frac & 0x0080000000000LL)? 3 :
                       (ex1_d.frac & 0x0040000000000LL)? 4 :
                       (ex1_d.frac & 0x0020000000000LL)? 5 :
                       (ex1_d.frac & 0x0010000000000LL)? 6 :
                       (ex1_d.frac & 0x0008000000000LL)? 7 :
                       (ex1_d.frac & 0x0004000000000LL)? 8 :
                       (ex1_d.frac & 0x0002000000000LL)? 9 :
                       (ex1_d.frac & 0x0001000000000LL)?10 :
                       (ex1_d.frac & 0x0000800000000LL)?11 :
                       (ex1_d.frac & 0x0000400000000LL)?12 :
                       (ex1_d.frac & 0x0000200000000LL)?13 :
                       (ex1_d.frac & 0x0000100000000LL)?14 :
                       (ex1_d.frac & 0x0000080000000LL)?15 :
                       (ex1_d.frac & 0x0000040000000LL)?16 :
                       (ex1_d.frac & 0x0000020000000LL)?17 :
                       (ex1_d.frac & 0x0000010000000LL)?18 :
                       (ex1_d.frac & 0x0000008000000LL)?19 :
                       (ex1_d.frac & 0x0000004000000LL)?20 :
                       (ex1_d.frac & 0x0000002000000LL)?21 :
                       (ex1_d.frac & 0x0000001000000LL)?22 :
                       (ex1_d.frac & 0x0000000800000LL)?23 :
                       (ex1_d.frac & 0x0000000400000LL)?24 :
                       (ex1_d.frac & 0x0000000200000LL)?25 :
                       (ex1_d.frac & 0x0000000100000LL)?26 :
                       (ex1_d.frac & 0x0000000080000LL)?27 :
                       (ex1_d.frac & 0x0000000040000LL)?28 :
                       (ex1_d.frac & 0x0000000020000LL)?29 :
                       (ex1_d.frac & 0x0000000010000LL)?30 :
                       (ex1_d.frac & 0x0000000008000LL)?31 :
                       (ex1_d.frac & 0x0000000004000LL)?32 :
                       (ex1_d.frac & 0x0000000002000LL)?33 :
                       (ex1_d.frac & 0x0000000001000LL)?34 :
                       (ex1_d.frac & 0x0000000000800LL)?35 :
                       (ex1_d.frac & 0x0000000000400LL)?36 :
                       (ex1_d.frac & 0x0000000000200LL)?37 :
                       (ex1_d.frac & 0x0000000000100LL)?38 :
                       (ex1_d.frac & 0x0000000000080LL)?39 :
                       (ex1_d.frac & 0x0000000000040LL)?40 :
                       (ex1_d.frac & 0x0000000000020LL)?41 :
                       (ex1_d.frac & 0x0000000000010LL)?42 :
                       (ex1_d.frac & 0x0000000000008LL)?43 :
                       (ex1_d.frac & 0x0000000000004LL)?44 :
                       (ex1_d.frac & 0x0000000000002LL)?45 :
                       (ex1_d.frac & 0x0000000000001LL)?46 :
                                                        47 ;
  if (info) {
    printf("//ex1:%x %x %08.8x_%08.8x ", ex1_d.s, ex1_d.exp, (Uint)((Ull)ex1_d.frac>>32), (Uint)ex1_d.frac);
  }

  if (ex1_d.nan) {
    ex2_d.s    = 1;
    ex2_d.frac = 0x400000;
    ex2_d.exp  = 0xff;

  }
  else if (ex1_d.inf) {
    ex2_d.s    = ex1_d.s;
    ex2_d.frac = 0x000000;
    ex2_d.exp  = 0xff;
  }
  else if (ex2_w.lzc == 62) {//¡ú¡ú¡ú
    if (info) {
      printf("lzc==%d\n", ex2_w.lzc);
    }
    if (ex1_d.exp >= 253) {
      ex2_d.s    = ex1_d.s;
      ex2_d.frac = 0x000000;
      ex2_d.exp  = 0xff;
    }
    else {
      ex2_d.s    = ex1_d.s;
      ex2_d.frac = (ex1_d.frac>>2)>>23; //¡ú¡ú¡ú¥¬¡¼¥ÉÂÐ±þÉ¬Í×
      ex2_d.exp  = ex1_d.exp + 2;
    }
  }
  else if (ex2_w.lzc == 63) {//¡ú¡ú¡ú
    if (info) {
      printf("lzc==%d\n", ex2_w.lzc);
    }
    if (ex1_d.exp >= 254) {
      ex2_d.s    = ex1_d.s;
      ex2_d.frac = 0x000000;
      ex2_d.exp  = 0xff;
    }
    else {
      ex2_d.s    = ex1_d.s;
      ex2_d.frac = (ex1_d.frac>>1)>>23; //¡ú¡ú¡ú¥¬¡¼¥ÉÂÐ±þÉ¬Í×
      ex2_d.exp  = ex1_d.exp + 1;
    }
  }
  else if (ex2_w.lzc <= 46) {//¡ú¡ú¡ú
    if (info) {
      printf("lzc==%d\n", ex2_w.lzc);
    }
    if (ex1_d.exp >= ex2_w.lzc + 255) {
      ex2_d.s    = ex1_d.s;
      ex2_d.frac = 0x000000;
      ex2_d.exp  = 0xff;
    }
    else if (ex1_d.exp <= ex2_w.lzc) { /* subnormal num */
      ex2_d.s    = ex1_d.s;
      ex2_d.frac = (ex1_d.frac<<ex1_d.exp)>>23; //¡ú¡ú¡ú¥¬¡¼¥ÉÂÐ±þÉ¬Í×
      ex2_d.exp  = 0x00;
    }
    else { /* normalized num */
      ex2_d.s    = ex1_d.s;
      ex2_d.frac = (ex1_d.frac<<ex2_w.lzc)>>23; //¡ú¡ú¡ú¥¬¡¼¥ÉÂÐ±þÉ¬Í×
      ex2_d.exp  = ex1_d.exp - ex2_w.lzc;
    }
#define NO_GUARD_BITS
#ifndef NO_GUARD_BITS
    int f_ulp = (ex1_d.frac<<ex2_w.lzc)>>23&1;
    int f_g   = (ex1_d.frac<<ex2_w.lzc)>>22&1;
    int f_r   = (ex1_d.frac<<ex2_w.lzc)>>21&1;
    int f_s   =((ex1_d.frac<<ex2_w.lzc)&0x1fffff)!=0;
    switch (f_ulp<<3|f_g<<2|f_r<<1|f_s) {
    case 0: case 1: case 2: case 3: case 4: /* ulp|G|R|S */
    case 8: case 9: case 10: case 11:
      break;
    case 5: case 6: case 7: /* ulp++ */
    case 12: case 13: case 14: case 15: default:
      if (info)
	printf("//ex2:%x %x %x++ -> ", ex2_d.s, ex2_d.exp, ex2_d.frac);
      ex2_d.frac++;
      if (info)
	printf("%x\n", ex2_d.frac);
      break;
    }
#endif
  }
  else { /* zero */
    if (info) {
      printf("zero\n");
    }
    ex2_d.s    = 0;
    ex2_d.frac = 0x000000;
    ex2_d.exp  = 0x00;
  }
#endif

  if (info) {
    printf("//ex2:%x %x %x\n", ex2_d.s, ex2_d.exp, ex2_d.frac);
  }

  out.raw.w  = (ex2_d.s<<31)|(ex2_d.exp<<23)|(ex2_d.frac);
  org.flo.w  = i1+i2*i3;
  Uint diff = out.raw.w>org.raw.w ? out.raw.w-org.raw.w : org.raw.w-out.raw.w;

  if (!info)
    sprintf(softbuf64, "%8.8e:%08.8x %8.8e:%08.8x %8.8e:%08.8x ->%8.8e:%08.8x (%8.8e:%08.8x) %08.8x %s%s%s",
           in1.flo.w, in1.raw.w, in2.flo.w, in2.raw.w, in3.flo.w, in3.raw.w, out.flo.w, out.raw.w, org.flo.w, org.raw.w, diff,
           diff>=TH1 ? "S":"",
           diff>=TH2 ? "S":"",
           diff>=TH3 ? "S":""
           );
  *o = out.flo.w;
  return(diff);
}

/* radix-4 modified booth (unsigned A[23:0]*B[23:0] -> C[47:1]+S[46:0] */
/*                             0 0 B[23:................................0] 0 */
/*                                                                  B[ 1:-1] */
/*                                                               B[ 3: 1]    */
/*                                                            B[ 5: 3]       */
/*                                                         B[ 7: 5]          */
/*                                                      B[ 9: 7]             */
/*                                                   B[11: 9]                */
/*                                                B[13:11]                   */
/*                                             B[15:13]                      */
/*                                          B[17:15]                         */
/*                                       B[19:17]                            */
/*                                    B[21:19]                               */
/*                                 B[23:21]                                  */
/*                              B[25:23]                                     */
/*         switch (B[2j+1:2j-1])                                             */
/*         case 0: pp[j][47:2j] =   0;  ... single=0;double=0;neg=0          */
/*         case 1: pp[j][47:2j] =   A;  ... single=1;double=0;neg=0          */
/*         case 2: pp[j][47:2j] =   A;  ... single=1;double=0;neg=0          */
/*         case 3: pp[j][47:2j] =  2A;  ... single=0;double=1;neg=0          */
/*         case 4: pp[j][47:2j] = -2A;  ... single=0;double=1;neg=1          */
/*         case 5: pp[j][47:2j] =  -A;  ... single=1;double=0;neg=1          */
/*         case 6: pp[j][47:2j] =  -A;  ... single=1;double=0;neg=1          */
/*         case 7: pp[j][47:2j] =   0;  ... single=0;double=0;neg=1          */
/*            j= 0¤Î¾ì¹ç, pp[ 0][47: 0] Éä¹æ³ÈÄ¥                             */
/*            j=12¤Î¾ì¹ç, pp[12][47:24](Éä¹æ³ÈÄ¥ÉÔÍ×)                        */
/*                                   single = B[2j] ^ B[2j-1];               */
/*                                   double = ~(single | ~(B[2j+1] ^ B[2j]));*/
/*                                   s(neg) = B[2j+1];                       */
/*                                   pp[j+1][2j]= s(neg);                    */
/*                                   j= 0¤Î¾ì¹ç, pp[ 1][ 0]¤Ës               */
/*                                   j=11¤Î¾ì¹ç, pp[12][22]¤Ës               */

/*  --stage-1 (13in)---------------------------------------------------------------------------------------------------------------------------------------*/
/*  pp[ 0]                                                             ~s  s  s 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0 */
/*  pp[ 1]                                                           1 ~s 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2     s */
/*  pp[ 2]                                                     1 ~s 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4     s       */
/*                                                             |  | HA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA HA FA HA HA *//* HA,24FA,HA,FA,2HA */
/*  S1[0]                                                     30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0 */
/*  C1[0]                                                        29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1    */
/*                                                                                                                                                         */
/*  pp[ 3]                                               1 ~s 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6     s             */
/*  pp[ 4]                                         1 ~s 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8     s     |             */
/*  pp[ 5]                                   1 ~s 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10     s           |             */
/*                                           |  | HA HA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA HA FA HA HA     |             *//* 2HA,23FA,HA,FA,2HA */
/*  S1[1]                                   36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4             */
/*  C1[1]                                      35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7                      */
/*                                                                                                                                                         */
/*  pp[ 6]                             1 ~s 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12     s                               */
/*  pp[ 7]                       1 ~s 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14     s     |                               */
/*  pp[ 8]                 1 ~s 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16     s           |                               */
/*                         |  | HA HA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA HA FA HA HA     |                               *//* 2HA,23FA,HA,FA,2HA */
/*  S1[2]                 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10                               */
/*  C1[2]                    41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13                                        */
/*                                                                                                                                                         */
/*  pp[ 9]           1 ~s 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18     s                                                 */
/*  pp[10]     1 ~s 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20     s     |                                                 */
/*  pp[11] ~s 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22     s           |                                                 */
/*          | HA HA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA HA FA HA HA     |                                                 *//* 2HA,23FA,HA,FA,2HA */
/*  S1[3]  47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16                                                 */
/*  C1[3]  47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19                                                          */
/*                                                                                                                                                         */
/*  pp[12] 47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24     s                                                                   */
/*  -------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*  --stage-2 (9in)----------------------------------------------------------------------------------------------------------------------------------------*/
/*  S1[0]                                                     30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0 */
/*  C1[0]                                                        29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  | */
/*  S1[1]                                   36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4*          | */
/*                                           |  |  |  |  |  | HA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA HA HA HA  | *//* HA,26FA,3HA */
/*  S2[0]                                   36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0 */
/*  C2[0]                                                  31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2       */
/*                                                                                                                                                         */
/*  C1[1]                                      35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7                      */
/*  S1[2]                 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10* |  |  |                      */
/*  C1[2]                  | 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13           |  |  |                      */
/*                         | HA HA HA HA HA HA FA FA FA FA FA FA fA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA HA HA HA  |  |  |                      *//* 6HA,22FA,3HA */
/*  S2[1]                 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7                      */
/*  C2[1]                 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11                                  */
/*                                                                                                                                                         */
/*  S1[3]  47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16*                                                */
/*  C1[3]  47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19  |  |  |                                                 */
/*  pp[12] 47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24     s*          |  |  |                                                 */
/*         FA FA FA FA FA fA FA FA FA FA FA FA FA FA FA FA FA FA fA FA FA FA FA FA HA FA HA HA HA  |  |  |                                                 *//* 22FA,HA,FA,3HA */
/*  S2[2]  47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16                                                 */
/*  C2[2]  47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20                                                             */
/*  -------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*  --stage-3 (6in)----------------------------------------------------------------------------------------------------------------------------------------*/
/*  S2[0]                                   36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0 */
/*  C2[0]                                                  31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  |  | */
/*  S2[1]                 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7                 |  | */
/*                         |  |  |  |  |  | HA HA HA HA HA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA HA HA HA HA HA  |  | *//* 5HA,25FA,5HA */
/*  S3[0]                 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0 */
/*  C3[0]                                37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3          */
/*                                                                                                                                                         */
/*  C2[1]                 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11                                  */
/*  S2[2]  47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16  |  |  |  |  |                                  */
/*  C2[2]  47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20              |  |  |  |  |                                  */
/*         HA HA HA HA HA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA HA HA HA HA  |  |  |  |  |                                  *//* 5HA,23FA,4HA */
/*  S3[1]  47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11                                  */
/*  C3[1]  47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17                                                    */
/*  -------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*  --stage-4 (4in)----------------------------------------------------------------------------------------------------------------------------------------*/
/*  S3[0]                 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0 */
/*  C3[0]                                37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  |  |  | */
/*  S3[1]  47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11                          |  |  | */
/*          |  |  |  |  | HA HA HA HA HA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA HA HA HA HA HA HA HA HA  |  |  | *//* 5HA,27FA,8HA */
/*  S4     47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0 */
/*  C4                 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4             */
/*                                                                                                                                                         */
/*  C3[1]  47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17                                                    */
/*  -------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*  --stage-5 (3in)----------------------------------------------------------------------------------------------------------------------------------------*/
/*  S4     47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0 */
/*  C4                 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  |  |  |  | */
/*  C3[1]  47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17                                         |  |  |  | */
/*         HA HA HA HA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA HA HA HA HA HA HA HA HA HA HA HA HA HA  |  |  |  | *//* 4HA,27FA,13HA */
/*  S5     47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0 */
/*  C5     47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5                */
/*  -------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*  --stage-6 (2in+fadd) ¥·¥Õ¥ÈÄ´À°¸å----------------------------------------------------------------------------------------------------------------------*/
/*  S5     47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0 */
/*  C5     47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  |  |  |  |  | */
/*  AD     47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24                                                           |  |  |  |  | */
/*         FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA FA HA HA HA HA HA HA HA HA HA HA HA HA HA HA HA HA HA HA HA  |  |  |  |  | *//* 24FA,19HA */
/*  S6     47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0 */
/*  C6     47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6                   */
/*  -------------------------------------------------------------------------------------------------------------------------------------------------------*/

hard64(Uint info, float i1, float i2, float i3, float *o)
{
  int op = 3;
  in1.flo.w = i1;
  in2.flo.w = i2;
  in3.flo.w = i3;
  /* op=1:fmul (0.0 + s2 *  s3)  */
  /* op=2:fadd (s1  + s2 * 1.0) */
  /* op=3:fma3 (s1  + s2 *  s3)  */

  /* op=1:fmul, 2:fadd, 3:fma3 */
  struct src {
    Uint nan  :  1;
    Uint inf  :  1;
    Uint zero :  1;
    Uint frac : 24;
    Uint exp  :  8;
    Uint s    :  1;
  } s1, s2, s3; /* s1 + s2 * s3 */

  Uint tp;
  Uint ps[13]; /* partial_sign */
  Ull  pp[13]; /* partial_product */
  Ull  S1[4];  /* stage-1 */
  Ull  C1[4];  /* stage-1 */
  Ull  S2[3];  /* stage-2 */
  Ull  C2[3];  /* stage-2 */
  Ull  S3[2];  /* stage-3 */
  Ull  C3[2];  /* stage-3 */
  Ull  S4;     /* stage-4 */
  Ull  C4;     /* stage-4 */
  Ull  S5;     /* stage-5 */
  Ull  C5;     /* stage-5 */
  Ull  S6[3];  /* stage-6 */
  Ull  C6[3];  /* stage-6 */
  Ull  S7[3];  /* stage-6 */
  Ull  C7[3];  /* stage-6 */

  struct ex1_d {
    Uint nan  :  1;
    Uint inf  :  1;
    Uint zero :  1;
    Ull  csa_s: 48;//¡ú¡ú¡ú25->48
    Ull  csa_c: 48;//¡ú¡ú¡ú25->48
    Uint exp  :  9;
    Uint s    :  1;
  } ex1_d; /* csa */

  struct fadd_s {
    Uint nan  :  1;
    Uint inf  :  1;
    Uint zero :  1;
    Ull  frac : 48; /* aligned to ex1_d *///¡ú¡ú¡ú25->48 s1¤Ï24bit<<23¤Ê¤Î¤Ç¼ÂºÝ¤Ï47bitÊ¬
    Uint exp  :  9;
    Uint s    :  1;
  } fadd_s1;

  struct fadd_w {
    Uint exp_comp  :  1;
    Uint exp_diff  :  9;
    Uint align_exp :  9;
    Ull  s1_align_frac : 48;//¡ú¡ú¡ú25->48 s1¤Ï24bit<<23¤Ê¤Î¤Ç¼ÂºÝ¤Ï47bitÊ¬
    Ull  s2_align_frac : 48;//¡ú¡ú¡ú25->48 csa_s¤Ï48bitÊ¬¤¢¤ë
    Ull  s3_align_frac : 48;//¡ú¡ú¡ú25->48 csa_c¤Ï48bitÊ¬¤¢¤ë
  } fadd_w;

  struct ex2_d {
    Uint nan  :  1;
    Uint inf  :  1;
    Uint zero :  1;
    Ull  frac0: 49; /* 26bit *///¡ú¡ú¡ú26->49 (a+b)¤Ï49bit
    Ull  frac1: 48; /* 25bit *///¡ú¡ú¡ú25->48
    Ull  frac2: 49; /* 26bit *///¡ú¡ú¡ú26->49 (a-b)¤«(b-a)È½ÃÇ¤Î¤¿¤á1bitÂ¿¤¤
    Ull  frac : 49; /* 26bit *///¡ú¡ú¡ú26->49
    Uint exp  :  9;
    Uint s    :  1;
  } ex2_d;

  struct ex3_w {
    Uint lzc  :  6;//¡ú¡ú¡ú5->6
  } ex3_w;

  struct ex3_d {
    Uint frac : 23;
    Uint exp  :  8;
    Uint s    :  1;
  } ex3_d;

  s1.s    = (op==1)?0:in1.base.s;
  s1.exp  = (op==1)?0:in1.base.exp;
  s1.frac = (op==1)?0:(in1.base.exp==  0)?(0<<23)|in1.base.frac:(1<<23)|in1.base.frac;
  s1.zero = (op==1)?1:(in1.base.exp==  0) && (in1.base.frac==0);
  s1.inf  = (op==1)?0:(in1.base.exp==255) && (in1.base.frac==0);
  s1.nan  = (op==1)?0:(in1.base.exp==255) && (in1.base.frac!=0);
  s2.s    = in2.base.s;
  s2.exp  = in2.base.exp;
  s2.frac = (in2.base.exp==  0)?(0<<23)|in2.base.frac:(1<<23)|in2.base.frac;
  s2.zero = (in2.base.exp==  0) && (in2.base.frac==0);
  s2.inf  = (in2.base.exp==255) && (in2.base.frac==0);
  s2.nan  = (in2.base.exp==255) && (in2.base.frac!=0);
  s3.s    = (op==2)?0      :in3.base.s;
  s3.exp  = (op==2)?127    :in3.base.exp;
  s3.frac = (op==2)?(1<<23):(in3.base.exp==  0)?(0<<23)|in3.base.frac:(1<<23)|in3.base.frac;
  s3.zero = (op==2)?0      :(in3.base.exp==  0) && (in3.base.frac==0);
  s3.inf  = (op==2)?0      :(in3.base.exp==255) && (in3.base.frac==0);
  s3.nan  = (op==2)?0      :(in3.base.exp==255) && (in3.base.frac!=0);

  org.flo.w = in1.flo.w+in2.flo.w*in3.flo.w;
  if (info) {
    printf("//--hard64--\n");
    printf("//s1: %08.8x %f\n", in1.raw.w, in1.flo.w);
    printf("//s2: %08.8x %f\n", in2.raw.w, in2.flo.w);
    printf("//s3: %08.8x %f\n", in3.raw.w, in3.flo.w);
    printf("//d : %08.8x %f\n", org.raw.w, org.flo.w);
  }

  /* nan  * any  -> nan */
  /* inf  * zero -> nan */
  /* inf  * (~zero & ~nan) -> inf */
  /* zero * (~inf  & ~nan) -> zero */
  ex1_d.s    = s2.s ^ s3.s;
  ex1_d.exp  = ((0<<8)|s2.exp) + ((0<<8)|s3.exp) < 127 ? 0 :
               ((0<<8)|s2.exp) + ((0<<8)|s3.exp) - 127;

  /**************************************************************************************************************/
  /***  partial product  ****************************************************************************************/
  /**************************************************************************************************************/
  /*ex1_d.frac = (Ull)s2.frac * (Ull)s3.frac;*/
  partial_product(&tp, &ps[ 0], s2.frac, (s3.frac<< 1)&7,  0); pp[ 0] =  (Ull)tp;                        //if (info) {printf("pp[ 0]=%04.4x_%08.8x ps[ 0]=%d\n", (Uint)(pp[ 0]>>32), (Uint)pp[ 0], ps[ 0]);} /*1,0,-1*/
  partial_product(&tp, &ps[ 1], s2.frac, (s3.frac>> 1)&7,  1); pp[ 1] = ((Ull)tp<< 2)| (Ull)ps[ 0];      //if (info) {printf("pp[ 1]=%04.4x_%08.8x ps[ 1]=%d\n", (Uint)(pp[ 1]>>32), (Uint)pp[ 1], ps[ 1]);} /*3,2, 1*/
  partial_product(&tp, &ps[ 2], s2.frac, (s3.frac>> 3)&7,  2); pp[ 2] = ((Ull)tp<< 4)|((Ull)ps[ 1]<< 2); //if (info) {printf("pp[ 2]=%04.4x_%08.8x ps[ 2]=%d\n", (Uint)(pp[ 2]>>32), (Uint)pp[ 2], ps[ 2]);} /*5,4, 3*/
  partial_product(&tp, &ps[ 3], s2.frac, (s3.frac>> 5)&7,  3); pp[ 3] = ((Ull)tp<< 6)|((Ull)ps[ 2]<< 4); //if (info) {printf("pp[ 3]=%04.4x_%08.8x ps[ 3]=%d\n", (Uint)(pp[ 3]>>32), (Uint)pp[ 3], ps[ 3]);} /*7,6, 5*/
  partial_product(&tp, &ps[ 4], s2.frac, (s3.frac>> 7)&7,  4); pp[ 4] = ((Ull)tp<< 8)|((Ull)ps[ 3]<< 6); //if (info) {printf("pp[ 4]=%04.4x_%08.8x ps[ 4]=%d\n", (Uint)(pp[ 4]>>32), (Uint)pp[ 4], ps[ 4]);} /*9,8, 7*/
  partial_product(&tp, &ps[ 5], s2.frac, (s3.frac>> 9)&7,  5); pp[ 5] = ((Ull)tp<<10)|((Ull)ps[ 4]<< 8); //if (info) {printf("pp[ 5]=%04.4x_%08.8x ps[ 5]=%d\n", (Uint)(pp[ 5]>>32), (Uint)pp[ 5], ps[ 5]);} /*11,10,9*/
  partial_product(&tp, &ps[ 6], s2.frac, (s3.frac>>11)&7,  6); pp[ 6] = ((Ull)tp<<12)|((Ull)ps[ 5]<<10); //if (info) {printf("pp[ 6]=%04.4x_%08.8x ps[ 6]=%d\n", (Uint)(pp[ 6]>>32), (Uint)pp[ 6], ps[ 6]);} /*13,12,11*/
  partial_product(&tp, &ps[ 7], s2.frac, (s3.frac>>13)&7,  7); pp[ 7] = ((Ull)tp<<14)|((Ull)ps[ 6]<<12); //if (info) {printf("pp[ 7]=%04.4x_%08.8x ps[ 7]=%d\n", (Uint)(pp[ 7]>>32), (Uint)pp[ 7], ps[ 7]);} /*15,14,13*/
  partial_product(&tp, &ps[ 8], s2.frac, (s3.frac>>15)&7,  8); pp[ 8] = ((Ull)tp<<16)|((Ull)ps[ 7]<<14); //if (info) {printf("pp[ 8]=%04.4x_%08.8x ps[ 8]=%d\n", (Uint)(pp[ 8]>>32), (Uint)pp[ 8], ps[ 8]);} /*17,16,15*/
  partial_product(&tp, &ps[ 9], s2.frac, (s3.frac>>17)&7,  9); pp[ 9] = ((Ull)tp<<18)|((Ull)ps[ 8]<<16); //if (info) {printf("pp[ 9]=%04.4x_%08.8x ps[ 9]=%d\n", (Uint)(pp[ 9]>>32), (Uint)pp[ 9], ps[ 9]);} /*19,18,17*/
  partial_product(&tp, &ps[10], s2.frac, (s3.frac>>19)&7, 10); pp[10] = ((Ull)tp<<20)|((Ull)ps[ 9]<<18); //if (info) {printf("pp[10]=%04.4x_%08.8x ps[10]=%d\n", (Uint)(pp[10]>>32), (Uint)pp[10], ps[10]);} /*21,20,19*/
  partial_product(&tp, &ps[11], s2.frac, (s3.frac>>21)&7, 11); pp[11] = ((Ull)tp<<22)|((Ull)ps[10]<<20); //if (info) {printf("pp[11]=%04.4x_%08.8x ps[11]=%d\n", (Uint)(pp[11]>>32), (Uint)pp[11], ps[11]);} /**23,22,21*/
  partial_product(&tp, &ps[12], s2.frac, (s3.frac>>23)&7, 12); pp[12] = ((Ull)tp<<24)|((Ull)ps[11]<<22); //if (info) {printf("pp[12]=%04.4x_%08.8x ps[12]=%d\n", (Uint)(pp[12]>>32), (Uint)pp[12], ps[12]);} /*25,24,*23*/

  Ull x1 = (pp[0]+pp[1]+pp[2]+pp[3]+pp[4]+pp[5]+pp[6]+pp[7]+pp[8]+pp[9]+pp[10]+pp[11]+pp[12]);
  if (info) { printf("//x1(sum of pp)=%08.8x_%08.8x ->>23 %08.8x\n", (Uint)(x1>>32), (Uint)x1, (Uint)(x1>>23));}
  Ull x2 = (Ull)s2.frac * (Ull)s3.frac;
  if (info) { printf("//x2(s2 * s3)  =%08.8x_%08.8x ->>23 %08.8x\n", (Uint)(x2>>32), (Uint)x2, (Uint)(x2>>23));}

  /**************************************************************************************************************/
  /***  csa tree  ***********************************************************************************************/
  /**************************************************************************************************************/
  csa_line(&C1[0], &S1[0], pp[ 0], pp[ 1], pp[ 2]);
  csa_line(&C1[1], &S1[1], pp[ 3], pp[ 4], pp[ 5]);
  csa_line(&C1[2], &S1[2], pp[ 6], pp[ 7], pp[ 8]);
  csa_line(&C1[3], &S1[3], pp[ 9], pp[10], pp[11]);

  csa_line(&C2[0], &S2[0], S1[ 0], C1[ 0], S1[ 1]);
  csa_line(&C2[1], &S2[1], C1[ 1], S1[ 2], C1[ 2]);
  csa_line(&C2[2], &S2[2], S1[ 3], C1[ 3], pp[12]);

  csa_line(&C3[0], &S3[0], S2[ 0], C2[ 0], S2[ 1]);
  csa_line(&C3[1], &S3[1], C2[ 1], S2[ 2], C2[ 2]);

  csa_line(&C4,    &S4,    S3[ 0], C3[ 0], S3[ 1]);
  csa_line(&C5,    &S5,    S4,     C4,     C3[ 1]);

  ex1_d.csa_s = S5; // sum   ¡ú¡ú¡ú¥¬¡¼¥ÉÂÐ±þÉ¬Í× >>32Ìµ¤·¤Ê¤éÉÔÍ×
  ex1_d.csa_c = C5; // carry ¡ú¡ú¡ú¥¬¡¼¥ÉÂÐ±þÉ¬Í× >>32Ìµ¤·¤Ê¤éÉÔÍ×

  ex1_d.zero = (s2.zero && !s3.inf && !s3.nan) || (s3.zero && !s2.inf && !s2.nan);
  ex1_d.inf  = (s2.inf && !s3.zero && !s3.nan) || (s3.inf && !s2.zero && !s2.nan);
  ex1_d.nan  = s2.nan || s3.nan || (s2.inf && s3.zero) || (s3.inf && s2.zero);

  if (info) {
    printf("//S5           =%08.8x_%08.8x\n", (Uint)(S5>>32), (Uint)S5);
    printf("//C5           =%08.8x_%08.8x\n", (Uint)(C5>>32), (Uint)C5);
    printf("//++(48bit)    =%08.8x_%08.8x\n", (Uint)((C5+S5)>>32), (Uint)(C5+S5));
    printf("//csa_s        =%08.8x_%08.8x\n", (Uint)((Ull)ex1_d.csa_s>>32), (Uint)ex1_d.csa_s);
    printf("//csa_c        =%08.8x_%08.8x\n", (Uint)((Ull)ex1_d.csa_c>>32), (Uint)ex1_d.csa_c);
    printf("//ex1_d: %x %02.2x +=%08.8x_%08.8x\n", ex1_d.s, ex1_d.exp, (Uint)((Ull)(ex1_d.csa_c+ex1_d.csa_s)>>32), (Uint)(ex1_d.csa_c+ex1_d.csa_s));
  }

  /**************************************************************************************************************/
  /***  3in-csa  ************************************************************************************************/
  /**************************************************************************************************************/
  fadd_s1.s    = s1.s;
  fadd_s1.exp  = (0<s1.exp&&s1.exp<255)?(s1.exp-1):s1.exp;
  fadd_s1.frac = (0<s1.exp&&s1.exp<255)?(Ull)s1.frac<<(23+1):(Ull)s1.frac<<23;//¡ú¡ú¡ú0->23
  fadd_s1.zero = s1.zero;
  fadd_s1.inf  = s1.inf;
  fadd_s1.nan  = s1.nan;

  /* nan  + any  -> nan */
  /* inf  + -inf -> nan */
  /* inf  + (~-inf & ~nan) -> inf */
  /* -inf + (~inf  & ~nan) -> inf */
  fadd_w.exp_comp      = fadd_s1.exp>ex1_d.exp?1:0;
  fadd_w.exp_diff      = fadd_w.exp_comp?(fadd_s1.exp-ex1_d.exp):(ex1_d.exp-fadd_s1.exp);
  if (fadd_w.exp_diff>48) fadd_w.exp_diff=48;//¡ú¡ú¡ú25->48
  fadd_w.align_exp     = fadd_w.exp_comp?fadd_s1.exp:ex1_d.exp;
  fadd_w.s1_align_frac = fadd_s1.frac>>(fadd_w.exp_comp?0:fadd_w.exp_diff);
  fadd_w.s2_align_frac = ex1_d.csa_s >>(ex1_d.zero?48:fadd_w.exp_comp?fadd_w.exp_diff:0);
  fadd_w.s3_align_frac = ex1_d.csa_c >>(ex1_d.zero?48:fadd_w.exp_comp?fadd_w.exp_diff:0);

  if (info) {
    printf("//fadd_s1: %x %02.2x %08.8x_%08.8x (%x)-> %x %08.8x_%08.8x\n", fadd_s1.s, fadd_s1.exp, (Uint)((Ull)fadd_s1.frac>>32), (Uint)fadd_s1.frac, fadd_w.exp_diff, fadd_w.align_exp, (Uint)((Ull)fadd_w.s1_align_frac>>32), (Uint)fadd_w.s1_align_frac);
    printf("//csa_s: %x %02.2x %08.8x_%08.8x (%x)-> %x %08.8x_%08.8x\n", ex1_d.s, ex1_d.exp, (Uint)((Ull)ex1_d.csa_s>>32), (Uint)ex1_d.csa_s, fadd_w.exp_diff, fadd_w.align_exp, (Uint)((Ull)fadd_w.s2_align_frac>>32), (Uint)fadd_w.s2_align_frac);
    printf("//csa_c: %x %02.2x %08.8x_%08.8x (%x)-> %x %08.8x_%08.8x\n", ex1_d.s, ex1_d.exp, (Uint)((Ull)ex1_d.csa_c>>32), (Uint)ex1_d.csa_c, fadd_w.exp_diff, fadd_w.align_exp, (Uint)((Ull)fadd_w.s3_align_frac>>32), (Uint)fadd_w.s3_align_frac);
  }

  /*ex2_d.frac0       =  fadd_w.s1_align_frac+ (fadd_w.s2_align_frac+fadd_w.s3_align_frac);                        */
  /*ex2_d.frac1       =  fadd_w.s1_align_frac+~(fadd_w.s2_align_frac+fadd_w.s3_align_frac)+1;                      */
  /*ex2_d.frac2       = ~fadd_w.s1_align_frac+ (fadd_w.s2_align_frac+fadd_w.s3_align_frac)+1;                      */
  /*ex2_d.frac        = (fadd_s1.s==ex1_d.s) ? ex2_d.frac0 : (ex2_d.frac2 & 0x2000000) ? ex2_d.frac1 : ex2_d.frac2;*/
  /*printf("ex2d.frac0: %08.8x\n", ex2_d.frac0);*/
  /*printf("ex2d.frac1: %08.8x\n", ex2_d.frac1);*/
  /*printf("ex2d.frac2: %08.8x\n", ex2_d.frac2);*/
  /*printf("ex2d.frac:  %08.8x\n", ex2_d.frac );*/
  csa_line(&C6[0], &S6[0],  fadd_w.s1_align_frac,  fadd_w.s2_align_frac,  fadd_w.s3_align_frac);
  csa_line(&C6[1], &S6[1],  fadd_w.s1_align_frac, ~(Ull)fadd_w.s2_align_frac, ~(Ull)fadd_w.s3_align_frac);
  csa_line(&C7[1], &S7[1],  C6[1]|1LL,             S6[1],                 1LL);
  csa_line(&C6[2], &S6[2], ~(Ull)fadd_w.s1_align_frac,  fadd_w.s2_align_frac,  fadd_w.s3_align_frac);
  csa_line(&C7[2], &S7[2],  C6[2]|1LL,             S6[2],                 0LL);

  if (info) {
    printf("//C6[0]=%08.8x_%08.8x(a+c+s)\n",   (Uint)(C6[0]>>32), (Uint)C6[0]);
    printf("//S6[0]=%08.8x_%08.8x(a+c+s)\n",   (Uint)(S6[0]>>32), (Uint)S6[0]);
    printf("//C6[1]=%08.8x_%08.8x(a-c-s)\n",   (Uint)(C6[1]>>32), (Uint)C6[1]);
    printf("//S6[1]=%08.8x_%08.8x(a-c-s)\n",   (Uint)(S6[1]>>32), (Uint)S6[1]);
    printf("//C7[1]=%08.8x_%08.8x(c6+s6+2)\n", (Uint)(C7[1]>>32), (Uint)C7[1]);
    printf("//S7[1]=%08.8x_%08.8x(c6+s6+2)\n", (Uint)(S7[1]>>32), (Uint)S7[1]);
    printf("//C6[2]=%08.8x_%08.8x(c+s-a)\n",   (Uint)(C6[2]>>32), (Uint)C6[2]);
    printf("//S6[2]=%08.8x_%08.8x(c+s-a)\n",   (Uint)(S6[2]>>32), (Uint)S6[2]);
    printf("//C7[2]=%08.8x_%08.8x(c6+s6+1)\n", (Uint)(C7[2]>>32), (Uint)C7[2]);
    printf("//S7[2]=%08.8x_%08.8x(c6+s6+1)\n", (Uint)(S7[2]>>32), (Uint)S7[2]);
  }

  /**************************************************************************************************************/
  /***  2in-add  ************************************************************************************************/
  /**************************************************************************************************************/
  ex2_d.frac0       =  C6[0]+S6[0]; /* 49bit */
  ex2_d.frac1       =  C7[1]+S7[1]; /* 48bit */
  ex2_d.frac2       =  C7[2]+S7[2]; /* 49bit */

  if (info) {
    printf("//ex2_d.frac0=%08.8x_%08.8x(a+c+s)\n", (Uint)((Ull)ex2_d.frac0>>32), (Uint)ex2_d.frac0);
    printf("//ex2_d.frac1=%08.8x_%08.8x(a-c-s)\n", (Uint)((Ull)ex2_d.frac1>>32), (Uint)ex2_d.frac1);
    printf("//ex2_d.frac2=%08.8x_%08.8x(c+s-a)\n", (Uint)((Ull)ex2_d.frac2>>32), (Uint)ex2_d.frac2);
  }

  ex2_d.s           = (fadd_s1.s==ex1_d.s) ? fadd_s1.s   : (ex2_d.frac2 & 0x1000000000000LL) ? fadd_s1.s : ex1_d.s;
  ex2_d.exp         = fadd_w.align_exp;
  ex2_d.frac        = (fadd_s1.s==ex1_d.s) ? ex2_d.frac0 : (ex2_d.frac2 & 0x1000000000000LL) ? ex2_d.frac1 : ex2_d.frac2 & 0xffffffffffffLL; /* 49bit */
  ex2_d.zero        = ex2_d.frac==0;
  ex2_d.inf         = (!fadd_s1.s && fadd_s1.inf && !( ex1_d.s   && ex1_d.inf)   && !ex1_d.nan)
                   || ( fadd_s1.s && fadd_s1.inf && !(!ex1_d.s   && ex1_d.inf)   && !ex1_d.nan)
                   || (!ex1_d.s   && ex1_d.inf   && !( fadd_s1.s && fadd_s1.inf) && !fadd_s1.nan)
                   || ( ex1_d.s   && ex1_d.inf   && !(!fadd_s1.s && fadd_s1.inf) && !fadd_s1.nan) ;
  ex2_d.nan         = fadd_s1.nan || ex1_d.nan;

  if (info) {
    printf("//ex2_d.frac =%08.8x_%08.8x(a+c+s)\n", (Uint)((Ull)ex2_d.frac>>32), (Uint)ex2_d.frac);
  }

#define FLOAT_PZERO 0x00000000
#define FLOAT_NZERO 0x80000000
#define FLOAT_PINF  0x7f800000
#define FLOAT_NINF  0xff800000
#define FLOAT_NAN   0xffc00000

  /**************************************************************************************************************/
  /***  normalize  **********************************************************************************************/
  /**************************************************************************************************************/
#if 1
  ex3_w.lzc          = (ex2_d.frac & 0x1000000000000LL)?62 :
                       (ex2_d.frac & 0x0800000000000LL)?63 :
                       (ex2_d.frac & 0x0400000000000LL)? 0 :
                       (ex2_d.frac & 0x0200000000000LL)? 1 :
                       (ex2_d.frac & 0x0100000000000LL)? 2 :
                       (ex2_d.frac & 0x0080000000000LL)? 3 :
                       (ex2_d.frac & 0x0040000000000LL)? 4 :
                       (ex2_d.frac & 0x0020000000000LL)? 5 :
                       (ex2_d.frac & 0x0010000000000LL)? 6 :
                       (ex2_d.frac & 0x0008000000000LL)? 7 :
                       (ex2_d.frac & 0x0004000000000LL)? 8 :
                       (ex2_d.frac & 0x0002000000000LL)? 9 :
                       (ex2_d.frac & 0x0001000000000LL)?10 :
                       (ex2_d.frac & 0x0000800000000LL)?11 :
                       (ex2_d.frac & 0x0000400000000LL)?12 :
                       (ex2_d.frac & 0x0000200000000LL)?13 :
                       (ex2_d.frac & 0x0000100000000LL)?14 :
                       (ex2_d.frac & 0x0000080000000LL)?15 :
                       (ex2_d.frac & 0x0000040000000LL)?16 :
                       (ex2_d.frac & 0x0000020000000LL)?17 :
                       (ex2_d.frac & 0x0000010000000LL)?18 :
                       (ex2_d.frac & 0x0000008000000LL)?19 :
                       (ex2_d.frac & 0x0000004000000LL)?20 :
                       (ex2_d.frac & 0x0000002000000LL)?21 :
                       (ex2_d.frac & 0x0000001000000LL)?22 :
                       (ex2_d.frac & 0x0000000800000LL)?23 :
                       (ex2_d.frac & 0x0000000400000LL)?24 :
                       (ex2_d.frac & 0x0000000200000LL)?25 :
                       (ex2_d.frac & 0x0000000100000LL)?26 :
                       (ex2_d.frac & 0x0000000080000LL)?27 :
                       (ex2_d.frac & 0x0000000040000LL)?28 :
                       (ex2_d.frac & 0x0000000020000LL)?29 :
                       (ex2_d.frac & 0x0000000010000LL)?30 :
                       (ex2_d.frac & 0x0000000008000LL)?31 :
                       (ex2_d.frac & 0x0000000004000LL)?32 :
                       (ex2_d.frac & 0x0000000002000LL)?33 :
                       (ex2_d.frac & 0x0000000001000LL)?34 :
                       (ex2_d.frac & 0x0000000000800LL)?35 :
                       (ex2_d.frac & 0x0000000000400LL)?36 :
                       (ex2_d.frac & 0x0000000000200LL)?37 :
                       (ex2_d.frac & 0x0000000000100LL)?38 :
                       (ex2_d.frac & 0x0000000000080LL)?39 :
                       (ex2_d.frac & 0x0000000000040LL)?40 :
                       (ex2_d.frac & 0x0000000000020LL)?41 :
                       (ex2_d.frac & 0x0000000000010LL)?42 :
                       (ex2_d.frac & 0x0000000000008LL)?43 :
                       (ex2_d.frac & 0x0000000000004LL)?44 :
                       (ex2_d.frac & 0x0000000000002LL)?45 :
                       (ex2_d.frac & 0x0000000000001LL)?46 :
                                                        47 ;
  if (info) {
    printf("//ex2:%x %x %08.8x_%08.8x ", ex2_d.s, ex2_d.exp, (Uint)((Ull)ex2_d.frac>>32), (Uint)ex2_d.frac);
  }

  if (ex2_d.nan) {
    ex3_d.s    = 1;
    ex3_d.frac = 0x400000;
    ex3_d.exp  = 0xff;

  }
  else if (ex2_d.inf) {
    ex3_d.s    = ex2_d.s;
    ex3_d.frac = 0x000000;
    ex3_d.exp  = 0xff;
  }
  else if (ex3_w.lzc == 62) {//¡ú¡ú¡ú
    if (info) {
      printf("lzc==%d\n", ex3_w.lzc);
    }
    if (ex2_d.exp >= 253) {
      ex3_d.s    = ex2_d.s;
      ex3_d.frac = 0x000000;
      ex3_d.exp  = 0xff;
    }
    else {
      ex3_d.s    = ex2_d.s;
      ex3_d.frac = (ex2_d.frac>>2)>>23; //¡ú¡ú¡ú¥¬¡¼¥ÉÂÐ±þÉ¬Í×
      ex3_d.exp  = ex2_d.exp + 2;
    }
  }
  else if (ex3_w.lzc == 63) {//¡ú¡ú¡ú
    if (info) {
      printf("lzc==%d\n", ex3_w.lzc);
    }
    if (ex2_d.exp >= 254) {
      ex3_d.s    = ex2_d.s;
      ex3_d.frac = 0x000000;
      ex3_d.exp  = 0xff;
    }
    else {
      ex3_d.s    = ex2_d.s;
      ex3_d.frac = (ex2_d.frac>>1)>>23; //¡ú¡ú¡ú¥¬¡¼¥ÉÂÐ±þÉ¬Í×
      ex3_d.exp  = ex2_d.exp + 1;
    }
  }
  else if (ex3_w.lzc <= 46) {//¡ú¡ú¡ú
    if (info) {
      printf("lzc==%d\n", ex3_w.lzc);
    }
    if (ex2_d.exp >= ex3_w.lzc + 255) {
      ex3_d.s    = ex2_d.s;
      ex3_d.frac = 0x000000;
      ex3_d.exp  = 0xff;
    }
    else if (ex2_d.exp <= ex3_w.lzc) { /* subnormal num */
      ex3_d.s    = ex2_d.s;
      ex3_d.frac = (ex2_d.frac<<ex2_d.exp)>>23; //¡ú¡ú¡ú¥¬¡¼¥ÉÂÐ±þÉ¬Í×
      ex3_d.exp  = 0x00;
    }
    else { /* normalized num */
      ex3_d.s    = ex2_d.s;
      ex3_d.frac = (ex2_d.frac<<ex3_w.lzc)>>23; //¡ú¡ú¡ú¥¬¡¼¥ÉÂÐ±þÉ¬Í×
      ex3_d.exp  = ex2_d.exp - ex3_w.lzc;
    }
#define NO_GUARD_BITS
#ifndef NO_GUARD_BITS
    int f_ulp = (ex2_d.frac<<ex3_w.lzc)>>23&1;
    int f_g   = (ex2_d.frac<<ex3_w.lzc)>>22&1;
    int f_r   = (ex2_d.frac<<ex3_w.lzc)>>21&1;
    int f_s   =((ex2_d.frac<<ex3_w.lzc)&0x1fffff)!=0;
    switch (f_ulp<<3|f_g<<2|f_r<<1|f_s) {
    case 0: case 1: case 2: case 3: case 4: /* ulp|G|R|S */
    case 8: case 9: case 10: case 11:
      break;
    case 5: case 6: case 7: /* ulp++ */
    case 12: case 13: case 14: case 15: default:
      if (info)
	printf("//ex3:%x %x %x++ -> ", ex3_d.s, ex3_d.exp, ex3_d.frac);
      ex3_d.frac++;
      if (info)
	printf("%x\n", ex3_d.frac);
      break;
    }
#endif
  }
  else { /* zero */
    if (info) {
      printf("zero\n");
    }
    ex3_d.s    = 0;
    ex3_d.frac = 0x000000;
    ex3_d.exp  = 0x00;
  }
#endif

  if (info) {
    printf("//ex3:%x %x %x\n", ex3_d.s, ex3_d.exp, ex3_d.frac);
  }

  out.raw.w  = (ex3_d.s<<31)|(ex3_d.exp<<23)|(ex3_d.frac);
  org.flo.w  = i1+i2*i3;
  Uint diff = out.raw.w>org.raw.w ? out.raw.w-org.raw.w : org.raw.w-out.raw.w;

  if (!info)
    sprintf(hardbuf64, "%8.8e:%08.8x %8.8e:%08.8x %8.8e:%08.8x ->%8.8e:%08.8x (%8.8e:%08.8x) %08.8x %s%s%s",
           in1.flo.w, in1.raw.w, in2.flo.w, in2.raw.w, in3.flo.w, in3.raw.w, out.flo.w, out.raw.w, org.flo.w, org.raw.w, diff,
           diff>=TH1 ? "H":"",
           diff>=TH2 ? "H":"",
           diff>=TH3 ? "H":""
           );
  *o = out.flo.w;
  return(diff);
}
