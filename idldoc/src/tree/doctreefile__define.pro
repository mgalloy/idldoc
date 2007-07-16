pro doctreefile__define
  compile_opt strictarr
  
  define = { DOCtreeFile, $
             directory: obj_new(), $
             name: '', $
             hasMainLevel: 0B, $
             isBatch: 0B, $
             routines: obj_new() $
           }
end