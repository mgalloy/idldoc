  
;Read the image  
;READ_JPEG, FILEPATH('pollens.jpg', $  
;   SUBDIR=['examples','demo','demodata']), a  
READ_JPEG, FILEPATH('endocell.jpg', $  
   SUBDIR=['examples','data']), a  

idims = size(a, /dimensions)
window, xsize=idims[0]*2, ysize=idims[1]*2
  
;Invert the image  
b = MAX(a) - a  
  
TVSCL, b, 0  

;Radius of disc...  
r = 5
  
;Create a disc of radius r  
disc = SHIFT(DIST(2*r+1), r, r) LE r  
  
;Remove holes of radii less than r  
c = MORPH_CLOSE(b, disc, /GRAY)  
  
TVSCL, c, 1  
  
;Create watershed image  
d = WATERSHED(c)  
  
;Display it, showing the watershed regions  
TVSCL, d, 2  
  
;Merge original image with boundaries of watershed regions  
e = a > (MAX(a) * (d EQ 0b))  
  
TVSCL, e, 3  

end
