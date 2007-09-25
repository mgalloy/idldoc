pro doctreedirectory::getProperty, location=location
  compile_opt strictarr
  
  if (arg_present(location)) then location = self.location
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
  
  print, 'Generating output for ' + self.location
  
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
  
  ; generate file listing
end


;+
; Free resources, including items lower in the hierarchy
;-
pro doctreedirectory::cleanup
  compile_opt strictarr
  
  obj_destroy, self.proFiles
  obj_destroy, self.savFiles
  obj_destroy, self.idldocFiles
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
  
  for f = 0L, n_elements(files) - 1L do begin
    dotpos = strpos(files[f], '.', /reverse_search)
    extension = strmid(files[f], dotpos + 1L)
    case strlowcase(extension) of
      'pro': begin
          file = obj_new('DOCtreeProFile', $
                         name=file_basename(files[f]), $
                         directory=self, $
                         system=self.system)
          self.proFiles->add, file
        end
      'sav': begin
          file = obj_new('DOCtreeSavFile', $
                         name=file_basename(files[f]), $
                         directory=self, $
                         system=self.system)
          self.savFiles->add, file
        end
      'idldoc': begin
          file = obj_new('DOCtreeIDLdocFile', $
                         name=file_basename(files[f]), $
                         directory=self, $
                         self.system)
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
             proFiles: obj_new(), $
             savFiles: obj_new(), $
             idldocFiles: obj_new() $
           }
end