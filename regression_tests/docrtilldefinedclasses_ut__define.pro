; docformat = 'rst'

;+
; Basic IDLdoc run of on class definition file that is not well-defined.
;-
function docrtilldefinedclasses_ut::test_basic
  compile_opt strictarr

  idldoc, root=filepath('illdefinedclasses', root=self.root), $
          output=filepath('illdefinedclasses-docs', root=self.root), $
          title='Testing ill-defined OOP class files', $
          subtitle='Basic test', $
          /silent, n_warnings=nWarnings, error=error, $
          log_file=filepath('idldoc.log', subdir='illdefinedclasses-docs', root=self.root)
          
  assert, error eq 0, 'failed with error ' + !error_state.msg

  if (self.showResults) then begin
    filename = filepath('index.html', subdir='illdefinedclasses-docs', root=self.root)
    mg_open_url, 'file://' + filename
  endif

  assert, nWarnings lt 2 eq 0, 'failed with not enough warnings'
  assert, nWarnings gt 2 eq 0, 'failed with too many warnings'
      
  return, 1
end


;+
; Define instance variables.
;-
pro docrtilldefinedclasses_ut__define
  compile_opt strictarr
  
  define = { DOCrtIllDefinedClasses_ut, inherits DOCrtTestCase }
end