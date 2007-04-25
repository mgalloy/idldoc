;+
; Yet another example of reading the file <b>ascii.txt</b> in the
; <b>examples/data</b> subdirectory, using IDL free formatting rules.
; We know this file consists of 4 lines of header, followed by a blank
; line, followed by a 7-column by 15-row chunk of weather data.<p>
;
; Note that the data are read as an array of structures. This is fast
; and type is preserved. However, working with arrays of structures
; can sometimes be difficult because they don't follow all the array
; subscripting rules.<p>
;
; @keyword header {out}{optional}{type=string} A string array containing
;  the file's header.
; @returns A 15-element array of structures containing the data from
;  the file.
; @examples
; <pre>
; IDL> data = ascii_read_ex3(header=h)
; IDL> print, h
; IDL> print, data.wspd
; </pre>
; @requires IDL 5.2
; @author Mark Piper, RSI, 2004
;-
function ascii_read_ex3, header=header
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
	record = {lon:0.0, lat:0.0, elev:0S, temp:0S, dewp:0S, wspd:0U, wdir:0}
	data = replicate(record, n_recs)

	;; Open the file for reading.
	openr, lun, file, /get_lun

	;; Read the contents of the file.
	readf, lun, header
	readf, lun, blank_line
	readf, lun, data

	;; Close the file.
	free_lun, lun

	;; Return the array of structures.
	return, data
end