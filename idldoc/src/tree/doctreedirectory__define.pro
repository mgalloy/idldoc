; docformat = 'rst'

;+
; Represents a directory.
; 
; :Properties:
;    files
;       .sav/.pro/.idldoc files in directory
;    location
;       location of the directory relative to the ROOT (w/ trailing slash)
;    overview_comments
;       markup comment tree representing the overview comments for the 
;       directory
;    system
;       system object
;    url
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


;+
; Set properties.
;-
pro doctreedirectory::setProperty, overview_comments=overviewComments
  compile_opt strictarr

  if (n_elements(overviewComments) gt 0) then self.overviewComments = overviewComments
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
    'n_visible_pro_files': begin
        nVisible = 0L
        for f = 0L, self.proFiles->count() - 1L do begin
          file = self.proFiles->get(position=f)          
          nVisible += file->isVisible()          
        endfor
        return, nVisible
      end
    'visible_pro_files': begin        
        files = self.proFiles->get(/all, count=nFiles)
        if (nFiles eq 0L) then return, -1L
        
        isVisibleFiles = bytarr(nFiles)
        for f = 0L, nFiles - 1L do begin
          isVisibleFiles[f] = files[f]->isVisible()
        endfor
        
        ind = where(isVisibleFiles eq 1B, nVisibleFiles)
        if (nVisibleFiles eq 0L) then return, -1L
        
        return, files[ind]
      end
    'n_dlm_files' : return, self.dlmFiles->count()
    'dlm_files' : return, self.dlmFiles->get(/all)
    'n_sav_files' : return, self.savFiles->count()
    'sav_files' : return, self.savFiles->get(/all)
    'n_idldoc_files' : return, self.idldocFiles->count()
    'idldoc_files' : return, self.idldocFiles->get(/all)
    
    'fullname' : return, strjoin(strsplit(self.location, path_sep(), /extract), '.')
    
    'index_name': return, self.location
    'index_type': return, 'directory'
    'index_url': return, self.url + 'dir-overview.html'
    
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
; Directories are always visible.
;
; :Returns: 1 if visible, 0 if not visible
;-
function doctreedirectory::isVisible
  compile_opt strictarr
  
  return, 1B
end


;+
; Do any analysis necessary on information gathered during the "parseTree"
; phase.
;-
pro doctreedirectory::process
  compile_opt strictarr
  
  for f = 0L, self.proFiles->count() - 1L do begin
    file = self.proFiles->get(position=f)
    file->process
  endfor  
end


;+
; Generate all the output for the directory.
;
; :Params: 
;    outputRoot : in, required, type=string
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
    
  ; generate docs for each .pro/.dlm/.sav/.idldoc file in directory
  for f = 0L, self.proFiles->count() - 1L do begin
    file = self.proFiles->get(position=f)
    file->generateOutput, outputRoot, self.location
  endfor

  for f = 0L, self.dlmFiles->count() - 1L do begin
    file = self.dlmFiles->get(position=f)
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
  
  self.system->getProperty, extension=outputExtension
  ; generate directory overview
  dirOverviewFilename = filepath('dir-overview.' + outputExtension, root=outputDir)
  dirOverviewTemplate = self.system->getTemplate('dir-overview')
  dirOverviewTemplate->reset
  dirOverviewTemplate->process, self, dirOverviewFilename
    
  ; generate file listing
  listingFilename = filepath('dir-files.' + outputExtension, root=outputDir)
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
  obj_destroy, [self.proFiles, self.dlmFiles, self.savFiles, self.idldocFiles]
end


;+
; Create a directory object.
;
; :Returns: 
;    1 for success, 0 for failure
;-
function doctreedirectory::init, location=location, files=files, system=system
  compile_opt strictarr
  
  self.location = location
  self.system = system
  
  self.system->getProperty, index_level=indexLevel
  if (indexLevel ge 1L) then self.system->createIndexEntry, self.location, self
  
  self.proFiles = obj_new('MGcoArrayList', type=11, block_size=10)
  self.dlmFiles = obj_new('MGcoArrayList', type=11, block_size=5)
  self.savFiles = obj_new('MGcoArrayList', type=11, block_size=5)  
  self.idldocFiles = obj_new('MGcoArrayList', type=11, block_size=4)
  
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
      'dlm': begin
          file = obj_new('DOCtreeDLMFile', $
                         basename=file_basename(files[f]), $
                         directory=self, $
                         system=self.system)
          self.dlmFiles->add, file
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
;    system
;       system object
;    location
;       location of the directory relative to the ROOT (w/ trailing slash)
;    url
;       location of the directory relative to the ROOT as an URL (w/ trailing 
;       slash) 
;    overviewComments
;       markup tree representing the overview comments for the directory
;    proFiles
;       array list of .pro file objects
;    savFiles
;       array list of .sav file objects
;    idldocFiles
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
             dlmFiles: obj_new(), $
             savFiles: obj_new(), $
             idldocFiles: obj_new() $
           }
end