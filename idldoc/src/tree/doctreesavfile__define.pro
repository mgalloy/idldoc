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
  contents = self.savFile->contents()
  print, '    os=' + contents.os
  print, '    user=' + contents.user
  print, '    type=' + contents.filetype
end


;+
; Free resources.
;-
pro doctreesavfile::cleanup
  compile_opt strictarr
  
  obj_destroy, self.savFile
end


;+
; Create file tree object.
;
; :Returns: 1 for success, 0 for failure
; :Keywords:
;    `name` : in, required, type=string
;       basename of filename
;    `directory` : in, required, type=object
;       object representing parent directory
;-
function doctreesavfile::init, name=name, directory=directory, system=system
  compile_opt strictarr
  
  self.name = name
  self.directory = directory
  self.system = system
  
  self.system->getProperty, root=root
  self.directory->getProperty, location=location
  
  self.savFile = obj_new('IDL_Savefile', root + location + self.name)
  
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
             system: obj_new(), $
             directory: obj_new(), $
             name: '', $
             savFile: obj_new() $
           }
end