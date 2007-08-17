;+
; Test the _checkDocformatLine method.
;-
function docparprofileparser_ut::test_checkDocformatLine
  compile_opt strictarr
  
  ; invalid docformat lines
  invalid = ['; just a comment', $
             'docformat = ''idl rst''']
           
  for l = 0L, n_elements(invalid) - 1L do begin
    assert, self.parser->_checkDocformatLine(invalid[l]) eq 0B, $
            'accepted invalid docformat line: ' + invalid[l]
  endfor
  
  ; valid docformat lines
  valid = ['; docformat = ''idl rst''', $
           '    ;   DOCformat   =  "idl rst"', $
           '  ; Docformat  = "IDL Rst"' $
          ]    

  for l = 0L, n_elements(valid) - 1L do begin
    format = ''
    markup = ''
    result = self.parser->_checkDocformatLine(valid[l], $
                                              format=format, $
                                              markup=markup)
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
  
  filename = filepath('simple_example.pro', $
                      subdir=['unit_tests', 'examples'], $
                      root=self.root)            
  file = self.parser->parse(filename, found=found)
  
  assert, found, 'simple_example.pro not found'
  
  file->getProperty, name=name
  assert, name eq 'simple_example.pro', 'incorrect name of file'

  file->getProperty, has_main_level=hasMainLevel
  assert, ~hasMainLevel, 'main level found when none exists'

  file->getProperty, is_batch=isBatch
  assert, ~isBatch, 'batch file incorrectly found'
      
  obj_destroy, file
  
  return, 1
end


;+
; Test for compound_example.pro.
;-
function docparprofileparser_ut::test_compound_example
  compile_opt strictarr
  
  filename = filepath('compound_example.pro', $
                      subdir=['unit_tests', 'examples'], $
                      root=self.root)            
  file = self.parser->parse(filename, found=found)
  
  assert, found, 'compound_example.pro not found'
  
  file->getProperty, name=name
  assert, name eq 'compound_example.pro', 'incorrect name of file'

  file->getProperty, has_main_level=hasMainLevel
  assert, ~hasMainLevel, 'main level found when none exists'

  file->getProperty, is_batch=isBatch
  assert, ~isBatch, 'batch file incorrectly found'
      
  file->getProperty, routines=routines
  routine1 = routines->get(position=0)
  routine1->getProperty, name=name
  
  assert, name eq 'compound_example_helper', $
          'incorrect name for compound_example_helper'
          
  routine1->getProperty, parameters=parameters, keywords=keywords
  assert, parameters->count() eq 2, $
          'incorrect number of params for compound_example_helper'
  assert, keywords->count() eq 1, $
          'incorrect number of keywords for compound_example_helper'
  
  paramNames = ['hparam1', 'hparam2']
  for p = 0L, parameters->count() - 1L do begin
    arg = parameters->get(position=p)
    arg->getProperty, name=name
    assert, name eq paramNames[p], $
            'incorrect name "' + name + '" for parameter ' + paramNames[p]
  endfor

  keywordNames = ['hkeyword1']
  for p = 0L, keywords->count() - 1L do begin
    arg = keywords->get(position=p)
    arg->getProperty, name=name
    assert, name eq keywordNames[p], $
            'incorrect name "' + name + '" for keyword ' + keywordNames[p]
  endfor
    
  routine2 = routines->get(position=1)
  routine2->getProperty, name=name

  routine2->getProperty, parameters=parameters, keywords=keywords
  assert, parameters->count() eq 2, $
          'incorrect number of params for compound_example_helper'
  assert, keywords->count() eq 1, $
          'incorrect number of keywords for compound_example_helper'
            
  assert, name eq 'compound_example', 'incorrect name for compound_example'

  paramNames = ['param1', 'param2']
  for p = 0L, parameters->count() - 1L do begin
    arg = parameters->get(position=p)
    arg->getProperty, name=name
    assert, name eq paramNames[p], $
            'incorrect name "' + name + '" for parameter ' + paramNames[p]
  endfor

  keywordNames = ['keyword1']
  for p = 0L, keywords->count() - 1L do begin
    arg = keywords->get(position=p)
    arg->getProperty, name=name
    assert, name eq keywordNames[p], $
            'incorrect name "' + name + '" for keyword ' + keywordNames[p]
  endfor
              
  obj_destroy, file
  
  return, 1
end


;+
; Test for main_level_example.pro.
;-
function docparprofileparser_ut::test_main_level_example
  compile_opt strictarr
  
  filename = filepath('main_level_example.pro', $
                      subdir=['unit_tests', 'examples'], $
                      root=self.root)            
  file = self.parser->parse(filename, found=found)
  
  assert, found, 'main_level_example.pro not found'
  
  file->getProperty, name=name
  assert, name eq 'main_level_example.pro', 'incorrect name of file'
  
  file->getProperty, has_main_level=hasMainLevel
  assert, hasMainLevel, 'main level not found'

  file->getProperty, is_batch=isBatch
  assert, ~isBatch, 'batch file incorrectly found'
    
  obj_destroy, file
  
  return, 1
end


;+
; Test for batch_example.pro.
;-
function docparprofileparser_ut::test_batch_example
  compile_opt strictarr
  
  filename = filepath('batch_example.pro', $
                      subdir=['unit_tests', 'examples'], $
                      root=self.root)            
  file = self.parser->parse(filename, found=found)
  
  assert, found, 'batch_example.pro not found'
  
  file->getProperty, name=name
  assert, name eq 'batch_example.pro', 'incorrect name of file'
  
  file->getProperty, has_main_level=hasMainLevel
  assert, ~hasMainLevel, 'main level found when none exists'
  
  file->getProperty, is_batch=isBatch
  assert, isBatch, 'batch file not recognized'
  
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
