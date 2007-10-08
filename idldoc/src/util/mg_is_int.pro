function mg_is_int, n
  compile_opt strictarr
  
  ind = where([1, 2, 3, 12, 13, 14, 15] eq size(n, /type), isInt)
  return, isInt
end
