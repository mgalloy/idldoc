pro doctreeproperty::getProperty
  compile_opt strictarr
  
end


pro doctreeproperty::setProperty
  compile_opt strictarr
  
end


function doctreeproperty::getVariable, name, found=found
  compile_opt strictarr

  found = 1B
  case strlowcase(name) of
    'name': return, self.name
    
    'is_get': return, self.isGet
    'is_set': return, self.isSet
    'is_init': return, self.isInit
    
    'has_comments': return, obj_valid(self.comments)
    'comments': return, self.system->processComments(self.comments) 
    
    else: begin
        var = self.file->getVariable(name, found=found)
        if (found) then return, var
        
        found = 0B
        return, -1L    
      end
  endcase
end


pro doctreeproperty::cleanup
  compile_opt strictarr
  
  obj_destroy, self.comments
end


function doctreeproperty::init, system=system
  compile_opt strictarr

  self.system = system
  
  return, 1
end


pro doctreeproperty__define
  compile_opt strictarr
  
  define = { DOCtreeProperty, $
             system: obj_new(), $
             file: obj_new(), $
             
             name: '', $
             isGet: 0B, $
             isSet: 0B, $
             isInit: 0B, $
             
             comments: obj_new() $
           }
end