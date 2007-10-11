; docformat = 'rst'

;+
; :Properties:
;    `location` : get, init
;       location of the directory
;    `url` : get
;       location of the directory as an URL
;-


;+
; Get properties.
;-
pro doctreedirectory::getProperty, location=location, url=url
  compile_opt strictarr
  
  if (arg_present(location)) then location = self.location
  if (arg_present(url)) then url = self.url
end


pro doctreedirectory::setProperty, overview_comments=overviewComments
  compile_opt strictarr

  if (n_elements(overviewComments) gt 0) then self.overviewComments = overviewComments
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
function doctreedirectory::getVariable, name, found=found
  compile_opt strictarr

  found = 1B
  case strlowcase(name) of
    'location' : return, self.location
    'url' : return, self.url
    'relative_root' : begin
        if (self.location eq '.' + path_sep()) then return, ''
        dummy = strsplit(self.location, path_sep(), count=nUps)
        return, strjoin(replicate('..' + path_sep(), nUps))
      end
      
    'overview_comments': return, self.system->processComments(self.overviewComments)  
    'n_pro_files' : return, self.proFiles->count()
    'pro_files' : return, self.proFiles->get(/all)
    'n_sav_files' : return, self.savFiles->count()
    'sav_files' : return, self.savFiles->get(/all)
    'n_idldoc_files' : return, self.idldocFiles->count()
    'idldoc_files' : return, self.idldocFiles->get(/all)
    
    else: begin
        ; search in the system object if the variable is not found here
        var = self.system->getVariable(name, found=found)
        if (found) then return, var
        
        found = 0B
        return, -1L
      end
  endcase
end


;+
; Generate all the output for the directory.
;
; :Params: 
;    `outputRoot` : in, required, type=string
;       output root directory (w/ trailing slash)
;-
pro doctreedirectory::generateOutput, outputRoot
  compile_opt strictarr
  on_error, 2
  
  self.system->print, 'Generating output for ' + self.location + '...'

  ; create directory in the output if necessary
  outputDir = outputRoot + self.location
  if (~file_test(outputDir)) then begin
    self.system->makeDirectory, outputDir, error=error
    if (error ne 0L) then begin
      self.system->error, 'unable to make directory ' + outputDir
    endif
  endif
    
  ; generate docs for each .pro/.sav/.idldoc file in directory
  for f = 0L, self.proFiles->count() - 1L do begin
    file = self.proFiles->get(position=f)
    file->generateOutput, outputRoot, self.location
  endfor

  for f = 0L, self.savFiles->count() - 1L do begin
    file = self.savFiles->get(position=f)
    file->generateOutput, outputRoot, self.location
  endfor
  
  for f = 0L, self.idldocFiles->count() - 1L do begin
    file = self.idldocFiles->get(position=f)
    file->generateOutput, outputRoot, self.location
  endfor
      
  ; generate directory overview
  dirOverviewFilename = filepath('dir-overview.html', root=outputDir)
  dirOverviewTemplate = self.system->getTemplate('dir-overview')
  dirOverviewTemplate->reset
  dirOverviewTemplate->process, self, dirOverviewFilename
    
  ; generate file listing
  listingFilename = filepath('dir-files.html', root=outputDir)
  listingTemplate = self.system->getTemplate('file-listing')
  listingTemplate->reset
  listingTemplate->process, self, listingFilename
end


;+
; Free resources, including items lower in the hierarchy
;-
pro doctreedirectory::cleanup
  compile_opt strictarr
  
  obj_destroy, self.overviewComments
  obj_destroy, [self.proFiles, self.savFiles, self.idldocFiles]
end


;+
; Create a directory object.
;
; :Returns: 1 for success, 0 for failure
; :Keywords:
;    `location` : in, required, type=string
;       location of the directory relative to the ROOT (w/ trailing slash)
;    `files` : in, required, type=strarr
;       .sav/.pro/.idldoc files in directory
;    `system` : in, required, type=object
;       system object
;-
function doctreedirectory::init, location=location, files=files, system=system
  compile_opt strictarr
  
  self.location = location
  self.system = system
  
  self.proFiles = obj_new('MGcoArrayList', type=11)
  self.savFiles = obj_new('MGcoArrayList', type=11)
  self.idldocFiles = obj_new('MGcoArrayList', type=11)
  
  self.url = strjoin(strsplit(self.location, path_sep(), /extract), '/') + '/'
  
  self.system->getProperty, root=root  
  self.system->print, 'Parsing ' + self.location + '...'
  
  for f = 0L, n_elements(files) - 1L do begin
    dotpos = strpos(files[f], '.', /reverse_search)
    extension = strmid(files[f], dotpos + 1L)
    case strlowcase(extension) of
      'pro': begin
          proFileParser = self.system->getParser('profile')
          file = proFileParser->parse(root + files[f], directory=self)
          self.proFiles->add, file
        end
      'sav': begin
          file = obj_new('DOCtreeSavFile', $
                         basename=file_basename(files[f]), $
                         directory=self, $
                         system=self.system)
          self.savFiles->add, file
        end
      'idldoc': begin
          idldocFileParser = self.system->getParser('idldocfile')
          file = idldocFileParser->parse(root + files[f], directory=self)
          self.idldocFiles->add, file
        end                
    endcase
  endfor
  
  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    `system`
;       system object
;    `location`
;       location of the directory relative to the ROOT (w/ trailing slash)
;    `url`
;       location of the directory relative to the ROOT as an URL (w/ trailing 
;       slash) 
;    `proFiles`
;       array list of .pro file objects
;    `savFiles`
;       array list of .sav file objects
;    `idldocFiles`
;       array list of .idldoc file objects
;-
pro doctreedirectory__define
  compile_opt strictarr
  
  define = { DOCtreeDirectory, $
             system: obj_new(), $
             location: '', $
             url: '', $
             overviewComments: obj_new(), $
             proFiles: obj_new(), $
             savFiles: obj_new(), $
             idldocFiles: obj_new() $
           }
end