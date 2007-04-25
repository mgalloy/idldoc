;+
; A C linking example using MAKE_DLL and CALL_EXTERNAL.
; Hardcoded.  Calls C program 'f2c' in file 'f2c.c'.
;
; @author Mark Piper, 2000
; @copyright RSI
;-
pro make_dll_ex
    compile_opt idl2

    ; The name of the C input file (no dir info or '.c' suffix).
    inputFile = 'f2c'

    ; The name of the output DLL (again, no dir info or suffix).
    outputFile = inputFile

    ; Path to where input file can be found.
    inputDirectory = filepath('', subdir='training')
    ;inputDirectory = '/home/mpiper/IDL/intermediate/call_external'

    ; Path to place output DLL.
    outputDirectory = inputDirectory

    ; Set compiler options (use default).
    cc = !make_dll.cc

    ; Set linker options (use default).
    ld = !make_dll.ld

    ; Call MAKE_DLL.
    make_dll, inputFile, outputFile, $
        input_directory=inputDirectory, $
        output_directory=outputDirectory, $
        dll_path=dll_path, $
        cc=cc, $
        ld=ld, $
        nocleanup=0, $
        show_all_output=0, $
        verbose=0

    ; Where to enter the DLL; in this case, at the wrapper
    ; routine 'f2c_w'.
    entry_point = 'f2c_w'

    ; Define input value.
    f = 68.d0

    ; Call CALL_EXTERNAL.
    c = call_external(dll_path, entry_point, f, $
        /d_value, $
        /unload, $
        /cdecl)

    ; Display output.
    print, format='(a20, f8.2)', 'Degrees Farenheit:', f
    print, format='(a20, f8.2)', 'Degrees Celcius:', c
end
