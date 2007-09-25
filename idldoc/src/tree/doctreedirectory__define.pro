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


pro doctreedirectory::cleanup
  compile_opt strictarr
  
end


function doctreedirectory::init, location=location, system=system
  compile_opt strictarr
  
  self.location = location
  self.system = system
  
  return, 1
end


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