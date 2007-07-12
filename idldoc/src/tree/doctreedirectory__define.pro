pro doctreedirectory__define
  compile_opt strictarr
  
  define = { DOCtreeDirectory, $
             parent: obj_new(), $
             name: '', $
             location: '', $
             files: obj_new() $
           }
end