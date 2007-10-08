; docformat = 'rst'

;+
; Basic IDLdoc run of on save files.
;-
function docrtsavfiles_ut::test_basic
  compile_opt strictarr

  idldoc, root=filepath('savfiles', root=self.root), $
          output=filepath('savfiles-docs', root=self.root), $
          title='Testing save files', $
          subtitle='Basic test', $
          /silent, n_warnings=nWarnings, error=error
          
  assert, error eq 0, 'failed with error ' + !error_state.msg
  
  return, 1
end


;+
; Define instance variables.
;-
pro docrtsavfiles_ut__define
  compile_opt strictarr
  
  define = { DOCrtSavFiles_ut, inherits DOCrtTestCase }
end