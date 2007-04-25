;+
; Produces an IDL declaration for the given variable.
;
; @returns scalar string representing IDL syntax to create the given variable
; @param variable {in}{required}{type=any} variable to produce the declaration
;        for
;-
function idldoc_idl_declaration, variable
    compile_opt strictarr

    sz = size(variable, /structure)

    ; structures
    if (sz.type eq 8) then begin
        if (sz.n_dimensions gt 1 || sz.dimensions[0] gt 1) then begin
            return, 'replicate(' + idldoc_idl_declaration(variable[0]) + ', ' $
                + strjoin(strtrim(sz.dimensions[0:sz.n_dimensions-1L], 2), ', ') + ')'
        endif else begin
            s = '{ '
            tnames = tag_names(variable)
            for t = 0L, n_tags(variable) - 1L do begin
                s += (t eq 0 ? '' : ', ') $
                    + tnames[t] + ':' + idldoc_idl_declaration(variable.(t))
            endfor
            s += ' }'
            return, s
        endelse
    endif

    ; scalars
    if (sz.n_dimensions eq 0) then begin
        case sz.type of
        0 : return, '<undefined>'
        1 : return, strtrim(variable, 2) + 'B'
        2 : return, strtrim(variable, 2) + 'S'
        3 : return, strtrim(variable, 2) + 'S'
        4 : return, strtrim(variable, 2)
        5 : return, strtrim(variable, 2) + 'D'
        6 : return, 'complex(' + strtrim(real_part(variable), 2) + ', ' $
                + strtrim(imaginary(variable), 2) + ')'
        7 : return, '''' + variable + ''''
        8 : return, 'struct' ; shouldn't happen
        9 : return, 'complex(' + strtrim(real_part(variable), 2) + 'D, ' $
            + strtrim(imaginary(variable), 2) + 'D)'
        10 : return, 'ptr_new(' $
                + (ptr_valid(variable) ? idldoc_idl_declaration(*variable) : '') $
                + ')'
        11 : begin
                classname = obj_class(variable)
                if (classname ne '') then classname = '''' + classname + ''''
                return, 'obj_new(' + classname + ')'
             end
        12 : return, strtrim(variable, 2) + 'U'
        13 : return, strtrim(variable, 2) + 'UL'
        14 : return, strtrim(variable, 2) + 'LL'
        15 : return, strtrim(variable, 2) + 'ULL'
        endcase
    endif

    ; arrays
    if (sz.n_dimensions ge 1) then begin
        declarations = ['<undefined>', 'bytarr', 'intarr', 'lonarr', 'fltarr', $
            'dblarr', 'complexarr', 'strarr', 'struct', 'dcomplexarr', $
            'ptrarr', 'objarr', 'uintarr', 'ulonarr', 'lon64arr', 'ulon64arr']
        dims = strjoin(strtrim(sz.dimensions[0L:sz.n_dimensions-1L], 2), ', ')
        return, declarations[sz.type] + '(' + dims + ')'
    endif
end