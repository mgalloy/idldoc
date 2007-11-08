; docformat = 'rst'

;+
; Simple run on ADAPT_HIST_EQUAL routine from IDL standard library.
;-
function docrtadapt_hist_equal_ut::test_basic
  compile_opt strictarr

  idldoc, root=filepath('adapt_hist_equal', root=self.root), $
          output=filepath('adapt_hist_equal-docs', root=self.root), $
          title='Testing ADAPT_HIST_EQUAL docs in IDL standard library', $
          subtitle='Basic test', $
          format_style='idl', $
          n_warnings=nWarnings, error=error, $
          log_file=filepath('idldoc.log', subdir='adapt_hist_equal-docs', root=self.root)
          
  assert, error eq 0, 'failed with error ' + !error_state.msg
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
