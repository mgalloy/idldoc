; docformat = 'rst'

;+
; Basic IDLdoc run of on save files.
;-
function docrtclasses_ut::test_basic
  compile_opt strictarr

  idldoc, root=filepath('classes', root=self.root), $
          output=filepath('classes-docs', root=self.root), $
          title='Testing OOP class files', $
          subtitle='Basic test', $
          /silent, n_warnings=nWarnings, error=error
          
  assert, error eq 0, 'failed with error ' + !error_state.msg
  
  return, 1
end


;+
; Define instance variables.
;-
pro docrtclasses_ut__define
  compile_opt strictarr
  
  define = { DOCrtClasses_ut, inherits DOCrtTestCase }
end