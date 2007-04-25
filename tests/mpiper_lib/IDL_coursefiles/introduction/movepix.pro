;+
; Draws the word 'HELLO' in yellow on top of an image. Run the program and
; click the left mouse button in the window to display the text. Click the
; right mouse button to end the program.
; <p>
;
; This program is ancient. Unknown author. It should be replaced with
; a more modern example.
;-
pro movepix

	file = filepath('ctscan.dat', subdir=['examples','data'])
	scan = read_binary(file, data_dims=[256,256])
	window, 0, xsize=256, ysize=256
	tv, bytscl(scan, top=199), order=1
	!err = 0
	window, 1, xsize=256, ysize=256, /pixmap
	tv, bytscl(scan, top=199), order=1
	wset, 0
	wshow, 0
	tvlct, 255, 255, 0, 200
	cursor, x1, y1, /device, /down
	xyouts, x1, y1, /device, 'HELLO', charsize=3, $
	    align=0.5, color=200
	while (!err ne 4) do begin
	    cursor, x2, y2, /device, /nowait
	    device, copy=[0, 0, 256, 256, 0, 0, 1]
	    xyouts, x2, y2, /device, 'HELLO', charsize=3, $
	        align=0.5, color=200
	endwhile
	wdelete, 1
end