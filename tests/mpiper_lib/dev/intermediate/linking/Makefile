#
# Makefile for CALL_EXTERNAL examples in the class "Intermediate
# Programming with IDL."
#
# Call with
#	$ make example
#	$ make clean
#
# Mark Piper, RSI, 2005
#

# Where is IDL installed?
IDL_DIR = /usr/local/rsi/idl_6.2

# Default macros.
CC		= gcc
C_FLAGS		= -c -shared -fPIC -I$(IDL_DIR)/external
F		= g77
F_FLAGS		= -c -shared -fpic -I$(IDL_DIR)/external
LD 		= ld
LD_FLAGS	= -shared

# Make everything.
all : example f2c_c f2c_f moment_c moment_f

# Make example.
example : example.so
	@date
example.so : example.o
	$(LD) $(LD_FLAGS) -o example.so example.o
example.o :
	$(CC) $(C_FLAGS) example.c

# Make the C version of f2c.
f2c_c : f2c_c.so
	@date
f2c_c.so : f2c_c.o
	$(LD) $(LD_FLAGS) -o f2c_c.so f2c_c.o
f2c_c.o :
	$(CC) $(C_FLAGS) -o f2c_c.o f2c.c

# Make the Fortran version of f2c.
f2c_f : f2c_f.so
	@date
f2c_f.so : f2c_f.o
	$(LD) $(LD_FLAGS) -o f2c_f.so f2c_f.o
f2c_f.o :
	$(F) $(F_FLAGS) -o f2c_f.o f2c.f

# Make the C version of moment.
moment_c : moment_c.so
	@date
moment_c.so : moment_c.o moment_w_c.o
	$(LD) $(LD_FLAGS) -o moment_c.so moment_c.o moment_w_c.o
moment_c.o :
	$(CC) $(C_FLAGS) -o moment_c.o moment.c
	$(CC) $(C_FLAGS) -o moment_w_c.o moment_w.c

# Make the Fortran version of moment.
moment_f : moment_f.so
	@date
moment_f.so : moment.o moment_w.o
	$(LD) $(LD_FLAGS) -o moment_f.so moment.o moment_w.o
moment.o :
	$(F) $(F_FLAGS) moment.f moment_w.f 

# Cleanup.
.PHONY : clean
clean :
	-rm *.o *.so

