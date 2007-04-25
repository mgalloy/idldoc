;+
; An updated version of the IDL Tour.<p>
;
; Note: this is a batch file; it cannot be compiled.
;
; @uses LOAD_DATA, LOAD_GRAYS
; @author Mark Piper, RSI, 2003
;-

; This tour demonstrates aspects of the IDL language as well as some
; of the visualization capabilities of IDL.

journal, 'tour.pro'
; Open a journal file to log the statements you type at the command
; line to the file 'tour.pro'. After we finish the tour, you can open
; this file to see what you typed.

;----------------------------------------------------------------------------
;
; Scalar and array variables.
;

print, 3*4
; The PRINT procedure displays the result of the expression 3*4 in the
; IDLDE output log. Note that the comma is used in IDL to delimit
; arguments to a procedure or function.

a = 5*12
help, a
; Here, a is a variable.
; Get info about /a/ from the HELP procedure. HELP is useful for
; obtaining diagnostic information from IDL.
; Notice type. Default type is integer. Had we instead typed
a = 5.0*12.0
help, a
; the result would be a floating-point value.

b = fltarr(10)
help, b
print, b
; The FLTARR function is used to create floating-point arrays.
; Here, the variable /b/ is a 10-element floating point array. By
; default, the values of /b/ are initially set to zero.
; Note that the arguments to an IDL function are enclosed in
; parentheses.

; IDL has control statements similar to those in other programming
; languages. For example, a FOR loop executes a statement (or a group
; of statements) a specified number of times. Here's an example of
; initializing the array /b/ with values. Each element of /b/ receives
; the value of its index.
for i = 0, 9 do b[i] = i
print, b
; However, in IDL, the built-in function FINDGEN creates an indexed
; array automatically:
c = findgen(10) ; Don't need to load indexed array with loop in IDL!
help, c
print, c
; In IDL, using built-in array functions is much faster than
; performing equivalent operations with a control statement.

print, c[0:4]
; Extract a portion of the array c. This is the idea of /subscripting/ an
; array. Notice that array index values start at zero in IDL.

d = c[1:6]
help, d
; New variables can be made from subscripted arrays.

;----------------------------------------------------------------------------
;
; Line plots.
;

; The training program LOAD_DATA is used to read a data set from the
; training files. Here, we'll read the data set called 'chirp'.
chirp = load_data('chirp')
; What is in this new variable chirp?
help, chirp ; Note 1D array (vector). Data are read into an IDL array.
; Note the type: byte.

; Display the data with the PLOT procedure. Notice that a graphics
; window springs up.
; The data in the variable /chirp/ are passed into the
; PLOT procedure. (Don't forget the comma!)
plot, chirp

; Plot data with symbols instead of a line by using the PSYM keyword
; to PLOT. Notice that the same window is used.
plot, chirp, psym=1

; Plot with a line and a symbol.
plot, chirp, psym=-1, linestyle=2

; Plot the data and add descriptive titles.
plot, chirp, xtitle='Time (s)', ytitle='Amplitude (m)', $
    title='Sine Wave with Exponentially Increasing Frequency'
; Note the use of the continuation character $. This statement was too
; long to fit on one line in the manual. A statement can span multiple
; lines... Don't need to consider this when typing at the command
; line; simply type the entire statement without the $.
; Notice that many different plots can be created using keywords to
; the PLOT procedure.


;----------------------------------------------------------------------------
;
; Surface plots.
;

; Load the dataset 'lvdem.' It contains a digital elevation map (DEM)
; of the mouth of the Big Thompson Canyon, near Loveland, Colo.
dem = load_data('lvdem')
help, dem

;
surface, dem
surface, dem, ax=45, az=60

; Another routine for displaying surface data may provide a better
; view.
shade_surf, dem

; View dataset from above.
shade_surf, dem, az=0, ax=90

;----------------------------------------------------------------------------
;
; Contour plots.
;

; Display 2D data as a contour plot.
contour, dem

; Boundaries are bad. IDL is autoscaling axes. Turn this off.
contour, dem, xstyle=1, ystyle=1

; Use more contour levels.
contour, dem, xstyle=1, ystyle=1, nlevels=12
; IDL stores by default the last 20 statements typed at the command
; line. Instead of retyping statements, use the up arrow to retrieve
; a statement, then edit it.

; Make levels. Understand what's going on?
dmin = min(dem, max=dmax)
print, dmin, dmax
; make the c levels, given knowledge of data range.
clevels = indgen(15)*25+2800
print, clevels
contour, dem, xstyle=1, ystyle=1, levels=clevels

; Try these.
contour, dem, xstyle=1, ystyle=1, levels=clevels, /follow
contour, dem, xstyle=1, ystyle=1, levels=clevels, /fill
; Filled contours look better!
; What about a color bar? Write wrapper to IDLgrColorbar?


;----------------------------------------------------------------------------
;
; Displaying and processing images.
;

; Erase the current display window.
erase

; Load a grayscale color palette.
; Display the Big Thompson Canyon dataset as an image.
loadct, 0
tvscl, dem
; Whoa, it's small. This is because the array elts are matched to
; image pixels. The data are stored in a 64 x 64 array, so they're
; mapped to a 64 x 64 image. Also note the image is displayed
; in the lower left corner of the window.

; Blow up the image.
; Resize the data using bilinear interpolation. Display.
newx = 256
newy = 256
new_dem = rebin(dem, newx, newy)
tvscl, new_dem

; Set a different predefined CT and redisplay.
loadct, 5
window, 0, xsize=newx, ysize=newy
tvscl, new_dem
; See figure.

; The data used to display this image are just numbers.
; IDL can crunch them. Try using the sobel function.
; It differentiates the image. It acts as an edge detector.
; Load a default grayscale color table.
loadct, 0
tvscl, sobel(new_dem)
; The canyon walls are picked out with high values : white -- regions
; of increased change means larger derivative. Canyon floor is flat >
; derivative is small > low intesity values : black.

;----------------------------------------------------------------------------
;
; iTools example
;

; The Intelligent Tools (iTools), introduced in IDL 6.0, provide
; another way of interactively visualizing data.

;
isurface, elev

;----------------------------------------------------------------------------

journal
; This completes the tour. Open the file 'tour.pro' to see what has
; been logged from you IDL session.
