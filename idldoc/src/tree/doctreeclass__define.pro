; docformat = 'rst'

pro doctreeclass::setProperty, pro_file=proFile
  compile_opt strictarr
  
  if (n_elements(proFile) gt 0) then self.proFile = proFile
end


pro doctreeclass::cleanup
  compile_opt strictarr

  obj_destroy, self.fields
end


pro doctreeclass::findParents
  compile_opt strictarr
  
  ; TODO: use OBJ_CLASS(/SUPERCLASS) to find parents, ancestors
end


pro doctreeclass::findFields
  compile_opt strictarr
  
  ; TODO: create structure to find fields (and then run them past ancestors)
end


function doctreeclass::init, name, pro_file=proFile, system=system
  compile_opt strictarr
  
  self.name = name
  
  if (n_elements(proFile) gt 0) then self.proFile = proFile

  self.system->getProperty, classes=classes
  self.classes = classes
  self.classes->put, strlowcase(name), self
  
  self->findParents
  self->findFields
  
  return, 1
end


pro doctreeclass__define
  compile_opt strictarr
  
  define = { DOCtreeClass, $
             system: obj_new(), $
             classes: obj_new(), $
             proFile: obj_new(), $
             
             name: '', $
             
             parents: obj_new(), $
             ancestors: obj_new(), $
             fields: obj_new() $
           }
end
