;+
; Print error messages respecting /QUIET and /SILENT.
;
; :Params:
;    `msg` : in, required, type=string
;       error message to print 
;-
pro doc_system::error, msg
  compile_opt strictarr
  
end


;+
; Print warning messages respecting /QUIET and /SILENT.
;
; :Params:
;    `msg` : in, required, type=string
;       warning message to print 
;-
pro doc_system::warning, msg
  compile_opt strictarr
  
  ++self.nWarnings
end


;+
; Print messages respecting /QUIET and /SILENT.
;
; :Params:
;    `msg` : in, required, type=string
;       message to print 
;-
pro doc_system::print, msg
  compile_opt strictarr
  

end


;+
; Create system object.
; 
; :Returns: 1 for success, 0 for failure
; :Keywords:
;    `root` : in, required, type=string
;       root of directory hierarchy to document
;-
function doc_system::init, root=root
  compile_opt strictarr
  on_error, 2
  
  if (n_elements(root) eq 0) then begin
    message, 'ROOT must be defined'
  endif else begin
    self.root = file_expand_path(root) + path_sep()
  endelse
  
  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    `root` root directory of hierarchy to document; full path ending with slash
;    `nWarnings` number of warning messages printed
;-
pro doc_system__define
  compile_opt strictarr
  
  define = { DOC_System, $
             root: '', $
             nWarnings: 0L $             
           }
end