;+
; Print a message describing the TEST_IDLDOC keywords.
;
; @keyword assistant {in}{optional}{type=boolean} produce ADP help instead of
;          output optimized for web pages
; @keyword idldoc {in}{optional}{type=boolean} run on IDLdoc source code
; @keyword small {in}{optional}{type=boolean} run on a small example of two
;          .pro files
; @keyword sav {in}{optional}{type=boolean} run on a series of SAV files
; @keyword idl_lib {in}{optional}{type=boolean} run on the running version of
;          IDL's lib directory
; @keyword idl_complete {in}{optional}{type=boolean} run on the running version of
;          IDL's main directory
; @keyword time {in}{optional}{type=float} time of IDLdoc run
; @keyword nobrowser {in}{optional}{type=boolean} not used
;-
pro test_all_msg, lun, assistant=assistant, idldoc=idldoc, small=small, sav=sav, $
    idl_lib=idl_lib, idl_complete=idl_complete, bizarre=bizarre, $
    class_diagram=class_diagram, gs_code_library=gs_code_library, time=time, $
    nobrowser=nobrowser

    compile_opt strictarr

    case 1B of
    keyword_set(idldoc) : name = 'IDLdoc'
    keyword_set(small) : name = 'Small'
    keyword_set(sav) : name = 'SAV'
    keyword_set(idl_lib) : name = 'IDL lib'
    keyword_set(idl_complete) : name = 'IDL'
    keyword_set(itools_course) : name = 'iTools Programming'
    keyword_set(itools_lib) : name = 'iTools lib'
    keyword_set(bizarre) : name = 'Bizarre cases'
    keyword_set(class_diagram) : name = 'Class diagrams'
    keyword_set(gs_code_library) : name = 'GS Code Library'
    endcase

    printf, lun, name + (keyword_set(assistant) ? ' (assistant)' : '') $
        + ': ' + strtrim(time, 2) + ' seconds'
end


;+
; Run test suite on IDLdoc.
;-
pro test_all
    compile_opt strictarr

    error = 0L
    catch, error
    if (error ne 0L) then begin
        catch, /cancel
        printf, lun, 'Error running test.'
        free_lun, lun
    endif

    location = sourceroot()

    log = location + 'idldoc-000.log'
    index = 1
    while (file_test(log)) do begin
        log = location + 'idldoc-' + string(index++, format='(I03)') + '.log'
    endwhile

    openw, lun, log, /get

    for assistant = 0B, 1B do begin
        test_idldoc, /idldoc, assistant=assistant, time=time, /nobrowser
        test_all_msg, lun, /idldoc, assistant=assistant, time=time, /nobrowser

;        test_idldoc, /idl_lib, assistant=assistant, time=time, /nobrowser
;        test_all_msg, lun, /idl_lib, assistant=assistant, time=time, /nobrowser

;        test_idldoc, /idl_complete, assistant=assistant, time=time, /nobrowser
;        test_all_msg, lun, /idl_complete, assistant=assistant, time=time, /nobrowser

        test_idldoc, /itools_course, assistant=assistant, time=time, /nobrowser
        test_all_msg, lun, /itools_course, assistant=assistant, time=time, /nobrowser

        test_idldoc, /itools_lib, assistant=assistant, time=time, /nobrowser
        test_all_msg, lun, /itools_lib, assistant=assistant, time=time, /nobrowser

        test_idldoc, /sav, assistant=assistant, time=time, /nobrowser
        test_all_msg, lun, /sav, assistant=assistant, time=time, /nobrowser

        test_idldoc, /small, assistant=assistant, time=time, /nobrowser
        test_all_msg, lun, /small, assistant=assistant, time=time, /nobrowser

        test_idldoc, /bizarre, assistant=assistant, time=time, /nobrowser
        test_all_msg, lun, /bizarre, assistant=assistant, time=time, /nobrowser

        test_idldoc, /class_diagrams, assistant=assistant, time=time, /nobrowser
        test_all_msg, lun, /class_diagrams, assistant=assistant, time=time, /nobrowser

        test_idldoc, /gs_code_library, assistant=assistant, time=time, /nobrowser
        test_all_msg, lun, /gs_code_library, assistant=assistant, time=time, /nobrowser
    endfor

    free_lun, lun
end