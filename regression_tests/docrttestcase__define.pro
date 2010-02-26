; docformat = 'rst'

;+
; Parent class for IDLdoc test cases. All IDLdoc unit tests should inherit
; from this class. It provides IDLdoc specific testing features.
;-


;+
; Code run before each regression test. Saves heap state so that memory leaks
; can be found.
;-
pro docrttestcase::setup
  compile_opt strictarr
  
  mg_heapinfo, n_pointers=nptrs, n_objects=nobjs
  self.nptrsBefore = nptrs
  self.nobjsBefore = nobjs
end


;+
; Code run after each regression test. Checks heap state and compares with 
; status before the test saved by setup method.
;-
pro docrttestcase::teardown
  compile_opt strictarr

  mg_heapinfo, n_pointers=nptrs, n_objects=nobjs
  assert, nptrs eq self.nptrsBefore, $
          string(nptrs - self.nptrsBefore, format='(%"leaked %d pointers")')  
  assert, nobjs eq self.nobjsBefore, $
          string(nobjs - self.nobjsBefore, format='(%"leaked %d objects")')  
end


;+
; Initialize an IDLdoc test case.
; 
; Returns: 1 for success, 0 for failure
;
; Keywords:
;    _ref_extra : in, out, optional, type=keyword
;                   keywords to MGutTestCase::init
;-
function docrttestcase::init, _ref_extra=e
  compile_opt strictarr

  if (~self->mguttestcase::init(_strict_extra=e)) then return, 0
  
  self.root = mg_src_root()
  self.showResults = 0B
  
  return, 1
end


;+
; Define instance variables.
; 
; Fields:
;    root
;       absolute path to the root of the IDLdoc project (with trailing slash)
;    showResults
;       set to show results in web browser
;-
pro docrttestcase__define
  compile_opt strictarr
  
  define = { DOCrtTestCase, inherits MGutTestCase, $
             root: '', $
             showResults: 0B, $
             nptrsBefore: 0L, $
             nobjsBefore: 0L $
           }
end