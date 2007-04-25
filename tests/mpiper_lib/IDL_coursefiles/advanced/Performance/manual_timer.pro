;+
; Returns the current time as the number of seconds elapsed since
; 1970-01-01.
;
; @author Mark Piper, RSI, 2005
;-
function manual_timer, dummy
    compile_opt idl2

    return, !version.os_family eq 'Windows' ? qsystime(1) : systime(1)
end
