
infile = 'example'
outfile = 'sum_array'
indir = 'C:\Documents and Settings\mpiper\My Documents\tmp'
outdir = 'C:\Documents and Settings\mpiper\My Documents\tmp'

make_dll, infile, outfile, $
	dll_path=dll_path, $
	input_directory=indir, $
	output_directory=outdir, $
	/verbose, $
	/nocleanup

end