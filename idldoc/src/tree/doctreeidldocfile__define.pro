; docformat = 'rst'

;+
; This class represents a information about .pro file.
; 
; :Properties:
;    `basename` : get, set, type=string
;       basename of filename
;-


;+
; Get properties.
;-
pro doctreeidldocfile::getProperty, basename=basename
  compile_opt strictarr
  
  if (arg_present(basename)) then basename = self.basename
end


;+
; Set properties.
;-
pro doctreeidldocfile::setProperty
  compile_opt strictarr

end


pro doctreeidldocfile::generateOutput, outputRoot, directory
  compile_opt strictarr
  
  print, '  Generating output for .idldoc file ' + self.basename
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
;    `basename` : in, required, type=string
;    
;    `directory` : in, required, type=object
;-
function doctreeidldocfile::init, basename=basename, directory=directory, $
                                  system=system
  compile_opt strictarr
  
  self.basename = basename
  self.directory = directory
  self.system = system
  
  return, 1
end


;+
; :Fields:
;    `directory` directory tree object
;    `basename` basename of file
;    `hasMainLevel` true if the file has a main level program at the end
;    `isBatch` true if the file is a batch file
;    `routines` list of routine objects
;-
pro doctreeidldocfile__define
  compile_opt strictarr
  
  define = { DOCtreeIDLdocFile, $
             system: obj_new(), $
             directory: obj_new(), $
             basename: '' $
           }
end