; docformat = 'rst'

;+
; Parent class for IDLdoc test cases. All IDLdoc unit tests should inherit
; from this class. It provides IDLdoc specific testing features.
;-

;+
; Initialize an IDLdoc test case.
; 
; Returns: 1 for success, 0 for failure
;
; Keywords:
;    `_ref_extra` : in, out, optional, type=keyword
;                   keywords to MGutTestCase::init
;-
function docrttestcase::init, _ref_extra=e
  compile_opt strictarr

  if (~self->mguttestcase::init(_strict_extra=e)) then return, 0
  
  self.root = mg_src_root()
  
  return, 1
end


;+
; Define instance variables.
; 
; Fields:
;    `root` 
;       absolute path to the root of the IDLdoc project (with trailing slash)
;-
pro docrttestcase__define
  compile_opt strictarr
  
  define = { DOCrtTestCase, inherits MGutTestCase, $
             root: '' $
           }
end