
pro view_contour

    ; Make a contour object with ten contour levels to be displayed
    ; on the plane z = 0.
    ocontour = obj_new('idlgrcontour', dist(30), $
                      n_levels=10, $
                      /planar, $
                      geomz=0)

    ; Make the contours blue. Note that this could have been done
	; in the instantiation statement above.
	ocontour->setproperty, color=[0,0,255]

    ; Make a model object.
    omodel = obj_new('idlgrmodel')

    ; Make a view object & size it to hold the contour.
    oview = obj_new('idlgrview', $
                    viewplane_rect=[-5, -5, 40, 40])

    ; Build the object tree by adding the model to the view
    ; & the contour to the model.
    oview->add, omodel
    omodel->add, ocontour

    ; Make a window object. See "Other Performance Issues" for
    ; more on retain=2.
    owindow = obj_new('idlgrwindow', $
                      retain=2, $
                      graphics_tree=oview, $
                      dimensions=[300,200])

    ; Render the object tree to the window.
    owindow->draw

end
