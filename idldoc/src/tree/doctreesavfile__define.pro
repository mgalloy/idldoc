; docformat = 'rst'

;+
; This class represents a information about .pro file.
; 
; :Properties:
;    `name` : get, set, type=string
;       basename of filename
;-


;+
; Get properties.
;-
pro doctreesavfile::getProperty, name=name
  compile_opt strictarr
  
  if (arg_present(name)) then name = self.name
end


;+
; Set properties.
;-
pro doctreesavfile::setProperty, name=name
  compile_opt strictarr
  
  if (n_elements(name) ne 0) then self.name = name
end


pro doctreesavfile::generateOutput, outputRoot, directory
  compile_opt strictarr
  
  print, '  Generating output for .sav file ' + self.name
end


;+
; Free resources.
;-
pro doctreesavfile::cleanup
  compile_opt strictarr
  
end


;+
; Create file tree object.
;
; :Returns: 1 for success, 0 for failure
; :Keywords:
;    `name` : in, required, type=string
;    `directory` : in, required, type=object
;-
function doctreesavfile::init, name=name, directory=directory
  compile_opt strictarr
  
  self.name = name
  self.directory = directory
  
  return, 1
end


;+
; :Fields:
;    `directory` directory tree object
;    `name` basename of file
;-
pro doctreesavfile__define
  compile_opt strictarr
  
  define = { DOCtreeSavFile, $
             directory: obj_new(), $
             name: '' $
           }
end