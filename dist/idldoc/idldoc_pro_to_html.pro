;+
; Converts filenames from PRO extension to HTML extension.
;
; @private
; @returns string or string array with filenames changed from .PRO files to
;          .HTML files
; @param filename {in}{required}{type=string or string array} filenames ending
;        in .PRO
; @keyword add {in}{optional}{type=string} string to add to the end of the base
;          filename before .html is added
;-
function idldoc_pro_to_html, filename, add=add
    compile_opt idl2, hidden

    dot_pos = strpos(filename, '.', /reverse_search)
    base = strmid(filename, 0, dot_pos)
    return, base + (n_elements(add) eq 0 ? '' : add) + '.html'
end


