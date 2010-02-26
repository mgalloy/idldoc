;+
; Stuff
;
; @Param File {in}{required}{type=string} stuff
; @Param Comments {in}{required}{type=string} stuff
; @Keyword Compressed {in}{optional}{type=boolean}{default=0} stuff
; @Keyword Keywords {in}{optional}{type=string}{default="Comment"} stuff
; @Author stuff
; @History stuff
;-
Pro AddPNGComments, File, Comments, $
   Compressed = Compressed, $
   Keywords = Keywords_Local

end
