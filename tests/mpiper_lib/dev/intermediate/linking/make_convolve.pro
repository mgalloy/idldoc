;+
; An example of using MAKE_DLL to build the source file <b>convolve.c</b>
; into a Win 32-bit dynamic-link library.
;
; @author Mark Piper, RSI, 2004
;-
pro make_convolve
	compile_opt idl2

	infile  = 'convolve'
	outfile = 'convolve'
	export_name = 'convolve_w'
	indir = 'C:\Documents and Settings\mpiper\My Documents\incoming'
	outdir = indir

	make_dll, infile, outfile, export_name, $
		input_directory=indir, $
		output_directory=outdir
end