; docformat = 'rst'

pro doctreeroutine::getProperty, file=file, name=name, is_function=isFunction
  compile_opt strictarr
  
  if (arg_present(file)) then file = self.file
  if (arg_present(name)) then name = self.name
  if (arg_present(isFunction)) then isFunction = self.isFunction
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