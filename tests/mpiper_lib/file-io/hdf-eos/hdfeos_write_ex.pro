;+
; Test with
; IDL> newfile = dialog_pickfile(filter='*.hdf')
; IDL> ok = eos_gd_query(newfile, 'InterruptGoodeGrid', info)
;-


;; Read the datafields from the file.
fields = ['TSurfAir', 'Longitude', 'Latitude']
ok = read_l12_swath_file(file, 3, b, content_list=fields)
help, ok, b, /structures

;; Weed out bad points.
bad = where(b.tsurfair eq -9999.0, n_bad)
help, bad
grid_input, b.longitude, b.latitude, b.tsurfair, lon, lat, tsfc, exclude=bad
help, lon, lat, tsfc

;; Set up a regular lat-lon grid with 0.5 degree resolution.
lon_min = floor(min(lon))
lon_max = ceil(max(lon))
lat_min = floor(min(lat))
lat_max = ceil(max(lat))
help, lon_min, lon_max, lat_min, lat_max
lon_range = lon_max - lon_min
lat_range = lat_max - lat_min
help, lon_range, lat_range
delta = 0.5
n_lon_nodes = lon_range/delta + 1
n_lat_nodes = lat_range/delta + 1
lon_grid_nodes = findgen(n_lon_nodes)*delta + lon_min
lat_grid_nodes = findgen(n_lat_nodes)*delta + lat_min
help, lon_grid_nodes
print, lon_grid_nodes

;; Display locations of original points.
window, 0, xsize=450, ysize=350, title='Original Locations'
plot, findgen(2), /nodata, $
    xrange=[lon_min,lon_max], yrange=[lat_min,lat_max], $
    xtitle='Longitude (deg W)', ytitle='Latitude (deg N)'
plots, lon, lat, psym=5, symsize=0.8

;; Interpolate the original data to a regular lat-lon grid.
tgrid = griddata(lon, lat, tsfc, $
    /inverse_distance, $
    power=2, $
    /grid, $
    xout=lon_grid_nodes, $
    yout=lat_grid_nodes)
help, tgrid

;; Create a projection.
map = map_proj_init('Interrupted Goode')
help, map

;; Map the lat-lon grid nodes to the projection.
lon_grid_vals = lon_grid_nodes # (fltarr(n_lat_nodes)+1.0)
lat_grid_vals = (fltarr(n_lon_nodes)+1.0) # lat_grid_nodes
pairs = fltarr(2, n_lat_nodes*n_lon_nodes)
pairs[0,*] = reform(lon_grid_vals, 1, n_lat_nodes*n_lon_nodes)
pairs[1,*] = reform(lat_grid_vals, 1, n_lat_nodes*n_lon_nodes)
xy = map_proj_forward(pairs, map_structure=map)
help, xy

;; Open a new HDF-EOS file.
fid = eos_gd_open('sfctempgrid.hdf', /create)
help, fid

;; Create a grid object.
ul = fltarr(2)
lr = fltarr(2)
ul[0] = xy[0,0]
ul[1] = xy[1,0]
lr[0] = xy[0,n_lat_nodes*n_lon_nodes-1]
lr[1] = xy[1,n_lat_nodes*n_lon_nodes-1]
gid = eos_gd_create(fid, 'InterruptGoodeGrid', $
    n_lon_nodes, n_lat_nodes, ul, lr)
help, gid 

;; Define a projection. Codes from HDF-EOS User Guide.
proj_code = 24 ; Interrupted Goode Homolosize
zone_code = 0 ; UTM zone, not used
sphere_code = 0 ; default Clarke 1866 spheroid
proj_params = lonarr(13) ; zeros are default
ok = eos_gd_defproj(gid, proj_code, zone_code, sphere_code, proj_params)
help, ok

;; Define dimensions.
;ok = eos_gd_defdim(gid, 'nLonNodes', n_lon_nodes) 
;ok = eos_gd_defdim(gid, 'nLatNodes', n_lat_nodes) 
;ok = eos_gd_defdim(gid, 'nNodes', n_lon_nodes*n_lat_nodes) 

;; Define datafields.
ok = eos_gd_deffield(gid, 'SurfaceTemperature', 'YDim,XDim', 5)
help, ok
;ok = eos_gd_deffield(gid, 'LonNodes', 'nLonNodes', 5)
;ok = eos_gd_deffield(gid, 'LatNodes', 'nLatNodes', 5)
;ok = eos_gd_deffield(gid, 'xMapVals', 'nNodes', 5)
;ok = eos_gd_deffield(gid, 'yMapVals', 'nNodes', 5)

;; Detach the object and reattach it. This is vitally important for
;; reasons undescribed.
ok = eos_gd_detach(gid)
help, ok
gid = eos_gd_attach(fid, 'InterruptGoodeGrid')  
help, gid

;; Write data to the file.
ok = eos_gd_writefield(gid, 'SurfaceTemperature', tgrid)
;ok = eos_gd_writefield(gid, 'LonNodes', lon_grid_nodes)
;ok = eos_gd_writefield(gid, 'LatNodes', lat_grid_nodes)
;ok = eos_gd_writefield(gid, 'xMapVals', xy[0,*])
;ok = eos_gd_writefield(gid, 'yMapVals', xy[1,*])

;; Close the file.
ok = eos_gd_close(fid)
help, ok

end
