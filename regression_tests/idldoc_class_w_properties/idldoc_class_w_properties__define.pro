; docformat = 'idldoc'

;+
; @property prop {type=long} some property
;-

pro idldoc_class_w_properties::getProperty, prop=prop
  compile_opt strictarr

end


pro idldoc_class_w_properties::setProperty, prop=prop
  compile_opt strictarr

end


function idldoc_class_w_properties::init, prop=prop
  compile_opt strictarr

  return, 1
end


pro idldoc_class_w_properties__define
  compile_opt strictarr
  
  define = { idldoc_class_w_properties, prop: 0L }
end