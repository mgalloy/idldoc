; docformat = 'rst'

;+
; This class represents a information about .pro file.
; 
; :Properties:
;    `name` : get, set, type=string
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
pro doctreeprofile::getProperty, name=name, has_main_level=hasMainLevel, $
                                 is_batch=isBatch, comments=comments, $
                                 n_routines=nRoutines, routines=routines
  compile_opt strictarr
  
  if (arg_present(name)) then name = self.name
  if (arg_present(hasMainLevel)) then hasMainLevel = self.hasMainLevel
  if (arg_present(isBatch)) then isBatch = self.isBatch  
  if (arg_present(comments)) then comments = self.comments
  if (arg_present(nRoutines)) then nRoutines = self.routines->count()
  if (arg_present(routines)) then routines = self.routines
end


;+
; Set properties.
;-
pro doctreeprofile::setProperty, name=name, has_main_level=hasMainLevel, $
                                 is_batch=isBatch, comments=comments
  compile_opt strictarr
  
  if (n_elements(name) ne 0) then self.name = name
  if (n_elements(hasMainLevel) ne 0) then self.hasMainLevel = hasMainLevel
  if (n_elements(isBatch) ne 0) then self.isBatch = isBatch
  if (n_elements(comments) ne 0) then self.comments = comments
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
  
  print, '  Generating output for ' + self.name
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
;    `name` : in, required, type=string
;    `directory` : in, required, type=object
;-
function doctreeprofile::init, name=name, directory=directory
  compile_opt strictarr
  
  self.name = name
  self.directory = directory
  self.routines = obj_new('MGcoArrayList', type=11)
  
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
pro doctreeprofile__define
  compile_opt strictarr
  
  define = { DOCtreeProFile, $
             directory: obj_new(), $
             name: '', $
             hasMainLevel: 0B, $
             isBatch: 0B, $
             comments: obj_new(), $
             routines: obj_new() $
           }
end