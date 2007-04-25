function jpeg2000imagedata::getData, region=region, max_layers=max_layers, $
    discard_levels=discard_levels
    compile_opt strictarr

    o = obj_new('IDLffJPEG2000', self.filename, persistent=0)
    data = o->getData(region=region, discard_levels=discard_levels, $
        max_layers=max_layers, order=1)
    obj_destroy, o

    return, data
end


pro jpeg2000imagedata::getProperty, _ref_extra=e
    compile_opt strictarr

    self->imagedata::getProperty, _strict_extra=e
end


pro jpeg2000imagedata::cleanup
    compile_opt strictarr

    ; nothing needs to be done
end


function jpeg2000imagedata::init, filename, tile_dimensions=tile_dimensions
    compile_opt strictarr

    if (~self->imagedata::init(filename, tile_dimensions=tile_dimensions)) then return, 0B

    o = obj_new('IDLffJPEG2000', self.filename, persistent=0)
    o->getProperty, n_layers=n_layers, dimensions=dimensions
    obj_destroy, o

    self.n_layers = n_layers
    self.dimensions = dimensions

    return, 1B
end


pro jpeg2000imagedata__define
    compile_opt strictarr

    define = { jpeg2000imagedata, inherits imagedata }
end