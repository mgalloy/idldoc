; docformat = 'rst'

;+
; This class represents a information about .pro file.
; 
; :Properties:
;    `basename` : get, set, type=string
;       basename of filename
;-


;+
; Get properties.
;-
pro doctreeidldocfile::getProperty, basename=basename
  compile_opt strictarr
  
  if (arg_present(basename)) then basename = self.basename
end


;+
; Set properties.
;-
pro doctreeidldocfile::setProperty, comments=comments
  compile_opt strictarr

  if (n_elements(comments) gt 0) then begin
    if (obj_valid(self.comments)) then begin
      parent = obj_new('MGtmTag')
      parent->addChild, self.comments
      parent->addChild, comments
      self.comments = parent
    endif else self.comments = comments
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
function doctreeidldocfile::getVariable, name, found=found
  compile_opt strictarr
  
  found = 1B
  case strlowcase(name) of
    'basename': return, self.basename
    'local_url': return, file_basename(self.basename, '.idldoc') + '.html'
    
    'has_comments': return, obj_valid(self.comments)
    'comments': begin
        ; TODO: check system for output type (assuming HTML here)
        html = self.system->getParser('htmloutput')
        return, html->process(self.comments)        
      end
    'comments_first_line': begin
        if (~obj_valid(self.comments)) then return, ''
        
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
      
      
    else: begin
        ; search in the system object if the variable is not found here
        var = self.directory->getVariable(name, found=found)
        if (found) then return, var
        
        found = 0B
        return, -1L
      end
  endcase
end


pro doctreeidldocfile::generateOutput, outputRoot, directory
  compile_opt strictarr
  
  self.system->print, '  Generating output for .idldoc file ' + self.basename
  
  idldocFileTemplate = self.system->getTemplate('idldocfile')
    
  outputDir = outputRoot + directory
  outputFilename = outputDir + file_basename(self.basename, '.idldoc') + '.html'
  
  idldocFileTemplate->reset
  idldocFileTemplate->process, self, outputFilename   
end


;+
; Free resources.
;-
pro doctreeidldocfile::cleanup
  compile_opt strictarr
  
end


;+
; Create file tree object.
;
; :Returns: 1 for success, 0 for failure
; :Keywords:
;    `basename` : in, required, type=string
;    
;    `directory` : in, required, type=object
;-
function doctreeidldocfile::init, basename=basename, directory=directory, $
                                  system=system
  compile_opt strictarr
  
  self.basename = basename
  self.directory = directory
  self.system = system
  
  self.system->createIndexEntry, self.basename, self
  self.system->print, '  Parsing ' + self.basename + '...'
  
  self.system->getProperty, root=root
  self.directory->getProperty, location=location
  
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
pro doctreeidldocfile__define
  compile_opt strictarr
  
  define = { DOCtreeIDLdocFile, $
             system: obj_new(), $
             directory: obj_new(), $
             
             basename: '', $
             comments: obj_new() $
           }
end