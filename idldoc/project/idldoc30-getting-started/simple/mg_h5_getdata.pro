function mg_h5_getdata_convertbounds, sbounds, dimensions=dimensions
  compile_opt strictarr
  on_error, 2
  
  dimIndices = strsplit(sbounds, ', ', /extract, count=ndims)
  result = lonarr(ndims, 3)
  
  for d = 0L, ndims - 1L do begin
    args = strsplit(dimIndices[d], ':', /extract, count=nargs)
    case nargs of
      1 : begin
          if (args[0] eq '*') then begin
            result[d, *] = [0, dimensions[d] - 1L, 1L]
          endif else begin
            result[d, *] = [long(args[0]), long(args[0]), 1L]
          endelse
        end
      2 : begin
          if (args[1] eq '*') then begin
            result[d, *] = [long(args[0]), dimensions[d] - 1L, 1L]
          endif else begin
            result[d, *] = [long(args[0]), long(args[1]), 1L]
          endelse          
        end
      3 : begin
          if (args[1] eq '*') then begin
            result[d, *] = [long(args[0]), dimensions[d] - 1L, long(args[2])]
          endif else begin
            result[d, *] = long(args)
          endelse        
        end
      else: message, 'invalid array indexing notation'
    endcase
  endfor
  
  return, result
end


pro mg_h5_getdata_computeslab, bounds, $
                               start=start, count=count, $
                               block=block, stride=stride, $
                               result_dims=resultDims
  compile_opt strictarr
  
  ndims = (size(bounds, /dimensions))[0]
  
  start = reform(bounds[*, 0])
  stride = reform(bounds[*, 2])
    
  count = ceil((bounds[*, 1] - bounds[*, 0] + 1L) / float(bounds[*, 2])) > 1
  block = lonarr(ndims) + 1L
end


function mg_h5_getdata, filename, variable, bounds=bounds
  compile_opt strictarr
  on_error, 2
  
  fileId = h5f_open(filename)
  variableId = h5d_open(fileId, variable)
  variableSpace = h5d_get_space(variableId)
  
  fullBounds = h5s_get_select_bounds(variableSpace)
  sz = size(fullBounds, /dimensions)
  fullBounds = [[fullBounds], [lonarr(sz[0]) + 1L]]
  dimensions = reform(fullBounds[*, 1] - fullBounds[*, 0] + 1L)
  
  case size(bounds, /type) of
    0 : myBounds = fullBounds
    7 : myBounds = mg_h5_getdata_convertbounds(bounds, dimensions=dimensions)
    else: myBounds = transpose(bounds)
  endcase

  mg_h5_getdata_computeslab, myBounds, $
                             start=start, count=count, $
                             block=block, stride=stride
                                
  resultSpace = h5s_create_simple(count)
  
  h5s_select_hyperslab, variableSpace, start, count, $
                        block=block, stride=stride, /reset
  
  data = h5d_read(variableId, $
                  file_space=variableSpace, $
                  memory_space=resultSpace)
  
  h5s_close, resultSpace
  h5s_close, variableSpace
  h5d_close, variableId
  h5f_close, fileId    
  
  return, data
end


f = filepath('hdf5_test.h5', subdir=['examples', 'data'])

; full result is lonarr(10, 50, 100)
fullResult = mg_h5_getdata(f, '/arrays/3D int array')

; pull out a slice of the full result
bounds = [[3, 3, 1], [5, 49, 2], [0, 49, 3]]
result1 = mg_h5_getdata(f, '/arrays/3D int array', bounds=bounds)
help, result1

; compare indexing into fullResult versus slice pulled out 
same = array_equal(fullResult[3, 5:*:2, 0:49:3], result1)
print, same ? 'equal' : 'error'

; specify the same bounds with a string
result2 = mg_h5_getdata(f, '/arrays/3D int array', bounds='3, 5:*:2, 0:49:3')
print, array_equal(result1, result2) ? 'equal' : 'error'

end