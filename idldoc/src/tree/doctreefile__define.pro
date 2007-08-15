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
;-


;+
; Get properties.
;-
pro doctreefile::getProperty, name=name, has_main_level=hasMainLevel, $
                              is_batch=isBatch, comments=comments, $
                              n_routines=nRoutines
  compile_opt strictarr
  
  if (arg_present(name)) then name = self.name
  if (arg_present(hasMainLevel)) then hasMainLevel = self.hasMainLevel
  if (arg_present(isBatch)) then isBatch = self.isBatch  
  if (arg_present(comments)) then comments = self.comments
  if (arg_present(nRoutines)) then nRoutines = self.routines->count()
end


;+
; Set properties.
;-
pro doctreefile::setProperty, name=name, has_main_level=hasMainLevel, $
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
pro doctreefile::addRoutine, routine
  compile_opt strictarr
  
  self.routines->add, routine
end


;+
; Free resources.
;-
pro doctreefile::cleanup
  compile_opt strictarr
  
  obj_destroy, self.routines
end


;+
; Create file tree object.
;
; :Returns: 1 for success, 0 for failure
; :Keywords:
;    `name` : in, required, type=string
;-
function doctreefile::init, name=name
  compile_opt strictarr
  
  self.name = name
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
pro doctreefile__define
  compile_opt strictarr
  
  define = { DOCtreeFile, $
             directory: obj_new(), $
             name: '', $
             hasMainLevel: 0B, $
             isBatch: 0B, $
             comments: obj_new(), $
             routines: obj_new() $
           }
end