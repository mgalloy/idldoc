;+
; This is an example of an IDL .pro file to be documented.
;-
pro simple_example
  compile_opt strictarr

  ; example comment
  a = 5  ; this is a comment
  b = '; this is not a comment'   ; but this is a comment
  c = 'Eat at Joes''s'   ; also a comment
  d = "; not a comment"   ; comment
  e = ";';"   ; comment
  f = ';'';";"' + ";';';';"   ; comment
end
