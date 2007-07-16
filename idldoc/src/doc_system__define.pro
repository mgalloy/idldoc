function doc_system::init, root=root
end


pro doc_system__define
  compile_opt strictarr
  
  define = { DOC_Main, $
             root: '' $
           }
end