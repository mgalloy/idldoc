; docformat = 'rst'

;+
; Basic IDLdoc run of on class definition file.
;-
function docrtnonautoclasses_ut::test_basic
  compile_opt strictarr

  idldoc, root=filepath('nonautoclasses', root=self.root), $
          output=filepath('nonautoclasses-docs', root=self.root), $
          title='Testing non automatic structure definition OOP class files', $
          subtitle='Basic test', $
          /silent, n_warnings=nWarnings, error=error, $
          log_file=filepath('idldoc.log', subdir='nonautoclasses-docs', root=self.root)
          
  assert, error eq 0, 'failed with error ' + !error_state.msg

  if (self.showResults) then begin
    filename = filepath('index.html', subdir='nonautoclasses-docs', root=self.root)
    mg_open_url, 'file://' + filename
  endif

  assert, nWarnings eq 0, 'failed with warnings'
  
  return, 1
end


;+
; Define instance variables.
;-
pro docrtnonautoclasses_ut__define
  compile_opt strictarr
  
  define = { DOCrtNonAutoClasses_ut, inherits DOCrtTestCase }
end