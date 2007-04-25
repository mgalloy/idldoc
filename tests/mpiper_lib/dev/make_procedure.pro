;-----------------------------------------------------------------------------
;+
; An IDL code generator. Supply this routine with command-line
; arguments and it writes a template for a procedure to a file.
;
; @param name {in}{type=string} The name of the routine to be generated.
; @keyword parameters {optional}{type=string} An array of parameter
;    names for the generated procedure.
; @keyword keywords {optional}{type=string} An array of keyword
;    names for the generated procedure.
; @keyword filename {optional}{type=string} The name of the file to
;    which the generated code is written.
;
; @requires IDL 6.0
; @author Mark Piper, RSI, 2004
;-
pro make_procedure, name, $
                    filename = filename, $
                    parameters = params, $
                    keywords = keys
    compile_opt idl2, logical_predicate

    n_params = n_elements(params) 
    if n_params ne 0 then begin
        param_list = ', ' + strjoin(params, ', ')
    endif else param_list = ''

    n_keys = n_elements(keys) 
    if n_keys ne 0 then begin
        key_list = ''
        for i = 0, n_keys-1 do begin
            key_list = key_list + ', ' + keys[i] + '=' + keys[i]
        endfor 
    endif

    indent = '    '
    filename = name + '.pro'
    openw, lun, filename, /get_lun
    printf, lun, ';+'
    printf, lun, '; A code template generated with MAKE_PROCEDURE.'
    printf, lun, ';'
    i = 0
    while i lt n_params do begin
        printf, lun, '; @param ' + params[i]
        ++i
    endwhile 
    printf, lun, ';'
    i = 0
    while i lt n_keys do begin
        printf, lun, '; @keyword ' + keys[i]
        ++i
    endwhile
    printf, lun, ';'
    printf, lun, '; @author Mark Piper, RSI, ' + strtrim((bin_date())[0],2)
    printf, lun, ';-'
    printf, lun, 'pro ' + name + param_list + key_list
    printf, lun, indent + 'compile_opt idl2, logical_predicate'
    printf, lun
    printf, lun, 'end'
    free_lun, lun
end
