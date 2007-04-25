c======================================================================
c
c	f2c.f
c
c	10-11-99
c	Mark Piper
c
c	This file contains two F77 subprograms, 'f2c' and 'f2c_w.'
c
c	The subroutine 'f2c' converts a Farenheit temperature value 
c	to its value in Celcius. The function 'f2c_w' is a wrapper 
c	function that converts input from IDL (in ANSI C argc-argv 
c	format) into terms the f77 compiler understands, then calls 
c	'f2c.'  
c
c	Use the following compile and link statements to create the 
c	shared object library 'f2c.so' on a Sun Sparc running Solaris
c	2.7:
c
c	% f77 -G -pic -c f2c.f
c	% ld -G -o f2c.so f2c.o
c
c	From IDL, call the shared object using CALL_EXTERNAL:
c
c	IDL> f = 98.6
c	IDL> c = 0.0
c	IDL> null = call_external('f2c.so', 'f2c_w_', f, c)
c	IDL> print, f, c
c
c======================================================================

c---- f2c_w -----------------------------------------------------------
c	On most platforms IDL uses the argc-argv calling mechanism to 
c	pass data from IDL to an external routine via CALL_EXTERNAL.  
c	The (void *) argv[] pointers can be interpreted on most plat-
c	forms as FORTRAN integer*4 variables containing addresses.

      integer*4 function f2c_w(argc, argv)

      integer*4 argc, argv(*)

c	Given a four-byte integer value representing an address, a 
c	reference to the data can be passed to a called routine using
c	the F77 extension %val() intrinsic function.

      call f2c(%val(argv(1)), %val(argv(2)))
						
      return
      end

c---- f2c -------------------------------------------------------------
c	This subroutine is called by f2c_w and has no IDL-specific code.

      subroutine f2c(f, c)

      real*4 f, c

      c = (f - 32.0) * (5.0/9.0)

      return
      end
