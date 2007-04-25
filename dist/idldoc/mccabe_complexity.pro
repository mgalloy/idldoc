;+
; Searches for the given keywords in a line of IDL code and returns the number
; of keywords found, duplicates allowed.
;
; @returns integer
; @param line {in}{required}{type=str} line of IDL code
; @param keywords {in}{required}{type=strarr} keywords to search for
;-
function mccabe_find_keywords, line, keywords
    compile_opt idl2

    n_found = 0L
    for i = 0L, n_elements(keywords) - 1 do begin
        search_str = ' ' + keywords[i] + ' '
        pos = strpos(line, search_str)
        while (pos gt 0) do begin
            n_found++
            pos = strpos(line, search_str, pos+1)
        endwhile
    endfor

    return, n_found
end


;+
; Returns the McCabe Complexity of the code.
;
; @returns integer
; @param code {in}{required}{strarr} IDL code
;-
function mccabe_complexity, code
    compile_opt idl2

    keywords = ['and', 'or', 'if', 'repeat', 'for', 'while', 'case']
    total_complexity = 0L

    for i = 0L, n_elements(code) - 1 do begin
        line = code[i]
        comment_pos = strpos(line, ';')
        if (comment_pos ne -1) then begin
            line = strmid(line, 0, comment_pos)
        endif
        total_complexity += mccabe_find_keywords(line, keywords)
    endfor

    return, total_complexity
end
