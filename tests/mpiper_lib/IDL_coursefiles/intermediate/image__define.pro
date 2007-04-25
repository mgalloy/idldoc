pro image::get, xsize=xsize, ysize=ysize
    compile_opt idl2

    xsize = self.xsize
    ysize = self.ysize
end


pro image::set, xsize=xsize, ysize=ysize
    compile_opt idl2

    new_xsize = n_elements(xsize) eq 0 ? self.xsize : xsize
    new_ysize = n_elements(ysize) eq 0 ? self.ysize : ysize

    self->resize, new_xsize, new_ysize
end


pro image::smooth, width
    compile_opt idl2

    *self.pimage = smooth(*self.pimage, width)
    self->display
end


pro image::histeq
    compile_opt idl2

    *self.pimage = hist_equal(*self.pimage)
    self->display
end


pro image::revert
    compile_opt idl2

    *self.pimage = *self.pimage_copy
    sz = size(*self.pimage, /dimensions)
    self->resize, sz[0], sz[1]
end


pro image::resize, new_xsize, new_ysize
    compile_opt idl2

    self.xsize = new_xsize
    self.ysize = new_ysize

    *self.pimage = congrid(*self.pimage_copy, new_xsize, new_ysize, $
        /interp)

    self->display
end


function image::create_view
    compile_opt idl2

    oview = obj_new('IDLgrView', name='view', $
        viewplane_rect=[0, 0, self.xsize, self.ysize])
    omodel = obj_new('IDLgrModel', name='model')
    oview->add, omodel
    oimage = obj_new('IDLgrImage', *self.pimage, name='image')
    omodel->add, oimage

    return, oview
end


pro image::display
    compile_opt idl2

    if (not obj_valid(self.window)) then begin
        oview = self->create_view()
        self.window = obj_new('IDLgrWindow', graphics_tree=oview, $
            dimensions=[self.xsize, self.ysize], $
            retain=2, title=self.name)
    endif else begin
        ; make sure view is present (needed for inheritance)
        self.window->getProperty, graphics_tree=oview
        if (not obj_valid(oview)) then oview = self->create_view()
        self.window->setProperty, graphics_tree=oview

        oview->setProperty, $
            viewplane_rect=[0, 0, self.xsize, self.ysize]
        oimage = oview->getByName('model/image')
        oimage->setProperty, data=*self.pimage

        self.window->setProperty, dimensions=[self.xsize, self.ysize]
    endelse

    self.window->draw
end


pro image::cleanup
    compile_opt idl2

    ptr_free, self.pimage, self.pimage_copy
    obj_destroy, self.window
end


function image::init, filename, xsize, ysize
    compile_opt idl2

    if (n_params() ne 3) then return, 0

    openr, lun, filename, /get_lun
    image = bytarr(xsize, ysize)
    readu, lun, image
    free_lun, lun

    self.name = filename
    self.xsize = xsize
    self.ysize = ysize
    self.pimage = ptr_new(image)
    self.pimage_copy = ptr_new(image, /no_copy)
    self.window = obj_new()

    return, 1
end


pro image__define
    compile_opt idl2

    define = { image, $
        name:'', $
        xsize:0L, $
        ysize:0L, $
        pimage:ptr_new(), $
        pimage_copy:ptr_new(), $
        window:obj_new() $
        }
end