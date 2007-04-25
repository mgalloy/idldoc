;+
; An example of reading the file <b>ascii.txt</b> in the
; <b>examples/data</b> subdirectory, using IDL free formatting rules.
; We know this file consists of 4 lines of header, followed by a blank
; line, followed by a 7-column by 15-row chunk of weather data.<p>
;
; The data from the file are returned through the formal parameters
; <i>header</i>, <i>lon</i>, <i>lat</i>, etc., so the actual parameters
; to ASCII_READ_EX1 must be variables because of IDL's parameter-passing
; mechanism.<p>
;
; @param header {out}{type=string} A string array containing the
;  file's header.
; @param lon {out}{type=float} The longitude values from the file.
; @param lat {out}{type=float} The latitude values from the file.
; @param elev {out}{type=integer} The elevation values from the file.
; @param temp {out}{type=integer} The temperature values from the file.
; @param dewp {out}{type=integer} The dewpoint values from the file.
; @param wspd {out}{type=integer} The wind speed values from the file.
; @param wdir {out}{type=integer} The wind direction values from the file.
; @examples
; <pre>
; IDL> ascii_read_ex1, h, lon, lat, elev, temp, dewp, wspd, wdir
; IDL> print, elev
; </pre>
; @requires IDL 5.2
; @author Mark Piper, RSI, 2004
;-
pro ascii_read_ex1, header, lon, lat, elev, temp, dewp, wspd, wdir
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
	f1 = (f0 = 0.0)
	i4 = (i3 = (i2 = (i1 = (i0 = 0S))))
	lon = (lat = fltarr(n_recs))
	wdir = ( wspd = ( dewp = (temp = (elev = intarr(n_recs)))))

	;; Open the file for reading.
	openr, 1, file

	;; Read the contents of the file.
	readf, 1, header
	readf, 1, blank_line
	for i = 0, n_recs-1 do begin
		readf, 1, f0, f1, i0, i1, i2, i3, i4
		lon[i]  = f0
		lat[i]  = f1
		elev[i] = i0
		temp[i] = i1
		dewp[i] = i2
		wspd[i] = i3
		wdir[i] = i4
	endfor

	;; Close the file.
	close, 1
end