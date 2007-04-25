;+
; Another example of reading the file <b>ascii.txt</b> in the
; <b>examples/data</b> subdirectory, using IDL free formatting rules.
; We know this file consists of 4 lines of header, followed by a blank
; line, followed by a 7-column by 15-row chunk of weather data.<p>
;
; The data from the file are returned through the formal parameters
; <i>header</i> and <i>data</i>, so the actual parameters to
; ASCII_READ_EX2 must be variables because of IDL's parameter-passing
; mechanism.<p>
;
; Note that the data are read as a float array. This is fast, but
; type isn't preserved. The elevation, temperature, etc. data are
; cast as integer after the read.<p>
;
; @param header {out}{type=string} A string array containing the
;  file's header.
; @param data {out}{type=structure} The data values from the file.
; @examples
; <pre>
; IDL> ascii_read_ex2, h, d
; IDL> help, d.lon
; </pre>
; @requires IDL 5.2
; @author Mark Piper, RSI, 2004
;-
pro ascii_read_ex2, header, data
	compile_opt idl2

	;; Locate the file on the file system.
	file = filepath('ascii.txt', subdir=['examples','data'])

	;; The number of header lines and data records in the file.
	n_header = 4
	n_fields = 7
	n_recs = 15

	;; Define a data format for the file.
	header = strarr(n_header)
	blank_line = ''
	array = fltarr(n_fields, n_recs)

	;; Open the file for reading.
	openr, lun, file, /get_lun

	;; Read the contents of the file.
	readf, lun, header
	readf, lun, blank_line
	readf, lun, array

	;; Close the file.
	free_lun, lun

	;; Extract the columns of the variable 'array', put them
	;; into their own variables and group them in a structure.
	data = { $
		lon  : reform(array[0,*]), $
		lat  : reform(array[1,*]), $
		elev : fix(reform(array[2,*])), $
		temp : fix(reform(array[3,*])), $
		dewp : fix(reform(array[4,*])), $
		wspd : fix(reform(array[5,*])), $
		wdir : fix(reform(array[6,*])) $
		}
end