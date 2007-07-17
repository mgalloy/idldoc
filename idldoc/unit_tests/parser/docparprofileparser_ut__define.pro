function docparprofileparser_ut::test_stripComments
  compile_opt strictarr
  
  filename = filepath('simple_example.pro', subdir=['unit_tests', 'examples'], $
                      root=self.root)  
                      
  nLines = file_lines(filename)
  all = strarr(nLines)
  openr, lun, filename, /get_lun
  readf, lun, all
  free_lun, lun
  
  answer = [ '', $
             '', $
             '', $
             'pro simple_example', $
             '  compile_opt strictarr', $
             '', $  
             '  ', $
             '  a = 5  ', $
             '  b = ''; this is not a comment''   ', $
             '  c = ''Eat at Joes''''s''   ',$
             '  d = "; not a comment"   ', $
             '  e = ";'';"   ', $
             '  f = '';'''';";"'' + ";'';'';'';"   ', $ 
             'end']
  for line = 0L, nLines - 1L do begin
    code = self.parser->_stripComments(all[line], empty=empty)
    assert, code eq answer[line], $
            'incorrect code on line ' + strtrim(line, 2) + ': ' + code 
  endfor  
  
  return, 1
end


;+
; Test for simple_example.pro.
;-
function docparprofileparser_ut::test_simple_example
  compile_opt strictarr
  
  filename = filepath('simple_example.pro', subdir=['unit_tests', 'examples'], $
                      root=self.root)            
  file = self.parser->parse(filename, found=found)
  
  assert, found, 'simple_example.pro not found'
  
  file->getProperty, name=name
  assert, name eq 'simple_example.pro', 'incorrect name of file'
  
  return, 1
end


;+
; Prepare for each test.
;-
pro docparprofileparser_ut::setup
  compile_opt strictarr
  
  self.parser = obj_new('DOCparProFileParser')  
end


;+
; Cleanup after each test.
;-
pro docparprofileparser_ut::teardown
  compile_opt strictarr
  
  obj_destroy, self.parser
end


;+
; Define instance variables.
;
; :Fields:
;    `parser` parser object
;-
pro docparprofileparser_ut__define
  compile_opt strictarr
  
  define = { docparprofileparser_ut, inherits DOCutTestCase, $
             parser: obj_new() $
           }
end
