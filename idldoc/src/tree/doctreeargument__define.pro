; docformat = 'rst'

;+
; Argument class representing a positional parameter or keyword for a routine. 
; 
; :Properties:
;    `routine` : get, type=object
;       DOCtreeRoutine object that contains this argument
;    `name` : init, get, type=string
;       name of the routine
;    `is_first` : get, set, type=boolean
;       set to indicate that this argument is the first of its parent routine
;    `is_keyword` : init, get, set, type=boolean
;       set to indicate that this argument is a keyword
;    `is_optional` : get, set, type=boolean
;       set to indicate that this argument is optional
;    `is_required` : get, set, type=boolean
;       set to indicate that this argument is required
;    `is_input` : get, set, type=boolean
;       set to indicate that this argument is an input
;    `is_output` : get, set, type=boolean
;       set to indicate that this arugment is an output
;    `type` : get, set, type=string
;       string indicating the IDL variable type of the argument
;    `default_value` : get, set, type=string
;       string indicating the default value if this argument is not present
;    `is_hidden` : get, set, type=boolean
;       set to indicate that this argument is hidden (hidden from users and
;       developers)
;    `is_private` : get, set, type=boolean
;       set to indicate that this argument is private (hidden from users)
;    `comments` : get, set, type=strarr
;       text node hierarchy
;-

;+
; The getVariable method is required for objects passed as an input to a
; template.
;
; :Returns: value or -1L if variable name not found
;
; :Params:
;    `name` : in, required, type=string
;       name of variable (case insensitive)
; 
; :Keywords: 
;    `found` : out, optional, type=boolean
;       pass a named variable to get whether the variable was found
;-
function doctreeargument::getVariable, name, found=found
  compile_opt strictarr
  on_error, 2
  
  ; make sure name is present, a string, and only 1 element
  if (n_elements(name) ne 1 || size(name, /type) ne 7) then begin
    message, 'name parameter invalid'
  endif
  
  ; return value if name is ok
  found = 1B
  case name of
    'name': return, self.name
    
    'iskeyword' : return, self.isKeyword
    'isoptional': return, self.isOptional
    'isrequired': return, self.isRequired
    'isinput': return, self.isInput
    'isoutput': return, self.isOutput
    'type': return, self.type
    'isboolean': return, strlowcase(self.type) eq 'boolean'
    'defaultvalue': return, self.defaultValue
    'ishidden': return, self.isHidden
    'isprivate': return, self.isPrivate
    
    'prefix': begin
      self.routine->getProperty, is_function=isFunction
      return, (isFunction && self.isFirst) ? '' : ', '
    end
    'suffix': begin
      self.routine->getProperty, is_function=isFunction
      return, (isFunction && self.isLast) ? '' : ''
    end
    
    'comments': begin
        if (~obj_valid(self.comments)) then return, ''
        
        self.system->getProperty, comment_style=commentStyle
        commentParser = self.system->getParser(commentStyle + 'output')
        return, commentParser->process(self.comments)        
      end 
    else : begin
      found = 0B
      return, -1L
    end
  endcase
end


;+
; Set properties of the argument.
;-
pro doctreeargument::getProperty, routine=routine, name=name, $
    is_first=isFirst, is_last=isLast, is_keyword=isKeyword, is_optional=isOptional, $
    is_required=isRequired, is_input=isInput, is_output=isOutput, $
    type=type, default_value=defaultValue, is_hidden=isHidden, $
    is_private=isPrivate, comments=comments  
  compile_opt strictarr
  
  if (arg_present(routine)) then routine = self.routine
  if (arg_present(name)) then name = self.name
  if (arg_present(isFirst)) then isFirst = self.isFirst  
  if (arg_present(isLast)) then isLast = self.isLast  
  if (arg_present(isKeyword)) then isKeyword = self.isKeyword  
  if (arg_present(isOptional)) then isOptional = self.isOptional    
  if (arg_present(isRequired)) then isRequired = self.isRequired      
  if (arg_present(isInput)) then isInput = self.isInput    
  if (arg_present(isOutput)) then isOutput = self.isOutput      
  if (arg_present(type)) then type = self.type      
  if (arg_present(defaultValue)) then defaultValue = self.defaultValue      
  if (arg_present(isHidden)) then isHidden = self.isHidden      
  if (arg_present(isPrivate)) then isPrivate = self.isPrivate      
  if (arg_present(comments)) then comments = self.comments
end


;+
; Set properties of the argument.
;-
pro doctreeargument::setProperty, is_keyword=isKeyword, $
                                  is_first=isFirst, is_last=isLast, $
                                  is_optional=isOptional, $
                                  is_required=isRequired, $
                                  is_input=isInput, $
                                  is_output=isOutput, $
                                  type=type, $
                                  default_value=defaultValue, $
                                  is_hidden=isHidden, $
                                  is_private=isPrivate, $
                                  comments=comments
  compile_opt strictarr
  
  if (n_elements(isFirst) gt 0) then self.isFirst = isFirst
  if (n_elements(isLast) gt 0) then self.isLast = isLast  
  if (n_elements(isKeyword) gt 0) then self.isKeyword = isKeyword
  if (n_elements(isOptional) gt 0) then self.isOptional = isOptional
  if (n_elements(isRequired) gt 0) then self.isRequired = isRequired
  if (n_elements(isInput) gt 0) then self.isInput = isInput
  if (n_elements(isOutput) gt 0) then self.isOutput = isOutput
  if (n_elements(type) gt 0) then self.type = type
  if (n_elements(defaultValue) gt 0) then self.defaultValue = defaultValue
  if (n_elements(isHidden) gt 0) then self.isHidden = isHidden
  if (n_elements(isPrivate) gt 0) then self.isPrivate = isPrivate
  if (n_elements(comments) gt 0) then self.comments = comments
end


;+
; Free resources lower in the hierarchy.
;-
pro doctreeargument::cleanup
  compile_opt strictarr
  
  obj_destroy, self.comments
end


;+
; Create an argument: positional parameter or keyword.
; 
; :Returns: 1 for success, 0 for failure
; :Params: 
;    `routine` : in, required, type=object
;       DOCtreeRoutine object
;-
function doctreeargument::init, routine, name=name, is_keyword=isKeyword, $
                                system=system
  compile_opt strictarr
  
  self.system = system
  self.routine = routine
  if (n_elements(name) gt 0) then self.name = name
  self.isKeyword = keyword_set(isKeyword)
  
  return, 1
end


;+
; Define the instance variables.
;
; :Fields:
;    `routine` DOCtreeRoutine object that contains this argument
;    `name` name of the argument
;    `isFirst` indicates that this argument is the first of its parent routine
;    `isLast` indicates that this argument is the first of its parent routine
;    `isKeyword` indicates that this argument is a keyword
;    `isOptional` indicates that this argument is optional
;    `isRequired` indicates that this argument is required
;    `isInput` indicates that this argument is an input
;    `isOutput` indicates that this arugment is an output
;    `type` string indicating the IDL variable type of the argument
;    `defaultValue` string indicating the default value if this argument is 
;       not present
;    `isHidden` indicates that this argument is hidden (hidden from users and
;       developers)
;    `isPrivate` indicates that this argument is private (hidden from users)
;    `comments` text node hierarchy
;-
pro doctreeargument__define
  compile_opt strictarr
  
  define = { DOCtreeArgument, $
             system: obj_new(), $
             routine: obj_new(), $
             name: '', $
             isFirst: 0B, $
             isLast: 0B, $
             isKeyword: 0B, $
             isOptional: 0B, $
             isRequired: 0B, $
             isInput: 0B, $
             isOutput: 0B, $
             type: '', $
             defaultValue: '', $
             isHidden: 0B, $
             isPrivate: 0B, $
             comments: obj_new() $
           }
end