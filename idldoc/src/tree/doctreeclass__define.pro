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
    'n_ancestors': return, self.ancestors->count()
    'ancestors': return, self.ancestors->get(/all)
    else: begin
        ; search in the system object if the variable is not found here
        var = self.proFile->getVariable(name, found=found)
        if (found) then return, var
        
        found = 0B
        return, -1L
      end    
  endcase
end

  
pro doctreeclass::setProperty, pro_file=proFile
  compile_opt strictarr
  
  if (n_elements(proFile) gt 0) then self.proFile = proFile
end


pro doctreeclass::getProperty, ancestors=ancestors
  compile_opt strictarr

  if (arg_present(ancestors)) then ancestors = self.ancestors
end


pro doctreeclass::cleanup
  compile_opt strictarr

  obj_destroy, self.fields
end


pro doctreeclass::findParents
  compile_opt strictarr
  
  parents = obj_class(self.classname, /superclass)
  if (n_elements(parents) eq 1 && parents eq '') then return
  
  for i = 0L, n_elements(parents) - 1L do begin
    p = self.classes->get(parents[i], found=found)
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


pro doctreeclass::findFields
  compile_opt strictarr
  
  ; TODO: create structure to find fields (and then run them past ancestors)
end


function doctreeclass::init, classname, pro_file=proFile, system=system
  compile_opt strictarr
  
  self.classname = classname
  if (n_elements(proFile) gt 0) then self.proFile = proFile
  self.system = system
  
  self.system->getProperty, classes=classes
  self.classes = classes
  ; TODO: what if you're already in there?
  self.classes->put, strlowcase(self.classname), self
  
  self.parents = obj_new('MGcoArrayList', type=11)
  self.ancestors = obj_new('MGcoArrayList', type=11)
  
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
             fields: obj_new() $
           }
end
