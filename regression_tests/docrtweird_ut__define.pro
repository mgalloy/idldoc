; docformat = 'rst'

;+
; Basic IDLdoc run on some odd markup.
;-
function docrtweird_ut::test_basic
  compile_opt strictarr

  idldoc, root=filepath('weird', root=self.root), $
          output=filepath('weird-docs', root=self.root), $
          title='Testing on weird markup', $
          subtitle='Basic test', $
          /silent, n_warnings=nWarnings, error=error, $
          log_file=filepath('idldoc.log', subdir='weird-docs', root=self.root)
          
  assert, error eq 0, 'failed with error ' + !error_state.msg

  if (self.showResults) then begin
    filename = filepath('index.html', subdir='weird-docs', root=self.root)
    mg_open_url, 'file://' + filename
  endif

  assert, nWarnings eq 1, 'failed without exactly one warning'
  
  return, 1
end


;+
; Define instance variables.
;-
pro docrtweird_ut__define
  compile_opt strictarr
  
  define = { DOCrtWeird_ut, inherits DOCrtTestCase }
end