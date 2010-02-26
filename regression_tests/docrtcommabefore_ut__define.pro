; docformat = 'rst'

;+
; Basic IDLdoc run on a routine with a header on several lines with commas on
; the beginning of the line instead of before the $ at the end.
;-
function docrtcommabefore_ut::test_basic
  compile_opt strictarr

  idldoc, root=filepath('commabefore', root=self.root), $
          output=filepath('commabefore-docs', root=self.root), $
          title='Testing parser on headers with commas at beginning of line', $
          subtitle='Basic test', $
          /silent, n_warnings=nWarnings, error=error, $
          log_file=filepath('idldoc.log', subdir='commabefore-docs', root=self.root)
          
  assert, error eq 0, 'failed with error ' + !error_state.msg

  if (self.showResults) then begin
    filename = filepath('index.html', subdir='commabefore-docs', root=self.root)
    mg_open_url, 'file://' + filename
  endif

  assert, nWarnings eq 0, 'failed with warnings'
  
  return, 1
end


;+
; Define instance variables.
;-
pro docrtcommabefore_ut__define
  compile_opt strictarr
  
  define = { DOCrtCommaBefore_ut, inherits DOCrtTestCase }
end