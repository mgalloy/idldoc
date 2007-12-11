; docformat = 'rst'

;+
; Reproduce case for bug report.
;-
function docrtaddpngcomment_ut::test_basic
  compile_opt strictarr

  idldoc, root=filepath('addpngcomment', root=self.root), $
          output=filepath('addpngcomment-docs', root=self.root), $
          title='Reproduce case for bug report', $
          subtitle='Basic test', $
          /silent, n_warnings=nWarnings, error=error, $
          log_file=filepath('idldoc.log', subdir='classes-docs', root=self.root)
          
  assert, error eq 0, 'failed with error ' + !error_state.msg
  
  mg_open_url, 'file://' + filepath('index.html', subdir='addpngcomment-docs', root=self.root)
  
  assert, nWarnings eq 0, 'failed with warnings'
  
  return, 1
end


;+
; Define instance variables.
;-
pro docrtaddpngcomment_ut__define
  compile_opt strictarr
  
  define = { DOCrtAddPNGComment_ut, inherits DOCrtTestCase }
end