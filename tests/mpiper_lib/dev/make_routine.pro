;-----------------------------------------------------------------------------
;+
; An IDL code generator. Supply this routine with command-line
; arguments and it writes a template for a routine to a file.
;
; @param name {in}{type=string} The name of the routine to be generated.
; @keyword type {type=string}{default='procedure'} A string giving the
;    type of routine to be generated. Available choices are
;    'procedure', 'function', 'widget', and 'class'.
; @keyword filename {optional}{type=string} The name of the file to
;    which the generated code is written.
; @returns On success, a string array containing the code template;
;    otherwise, a null string.
;
; @requires IDL 6.0
;
; @author Mark Piper, RSI, 2004
;-
function make_routine, name, $
                  type = type_name, $
                  filename = filename
    compile_opt idl2



end
