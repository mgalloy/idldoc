; docformat = 'rst'

;+
; This class represents a information about .pro file.
; 
; :Properties:
;    `basename` : get, set, type=string
;       basename of filename
;    `has_main_level` : get, set, type=boolean
;       true if the file has a main-level program at the end
;    `is_batch` : get, set, type=boolean
;       true if the file is a batch file
;    `comments` : get, set, type=object
;       text tree hierarchy for file level comments
;    `n_routines` : get, type=integer
;       number of routines in the file
;    `routines` : get, type=object
;       list object containing routine objects in file
;-


;+
; Get properties.
;-
pro doctreeprofile::getProperty, basename=basename, $
                                 has_main_level=hasMainLevel, $
                                 is_batch=isBatch, comments=comments, $
                                 n_routines=nRoutines, routines=routines
  compile_opt strictarr
  
  if (arg_present(basename)) then basename = self.basename
  if (arg_present(hasMainLevel)) then hasMainLevel = self.hasMainLevel
  if (arg_present(isBatch)) then isBatch = self.isBatch  
  if (arg_present(comments)) then comments = self.comments
  if (arg_present(nRoutines)) then nRoutines = self.routines->count()
  if (arg_present(routines)) then routines = self.routines
end


;+
; Set properties.
;-
pro doctreeprofile::setProperty, has_main_level=hasMainLevel, $
                                 is_batch=isBatch, comments=comments, $
                                 modification_time=mTime, n_lines=nLines, $ 
                                 format=format, markup=markup                                 
  compile_opt strictarr
  
  if (n_elements(hasMainLevel) gt 0) then self.hasMainLevel = hasMainLevel
  if (n_elements(isBatch) gt 0) then self.isBatch = isBatch
  if (n_elements(comments) gt 0) then begin
    if (obj_valid(self.comments)) then begin
      parent = obj_new('MGtmTag')
      parent->addChild, self.comments
      parent->addChild, comments
      self.comments = parent
    endif else self.comments = comments
  endif
  if (n_elements(format) gt 0) then self.format = format
  if (n_elements(markup) gt 0) then self.markup = markup
  if (n_elements(nLines) gt 0) then self.nLines = nLines
  if (n_elements(mTime) gt 0) then self.modificationTime = mTime
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
function doctreeprofile::getVariable, name, found=found
  compile_opt strictarr
  
  catch, error
  if error ne 0 then begin
    catch, /cancel
    print, !error_state.msg
    message, 'problem'
  endif
  
  found = 1B
  case strlowcase(name) of
    'basename': return, self.basename
    'local_url': return, file_basename(self.basename, '.pro') + '.html'
    
    'is_batch': return, self.isBatch
    'has_main_level': return, self.hasMainLevel
    'is_class': return, strlowcase(strmid(self.basename, 11, /reverse_offset)) eq '__define.pro'
    
    'modification_time': return, self.modificationTime
    'n_lines': return, mg_int_format(self.nLines)
    'format': return, self.format
    'markup': return, self.markup
    
    'has_comments': return, obj_valid(self.comments)
    'comments': begin
        ; TODO: check system for output type (assuming HTML here)
        html = self.system->getParser('htmloutput')
        return, html->process(self.comments)        
      end
    'comments_first_line': begin
        ; if no file comments, but there is only one routine then return the
        ; first line of the routine's comments
        if (~obj_valid(self.comments)) then begin
          if (self.routines->count() eq 1) then begin
            routine = self.routines->get(position=0)
            return, routine->getVariable('comments_first_line', found=found)
          endif else return, ''
        endif else return, ''
        
        ; TODO: check system for output type (assuming HTML here)
        html = self.system->getParser('htmloutput')    
        comments = html->process(self.comments)
        
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
          
    'n_routines' : return, self.routines->count()
    'routines' : return, self.routines->get(/all)
    
    else: begin
        ; search in the system object if the variable is not found here
        var = self.directory->getVariable(name, found=found)
        if (found) then return, var
        
        found = 0B
        return, -1L
      end
  endcase
end


;+
; Add a routine to the list of routines in the file.
; 
; :Params:
;    `routine` : in, required, type=object
;       routine object
;-
pro doctreeprofile::addRoutine, routine
  compile_opt strictarr
  
  self.routines->add, routine
end


pro doctreeprofile::generateOutput, outputRoot, directory
  compile_opt strictarr
  
  self.system->print, '  Generating output for ' + self.basename + '...'

  for r = 0L, self.routines->count() - 1L do begin
    routine = self.routines->get(position=r)
    routine->markArguments
  endfor

  proFileTemplate = self.system->getTemplate('profile')
  
  outputDir = outputRoot + directory
  outputFilename = outputDir + file_basename(self.basename, '.pro') + '.html'
  
  proFileTemplate->reset
  proFileTemplate->process, self, outputFilename  
end


;+
; Free resources.
;-
pro doctreeprofile::cleanup
  compile_opt strictarr
  
  obj_destroy, self.routines
end


;+
; Create file tree object.
;
; :Returns: 1 for success, 0 for failure
; :Keywords:
;    `basename` : in, required, type=string
;    `directory` : in, required, type=object
;-
function doctreeprofile::init, basename=basename, directory=directory, $
                               system=system
  compile_opt strictarr
  
  self.basename = basename
  self.directory = directory
  self.system = system
  
  self.routines = obj_new('MGcoArrayList', type=11)
  
  self.system->createIndexEntry, self.basename, self
  self.system->print, '  Parsing ' + self.basename + '...'
  
  return, 1
end


;+
; :Fields:
;    `directory` directory tree object
;    `basename` basename of file
;    `hasMainLevel` true if the file has a main level program at the end
;    `isBatch` true if the file is a batch file
;    `routines` list of routine objects
;-
pro doctreeprofile__define
  compile_opt strictarr
  
  define = { DOCtreeProFile, $
             system: obj_new(), $
             directory: obj_new(), $
             
             basename: '', $
             hasMainLevel: 0B, $
             isBatch: 0B, $
             isClass: 0B, $
             
             modificationTime: '', $
             nLines: 0L, $
             format: '', $
             markup: '', $
             
             comments: obj_new(), $
             
             routines: obj_new() $
           }
end