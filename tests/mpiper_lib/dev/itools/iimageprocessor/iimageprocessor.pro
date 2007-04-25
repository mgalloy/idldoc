;+
; IIMAGEPROCESSOR is the IMAGEPROCESSOR program from the
; <i>Intermediate Programming in IDL</i> course, recast as an iTool
; with a custom UI for the <i>iTools Programming</i> course.
;
; <p> This is the iTool launch routine used to
; <ul>
;   <li> load the input image data (if available) into the iTool system
;   <li> register the iImageprocessor class with the iTool system
;   <li> register the iImageprocessor UI with the iTool system
;   <li> start the iImageprocessor iTool
; </ul> 
; in the same manner as the launch routines IPLOT, ISURFACE, etc.
;
; @examples
;   <pre>
;   IDL> file = filepath('endocell.jpg', subdir=['examples','data'])
;   IDL> cells = read_image(file)
;   IDL> iimageprocessor, cells
;   </pre>
;
; @todo Add RGB_TABLE keyword.
; @param image {in} A numeric array that can be displayed as an
;    image. The data are displayed as a grayscale intensity image
;    [unless the RGB_TABLE keyword is used] or an RGB image.
; @keyword identifier {out}{optional}{type=string} The iTool identifier
;    for this iImageprocessor iTool.
; @keyword _ref_extra Pass-by-reference keyword inheritance mechanism.
;
; @uses IIMAGEPROCESSOR_TOOL, IIMAGEPROCESSOR__DEFINE, GETCT, 
;    GET_INTERLEAVING
; @requires IDL 6.1
; @author Mark Piper, RSI, 2004
;-
pro iimageprocessor, image, $
                     identifier=id, $
                     _ref_extra=re
    compile_opt idl2, logical_predicate

    on_error, 2 
    catch, err
    if (err ne 0) then begin
        catch, /cancel 
        if obj_valid(oparameterset) then obj_destroy, oparameterset 
        message, /reissue_last 
        return 
    endif

    if (n_params() gt 0 && n_elements(image) gt 0) then begin

        ;; Build a parameterset object for the data (optionally)
        ;; passed in through the 'image' parameter.
        oparameterset = obj_new('idlitparameterset', $
                                name='iimageprocessor parameter', $
                                icon='image', $
                                description='iimageprocessor data')
        odata = obj_new('idlitdataidlimagepixels', image, _extra=re)
        oparameterset->add, odata, parameter_name='imagepixels'

        ;; Create a grayscale palette for an intensity image. (Why
        ;; doesn't IDLitDataIDLPalette (which must be used here) have
        ;; a handy LoadCT method like IDLgrPalette?)
        if (size(image, /n_dimensions) eq 2) then begin
            rgb = getct(0)
            opalette = obj_new('idlitdataidlpalette', transpose(rgb), $
                               name='palette')
            oparameterset->add, opalette, parameter_name='palette'
        endif
    endif

    ;; Determine the width and height of the image, if one is
    ;; passed. Pass this info to the iTool to set the virtual
    ;; dimensions of the draw window.
    true_val = get_interleaving(image, dimensions=idims)
    vdim = true_val ge 0 ? idims : 0

    ;; Register the iImageprocessor tool class (stored in
    ;; iimageprocessor__define) with the iTool system.
    itregister, 'imageprocessor_itool', 'iimageprocessor'

    ;; Register the corresponding user interface for iImageprocessor.
    ;; This is where we add our own controls to the interface.
    itregister, 'imageprocessor_ui', 'iimageprocessor_tool', /user_interface

    ;; Create an iImageprocessor iTool.
    id = idlitsys_createtool('imageprocessor_itool', $
                             visualization_type=['image'], $
                             user_interface='imageprocessor_ui', $
                             initial_data=oparameterset, $
                             title='iImageprocessor', $
                             virtual_dimensions=vdim, $
                             _extra=re)
end
