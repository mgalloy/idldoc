;+
; An example of reading the file <b>cities.txt</b> in the
; <b>introduction</b> subdirectory, using IDL explicit formatting rules.
; This file contains a list of 52 cities & their locations.
; <p>
;
; The data from the file are returned through the formal parameters
; <i>lon</i>, <i>lat</i> and <i>city</i>, so the actual parameters
; to ASCII_READ_EX4 must be variables because of IDL's parameter-passing
; mechanism.
; <p>
;
; @param lon {out}{type=float} The longitude values from the file.
; @param lat {out}{type=float} The latitude values from the file.
; @param city {out}{type=string} The array of city names.
; @examples
; <pre>
; IDL> ascii_read_ex4, lon, lat, cities
; IDL> print, cities
; </pre>
; @uses GET_INTRO_DIR
; @requires IDL 5.2
; @author Mark Piper, RSI, 2004
;-
pro ascii_read_ex4, lon, lat, city
	compile_opt idl2

	;; Locate the file on the file system.
	file = filepath('cities.txt', root_dir=get_intro_dir())

	;; The number of header lines and data records in the file.
	n_fields = 3
	n_recs   = file_lines(file)

	;; Define a data format for the file.
	s0 = ''
	f1 = (f0 = 0.0)
	city = strarr(n_recs)
	lon  = fltarr(n_recs)
	lat  = fltarr(n_recs)

	;; Open the file for reading.
	openr, lun, file, /get_lun

	;; Read the contents of the file.
	for i = 0, n_recs-1 do begin
		readf, lun, s0, f0, f1, format='(a15,f7.2,2x,f7.2)'
		city[i] = s0
		lon[i]  = f0
		lat[i]  = f1
	endfor

	;; Close the file.
	free_lun, lun
end