;+
; Compares two version numbers for the more updated number. Returns 0 for 
; equal versions, 1 if version1 is later than version2, and -1 if version1 is 
; less than version2. Each section delimited by .'s is compared as a string.
;     
; @returns -1, 0, or 1    
; @param version1 {in}{required}{type=string}
;        first version number
; @param version2 {in}{required}{type=string}
;        second version number
;- 
function mg_cmp_version, version1, version2
  compile_opt strictarr
  
  v1parts = strsplit(version1, '.', /extract, count=v1len)
  v2parts = strsplit(version2, '.', /extract, count=v2len)
  
  for i = 0L, (v1len < v2len) - 1L do begin
    if (v1parts[i] gt v2parts[i]) then return, 1
    if (v1parts[i] lt v2parts[i]) then return, -1
  endfor
  
  if (v1len gt v2len) then return, 1
  if (v1len lt v2len) then return, -1
  
  return, 0
end