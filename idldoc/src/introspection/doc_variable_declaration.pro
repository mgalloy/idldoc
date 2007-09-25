; docformat = 'rst'

;+
; Returns a string that declares the type of the given variable.
; 
; :Returns: string
; :Params:
;    `var` : in, required, type=any
;-
function doc_variable_declaration, var
  compile_opt strictarr

  ; get size/type information
  sz = size(var, /structure)
    
  ; structures
  if (sz.type eq 8) then begin
  endif
  
  ; scalars
  if (sz.n_dimensions eq 0) then begin
    case sz.type of
      0 : return, '<undefined>'
      1 : return, strtrim(fix(var), 2) + 'B'   ; use FIX to not use ASCII value
      2 : return, strtrim(var, 2) + 'S'
      3 : return, strtrim(var, 2) + 'L'
      4 : return, strtrim(var, 2)
      5 : return, strtrim(var, 2) + 'D'
      6 : return, 'complex(' + strtrim(real_part(var), 2) + ', ' + strtrim(imaginary(var), 2) + ')'
      7 : return, '''' + var + ''''
      8 : ; handled structure case already
      9 : return, 'dcomplex(' + strtrim(real_part(var), 2) + 'D , ' + strtrim(imaginary(var), 2) + 'D)'
      10 : return, 'ptr_new(' + (ptr_valid(var) ? doc_variable_declaration(*var): '') + ')'
      11 : begin
          classname = obj_class(var)
          classname = classname eq '' ? '' : '''' + classname + ''''
          return, 'obj_new(' + classname + ')'
        end
      12 :
      13 :
      14 :
      15 :
      else : return, 'unknown type'
    endcase
  endif
    
  ; arrays
  declarations = ['---', 'bytarr', 'intarr', 'lonarr', 'fltarr', $
            'dblarr', 'complexarr', 'strarr', '---', 'dcomplexarr', $
            'ptrarr', 'objarr', 'uintarr', 'ulonarr', 'lon64arr', 'ulon64arr']
            

end
