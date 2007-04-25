;+
; Remove the slashes before "at" signs.  Only run this routine after processing
; tags have been handled.
;
; @param comments {in}{out}{required}{type=strarr} comment lines
;-
pro idldoc_escape_slashes, comments
    compile_opt idl2

    for i = 0, n_elements(comments) - 1 do begin
        comments[i] $
            = strjoin(strsplit(comments[i], '@', escape='\', /extract), '@')
    endfor
end
