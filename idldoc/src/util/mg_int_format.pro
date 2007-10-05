function mg_int_format, n
  compile_opt strictarr
  
  v = strtrim(n, 2)
  npad = 3 - strlen(v) mod 3
  if (npad lt 3) then v = strjoin(replicate(' ', npad)) + v
  v = reform(byte(v), 3, strlen(v) / 3)
  v = string(v)
  return, strtrim(strjoin(v, ','), 2)
end
