;+
; File comments.
;-

;+
; Comments.
;-
pro compound_example_helper, hparam1, hparam2, hkeyword1=hkw
  if 1 then begin & print, 5 & endif  ; end-of-line comment
  ;+
  ; Fake "header".
  ;-
end

;+
; More file comments.
;-

; Fake file comment.

;+
; More comments.
;-
pro compound_example, param1, param2, $
                      keyword1=kw
end
