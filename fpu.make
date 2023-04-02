
## FPU Simulator                       ##
##   Copyright (C) 2014 by NAIST UNIV. ##
##         Primary writer: Y.Nakashima ##
##                nakashim@is.naist.jp ##

PROJTOP	      = ../../
OPTION        = -DDEBUG -DCYCLECNT
PROGRAM1      = fpu
CC            = gcc
CFLAGS        = -m32 -I/usr/X11R6/include -O3 $(OPTION)
AS            = as
ASFLAGS       = 
LD            = ld
LDFLAGS       = -m32
LIBS          = -lX11 -lm -lc
LIBFLAGS      = -L/usr/X11R6/lib
OBJS1	      =	fpu.o
SRCS1	      =	fpu.c

all:		$(PROGRAM1) $(PROGRAM2)

clean:;		rm -f $(OBJS1) $(OBJS2) core *.s *~

$(PROGRAM1):     $(OBJS1)
		$(CC) $(CFLAGS) -o $(PROGRAM1) $(OBJS1) $(LDFLAGS) $(LIBFLAGS) $(LIBS)

###
