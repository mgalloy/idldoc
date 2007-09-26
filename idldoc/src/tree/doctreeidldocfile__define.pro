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


;+
; Get variables for use with templates.
;
; :Returns: variable
; :Params:
;    `name` : in, required, type=string
;       name of variable
;
; :Keywords:
;    `found` : out, optional, type=boolean
;       set to a named variable, returns if variable name was found
;-
function doctreeidldocfile::getVariable, name, found=found
  compile_opt strictarr
  
  found = 1B
  case strlowcase(name) of
    'basename' : return, self.basename
    else: begin
        ; search in the system object if the variable is not found here
        var = self.directory->getVariable(name, found=found)
        if (found) then return, var
        
        found = 0B
        return, -1L
      end
  endcase
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