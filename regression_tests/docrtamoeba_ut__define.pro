; docformat = 'rst'

;+
; Simple run on AMOEBA routine from IDL standard library.
;-
function docrtamoeba_ut::test_basic
  compile_opt strictarr

  idldoc, root=filepath('amoeba', root=self.root), $
          output=filepath('amoeba-docs', root=self.root), $
          title='Testing AMOEBA docs in IDL standard library', $
          subtitle='Basic test', $
          format_style='idl', $
          /silent, n_warnings=nWarnings, error=error, $
          log_file=filepath('idldoc.log', subdir='amoeba-docs', root=self.root)
          
  assert, error eq 0, 'failed with error ' + !error_state.msg

  if (self.showResults) then begin
    filename = filepath('index.html', subdir='amoeba-docs', root=self.root)
    mg_open_url, 'file://' + filename
  endif
  
  assert, nWarnings eq 0, 'failed with warnings'
  
  return, 1
end


;+
; Define instance variables.
;-
pro docrtamoeba_ut__define
  compile_opt strictarr
  
  define = { DOCrtAmoeba_ut, inherits DOCrtTestCase }
end
