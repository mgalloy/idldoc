;+
; An example of using CALL_EXTERNAL to access the C (or Fortran)
; routine <i>moment</i>. The results of the call are compared with the
; output of the IDL MOMENT function.<p>
;
; @param arr {in}{optional}{type=float} An array of numbers.
; @keyword build {optional}{type=boolean} Set this keyword to call
; <code>make</code> to build the shared object. Only implemented on
; UNIX-based systems with GCC, for now.
; @keyword clean {optional}{type=boolean} Set this keyword to call
; <code>make clean</code>.
; @keyword fortran {optional}{type=boolean} Set this keyword to call
; the Fortran version of <i>moment</i>.
; @examples
; <pre>
; IDL> call_moment, /build
; gcc -c -shared -fPIC -I/usr/local/rsi/idl_6.2/external moment.c moment_w.c
; ld -shared -o moment.so moment.o moment_w.o
; Thu Aug 25 13:15:00 MDT 2005
;                            mean         variance   skewness      kurtosis
; "Moment" routine   :       127.247      2999.45   -0.0287142    -0.640767
; IDL MOMENT function:       127.793      2950.69   -0.0228639    -0.637691
; IDL> call_moment, /clean
; rm moment.o moment_w.o moment.so
; </pre>
; @requires IDL 6.0
; @uses The makefile <b>Makefile</b>, along with either the C source
; files <b>moment.c</b> and <b>moment_w.c</b> or the Fortran source
; files <b>moment.f</b> and <b>moment_w.f</b>.
; @author Mark Piper, RSI, 2000
; @history
; 2005-08, MP: Added BUILD, CLEAN and FORTRAN keywords.<br>
;-
pro call_moment, arr, $
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
        spawn, 'make moment_' + lang
    if keyword_set(clean) && (os_family eq 'unix') then begin
        spawn, 'make clean'
        return
    endif

    ;; Give the location of & the entry point into the shared
    ;; object. Note the underscores appended to the Fortran version.
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
    entry = keyword_set(fortran) ? 'moment_w__' : 'moment_w'

    ;; If no parameter is passed, then read some sample data.
    if n_params() eq 0 then begin
        file = filepath('damp_sn.dat', subdir=['examples','data'])
        arr = bytarr(256)
        openr, lun, file, /get_lun
        readu, lun, arr
        free_lun, lun
    endif

    ;; View the data.
    plot, arr

    ;; Call the shared object using CALL_EXTERNAL, using appropriate
    ;; type definitions.
    arr = float(arr)
    n = n_elements(arr)
    mean=0.0 & adev=0.0 & sdev=0.0 & svar=0.0 & skew=0.0 & kurt=0.0
    void = call_external(so_path, entry, arr, n, mean, adev, sdev, $
        svar, skew, kurt, /unload)

    ;; Compare the results from the 'moment' routine with the IDL
    ;; MOMENT function.
    print, format='(27x,"mean",9x,"variance",3x,"skewness",6x,"kurtosis")'
    print, '"Moment" routine   : ', mean, svar, skew, kurt
    print, 'IDL MOMENT function: ', moment(arr)
end
