c======================================================================
c
c	moment_w
c
c	2002-02-06
c	Mark Piper
c
c	This is a wrapper function for the subroutine moment. It acts 
c	as an intermediary for passing parameters between IDL and 
c	Fortran.
c
c======================================================================

	integer*4 function moment_w(argc, argv)

	integer*4 argc, argv(*)

	call moment(%val(argv(1)), %val(argv(2)), %val(argv(3)),
     +  	%val(argv(4)), %val(argv(5)), %val(argv(6)), 
     +		%val(argv(7)), %val(argv(8)))
						
	return
	end
