;+
; Returns the directory of the calling routine's source code. If called from
; the main level, returns the empty string.
;
; @returns string
; @categories introspection
; @history Jim Pendelton, Oct. 2001 <br>
;          Michael Galloy, June 2005 - modernized
;-
function sourceroot
    compile_opt strictarr

    help, calls=calls
    upperRoutine = (strtok(calls[1], ' ', /extract))[0]

    ; handles functions
    skip = 0
    catch, errorNumber
    if (errorNumber ne 0) then begin
        catch, /cancel
        thisRoutine = routine_info(upperRoutine, /functions, /source)
        skip = 1
    endif

    ; handles procedures
    if (skip eq 0) then begin
        thisRoutine = routine_info(upperRoutine, /source)
    endif

    lastSepPos = strpos(thisRoutine.path, path_sep(), /reverse_search)
    root = strmid(thisRoutine.path, 0,  lastSepPos + 1)
    return, root
end
