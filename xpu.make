
## Compare fpu/spu/npu                 ##
##   Copyright (C) 2020 by NAIST UNIV. ##
##         Primary writer: Y.Nakashima ##
##                nakashim@is.naist.jp ##

PROJTOP	      = ../../
OPTION        = -DDEBUG -DCYCLECNT
PROGRAM       = xpu
CC            = gcc
CFLAGS        = -m32 -I/usr/X11R6/include -O3 $(OPTION)
AS            = as
ASFLAGS       = 
LD            = ld
LDFLAGS       = -m32
LIBS          = -lX11 -lm -lc
LIBFLAGS      = -L/usr/X11R6/lib
OBJS	      =	xpu.o
SRCS	      =	xpu.c

all:		$(PROGRAM)

clean:;		rm -f $(OBJS) core *.s *~

$(PROGRAM):	$(OBJS)
		$(CC) $(CFLAGS) -o $(PROGRAM) $(OBJS) $(LDFLAGS) $(LIBFLAGS) $(LIBS)

###
