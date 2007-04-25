pro tileviewer::refreshGraphics
    compile_opt strictarr

    if (~obj_valid(self.imagedata)) then return

    tiles = self.owindow->queryRequiredTiles(self.oview, self.oimage, $
        count=ntiles)

    for t = 0L, ntiles - 1L do begin
        scale = ishft(1L, tiles[t].level)
        region = [tiles[t].x, tiles[t].y, tiles[t].width, tiles[t].height] * scale
        data = self.imageData->getData(region=region, $
            discard_levels=tiles[t].level)
        self.oimage->setTileData, tiles[t], data, no_free=0B
    endfor

    self.owindow->draw, self.oview
end


pro tileviewer::openFile, filename
    compile_opt strictarr

    self->setCurrentFilename, file_basename(filename)

    if (obj_valid(self.imagedata)) then obj_destroy, self.imagedata

    ; We could choose from multiple types of image data. Here we are just using
    ; JPEG2000 data to make it simpler.
    self.imagedata = obj_new('JPEG2000ImageData', filename)
    self.imagedata->getProperty, dimensions=dimensions

    self.oimage->setProperty, tiled_image_dimensions=dimensions

    self->refreshGraphics
end


pro tileviewer::open
    compile_opt strictarr

    f = dialog_pickfile(dialog_parent=self.tlb)
    self->openFile, f
end


pro tileviewer::zoomIn, vr
    compile_opt strictarr

    vr[0:1] += vr[2:3] /4L
    vr[2:3] /= 2L
    self.zoom_level--
    self.zoom_factor = self.zoom_level lt 0L ? 1.0 / (ishft(1L, -self.zoom_level)) : ishft(1L, self.zoom_level)
end


pro tileviewer::zoomOut, vr
    compile_opt strictarr

    vr[0:1] -= vr[2:3] / 2L
    vr[2:3] *= 2L
    self.zoom_level++
    self.zoom_factor = self.zoom_level lt 0L ? 1.0 / (ishft(1L, -self.zoom_level)) : ishft(1L, self.zoom_level)
end


pro tileviewer::handleDrawEvents, event
    compile_opt strictarr

    case event.type of
    0 : begin ; button press
            self.owindow->setCurrentCursor, 'MOVE'

            self.buttons_down or= event.press

            self.oview->getProperty, viewplane_rect=vr
            self.button_down_position = vr[0:1] + [event.x, event.y] * self.zoom_factor
        end
    1 : begin ; button release
            self.buttons_down xor= event.release
            if (self.buttons_down eq 0B) then self.owindow->setCurrentCursor, 'ARROW'
        end
    2 : begin ; motion event
            if (self.buttons_down eq 0) then return

            self.oview->getProperty, viewplane_rect=vr
            vr[0:1] = self.button_down_position - [event.x, event.y] * self.zoom_factor
            self.oview->setProperty, viewplane_rect=vr

            self->refreshGraphics
        end
    3 : ; scroll event
    4 : begin ; expose event
            self->refreshGraphics
        end
    5 : ; ASCII key press
    6 : begin ; non-ASCII key press
            if (event.press eq 0B) then return

            self.oview->getProperty, viewplane_rect=vr

            case event.key of
            5 : begin ; left
                    vr[0] -= (self.scr_xsize / 4L) * self.zoom_factor
                end
            6 : begin ; right
                    vr[0] += (self.scr_xsize / 4L) * self.zoom_factor
                end
            7 : begin ; up
                    vr[1] += (self.scr_ysize / 4L) * self.zoom_factor
                end
            8 : begin ; down
                    vr[1] -= (self.scr_ysize / 4L) * self.zoom_factor
                end
            9 : self->zoomIn, vr ; page up
            10 : self->zoomOut, vr ; page down
            else :
            endcase

            self.oview->setProperty, viewplane_rect=vr
            self->refreshGraphics
        end
    7 : begin ; scroll wheel (new in IDL 6.2)
            self.oview->getProperty, viewplane_rect=vr
            if (event.clicks lt 0) then self->zoomOut, vr else self->zoomIn, vr
            self.oview->setProperty, viewplane_rect=vr
            self->refreshGraphics
        end
    endcase
end


pro tileviewer::resize, x, y
    compile_opt strictarr

    tlbG = widget_info(self.tlb, /geometry)

    self.scr_xsize = x - 2 * tlbG.xpad
    self.scr_ysize = y - 2 * tlbG.ypad
    widget_control, self.draw, xsize=self.scr_xsize, ysize=self.scr_ysize

    self.oview->getProperty, viewplane_rect=vr
    vr[2:3] = [self.scr_xsize, self.scr_ysize] * self.zoom_factor
    self.oview->setProperty, viewplane_rect=vr

    self->refreshGraphics
end


pro tileviewer::handleEvents, event
    compile_opt strictarr

    uname = widget_info(event.id, /uname)

    case uname of
    'tlb' : self->resize, event.x, event.y
    'open' : self->open
    'exit' : widget_control, self.tlb, /destroy
    'draw' : self->handleDrawEvents, event
    endcase
end


pro tileviewer::cleanupWidgets
    compile_opt strictarr

    ; This widget program will destroy the TileViewer object when the widget
    ; interface goes away. This is a choice; the object could be persistent
    ; while the user interface comes and goes.
    obj_destroy, self
end


pro tileviewer::realizeWidgets
    compile_opt strictarr

    self->objectwidget::realizeWidgets
    widget_control, self.draw, get_value=owindow
    self.owindow = owindow
    widget_control, self.draw, /input_focus
    self.owindow->setCurrentCursor, 'ARROW'
end


pro tileviewer::createWidgets
    compile_opt strictarr

    self.tlb = widget_base(title=self.name, /column, mbar=menubar, $
        uname='tlb', uvalue=self, /tlb_size_events);, xpad=0L, ypad=0L)

    file_menu = widget_button(menubar, value='File', /menu)
    open_menu = widget_button(file_menu, value='Open', uname='open')
    exit_menu = widget_button(file_menu, value='Exit', uname='exit', /separator)

    self.draw = widget_draw(self.tlb, graphics_level=2, uname='draw', retain=0, $
        xsize=self.scr_xsize, ysize=self.scr_ysize, $
        /button_events, /motion_events, /expose_events, keyboard_events=2, $
        /wheel_events)
end


pro tileviewer::cleanup
    compile_opt strictarr

    self->objectwidget::cleanup
    obj_destroy, self.oview

    if (obj_valid(self.imagedata)) then obj_destroy, self.imagedata
end


function tileviewer::init, _ref_extra=e
    compile_opt strictarr

    if (~self->objectwidget::init(_strict_extra=e)) then return, 0B

    self.scr_xsize = 512L
    self.scr_ysize = 512L

    self.zoom_factor = 1L

    self.oview = obj_new('IDLgrView', name='view', color=[0B, 0B, 0B], $
        viewplane_rect=[0L, 0L, self.scr_xsize, self.scr_ysize])
    omodel = obj_new('IDLgrModel', name='model')
    self.oview->add, omodel
    self.oimage = obj_new('IDLgrImage', name='image', order=1, $
        /tiling, tile_level_mode=1B, $ ; /tile_show_boundaries, $
        tile_dimensions=[self.scr_xsize, self.scr_ysize])
    omodel->add, self.oimage

    return, 1B
end


;+
; Inherits from ObjectWidget.
;-
pro tileviewer__define
    compile_opt strictarr

    define = { tileviewer, inherits objectwidget, $
        draw : 0L, $
        scr_xsize : 0L, $
        scr_ysize : 0L, $
        buttons_down : 0B, $
        button_down_position : lonarr(2), $
        zoom_factor : 0.0, $
        zoom_level : 0L, $
        oview : obj_new(), $
        oimage : obj_new(), $
        owindow : obj_new(), $
        imagedata : obj_new() $
        }
end
