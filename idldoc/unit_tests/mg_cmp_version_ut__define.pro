;+
; Compares each item in a list of versions to all items in the list.
; 
; @returns 1 for success, 0 for failure
;-
function mg_cmp_version_ut::test
  compile_opt strictarr
  @error_is_fail
  
  versions = ['0.1', '1.0alpha', '1.0beta', '1.0rc1', '1.0rc2', '2.0', $
              '2.0.1', '2.0.2']
  
  for i = 0L, n_elements(versions) - 1L do begin
    for j = 0L, n_elements(versions) - 1L do begin
      result = mg_cmp_version(versions[i], versions[j])
      expectedResult = (i gt j)  $
                         ? 1 $
                         : ((i lt j) ? -1 : 0)
      assert, result eq expectedResult, $
              versions[i] + ', ' + versions[j] + ' should be ' $
              + strtrim(expectedResult, 2) + ', but is ' $
              + strtrim(result, 2)
    endfor
  endfor  
  
  return, 1
end


;+
; Define member variables.
;     
; @file_comments Tests for MG_CMP_VERSION.
;-
pro mg_cmp_version_ut__define
	compile_opt strictarr
	
	define = { mg_cmp_version_ut, inherits MGTestCase }
end