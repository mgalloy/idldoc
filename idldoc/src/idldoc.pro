pro idldoc, root=root
  compile_opt strictarr

  cd, current=startDirectory
  
  system = obj_new('DOC_System', root=root)
  
  obj_destroy, system
  cd, startDirectory
end