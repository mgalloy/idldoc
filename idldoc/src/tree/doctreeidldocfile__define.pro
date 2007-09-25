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
pro doctreeidldocfile::getProperty, name=name
  compile_opt strictarr
  
  if (arg_present(name)) then name = self.name
end


;+
; Set properties.
;-
pro doctreeidldocfile::setProperty, name=name
  compile_opt strictarr
  
  if (n_elements(name) ne 0) then self.name = name
end


pro doctreeidldocfile::generateOutput, outputRoot, directory
  compile_opt strictarr
  
  print, '  Generating output for .idldoc file ' + self.name
end


;+
; Free resources.
;-
pro doctreeidldocfile::cleanup
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
function doctreeidldocfile::init, name=name, directory=directory, system=system
  compile_opt strictarr
  
  self.name = name
  self.directory = directory
  self.system = system
  
  return, 1
end


;+
; :Fields:
;    `directory` directory tree object
;    `name` basename of file
;    `hasMainLevel` true if the file has a main level program at the end
;    `isBatch` true if the file is a batch file
;    `routines` list of routine objects
;-
pro doctreeidldocfile__define
  compile_opt strictarr
  
  define = { DOCtreeIDLdocFile, $
             system: obj_new(), $
             directory: obj_new(), $
             name: '' $
           }
end