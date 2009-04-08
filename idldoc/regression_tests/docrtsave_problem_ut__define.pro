; docformat = 'rst'

;+
; Basic IDLdoc run of on save files.
;-
function docrtsave_problem_ut::test_basic
  compile_opt strictarr
  
  idldoc, root=filepath('save_problem', root=self.root), $
          output=filepath('save_problem-docs', root=self.root), $
          title='Problem with save file', $
          subtitle='Basic test', $
          /silent, n_warnings=nWarnings, error=error, $
          log_file=filepath('idldoc.log', subdir='save_problem-docs', root=self.root)
          
  assert, error eq 0, 'failed with error ' + !error_state.msg

  if (self.showResults) then begin
    filename = filepath('index.html', subdir='save_problem-docs', root=self.root)
    mg_open_url, 'file://' + filename
  endif
    
  assert, nWarnings eq 0, 'failed with warnings'

  mg_heapinfo, n_pointers=nptrsAfter, n_objects=nobjsAfter
    
  return, 1
end


;+
; Define instance variables.
;-
pro docrtsave_problem_ut__define
  compile_opt strictarr
  
  define = { DOCrtSave_Problem_ut, inherits DOCrtTestCase }
end