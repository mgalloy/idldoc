; docformat = 'rst'

;+
; Create a thumbnail image of a simple visualization of the data. The 
; visualization type is guessed based on the dimensions of the data.
;-

;+
; Create a line plot.
;
; :Returns: bytarr(3, m,n ) or -1L
; :Params:
;    `data` : in, required, type=numeric array
; :Keywords:
;    `valid` : out, optional, type=boolean
;       set to a named variable to get status of visualization; if no valid 
;       visualization type could be found, -1L is returned
;-
function doc_thumbnail_lineplot, data, valid=valid
  compile_opt strictarr
  
  ; TODO: set dimensions based on derivative and/or golden ratio?
  dims = [100, 75]
  
  view = obj_new('IDLgrView')
  
  model = obj_new('IDLgrModel')
  view->add, model
  
  plot = obj_new('IDLgrPlot', data, color=[0, 0, 255])
  model->add, plot
  
  ; TODO: set coord conv functions on plot
  
  buffer = obj_new('IDLgrBuffer', dimensions=dims)
  buffer->draw, view
  buffer->getProperty, image_data=im
  
  obj_destroy, [buffer, view]
  
  return, im
end


;+
; Create a contour plot.
;
; :Returns: bytarr(3, m,n ) or -1L
; :Params:
;    `data` : in, required, type=numeric array
; :Keywords:
;    `valid` : out, optional, type=boolean
;       set to a named variable to get status of visualization; if no valid 
;       visualization type could be found, -1L is returned
;-
function doc_thumbnail_contourplot, data, valid=valid
  compile_opt strictarr
  
end


;+
; Create a volume visualization.
;
; :Returns: bytarr(3, m,n ) or -1L
; :Params:
;    `data` : in, required, type=numeric array
; :Keywords:
;    `valid` : out, optional, type=boolean
;       set to a named variable to get status of visualization; if no valid 
;       visualization type could be found, -1L is returned
;-
function doc_thumbnail_volumeplot, data, valid=valid
  compile_opt strictarr
  
end


;+
; Resize image to correct dimensions while preserving the aspect ratio.
;
; :Returns: bytarr(3, m,n ) or -1L
; :Params:
;    `data` : in, required, type=numeric array
; :Keywords:
;    `valid` : out, optional, type=boolean
;       set to a named variable to get status of visualization; if no valid 
;       visualization type could be found, -1L is returned
;-
function doc_thumbnail_image, data, valid=valid
  compile_opt strictarr
  
end


;+
; Dispatches data to proper helper routine to produce a simple thumbnail
; visualization of the data and returns the result as a true color image.
;
; :Returns: bytarr(3, m,n ) or -1L
; :Params:
;    `data` : in, required, type=numeric array
; :Keywords:
;    `valid` : out, optional, type=boolean
;       set to a named variable to get status of visualization; if no valid 
;       visualization type could be found, -1L is returned
;-
function doc_thumbnail, data, valid=valid
  compile_opt strictarr
  
  sz = size(data, /structure)
  
  ; set to not valid for any of the following types or sizes
  valid = 0B
  
  ; invalid types/sizes
  if (sz.type eq 7) then return, -1L
  if (sz.type eq 8) then return, -1L
  if (sz.type eq 11) then return, -1L  
  
  if (sz.n_dimensions eq 0) then return, -1L
  if (sz.n_dimensions gt 3) then return, -1L
  
  valid = 1B
  
  ; valid types/sizes
  case sz.n_dimensions of
    1: return, doc_thumbnail_lineplot(data, valid=valid)
    2: return, doc_thumbnail_contourplot(data, valid=valid)
    3: begin
        ind = where(sz.dimensions le 4, count)
        
        ; if no small dimensions then assume volume
        if (count eq 0) then return, doc_thumbnail_volumeplot(data, valid=valid) 
        
        ; if there are small dimensions then assume an image
        return, doc_thumbnail_image(data, valid=valid)
      end
  endcase
end
