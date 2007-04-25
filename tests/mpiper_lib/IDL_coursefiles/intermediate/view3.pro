;+
; <center><img src="view3.png" alt="view3" /></center><br>
;
; Displays a two-dimensional numeric array as a contour plot, a surface
; plot and an image. This program demonstrates the use of multiple view
; objects with different dimensions contained in a scene. Also demonstrated
; are surface, contour and image graphics atoms, as well as the use of
; the window object's graphics_tree property.
;
; @param data {in}{type=float or integer array} an array to be displayed
;       as a contour plot, surface plot & image
; @uses <a href="setcc.html">setcc</a>
; @author Mark Piper, 2001 (idea from Beau Legeer, 1999)
; @copyright RSI
;-
pro view3, data

    compile_opt idl2

    ; Check the input data. If no data were passed, then create some.
    if n_params() ne 1 then $
        data = bytscl(shift(beselj(dist(30)),15,15))

    ; Create a viewgroup to contain the three views.
    oViewgroup = obj_new('IDLgrViewgroup')

    ; A view to display an image.
    oImageView = obj_new('IDLgrView', $
        units=3, $
        location=[0.0, 0.5], $
        dimension=[0.5,0.5])

    ; A view to display a contour plot.
    oContourView = obj_new('IDLgrView', $
        units=3, $
        location=[0.5, 0.5], $
        dimension=[0.5,0.5])

    ; A view to display a surface.
    oSurfaceView = obj_new('IDLgrView', $
        units=3, $
        location=[0.0, 0.0], $
        dimension=[1.0,0.5])

    ; Models for the three atoms.
    oImageModel = obj_new('IDLgrModel')
    oContourModel = obj_new('IDLgrModel')
    oSurfaceModel = obj_new('IDLgrModel')

    ; The three atoms. The image has a palette, an attribute object.
    oPalette = obj_new('IDLgrPalette')
    oPalette->LoadCT, 5
    oImage = obj_new('IDLgrImage', data, palette=oPalette)
    oContour = obj_new('IDLgrContour', data, n_levels=15)
    oSurface = obj_new('IDLgrSurface', data, color=[0,0,255])

    ; Build the Object Graphics hierarchy (OGH).
    oSurfaceModel->Add, oSurface
    oContourModel->Add, oContour
    oImageModel->Add, oImage

    oSurfaceView->Add, oSurfaceModel
    oContourView->Add, oContourModel
    oImageView->Add, oImageModel

    oViewgroup->Add, oSurfaceView
    oViewgroup->Add, oContourView
    oViewgroup->Add, oImageView

    ; Don't forget to add the palette to the viewgroup for proper disposal.
    oViewgroup->Add, oPalette

    ; Calculate coordinate conversion factors for the three atoms.
    setcc, [oSurface, oContour, oImage]

    ; Rotate the model containing the surface object.
    oSurfaceModel->Rotate, [1,0,0], -90
    oSurfaceModel->Rotate, [0,1,0], 45
    oSurfaceModel->Rotate, [1,0,0], 40

    ; Destination object. Use the graphics_tree property.
    oWindow = obj_new('IDLgrWindow', $
        dimensions=[400,400], $
        title='View3', $
        graphics_tree=oViewgroup)

    ; Render the OGH to the destination.
    oWindow->Draw
end





