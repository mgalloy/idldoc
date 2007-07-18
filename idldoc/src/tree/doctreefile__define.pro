; docformat = 'rst'

;+
; This class represents a .pro file.
; 
; :Properties:
;    `name` : in, out, type=string
;       basename of filename
;    `is_batch` : in, out, type=boolean
;       true if the file is a batch file
;-

;+
; Get properties.
;-
pro doctreefile::getProperty, name=name, is_batch=isBatch
  compile_opt strictarr
  
  if (arg_present(name)) then name = self.name
  if (arg_present(isBatch)) then name = self.isBatch  
end


;+
; Set properties.
;-
pro doctreefile::setProperty, name=name, is_batch=isBatch
  compile_opt strictarr
  
  if (n_elements(name) eq 0) then self.name = name
  if (n_elements(isBatch) eq 0) then self.isBatch = isBatch
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
             routines: obj_new() $
           }
end