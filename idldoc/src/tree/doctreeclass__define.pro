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

    'n_children': return, self.children->count()
    'children': return, self.children->get(/all)
    
    'n_fields': return, self.fields->count()
    'fields': return, self.fields->values()
    'field_names': return, self->getFieldNames()
    
    'n_properties': return, self.properties->count()
    'properties': return, self.properties->values()
            
    'index_name': return, self.classname
    'index_type': return, 'class'
    'index_url': return, self->getVariable('url')
    
    else: begin
        ; search in the system object if the variable is not found here
        var = self.proFile->getVariable(name, found=found)
        if (found) then return, var
        
        found = 0B
        return, -1L
      end    
  endcase
end


;+
; Easy to use accessor for classname.
;
; :Returns: string
;-
function doctreeclass::getClassname
  compile_opt strictarr
  
  return, self.classname
end


;+
; Easy to use accessor for whether the class has an URL.
; 
; :Returns: boolean
;-
function doctreeclass::hasUrl
  compile_opt strictarr
  
  return, obj_valid(self.proFile)
end


;+
; Easy to use accessor for URL.
;
; :Returns: string
;-
function doctreeclass::getUrl
  compile_opt strictarr
  
  if (~obj_valid(self.proFile)) then return, ''
  
  self.proFile->getProperty, directory=directory
  dirUrl = directory->getVariable('url')
  proUrl = self.proFile->getVariable('local_url')
  return, dirUrl + proUrl  
end


;+
; Easy to use accessor for number of fields.
;
; :Returns: strarr or string
;-
function doctreeclass::getFieldCount
  compile_opt strictarr
  
  return, self.fields->count()
end


;+
; Easy to use accessor for field names.
;
; :Returns: strarr or string
;-
function doctreeclass::getFieldNames
  compile_opt strictarr
  
  nFields = self.fields->count()
  if (nFields eq 0) then return, ''
  
  fieldNames = strarr(nFields)
  fields = self.fields->values()
  for f = 0L, nFields - 1L do begin
    fields[f]->getProperty, name=name
    fieldNames[f] = name
  endfor
  
  return, fieldNames
end


;+
; Easy to use accessor for field types.
;
; :Returns: strarr or string
;-
function doctreeclass::getFieldTypes
  compile_opt strictarr
  
  nFields = self.fields->count()
  if (nFields eq 0) then return, ''
  
  fieldTypes = strarr(nFields)
  fields = self.fields->values()
  for f = 0L, nFields - 1L do begin
    fields[f]->getProperty, type=type
    fieldTypes[f] = type
  endfor
  
  return, fieldTypes
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


pro doctreeclass::addChild, child
  compile_opt strictarr
  
  self.children->add, child
end


;+
; Classes are visible if their files are visible.
;-
function doctreeclass::isVisible
  compile_opt strictarr
  
  return, obj_valid(self.proFile) ? self.proFile->isVisible() : 1B
end


function doctreeclass::_createClass, classname, error=error
  compile_opt strictarr
  
  error = 0L
  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    error = 1L
    return, -1L
  endif
  
  s = create_struct(name=classname)
  return, s
end


pro doctreeclass::findParents
  compile_opt strictarr
  
  s = self->_createClass(self.classname, error=error)
  if (error ne 0L) then begin
    self.system->warning, 'cannot find definition for class ' + self.classname $
                            + ' in path'
    return
  endif
    
  parents = obj_class(self.classname, /superclass)
  nParents = parents[0] eq '' ? 0 : n_elements(parents)  
  
  parentFieldNameList = obj_new('MGcoArrayList', type=7)
  
  for i = 0L, nParents - 1L do begin
    p = self.classes->get(strlowcase(parents[i]), found=found)
    if (~found) then begin
      p = obj_new('DOCtreeClass', parents[i], system=self.system)
      self.classes->put, strlowcase(parents[i]), p
    endif

    parentFieldNameList->add, p.fields->keys()

    ; connect classes
    p->addChild, self
    self.parents->add, p
    self.ancestors->add, p
    
    p->getProperty, ancestors=ancestors
    if (ancestors->count() gt 0) then begin
      self.ancestors->add, ancestors->get(/all)
    endif
  endfor
  
  parentFieldNames = parentFieldNameList->get(/all, count=nParentFieldNames)
  fieldNames = tag_names(s)

  for f = 0L, n_tags(s) - 1L do begin  
    if (nParentFieldNames ne 0) then begin
      ind = where(strlowcase(fieldNames[f]) eq parentFieldNames, nMatches)
    endif
    if (nParentFieldNames eq 0 || nMatches eq 0) then begin
      field = self->addField(fieldNames[f])
      field->setProperty, type=doc_variable_declaration(s.(f))
    endif
  endfor  
  
  obj_destroy, parentFieldNameList
end


function doctreeclass::addField, fieldName, get_only=getOnly
  compile_opt strictarr
  
  field = self.fields->get(strlowcase(fieldName), found=found)
  if (~found && ~keyword_set(getOnly)) then begin
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


;+
; Free resources.
;-
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
  
  self.system->createIndexEntry, self.classname, self
  
  self.system->getProperty, classes=classes
  self.classes = classes
  self.classes->put, strlowcase(self.classname), self

  self.parents = obj_new('MGcoArrayList', type=11)
  self.ancestors = obj_new('MGcoArrayList', type=11)
  self.children = obj_new('MGcoArrayList', type=11)
  
  self.fields = obj_new('MGcoHashtable', key_type=7, value_type=11)
  self.properties = obj_new('MGcoHashtable', key_type=7, value_type=11)
  
  self->findParents
  
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
             children: obj_new(), $
             
             fields: obj_new(), $
             properties: obj_new() $
           }
end
