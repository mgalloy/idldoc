; docformat = 'rst'

;+
; Simple run on DERIV routine from IDL standard library. This is an example
; of a routine with an "inside" comment.
;-
function docrtderiv_ut::test_basic
  compile_opt strictarr

  idldoc, root=filepath('deriv', root=self.root), $
          output=filepath('deriv-docs', root=self.root), $
          title='Testing DERIV docs in IDL standard library', $
          subtitle='Basic test', $
          format_style='idl', $
          /silent, n_warnings=nWarnings, error=error, $
          log_file=filepath('idldoc.log', subdir='congrid-docs', root=self.root)
          
  assert, error eq 0, 'failed with error ' + !error_state.msg
  assert, nWarnings eq 0, 'failed with warnings'
  
  return, 1
end


;+
; Define instance variables.
;-
pro docrtderiv_ut__define
  compile_opt strictarr
  
  define = { DOCrtDeriv_ut, inherits DOCrtTestCase }
end
