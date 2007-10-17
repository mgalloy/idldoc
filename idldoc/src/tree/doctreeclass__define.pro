; docformat = 'rst'

;+
; Get variables for use with templates.
;
; :Returns: variable
; :Params:
;    `name` : in, required, type=string
;       name of variable
;
; :Keywords:
;    `found` : out, optional, type=boolean
;       set to a named variable, returns if variable name was found
;-
function doctreeclass::getVariable, name, found=found
  compile_opt strictarr
  
  found = 1B
  case strlowcase(name) of
    'classname': return, self.classname
    'url': begin
        if (~obj_valid(self.proFile)) then return, ''
        
        self.proFile->getProperty, directory=directory
        dirUrl = directory->getVariable('url')
        proUrl = self.proFile->getVariable('local_url')
        return, dirUrl + proUrl
      end
      
    'n_parents': return, self.parents->count()
    'parents': return, self.parents->get(/all)
          
    'n_ancestors': return, self.ancestors->count()
    'ancestors': return, self.ancestors->get(/all)

    'n_fields': return, self.fields->count()
    'fields': return, self.fields->values()

    'n_properties': return, self.properties->count()
    'properties': return, self.properties->values()
            
    else: begin
        ; search in the system object if the variable is not found here
        var = self.proFile->getVariable(name, found=found)
        if (found) then return, var
        
        found = 0B
        return, -1L
      end    
  endcase
end

function doctreeclass::getClassname
  compile_opt strictarr
  
  return, self.classname
end


function doctreeclass::hasUrl
  compile_opt strictarr
  
  return, obj_valid(self.proFile)
end


function doctreeclass::getUrl
  compile_opt strictarr
  
  if (~obj_valid(self.proFile)) then return, ''
  
  self.proFile->getProperty, directory=directory
  dirUrl = directory->getVariable('url')
  proUrl = self.proFile->getVariable('local_url')
  return, dirUrl + proUrl  
end


pro doctreeclass::setProperty, pro_file=proFile, classname=classname
  compile_opt strictarr
  
  if (n_elements(proFile) gt 0) then self.proFile = proFile
  if (n_elements(classname) gt 0) then self.classname = classname
end


pro doctreeclass::getProperty, ancestors=ancestors, classname=classname
  compile_opt strictarr

  if (arg_present(ancestors)) then ancestors = self.ancestors
  if (arg_present(classname)) then classname = self.classname
end


pro doctreeclass::cleanup
  compile_opt strictarr

  obj_destroy, self.fields
end


pro doctreeclass::findParents
  compile_opt strictarr
  
  s = create_struct(name=self.classname)
  parents = obj_class(self.classname, /superclass)
  if (n_elements(parents) eq 1 && parents eq '') then return
  
  for i = 0L, n_elements(parents) - 1L do begin
    p = self.classes->get(strlowcase(parents[i]), found=found)
    if (~found) then begin
      p = obj_new('DOCtreeClass', parents[i], system=self.system)
      self.classes->put, strlowcase(parents[i]), p
    endif
    
    self.parents->add, p
    self.ancestors->add, p
    
    p->getProperty, ancestors=ancestors
    if (ancestors->count() gt 0) then begin
      self.ancestors->add, ancestors->get(/all)
    endif
  endfor
end


function doctreeclass::addField, fieldName
  compile_opt strictarr
  
  field = self.fields->get(strlowcase(fieldName), found=found)
  if (~found) then begin
    field = obj_new('DOCtreeField', fieldName, $
                    class=self, system=self.system)
    self.fields->put, strlowcase(fieldName), field
  endif
  return, field
end


function doctreeclass::addProperty, propertyName
  compile_opt strictarr
  
  property = self.properties->get(strlowcase(propertyName), found=found)
  if (~found) then begin
    property = obj_new('DOCtreeProperty', propertyName, $
                       class=self, system=self.system)
    self.properties->put, strlowcase(propertyName), property
  endif
  return, property
end


pro doctreeclass::findFields
  compile_opt strictarr
  
  ; TODO: create structure to find fields (and then run them past ancestors)
end


pro doctreeclass::cleanup
  compile_opt strictarr
  
  if (self.fields->count() gt 0) then obj_destroy, self.fields->values()
  obj_destroy, self.fields
  if (self.properties->count() gt 0) then obj_destroy, self.properties->values()
  obj_destroy, self.properties
end


function doctreeclass::init, classname, pro_file=proFile, system=system
  compile_opt strictarr
  
  self.classname = classname
  if (n_elements(proFile) gt 0) then self.proFile = proFile
  self.system = system
  
  self.system->getProperty, classes=classes
  self.classes = classes
  self.classes->put, strlowcase(self.classname), self

  self.parents = obj_new('MGcoArrayList', type=11)
  self.ancestors = obj_new('MGcoArrayList', type=11)
  
  self.fields = obj_new('MGcoHashtable', key_type=7, value_type=11)
  self.properties = obj_new('MGcoHashtable', key_type=7, value_type=11)
  
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
             
             classname: '', $
             
             parents: obj_new(), $
             ancestors: obj_new(), $
             fields: obj_new(), $
             properties: obj_new() $
           }
end
