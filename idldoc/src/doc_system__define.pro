;+
; Print error messages respecting /QUIET and /SILENT.
;
; :Params:
;    `msg` : in, required, type=string
;       error message to print 
;-
pro doc_system::error, msg
  compile_opt strictarr
  
  ; TODO: implement this
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
  
  if (~self.silent) then print, msg
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
  
  if (~self.quiet || ~self.silent) then print, msg
end


;+
; Create system object.
; 
; :Returns: 1 for success, 0 for failure
; :Keywords:
;    `root` : in, required, type=string
;       root of directory hierarchy to document
;    `output` : in, optional, type=string
;       directory to place output
;    `quiet` : in, optional, type=boolean
;       if set, don't print info or warning messages, only print errors
;    `silent` : in, optional, type=boolean
;       if set, don't print anything
;-
function doc_system::init, root=root, output=output, $
                           quiet=quiet, silent=silent
  compile_opt strictarr
  on_error, 2
  
  if (n_elements(root) eq 0) then begin
    message, 'ROOT must be defined'
  endif else begin
    self.root = file_expand_path(root) + path_sep()
  endelse
  
  if (n_elements(output) gt 0) then begin
    self.output = file_expand_path(output) + path_sep()
  endif else begin
    self.output = self.root
  endelse
  
  self.quiet = keyword_set(quiet)
  self.silent = keyword_set(silent)
  
  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    `root` 
;       root directory of hierarchy to document; full path ending with slash
;    `output`
;       directory to place output
;    `nWarnings` 
;       number of warning messages printed
;    `quiet`
;       set to only print errors and warnings
;    `silent`
;       don't print anything
;-
pro doc_system__define
  compile_opt strictarr
  
  define = { DOC_System, $
             root: '', $
             output: '', $
             nWarnings: 0L, $
             quiet: 0B, $
             silent: 0B $             
           }
end