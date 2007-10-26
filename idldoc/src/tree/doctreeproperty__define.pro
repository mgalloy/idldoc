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
pro doctreeproperty::getProperty
  compile_opt strictarr
  
end


;+
; Set properties.
;-
pro doctreeproperty::setProperty, is_get=isGet, is_set=isSet, is_init=isInit, $
                                  comments=comments
  compile_opt strictarr
  
  if (n_elements(isGet) gt 0) then self.isGet = isGet
  if (n_elements(isSet) gt 0) then self.isSet = isSet
  if (n_elements(IsInit) gt 0) then self.IsInit = IsInit
  
  if (n_elements(comments) gt 0) then self.comments = comments      
end


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
;-
function doctreeproperty::isVisible
  compile_opt strictarr
  
  return, self.class->isVisible()
end


;+
; Free up resources.
;-
pro doctreeproperty::cleanup
  compile_opt strictarr
  
  obj_destroy, self.comments
end


;+
; Create a DOCtreeProperty class.
;
; :Returns: 1 if successful, 0 for failure
; :Params:
;    `name` : in, required, type=string
;       name of the property
;
; :Keywords:
;    `class` : in, required, type=object
;       class object
;    `system` : in, required, type=object
;       system object
;-
function doctreeproperty::init, name, class=class, system=system
  compile_opt strictarr

  self.name = name
  self.class = class
  self.system = system
  
  self.system->createIndexEntry, self.name, self
  
  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    `system` 
;       system object
;    `class` 
;       class object that the property is part of
;    `name` 
;       name of the property
;    `isGet` 
;       boolean that indicates whether the property can be retrieved with the 
;       getProperty method
;    `isSet` 
;       boolean that indicates whether the property can be set with the 
;       setProperty method
;    `isInit` 
;       boolean that indicates whether the property can be set on initialization
;    `comments` parse tree object
;-
pro doctreeproperty__define
  compile_opt strictarr
  
  define = { DOCtreeProperty, $
             system: obj_new(), $
             class: obj_new(), $
             
             name: '', $
             isGet: 0B, $
             isSet: 0B, $
             isInit: 0B, $
             
             comments: obj_new() $
           }
end