;+
; An example of masking a portion of an image using a relational
; operator. See also "Masking Images" in <i>Image Processing in
; IDL</i> in the Online Help.
;
; @requires IDL 5.3
; @author Mark Piper, RSI, 2005
;-
pro masking_ex
    compile_opt idl2

    ;; Open a sample image. This is a model of mantle convection.
    file = filepath('convec.dat', subdir=['examples','data'])
    mantle = read_binary(file, data_dims=[248,248], data_type=1)

    ;; Display the image.
    window, 0, xsize=248, ysize=248, title='Original Image', xpos=0, ypos=0
    tvscl, mantle

    ;; Create a mask, singling out the high intensities at the core,
    ;; using the NE relational operator. Display it. Note that the
    ;; mask preserves the type (byte) of the image.
    mask = mantle ne 255B
    window, 1, xsize=248, ysize=248, title='Image Mask', xpos=100, ypos=100
    tvscl, mask

    ;; Apply the mask, removing the core. Display the result.
    new = mantle * mask
    window, 2, xsize=248, ysize=248, title='Masked Image', xpos=200, ypos=200
    tv, new
end
