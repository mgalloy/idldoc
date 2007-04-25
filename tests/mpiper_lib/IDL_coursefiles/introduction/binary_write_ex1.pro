;+
; An example of writing a variable to a binary file.
;
; @examples
; <pre>
; IDL> binary_write_ex1
; </pre>
; @uses BINARY_READ_EX1
; @requires IDL 5.2
; @author Mark Piper, RSI, 2004
;-
pro binary_write_ex1
	compile_opt idl2

	;; Get some data.
	mantle = binary_read_ex1()

	openw, lun, 'antimantle.dat', /get_lun
	writeu, lun, -mantle
	free_lun, lun
end