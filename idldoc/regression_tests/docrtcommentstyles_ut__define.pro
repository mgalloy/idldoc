; docformat = 'rst'

;+
; Basic IDLdoc run on files with differing comment styles.
;-
function docrtcommentstyles_ut::test_basic
  compile_opt strictarr

  idldoc, root=filepath('commentstyles', root=self.root), $
          output=filepath('commentstyles-docs', root=self.root), $
          title='Testing differing comment styles', $
          subtitle='Basic test', $
          /silent, n_warnings=nWarnings, error=error
          
  assert, error eq 0, 'failed with error ' + !error_state.msg
  
  return, 1
end


;+
; Define instance variables.
;-
pro docrtcommentstyles_ut__define
  compile_opt strictarr
  
  define = { DOCrtCommentStyles_ut, inherits DOCrtTestCase }
end