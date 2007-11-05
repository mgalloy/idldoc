; docformat = 'rst'

;+
; Simple run on CONGRID routine from IDL standard library.
;-
function docrtcongrid_ut::test_basic
  compile_opt strictarr

  idldoc, root=filepath('congrid', root=self.root), $
          output=filepath('congrid-docs', root=self.root), $
          title='Testing CONGRID docs in IDL standard library', $
          subtitle='Basic test', $
          format_style='idl', $
          /silent, n_warnings=nWarnings, error=error, $
          log_file=filepath('idldoc.log', subdir='congrid-docs', root=self.root)
          
  assert, error eq 0, 'failed with error ' + !error_state.msg
  assert, nWarnings eq 0, 'failed with warnings'
  
  return, 1
end


;+
; Define instance variables.
;-
pro docrtcongrid_ut__define
  compile_opt strictarr
  
  define = { DOCrtCongrid_ut, inherits DOCrtTestCase }
end
