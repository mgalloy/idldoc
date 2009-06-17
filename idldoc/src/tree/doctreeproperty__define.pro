; docformat = 'rst'

;+
; Properties represent keywords to the setProperty/getProperty/init set of
; methods.
;
; :Properties:
;    is_get 
;       boolean indicating whether the property can be retrieved with the 
;       getProprty method
;    is_set 
;       boolean indicating whether the property can be set with the setProperty
;       method
;    is_init
;       boolean indicating whether the property can be set in the init method
;    type
;       IDL data type of the property
;    comments
;       parse tree object; comments about the property
;    class 
;       class object
;    system
;       system object
;-


;+
; Retrieve properties.
;-
pro doctreeproperty::getProperty, is_get=isGet, is_set=isSet, is_init=isInit, $
                                  comments=comments, name=name, type=type
  compile_opt strictarr, hidden
  
  if (arg_present(isGet)) then isGet = self.isGet
  if (arg_present(isSet)) then isSet = self.isSet
  if (arg_present(isInit)) then isInit = self.isInit
  if (arg_present(type)) then type = self.type
  if (arg_present(comments)) then comments = self.comments
  if (arg_present(name)) then name = self.name
end


;+
; Set properties.
;-
pro doctreeproperty::setProperty, is_get=isGet, is_set=isSet, is_init=isInit, $
                                  comments=comments, class=class, type=type
  compile_opt strictarr, hidden
  
  if (n_elements(isGet) gt 0) then self.isGet = isGet
  if (n_elements(isSet) gt 0) then self.isSet = isSet
  if (n_elements(IsInit) gt 0) then self.IsInit = IsInit
  
  if (n_elements(type) gt 0) then self.type = type
  
  if (n_elements(comments) gt 0) then begin
    if (obj_valid(self.comments)) then begin
      parent = obj_new('MGtmTag')
      parent->addChild, self.comments
      parent->addChild, comments
      self.comments = parent
    endif else self.comments = comments
  endif

  if (n_elements(class) gt 0) then self.class = class      
end


;+
; Get variables for use with templates.
;
; :Returns: 
;    variable
;
; :Params:
;    name : in, required, type=string
;       name of variable
;
; :Keywords:
;    found : out, optional, type=boolean
;       set to a named variable, returns if variable name was found
;-
function doctreeproperty::getVariable, name, found=found
  compile_opt strictarr, hidden

  found = 1B
  case strlowcase(name) of
    'name': return, self.name
    
    'is_get': return, self.isGet
    'is_set': return, self.isSet
    'is_init': return, self.isInit
    
    'has_type': return, self.type ne ''
    'type': return, self.type
     
    'has_comments': return, obj_valid(self.comments)
    'comments': return, self.system->processComments(self.comments)
     
    'index_name': return, self.name
    'index_type': begin
        self.class->getProperty, classname=classname
        return, 'property in class ' + classname
      end
        
    else: begin
        var = self.class->getVariable(name, found=found)
        if (found) then return, var
        
        found = 0B
        return, -1L    
      end
  endcase
end


;+
; Properties are visible if their class is visible.
;
; :Returns: 
;    1 if visible, 0 if not visible
;-
function doctreeproperty::isVisible
  compile_opt strictarr, hidden
  
  return, obj_valid(self.class) ? self.class->isVisible() : 0B
end


;+
; Free up resources.
;-
pro doctreeproperty::cleanup
  compile_opt strictarr, hidden

  obj_destroy, self.comments
end


;+
; Create a DOCtreeProperty class.
;
; :Returns: 
;    1 if successful, 0 for failure
;    
; :Params:
;    name : in, required, type=string
;       name of the property
;
; :Keywords:
;    system : in, required, type=object
;       system object
;-
function doctreeproperty::init, name, system=system
  compile_opt strictarr, hidden

  self.name = name
  self.system = system

  self.system->getProperty, index_level=indexLevel
  if (indexLevel ge 2L) then self.system->createIndexEntry, self.name, self
  
  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    system
;       system object
;    class
;       class object that the property is part of
;    name
;       name of the property
;    isGet
;       boolean that indicates whether the property can be retrieved with the 
;       getProperty method
;    isSet
;       boolean that indicates whether the property can be set with the 
;       setProperty method
;    isInit
;       boolean that indicates whether the property can be set on initialization
;    comments
;       parse tree object
;-
pro doctreeproperty__define
  compile_opt strictarr, hidden
  
  define = { DOCtreeProperty, $
             system: obj_new(), $
             class: obj_new(), $
             
             name: '', $
             isGet: 0B, $
             isSet: 0B, $
             isInit: 0B, $
             
             type: '', $
             comments: obj_new() $
           }
end