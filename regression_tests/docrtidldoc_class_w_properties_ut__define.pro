; docformat = 'rst'

;+
; Basic IDLdoc run of on save files.
;-
function docrtidldoc_class_w_properties_ut::test_basic
  compile_opt strictarr

  idldoc, root=filepath('idldoc_class_w_properties', root=self.root), $
          output=filepath('idldoc_class_w_properties-docs', root=self.root), $
          title='Testing idldoc classes with properties', $
          subtitle='Basic test', $
          /silent, n_warnings=nWarnings, error=error, $
          log_file=filepath('idldoc.log', subdir='idldoc_class_w_properties-docs', root=self.root)
          
  assert, error eq 0, 'failed with error ' + !error_state.msg

  if (self.showResults) then begin
    filename = filepath('index.html', subdir='idldoc_class_w_properties-docs', root=self.root)
    mg_open_url, 'file://' + filename
  endif
    
  assert, nWarnings eq 0, 'failed with warnings'
  
  return, 1
end


;+
; Define instance variables.
;-
pro docrtidldoc_class_w_properties_ut__define
  compile_opt strictarr
  
  define = { DOCrtIDLdoc_class_w_properties_ut, inherits DOCrtTestCase }
end