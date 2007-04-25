

window, xsize=400, ysize=300
map_set, name='Mollweide', /noborder, /isotropic, $
        limit=[33.0, -106.0, 43.0, -92.0]
contour, g_temp, g_lon, g_lat, $
        /overplot, $
        levels=indgen(11)*2+278, $
        /follow, $
        c_colors=indgen(11)*20+20
map_grid
map_continents, /usa, fill_continents=1
map_continents, /usa, color=0
image = tvrd()
tvlct, r, g, b, /get
write_png, './pretty_picture.png', image

end
