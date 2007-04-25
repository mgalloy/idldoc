;+
; An example of reading from a binary file into an IDL variable.
;
; @returns a 248 x 248 byte array representing an intensity-mapped image.
; @examples
; <pre>
; IDL> image = binary_read_ex1()
; IDL> iimage, image
; </pre>
; @requires IDL 5.2
; @author Mark Piper, RSI, 2004
;-
function binary_read_ex1

	file = filepath('convec.dat', subdir=['examples','data'])
	mantle = bytarr(248,248)
	openu, lun, file, /get_lun
	readu, lun, mantle
	free_lun, lun

	return, mantle
end