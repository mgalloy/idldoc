;+
; An example of writing variables to a text file, using IDL explicit
; formatting rules.
;
; @examples
; <pre>
; IDL> ascii_write_ex1
; </pre>
; @uses ASCII_READ_EX4
; @requires IDL 5.2
; @author Mark Piper, RSI, 2004
;-
pro ascii_write_ex1
	compile_opt idl2

	;; Load the city data.
	ascii_read_ex4, lat, lon, city

	;; Find the cities in the Southern Hemisphere.
	i_south = where(lat lt 0.0, n_south)
	city_south = city[i_south]
	lat_south = lat[i_south]
	lon_south = lon[i_south]

	;; Sort the cities by increasing south latitude.
	sorted_city = city_south[sort(lat_south)]
	sorted_lat = lat_south[sort(lat_south)]
	sorted_lon = lon_south[sort(lat_south)]

	;; Write the city name and location to a file.
	openw, lun, 'southern_hemisphere_cities.txt', /get_lun
	printf, lun, format='("Cities in the Southern Hemisphere")'
	printf, lun
	printf, lun, format='(3x,"lat",5x,"lon",4x,"name")'
	printf, lun, format='(3x,"---",5x,"---",4x,"----")'
	for i = 0, n_south-1 do $
		printf, lun, sorted_lat[i], sorted_lon[i], sorted_city[i], $
			format='(2(f7.2,1x),a15)'
	free_lun, lun
end