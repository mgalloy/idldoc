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
          /silent, n_warnings=nWarnings, error=error, $
          log_file=filepath('idldoc.log', subdir='savfiles-docs', root=self.root)
          
  assert, error eq 0, 'failed with error ' + !error_state.msg
  
  if (self.showResults) then begin
    filename = filepath('index.html', subdir='savfiles-docs', root=self.root)
    mg_open_url, 'file://' + filename
  endif
    
  assert, nWarnings eq 0, 'failed with warnings'

  mg_heapinfo, n_pointers=nptrsAfter, n_objects=nobjsAfter
      
  return, 1
end


;+
; Define instance variables.
;-
pro docrtsavfiles_ut__define
  compile_opt strictarr
  
  define = { DOCrtSavFiles_ut, inherits DOCrtTestCase }
end