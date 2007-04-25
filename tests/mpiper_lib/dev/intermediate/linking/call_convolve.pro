;+
; An example of using CALL_EXTERNAL to call into a DLL made from the
; source file <b>convolve.c</b>.<p>
;
; The output of the C program <code>convolve</code> is compared with
; IDL's built-in CONVOL function.
;
; @author Mark Piper, RSI, 2004
;-
pro call_convolve
    compile_opt idl2

    ;; Read in an image to process.
    image_file = filepath('ctscan.dat', subdir=['examples','data'])
    scan = read_binary(image_file, data_dims=[256,256])
    image = size(scan, /structure)

    ;; Create a filter -- must be square!
    filter = intarr(5,5) + 1

    ;; Properly typecast the inputs & outputs for the C routine 'convolve.'
    xsize = long(image.dimensions[0])
    ysize = long(image.dimensions[1])
    in_scan = float(scan)
    filter_dimensions = long((size(filter, /dimensions))[0])
    in_filter = float(filter)
    output = scan*0.0
    center = 1L

    ;; Call 'convolve' through CALL_EXTERNAL. Note the use of relative
    ;; filepaths.
    dll_name = 'convolve.dll'
    entry_point = 'convolve_w'
    status = call_external(dll_name, entry_point, xsize, ysize, $
        in_scan, filter_dimensions, in_filter, output, center, /unload)
    if status eq 1 then print, 'Success!' $
    else begin
        print, 'Failure!'
        return
    endelse

    ;; Convert the output from 'convolve' from float back to byte.
    output = byte(output)

    ;; Display the results, compare to IDL's CONVOL function.
    window, 0, xsize=3*xsize, ysize=2*ysize, $
        title='image convolution example'
    tv, scan, 0
    tv, output, 1
    tv, scan - output, 2
    tv, convol(scan, filter, total(filter), center=center), 4
    tv, scan - convol(scan, filter, total(filter), center=center), 5
    xyouts, xsize/2, 0.9*ysize, 'original image', /device, align=0.5
    xyouts, 3*xsize/2, 0.9*ysize, 'filtered image', /device, align=0.5
    xyouts, 5*xsize/2, 0.9*ysize, 'unsharp masked image', /device, align=0.5
    xyouts, 4*xsize/2, 1.75*ysize, '<-- convolve.c -->', /device, align=0.5
    xyouts, 4*xsize/2, 0.75*ysize, '<-- CONVOL -->', /device, align=0.5
end
