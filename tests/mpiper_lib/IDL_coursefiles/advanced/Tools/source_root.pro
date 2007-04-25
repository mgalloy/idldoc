;+
; Find the filepath to the file that the calling routine was in.  Parsing the
; output from the HELP routine is not normally a good practice, but there is
; no routine to accomplish our purpose here.
;
; @returns filepath to calling routine; the empty string if called from the
;          command line
; @history Written by Jim Pendelton, Oct. 2001<br>
;          Modified by Michael Galloy, May 7, 2002 to conform to style
;              guidelines
;-
function source_root
    compile_opt idl2

    help, calls=calls

    upper_routine = (strtok(calls[1], ' ', /extract))[0]
    skip = 0

    catch, errno
    if (errno ne 0) then begin
        catch, /cancel
        this_routine = routine_info(upper_routine, /functions, /source)
        skip = 1
    endif
    if (skip eq 0) then begin
        this_routine = routine_info(upper_routine, /source)
    endif

    pos = strpos(this_routine.path, path_sep(), /reverse_search) + 1
    return, strmid(this_routine.path, 0, pos)
end
