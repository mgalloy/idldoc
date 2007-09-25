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
;    `system` : in, required, type=object
;       system object
;-
function doctreedirectory::init, location=location, system=system
  compile_opt strictarr
  
  self.location = location
  self.system = system
  
  self.proFiles = obj_new('MGcoArrayList', type=11)
  self.savFiles = obj_new('MGcoArrayList', type=11)
  self.idldocFiles = obj_new('MGcoArrayList', type=11)
  
  ; find .pro/.sav/.idldoc files in directory 
  ; create file objects
  
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