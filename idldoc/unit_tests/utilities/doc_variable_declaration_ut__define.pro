; docformat = 'rst'

;+
; Unit test for mg_variable_declaration.
;-

;+
; Test numeric scalar variables.
; 
; :Returns: 1 for pass, 0 for fail
;-
function mg_variable_declaration_ut::test_scalar
  compile_opt strictarr
  
  assert, mg_variable_declaration(0B) eq '0B', 'incorrect declaration for 0B'
  assert, mg_variable_declaration(0S) eq '0S', 'incorrect declaration for 0S'
  assert, mg_variable_declaration(0L) eq '0L', 'incorrect declaration for 0L'

  return, 1
end


;+
; Test pointer variables.
; 
; :Returns: 1 for pass, 0 for fail
;-
function mg_variable_declaration_ut::test_pointer
  compile_opt strictarr
 
  assert, mg_variable_declaration(ptr_new()) eq 'ptr_new()', $
    'incorrect declaration for ptr_new()'
    
  p = ptr_new(5L)
  assert, mg_variable_declaration(p) eq 'ptr_new(5L)', $
    'incorrect declaration for ptr_new(5L)'
  ptr_free, p
  
  return, 1
end


;+
; Test object variables.
; 
; :Returns: 1 for pass, 0 for fail
;-
function mg_variable_declaration_ut::test_object
  compile_opt strictarr
  
  assert, mg_variable_declaration(obj_new()) eq 'obj_new()', $
    'incorrect declaration for obj_new()'
  o = obj_new('IDL_Container')
  assert, mg_variable_declaration(o) eq 'obj_new(''IDL_CONTAINER'')', $
    'incorrect declaration for obj_new(''IDL_Container'')'
  obj_destroy, o
  
  return, 1
end


;+
; Define instance variables.
;-
pro mg_variable_declaration_ut__define
  compile_opt strictarr
  
  define = { mg_variable_declaration_ut, inherits DOCutTestCase }
end