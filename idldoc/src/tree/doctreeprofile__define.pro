; docformat = 'rst'

;+
; This class represents a information about .pro file.
; 
; :Properties:
;    `basename` : get, set, type=string
;       basename of filename
;    `has_main_level` : get, set, type=boolean
;       true if the file has a main-level program at the end
;    `is_batch` : get, set, type=boolean
;       true if the file is a batch file
;    `comments` : get, set, type=object
;       text tree hierarchy for file level comments
;    `n_routines` : get, type=integer
;       number of routines in the file
;    `routines` : get, type=object
;       list object containing routine objects in file
;-


;+
; Get properties.
;-
pro doctreeprofile::getProperty, basename=basename, $
                                 has_main_level=hasMainLevel, $
                                 is_batch=isBatch, comments=comments, $
                                 n_routines=nRoutines, routines=routines
  compile_opt strictarr
  
  if (arg_present(basename)) then basename = self.basename
  if (arg_present(hasMainLevel)) then hasMainLevel = self.hasMainLevel
  if (arg_present(isBatch)) then isBatch = self.isBatch  
  if (arg_present(comments)) then comments = self.comments
  if (arg_present(nRoutines)) then nRoutines = self.routines->count()
  if (arg_present(routines)) then routines = self.routines
end


;+
; Set properties.
;-
pro doctreeprofile::setProperty, has_main_level=hasMainLevel, $
                                 is_batch=isBatch, comments=comments
  compile_opt strictarr
  
  if (n_elements(hasMainLevel) ne 0) then self.hasMainLevel = hasMainLevel
  if (n_elements(isBatch) ne 0) then self.isBatch = isBatch
  if (n_elements(comments) ne 0) then self.comments = comments
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
function doctreeprofile::getVariable, name, found=found
  compile_opt strictarr
  
  found = 1B
  case strlowcase(name) of
    'basename' : return, self.basename
    'local_url' : return, file_basename(self.basename, '.pro') + '.html'
    else: begin
        ; search in the system object if the variable is not found here
        var = self.directory->getVariable(name, found=found)
        if (found) then return, var
        
        found = 0B
        return, -1L
      end
  endcase
end


;+
; Add a routine to the list of routines in the file.
; 
; :Params:
;    `routine` : in, required, type=object
;       routine object
;-
pro doctreeprofile::addRoutine, routine
  compile_opt strictarr
  
  self.routines->add, routine
end


pro doctreeprofile::generateOutput, outputRoot, directory
  compile_opt strictarr
  
  print, '  Generating output for ' + self.basename
end


;+
; Free resources.
;-
pro doctreeprofile::cleanup
  compile_opt strictarr
  
  obj_destroy, self.routines
end


;+
; Create file tree object.
;
; :Returns: 1 for success, 0 for failure
; :Keywords:
;    `basename` : in, required, type=string
;    `directory` : in, required, type=object
;-
function doctreeprofile::init, basename=basename, directory=directory, $
                               system=system
  compile_opt strictarr
  
  self.basename = basename
  self.directory = directory
  self.system = system
  
  self.routines = obj_new('MGcoArrayList', type=11)
  
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
pro doctreeprofile__define
  compile_opt strictarr
  
  define = { DOCtreeProFile, $
             system: obj_new(), $
             directory: obj_new(), $
             basename: '', $
             hasMainLevel: 0B, $
             isBatch: 0B, $
             comments: obj_new(), $
             routines: obj_new() $
           }
end