; docformat = 'rst'

;+
; Simple run on ADAPT_HIST_EQUAL routine from IDL standard library.
;-
function docrtadapt_hist_equal_ut::test_basic
  compile_opt strictarr

  mg_heapinfo, n_pointers=nptrsBefore, n_objects=nobjsBefore

  idldoc, root=filepath('adapt_hist_equal', root=self.root), $
          output=filepath('adapt_hist_equal-docs', root=self.root), $
          title='Testing ADAPT_HIST_EQUAL docs in IDL standard library', $
          subtitle='Basic test', $
          format_style='idl', $
          /silent, n_warnings=nWarnings, error=error, $
          log_file=filepath('idldoc.log', subdir='adapt_hist_equal-docs', root=self.root)
          
  assert, error eq 0, 'failed with error ' + !error_state.msg

  if (self.showResults) then begin
    filename = filepath('index.html', subdir='adapt_hist_equal-docs', root=self.root)
    mg_open_url, 'file://' + filename
  endif
    
  assert, nWarnings eq 0, 'failed with warnings'
  
  return, 1
end


;+
; Define instance variables.
;-
pro docrtadapt_hist_equal_ut__define
  compile_opt strictarr
  
  define = { DOCrtAdapt_hist_equal_ut, inherits DOCrtTestCase }
end
