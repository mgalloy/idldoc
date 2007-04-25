;+
; Launch routine for TileViewer object widget program.
;-
pro tileviewer
    compile_opt strictarr

    oviewer = obj_new('TileViewer', name='Tile Viewer')
    oviewer->createWidgets
    oviewer->realizeWidgets
    oviewer->startXmanager

    oviewer->openFile, '~/IDL/dev/advanced/tiler/ohareJP2.jp2'
end
