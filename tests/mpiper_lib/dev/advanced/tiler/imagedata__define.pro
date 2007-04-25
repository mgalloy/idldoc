function imagedata::getData, region=region, max_layers=max_layers, $
    discard_levels=discard_levels
    compile_opt strictarr

    ; implemented by subclasses
end


pro imagedata::getProperty, filename=filename, tile_dimensions=tile_dimensions, $
    n_layers=n_layers, dimensions=dimensions
    compile_opt strictarr

    filename = self.filename
    tile_dimensions = self.tile_dimensions
    n_layers = self.n_layers
    dimensions = self.dimensions
end


pro imagedata::cleanup
    compile_opt strictarr

    ; nothing needs to be done
end


function imagedata::init, filename, tile_dimensions=tile_dimensions
    compile_opt strictarr

    self.filename = filename
    self.tile_dimensions = n_elements(tile_dimensions) eq 0L ? [1024L, 1024L] : tile_dimensions

    return, 1B
end


pro imagedata__define
    compile_opt strictarr

    define = { imagedata, $
        filename : '', $
        tile_dimensions : lonarr(2), $
        n_layers : 0L, $
        dimensions : lonarr(2) $
        }
end