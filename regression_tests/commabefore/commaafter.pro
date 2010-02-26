;+
; test for continuation lines
; comma before $
;
; @param param1 param1 docs
; @param param2 param2 docs
; @param param3 param3 docs
;-
pro commabefore, param1, $
                param2, $
                param3
end

;+
; test for continuation lines
; comma after $ (on the following line)
;
; @param param1 param1 docs
; @param param2 param2 docs
; @param param3 param3 docs
;
; idldoc3b0.3 :
; IDLDOC: param param1 not found in commaafter
; IDLDOC: param param2 not found in commaafter
;
;-
pro commaafter, param1 $
             , param2 $
             , param3
end
