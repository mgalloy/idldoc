; docformat = 'rst'

;+
; :Properties:
;    `file` : get, type=object
;       file tree object
;    `name` : set, get, type=string
;       name of the routine
;    `is_function` : get, set, type=boolean
;       1 if a function, 0 if not 
;    `is_method` : get, set, type=boolean
;       1 if a method, 0 if not
;    `parameters` : get, type=object
;       list object of positional parameter objects for routine
;    `keywords` : get, type=object
;       list object of keyword objects for routine
;-

;+
; Get properties.
;-
pro doctreeroutine::getProperty, file=file, name=name, is_function=isFunction, $
                                 is_method=isMethod, parameters=parameters, $
                                 keywords=keywords
  compile_opt strictarr
  
  if (arg_present(file)) then file = self.file
  if (arg_present(name)) then name = self.name
  if (arg_present(isFunction)) then isFunction = self.isFunction
  if (arg_present(isMethod)) then isMethod = self.isMethod
  if (arg_present(parameters)) then parameters = self.parameters
  if (arg_present(keywords)) then keywords = self.keywords
end


;+
; Set properties.
;-
pro doctreeroutine::setProperty, name=name, $
                                 is_Function=isFunction, $
                                 is_method=isMethod, $
                                 is_abstract=isAbstract, $
                                 is_hidden=isHidden, $
                                 is_private=isPrivate, $
                                 comments=comments, $
                                 returns=returns, $
                                 examples=examples, $
                                 bugs=bugs, pre=pre, post=post, $
                                 author=author, copyright=copyright, history=history
  compile_opt strictarr
  
  if (n_elements(name) gt 0) then self.name = name
  
  if (n_elements(isFunction) gt 0) then self.isFunction = isFunction
  if (n_elements(isMethod) gt 0) then self.isMethod = isMethod
  if (n_elements(isAbstract) gt 0) then self.isAbstract = isAbstract
  if (n_elements(isHidden) gt 0) then self.isHidden = isHidden
  if (n_elements(isPrivate) gt 0) then self.isPrivate = isPrivate
  
  if (n_elements(comments) gt 0) then self.comments = comments
  if (n_elements(returns) gt 0) then self.returns = returns  
  if (n_elements(examples) gt 0) then self.examples = examples
  
  ; "author info" attributes
  if (n_elements(author) gt 0) then begin
    self.hasAuthorInfo = 1B
    self.author = author
  endif

  if (n_elements(copyright) gt 0) then begin
    self.hasAuthorInfo = 1B
    self.copyright = copyright
  endif
  
  if (n_elements(history) gt 0) then begin
    self.hasAuthorInfo = 1B
    self.history = history
  endif
  
  ; "other" attributes
  if (n_elements(bugs) gt 0) then begin
    self.hasOthers = 1B
    self.bugs = bugs
  endif  
  
  if (n_elements(pre) gt 0) then begin
    self.hasOthers = 1B
    self.pre = pre
  endif 
  
  if (n_elements(post) gt 0) then begin
    self.hasOthers = 1B
    self.post = post
  endif     
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
function doctreeroutine::getVariable, name, found=found
  compile_opt strictarr
  
  found = 1B
  case strlowcase(name) of
    'name': return, self.name

    'is_function': return, self.isFunction
    
    'has_comments': return, obj_valid(self.comments)
    'comments': return, self.system->processComments(self.comments)
    'comments_first_line': begin
        if (~obj_valid(self.comments)) then return, ''
        
        comments = self.system->processComments(self.comments) 
        
        nLines = n_elements(comments)
        line = 0
        while (line lt nLines) do begin
          pos = stregex(comments[line], '\.( |$)')
          if (pos ne -1) then break
          line++
        endwhile  
        
        if (pos eq -1) then return, comments[0:line-1]
        if (line eq 0) then return, strmid(comments[line], 0, pos + 1)
        
        return, [comments[0:line-1], strmid(comments[line], 0, pos + 1)]
      end
      
    'has_returns': return, obj_valid(self.returns)
    'returns': return, self.system->processComments(self.returns)

    'has_examples': return, obj_valid(self.examples)
    'examples': return, self.system->processComments(self.examples)
    
    'has_author_info': return, self.hasAuthorInfo
    
    'has_author': return, obj_valid(self.author)
    'author': return, self.system->processComments(self.author)

    'has_copyright': return, obj_valid(self.copyright)
    'copyright': return, self.system->processComments(self.copyright)
    
    'has_history': return, obj_valid(self.history)
    'history': return, self.system->processComments(self.history)
    
    'has_others': return, self.hasOthers
    
    'has_bugs': return, obj_valid(self.bugs)
    'bugs': return, self.system->processComments(self.bugs)

    'has_pre': return, obj_valid(self.pre)
    'pre': return, self.system->processComments(self.pre)
    
    'has_post': return, obj_valid(self.post)
    'post': return, self.system->processComments(self.post)
            
    'n_parameters': return, self.parameters->count()
    'parameters': return, self.parameters->get(/all)
    'n_keywords': return, self.keywords->count()
    'keywords': return, self.keywords->get(/all)
    else: begin
        ; search in the system object if the variable is not found here
        var = self.file->getVariable(name, found=found)
        if (found) then return, var
        
        found = 0B
        return, -1L
      end
  endcase
end


;+
; Uses file hidden/private attributes, system wide user/developer level, and
; the status of the containing file to determine if this routine should be 
; visible.
;
; :Returns: boolean
;-
function doctreeroutine::isVisible
  compile_opt strictarr

  ; each routine in a not-visible file is not visible
  if (~self.file->isVisible()) then return, 0B
  
  if (self.hidden) then return, 0B
  
  ; if creating user-level docs and private then not visible
  self.system->getProperty, user=user
  if (self.private && user) then return, 0B
  
  return, 1B
end


;+
; Add a parameter to the list of parameters for this routine.
; 
; :Params:
;    `param` : in, required, type=object
;       argument tree object
;-
pro doctreeroutine::addParameter, param
  compile_opt strictarr
  
  param->getProperty, name=n
  self.parameters->add, param
end


function doctreeroutine::getParameter, name, found=found
  compile_opt strictarr
  
  found = 1B
  for i = 0L, self.parameters->count() - 1L do begin
    p = self.parameters->get(position=i)
    p->getProperty, name=n
    if (strlowcase(name) eq strlowcase(n)) then return, p
  endfor
  found = 0B
  return, -1L
end


;+
; Add a keyword to the list of keywords for this routine.
; 
; :Params:
;    `keyword` : in, required, type=object
;       argument tree object
;-
pro doctreeroutine::addKeyword, keyword
  compile_opt strictarr
  
  self.keywords->add, keyword
end


function doctreeroutine::getKeyword, name, found=found
  compile_opt strictarr

  found = 1B
  for i = 0L, self.keywords->count() - 1L do begin
    k = self.keywords->get(position=i)
    k->getProperty, name=n
    if (strlowcase(name) eq strlowcase(n)) then return, k 
  endfor
  found = 0B
  return, -1L
end


;+
; Mark first and last arguments of a routine. Needs to be called after parsing
; the routine, but before the output is started.
;-
pro doctreeroutine::markArguments
  compile_opt strictarr
  
  nArgs = self.parameters->count() + self.keywords->count()
  if (nArgs le 0) then return
  
  arguments = objarr(nArgs)
  
  if (self.parameters->count() gt 0) then begin
    arguments[0] = self.parameters->get(/all)
  endif
  
  if (self.keywords->count() gt 0) then begin
    arguments[self.parameters->count()] = self.keywords->get(/all)
  endif

  arguments[0]->setProperty, is_first=1B
  arguments[n_elements(arguments) - 1L]->setProperty, is_last=1B
end


;+
; Free resources.
;-
pro doctreeroutine::cleanup
  compile_opt strictarr
  
  obj_destroy, [self.parameters, self.keywords, self.comments]
  obj_destroy, [self.returns, self.bugs]
  obj_destroy, [self.author, self.copyright, self.history]
end


;+
; Create a routine object.
;
; :Returns:
;    1 for success, 0 for failure
;
; :Params:
;    `file` : in, required, type=object
;       file tree object
;-
function doctreeroutine::init, file, system=system
  compile_opt strictarr
  
  self.file = file
  self.system = system
  
  self.parameters = obj_new('MGcoArrayList', type=11)
  self.keywords = obj_new('MGcoArrayList', type=11)
  
  return, 1B
end


;+
; Define instance variables for routine class. 
;
; :Fields:
;    `file` file object containing this routine
;    `name` string name of this routine
;    `isFunction` true if this routine is a function
;    `isMethod` true if this routine is a method of a class
;    `parameters` list of parameter objects
;    `keywords` list of keyword objects
;    `comments` tree node hierarchy
;-
pro doctreeroutine__define
  compile_opt strictarr
  
  define = { DOCtreeRoutine, $
             system: obj_new(), $
             file: obj_new(), $
             
             name: '', $
             isFunction: 0B, $
             isMethod: 0B, $
             isAbstract: 0B, $
             isHidden: 0B, $
             isPrivate: 0B, $
             
             parameters: obj_new(), $
             keywords: obj_new(), $
             
             comments: obj_new(), $
             returns: obj_new(), $

             examples: obj_new(), $
             
             hasAuthorInfo: 0B, $
             author: obj_new(), $
             copyright: obj_new(), $
             history: obj_new(), $
                          
             hasOthers: 0B, $
             bugs: obj_new(), $
             pre: obj_new(), $
             post: obj_new() $             
           }
end