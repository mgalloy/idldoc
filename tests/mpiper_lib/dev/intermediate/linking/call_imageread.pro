;+
; An example of passing a string variable from IDL to C.
;
; @uses the C routines in the file <b>imageread.c</b>
; @requires IDL 5.6
;
; @author Mark Piper
; @copyright RSI, 2003
;-
pro call_imageread
    compile_opt idl2

    ;; Specify the path to a flat binary image file + the size of the
    ;; image it contains.
    file = filepath('convec.dat', subdir=['examples','data'])
    xsize = 248L
    ysize = 248L

    ;; Dimension a variable to contain the image.
    mantle = bytarr(xsize,ysize)

    ;; Specify the path to the shared object and its name.
    so_path = 'imageread.so'
    so_name = 'imageread_w'

    ;; Call. Use CDECL keyword for Win compatibility.
    junk = 0L
    junk = call_external(so_path, so_name, $
                         file, $
                         xsize, $
                         ysize, $
                         mantle, $
                         /cdecl)
                         
    ;; Display the image.
    window, /free, xsize=xsize, ysize=ysize
    tv, mantle

    return
end
