;+
; Test the _stripComments method.
;-
function docparprofiletokenizer_ut::test_stripComments
  compile_opt strictarr
  
  tokenizer = obj_new('DOCparProFileTokenizer', '')
  
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
    code = tokenizer->_stripComments(all[line], empty=empty)
    assert, code eq answer[line], $
            'incorrect code on line ' + strtrim(line, 2) + ': ' + code 
  endfor  
  
  obj_destroy, tokenizer
  
  return, 1
end

;+
; Define instance variables.
;-
pro docparprofiletokenizer_ut__define
  compile_opt strictarr
  
  define = { docparprofiletokenizer_ut, inherits DOCutTestCase }
end