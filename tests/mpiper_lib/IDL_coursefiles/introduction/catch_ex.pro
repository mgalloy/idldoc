;+
; An example of trapping an error using the CATCH procedure.
;
; @requires IDL 6.0
; @author Mark Piper, 2003
; @copyright RSI
;-
pro catch_ex
    compile_opt idl2

    i = 0

    err = 0
    catch, err
    if err ne 0 then begin
        catch, /cancel
        print, !error_state.msg
        print, err
        a = 1
    endif

    print, 'i = ', ++i

    ; This will break the first time, but work the second.
    print, 'a = ', a
end