; docformat = 'rst'

;+
; Test suite containing all unit tests for IDLdoc.
;-

;+
; Create full test suite for IDLdoc.
; 
; :Keywords:
;    `_ref_extra` : in, out, optional, type=keyword
;                   keywords to MGutTestSuite::init
;-
function docutalltests_uts::init, _ref_extra=e
  compile_opt strictarr
  
  if (~self->mguttestsuite::init(_strict_extra=e)) then return, 0
  
  self->add, /all
  
  return, 1
end


;+
; Define instance variables.
;-
pro docutalltests_uts__define
  compile_opt strictarr
  
  define = { DOCutAllTests_uts, inherits MGutTestSuite }
end
