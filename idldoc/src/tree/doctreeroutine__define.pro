; docformat = 'rst'

;+
; :Properties:
;    `file` : get, type=object
;       file tree object
;    `name` : set, get, type=string
;       name of the routine
;    `is_function` : get, set, type=boolean
;       1 if a function, 0 if not 
;    `is_method` : get, set, type=boolean
;       1 if a method, 0 if not
;-

;+
; Get properties.
;-
pro doctreeroutine::getProperty, file=file, name=name, is_function=isFunction, $
                                 is_method=isMethod
  compile_opt strictarr
  
  if (arg_present(file)) then file = self.file
  if (arg_present(name)) then name = self.name
  if (arg_present(isFunction)) then isFunction = self.isFunction
  if (arg_present(isMethod)) then isMethod = self.isMethod
end


;+
; Set properties.
;-
pro doctreeroutine::setProperty, name=name, is_Function=isFunction, $
                                 is_method=isMethod
  compile_opt strictarr
  
  if (n_elements(name) gt 0) then self.name = name
  if (n_elements(isFunction) gt 0) then self.isFunction = isFunction
  if (n_elements(isMethod) gt 0) then self.isMethod = isMethod
end


;+
; Add a parameter to the list of parameters for this routine.
; 
; :Params:
;    `param` : in, required, type=object
;       argument tree object
;-
pro doctreeroutine::addParameter, param
  compile_opt strictarr
  
  self.parameters->add, param
end


;+
; Add a keyword to the list of keywords for this routine.
; 
; :Params:
;    `keyword` : in, required, type=object
;       argument tree object
;-
pro doctreeroutine::addKeyword, keyword
  compile_opt strictarr
  
  self.keywords->add, keyword
end


;+
; Free resources.
;-
pro doctreeroutine::cleanup
  compile_opt strictarr
  
  obj_destroy, [self.parameters, self.keywords]
end


;+
; Create a routine object.
;
; :Returns:
;    1 for success, 0 for failure
;
; :Params:
;    `file` : in, required, type=object
;       file tree object
;-
function doctreeroutine::init, file
  compile_opt strictarr
  
  self.file = file
  
  self.parameters = obj_new('MGcoArrayList', type=11)
  self.keywords = obj_new('MGcoArrayList', type=11)
  
  return, 1B
end


;+
; Define instance variables for routine class. 
;
; :Fields:
;    `file` file object containing this routine
;    `name` string name of this routine
;    `isFunction` true if this routine is a function
;    `isMethod` true if this routine is a method of a class
;    `parameters` list of parameter objects
;    `keywords` list of keyword objects
;    `comments` tree node hierarchy
;-
pro doctreeroutine__define
  compile_opt strictarr
  
  define = { DOCtreeRoutine, $
             file: obj_new(), $
             name: '', $
             isFunction: 0B, $
             isMethod: 0B, $
             parameters: obj_new(), $
             keywords: obj_new(), $
             comments: obj_new() $
           }
end