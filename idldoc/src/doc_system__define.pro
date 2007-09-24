; docformat = 'rst'


;+
; Print out debugging information about the system object.
;-
pro doc_system::debug
  compile_opt strictarr
  
  print, 'ROOT = ' + self.root
  print, 'OUTPUT = ' + self.output
end


;+
; Print error messages respecting /QUIET and /SILENT.
;
; :Params:
;    `msg` : in, required, type=string
;       error message to print 
;-
pro doc_system::error, msg
  compile_opt strictarr
  on_error, 2
  
  message, msg, /noname
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
  
  if (~self.silent) then message, msg, /informational
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
; Build the tree of directories, files, routines, and parameters.
;-
pro doc_system::buildTree
  compile_opt strictarr
  
  proFiles = file_search(self.root, '*.pro')
  savFiles = file_search(self.root, '*.sav')
  idldocFiles = file_search(self.root, '*.idldoc')

  ; TODO: implement this
end


;+
; Determine if the output directory can be written to.
;
; :Returns: error code (0 indicates no error)
;-
function doc_system::testOutput
  compile_opt strictarr
  
  testfile = self.output + 'idldoc.test'
  openw, lun, testfile, error=error, /get_lun
  if (error eq 0L) then free_lun, lun
  file_delete, testfile, /allow_nonexistent
  return, error
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
    self->error, 'ROOT keyword must be defined'
  endif else begin
    self.root = file_search(root, /mark_directory)
  endelse
  
  if (n_elements(output) gt 0) then begin
    self.output = file_search(output, /mark_directory)
  endif else begin
    self.output = self.root
  endelse
  
  self.quiet = keyword_set(quiet)
  self.silent = keyword_set(silent)
  
  ; test output directory for write permission
  outputError = self->testOutput()
  if (outputError ne 0L) then self->error, 'unable to write to ' + self.output
  
  ; build tree of directories
  self->buildTree
    
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