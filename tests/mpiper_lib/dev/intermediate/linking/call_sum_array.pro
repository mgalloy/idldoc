;+
; An example of using CALL_EXTERNAL to access the C routine
; <i>sum_array</i> compiled into the shared object <b>example.so</b>
; (*NIX) or <b>example.dll</b> (Windows).
;
; @keyword build {optional}{type=boolean} Set this keyword to call
; <code>make</code> to build the shared object. Only implemented on
; UNIX-based systems with GCC, for now.
; @keyword clean {optional}{type=boolean} Set this keyword to call
; <code>make clean</code>.
; @examples
; <pre>
; IDL> call_sum_array, /build
; gcc -c  -shared -fPIC -I/usr/local/rsi/idl_6.2/external example.c
; ld -shared -o example.so example.o
; Tue Aug 23 14:19:51 MDT 2005
; Total from "sum_array":         0.229994
; Total from TOTAL function:      0.229994
; </pre>
; @requires IDL 6.0
; @uses The C source file <b>example.c</b> and the makefile
; <b>Makefile</b>.
; @author Mark Piper, RSI, 2002
; @history
; 2005-08, MP: Added BUILD and CLEAN keywords.<br>
;-
pro call_sum_array, $
    build=build, $
    clean=clean

    compile_opt idl2

    ;; What operating system family is being used?
    os_family = strlowcase(!version.os_family)

    ;; Spawn a call to make, if available.
    if keyword_set(build) && (os_family eq 'unix') then $
        spawn, 'make example'
    if keyword_set(clean) && (os_family eq 'unix') then begin
        spawn, 'make clean
        return
    endif
    ;; Read the ENSO time series data from the examples/data subdir.
    file = filepath('elnino.dat', subdir=['examples','data'])
    enso = read_binary(file, data_type=4, endian='little')
    n_enso = n_elements(enso)

    ;; Give the location of & the entry point into the shared object.
    case os_family of
        'windows' :	ext = '*.dll'
        'unix' : 	ext = '*.so'
        else:
    endcase
    so_path = dialog_pickfile(filter=ext, /must_exist, $
        title='Select shared object file...')
    if file_test(so_path) eq 0 then begin
        message, 'Shared object file not found.', /informational
        return
    endif 
    entry = 'sum_array'

    ;; Call into the shared object, passing the data vector & the
    ;; number of elements in the vector. Watch the type! Ensure the
    ;; return value is of type float.
    sum = call_external(so_path, entry, enso, n_enso, /f_value)

    ;; Compare the result with the IDL TOTAL function.
    print, 'Total from "sum_array":    ', sum
    print, 'Total from TOTAL function: ', total(enso)
end
