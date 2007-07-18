;+
; Test the _checkDocformatLine method.
;-
function docparprofileparser_ut::test_checkDocformatLine
  compile_opt strictarr
  
  ; invalid docformat lines
  invalid = ['; just a comment', $
             'docformat = ''idl rst''']
           
  for l = 0L, n_elements(invalid) - 1L do begin
    ;assert, self.parser->_checkDocformatLine(invalid[l]) eq 0B, $
    ;        'accepted invalid docformat line: ' + invalid[l]
  endfor
  
  ; valid docformat lines
  valid = ['; docformat = ''idl rst''', $
           '    ;   DOCformat   =  "idl rst"', $
           '  ; Docformat  = "IDL Rst"' $
          ]    

  for l = 0L, n_elements(valid) - 1L do begin
    format = ''
    markup = ''
    result = self.parser->_checkDocformatLine(valid[l], format=format, markup=markup)
    assert, result eq 1B, $
            'rejected valid docformat line: ' + valid[l]
    assert, format eq 'idl', 'incorrect format on line: ' + valid[l]
    assert, markup eq 'rst', 'incorrect markup on line: ' + valid[l]
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
  
  obj_destroy, file
  
  return, 1
end


;+
; Test for compound_example.pro.
;-
function docparprofileparser_ut::test_compound_example
  compile_opt strictarr
  
  filename = filepath('compound_example.pro', subdir=['unit_tests', 'examples'], $
                      root=self.root)            
  file = self.parser->parse(filename, found=found)
  
  assert, found, 'compound_example.pro not found'
  
  file->getProperty, name=name
  assert, name eq 'compound_example.pro', 'incorrect name of file'
  
  obj_destroy, file
  
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
