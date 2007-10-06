
;+
; Dispatches data to proper helper routine to produce a simple thumbnail
; visualization of the data and returns the result as a true color image.
;
; :Returns: bytarr(3, m,n ) or -1L
; :Params:
;    `data` : in, required, type=numeric array
;
; :Keywords:
;    `valid` : out, optional, type=boolean
;       set to a named variable to get status of visualization; if no valid 
;       visualization type could be found, -1L is returned
;-
function doc_thumbnail, data, 
  compile_opt strictarr
  
end
