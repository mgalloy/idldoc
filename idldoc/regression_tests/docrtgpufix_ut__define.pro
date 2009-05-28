; docformat = 'rst'

;+
; Simple run on ADAPT_HIST_EQUAL routine from IDL standard library.
;-
function docrtgpufix_ut::test_basic
  compile_opt strictarr

  idldoc, root=filepath('gpufix', root=self.root), $
          output=filepath('gpufix-docs', root=self.root), $
          title='Testing GPUFIX docs in GPULib library', $
          subtitle='Basic test', $
          /silent, n_warnings=nWarnings, error=error, $
          log_file=filepath('idldoc.log', subdir='gpufix-docs', root=self.root)
          
  assert, error eq 0, 'failed with error ' + !error_state.msg

  if (self.showResults) then begin
    filename = filepath('index.html', subdir='gpufix-docs', root=self.root)
    mg_open_url, 'file://' + filename
  endif
    
  assert, nWarnings eq 0, 'failed with warnings'
  
  return, 1
end


;+
; Define instance variables.
;-
pro docrtgpufix_ut__define
  compile_opt strictarr
  
  define = { DOCrtGpuFix_ut, inherits DOCrtTestCase }
end
