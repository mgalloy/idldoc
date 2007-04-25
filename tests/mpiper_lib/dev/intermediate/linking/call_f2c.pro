;+
; An example of using CALL_EXTERNAL to access the C (or Fortran)
; routine <i>f2c</i>.<p>
; Problem: this routine uses the standard calling convention, while
; IDL's CALL_EXTERNAL function requires the ANSI C argc-argv calling
; convention.<p>
; Solution: call <i>f2c</i> through the wrapper function <i>f2c_w</i>,
; which uses the argc-argv calling convention.<p>
;
; @keyword build {optional}{type=boolean} Set this keyword to call
; <code>make</code> to build the shared object. Only implemented on
; UNIX-based systems with GCC, for now.
; @keyword clean {optional}{type=boolean} Set this keyword to call
; <code>make clean</code>.
; @keyword fortran {optional}{type=boolean} Set this keyword to call
; the Fortran version of <i>f2c</i>.
; @examples
; <pre>
; IDL> call_f2c, /build
; gcc -c  -shared -fPIC -I/usr/local/rsi/idl_6.2/external -o f2c_c.o f2c.c
; ld -shared -o f2c_c.so f2c_c.o
; Tue Aug 23 16:18:46 MDT 2005
; F               DOUBLE    =        98.600000
; C               DOUBLE    =        37.000000
; IDL> 
; IDL> call_f2c, /clean
; rm f2c_c.o f2c_c.so
; </pre>
; @requires IDL 6.0
; @uses The makefile <b>Makefile</b>, along with either the C source
; file <b>f2c.c</b> or the Fortran source file <b>f2c.f</b>.
; 
; @author Mark Piper, RSI, 2002
; @history
; 2005-08, MP: Added BUILD, CLEAN and FORTRAN keywords.<br>
;-
pro call_f2c, $
    build=build, $
    clean=clean, $
    fortran=fortran
    
    compile_opt idl2

    ;; What operating system family is being used?
    os_family = strlowcase(!version.os_family)

    ;; Is this a C or a Fortran example?
    lang = keyword_set(fortran) ? 'f' : 'c'

    ;; Spawn a call to make, if available.
    if keyword_set(build) && (os_family eq 'unix') then $
        spawn, 'make f2c_' + lang
    if keyword_set(clean) && (os_family eq 'unix') then begin
        spawn, 'make clean'
        return
    endif

    ;; Give the location of & the entry point into the shared object.
    case os_family of
        'windows' :	ext = '*.dll'
        'unix' : 	ext = '*.so'
        else:
    endcase
    so_path = dialog_pickfile(filter=ext, /must_exist, $
        title='Select shared object file...')
    if file_test(so_path) eq 0 then begin
        message, 'Shared object file not found.', /info
        return
    endif     
    entry = keyword_set(fortran) ? 'f2c_w__' : 'f2c_w' ;; note underscores

    ;; Convert a Fahrenheit value to Celcius. Be aware of input and
    ;; output types! Display the result.
    if keyword_set(fortran) then begin
        f = 98.6
        c = 0.0
        a = call_external(so_path, entry, f, c)
        help, f, c, a
    endif else begin
        f = 98.6D
        c = call_external(so_path, entry, f, /d_value)
        help, f, c
    endelse 
end

