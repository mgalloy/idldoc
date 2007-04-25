;-------------------------------------------------------------------------------
FUNCTION IMDISP_GETPOS, ASPECT, POSITION=POSITION, MARGIN=MARGIN

;- Compute a position vector given an aspect ratio (called by IMDISP_IMSIZE)

;- Check arguments
if (n_params() ne 1) then message, 'Usage: RESULT = IMDISP_GETPOS(ASPECT)'
if (n_elements(aspect) eq 0) then message, 'ASPECT is undefined'

;- Check keywords
if (n_elements(position) eq 0) then position = [0.0, 0.0, 1.0, 1.0]
if (n_elements(margin) eq 0) then margin = 0.1

;- Get range limited aspect ratio and margin input values
aspect_val = (float(aspect[0]) > 0.01) < 100.0
margin_val = (float(margin[0]) > 0.0) < 0.495

;- Compute aspect ratio of position vector in this window
xsize = (position[2] - position[0]) * !d.x_vsize
ysize = (position[3] - position[1]) * !d.y_vsize
cur_aspect = ysize / xsize

;- Compute aspect ratio of this window
win_aspect = float(!d.y_vsize) / float(!d.x_vsize)

;- Compute height and width in normalized units
if (aspect_val ge cur_aspect) then begin
  height = (position[3] - position[1]) - 2.0 * margin
  width  = height * (win_aspect / aspect_val)
endif else begin
  width  = (position[2] - position[0]) - 2.0 * margin
  height = width * (aspect_val / win_aspect)
endelse

;- Compute and return position vector
xcenter = 0.5 * (position[0] + position[2])
ycenter = 0.5 * (position[1] + position[3])
x0 = xcenter - 0.5 * width
y0 = ycenter - 0.5 * height
x1 = xcenter + 0.5 * width
y1 = ycenter + 0.5 * height
return, [x0, y0, x1, y1]

END
;-------------------------------------------------------------------------------
FUNCTION IMDISP_IMSCALE, IMAGE, RANGE=RANGE, BOTTOM=BOTTOM, NCOLORS=NCOLORS, $
  NEGATIVE=NEGATIVE

;- Byte-scale an image (called by IMDISP)

;- Check arguments
if (n_params() ne 1) then message, 'Usage: RESULT = IMDISP_IMSCALE(IMAGE)'
if (n_elements(image) eq 0) then message, 'Argument IMAGE is undefined'

;- Check keywords
if (n_elements(range) eq 0) then begin
  min_value = min(image, max=max_value)
  range = [min_value, max_value]
endif
if (n_elements(bottom) eq 0) then bottom = 0B
if (n_elements(ncolors) eq 0) then ncolors = !d.table_size - bottom

;- Compute the scaled image
scaled = bytscl(image, min=range[0], max=range[1], top=(ncolors - 1))

;- Create a negative image if required
if keyword_set(negative) then scaled = byte(ncolors - 1) - scaled

;- Return the scaled image in the correct color range
return, scaled + byte(bottom)

END
;-------------------------------------------------------------------------------
FUNCTION IMDISP_IMREGRID, DATA, NX, NY, INTERP=INTERP

;- Regrid a 2D array (called by IMDISP)

;- Check arguments
if (n_params() ne 3) then $
  message, 'Usage: RESULT = IMDISP_IMREGRID(DATA, NX, NY)'
if (n_elements(data) eq 0) then message, 'Argument DATA is undefined'
result = size(data)
ndims = result[0]
dims = result[1:ndims]
if (ndims ne 2) then message, 'Argument DATA must have 2 dimensions'
if (n_elements(nx) eq 0) then message, 'Argument NX is undefined'
if (n_elements(ny) eq 0) then message, 'Argument NY is undefined'
if (nx lt 1) then message, 'NX must be 1 or greater'
if (ny lt 1) then message, 'NY must be 1 or greater'

;- Copy the array if the requested size is the same as the current size
if (nx eq dims[0]) and (ny eq dims[1]) then begin
  new = data
  return, new
endif

;- Compute index arrays for bilinear interpolation
xindex = (findgen(nx) + 0.5) * (dims[0] / float(nx)) - 0.5
yindex = (findgen(ny) + 0.5) * (dims[1] / float(ny)) - 0.5

;- Round the index arrays if nearest neighbor sampling is required
if (keyword_set(interp) eq 0) then begin
  xindex = round(xindex)
  yindex = round(yindex)
endif

;- Return regridded array
return, interpolate(data, xindex, yindex, /grid)

END
;-------------------------------------------------------------------------------
PRO IMDISP_IMSIZE, IMAGE, X0, Y0, XSIZE, YSIZE, ASPECT=ASPECT, $
  POSITION=POSITION, MARGIN=MARGIN

;- Compute the size and offset for an image (called by IMDISP)

;- Check arguments
if (n_params() ne 5) then $
  message, 'Usage: IMDISP_IMSIZE, IMAGE, X0, Y0, XSIZE, YSIZE'
if (n_elements(image) eq 0) then $
  message, 'Argument IMAGE is undefined'
if (n_elements(position) eq 0) then position = [0.0, 0.0, 1.0, 1.0]
if (n_elements(position) ne 4) then $
  message, 'POSITION must be a 4 element vector'
if (n_elements(margin) eq 0) then margin = 0.1
if (n_elements(margin) ne 1) then $
  message, 'MARGIN must be a scalar'

;- Get image dimensions
result = size(image)
ndims = result[0]
if (ndims ne 2) then message, 'IMAGE must be a 2D array'
dims = result[1 : ndims]

;- Get aspect ratio for image
if (n_elements(aspect) eq 0) then $
  aspect = float(dims[1]) / float(dims[0])
if (n_elements(aspect) ne 1) then $
  message, 'ASPECT must be a scalar'

;- Check output parameters
if (arg_present(x0) ne 1) then message, 'Argument XO cannot be set'
if (arg_present(y0) ne 1) then message, 'Argument YO cannot be set'
if (arg_present(xsize) ne 1) then message, 'Argument XSIZE cannot be set'
if (arg_present(ysize) ne 1) then message, 'Argument YSIZE cannot be set'

;- Get approximate image position
position = imdisp_getpos(aspect, position=position, margin=margin)

;- Compute lower left position of image (device units)
x0 = round(position[0] * !d.x_vsize) > 0L
y0 = round(position[1] * !d.y_vsize) > 0L

;- Compute size of image (device units)
xsize = round((position[2] - position[0]) * !d.x_vsize) > 2L
ysize = round((position[3] - position[1]) * !d.y_vsize) > 2L

;- Recompute the image position based on actual image size
position = fltarr(4)
position[0] = x0 / float(!d.x_vsize)
position[1] = y0 / float(!d.y_vsize)
position[2] = (x0 + xsize) / float(!d.x_vsize)
position[3] = (y0 + ysize) / float(!d.y_vsize)

END
;-------------------------------------------------------------------------------
PRO IMDISP, IMAGE, RANGE=RANGE, BOTTOM=BOTTOM, NCOLORS=NCOLORS, $
  MARGIN=MARGIN, INTERP=INTERP, DITHER=DITHER, ASPECT=ASPECT, $
  POSITION=POSITION, OUT_POS=OUT_POS, NOSCALE=NOSCALE, NORESIZE=NORESIZE, $
  ORDER=ORDER, USEPOS=USEPOS, CHANNEL=CHANNEL, $
  BACKGROUND=BACKGROUND, ERASE=ERASE, $
  AXIS=AXIS, NEGATIVE=NEGATIVE, _EXTRA=EXTRA_KEYWORDS

;+
; NAME:
;    IMDISP
;
; PURPOSE:
;    Display an image on the current graphics device.
;    IMDISP is an advanced replacement for TV and TVSCL.
;
;    - Supports WIN, MAC, X, CGM, PCL, PRINTER, PS, and Z graphics devices,
;    - Image is automatically byte-scaled (can be disabled),
;    - Custom byte-scaling of Pseudo color images via the RANGE keyword,
;    - Pseudo (indexed) color and True color images are handled automatically,
;    - 8-bit and 24-bit graphics devices  are handled automatically,
;    - Decomposed color settings are handled automatically,
;    - Image is automatically sized to fit the display (can be disabled),
;    - The !P.MULTI system variable is honored for multiple image display,
;    - Image can be positioned via the POSITION keyword,
;    - Color table splitting via the BOTTOM and NCOLORS keywords,
;    - Image aspect ratio customization via the ASPECT keyword,
;    - Resized images can be resampled (default) or interpolated,
;    - Top down image display via the ORDER keyword (!ORDER is ignored),
;    - Selectable display channel (R/G/B) via the CHANNEL keyword,
;    - Background can be set to a specified color via the BACKGROUND keyword,
;    - Screen can be erased prior to image display via the ERASE keyword,
;    - Plot axes can be drawn on the image via the AXIS keyword,
;    - Photographic negative images can be displayed via the NEGATIVE keyword.
;
; CATEGORY:
;    Image display
;
; CALLING SEQUENCE:
;    IMDISP, IMAGE
;
; INPUTS:
;    IMAGE       Array containing image data.
;                Pseudo (indexed) color images must have 2 dimensions.
;                True color images must have 3 dimensions, in either
;                [3, NX, NY], [NX, 3, NY], or [NX, NY, 3] form.
;
; OPTIONAL INPUTS:
;    None.
;
; KEYWORD PARAMETERS:
;    RANGE       For Pseudo Color images only, a vector with two elements
;                specifying the minimum and maximum values of the image
;                array to be considered when the image is byte-scaled
;                (default is minimum and maximum array values).
;                This keyword is ignored for True Color images,
;                or if the NOSCALE keyword is set.
;
;    BOTTOM      Bottom value in the color table to be used
;                for the byte-scaled image
;                (default is 0).
;                This keyword is ignored if the NOSCALE keyword is set.
;
;    NCOLORS     Number of colors in the color table to be used
;                for the byte-scaled image
;                (default is !D.TABLE_SIZE - BOTTOM).
;                This keyword is ignored if the NOSCALE keyword is set.
;
;    MARGIN      A scalar value specifying the margin to be maintained
;                around the image in normal coordinates
;                (default is 0.1, or 0.025 if !P.MULTI is set to display
;                multiple images).
;
;    INTERP      If set, the resized image will be interpolated using
;                bilinear interpolation
;                (default is nearest neighbor sampling).
;
;    DITHER      If set, true color images will be dithered when displayed
;                on an 8-bit graphics device
;                (default is no dithering).
;
;    ASPECT      A scalar value specifying the aspect ratio (height/width)
;                for the displayed image
;                (default is to maintain native aspect ratio).
;
;    POSITION    On input, a 4-element vector specifying the position
;                of the displayed image in the form [X0,Y0,X1,Y1] in
;                in normal coordinates
;                (default is [0.0,0.0,1.0,1.0]).
;                See the examples below to display an image where only the
;                offset and size are known (e.g. MAP_IMAGE output).
;
;    OUT_POS     On output, a 4-element vector specifying the position
;                actually used to display the image.
;
;    NOSCALE     If set, the image will not be byte-scaled
;                (default is to byte-scale the image).
;
;    NORESIZE    If set, the image will not be resized.
;                (default is to resize the image to fit the display).
;
;    ORDER       If set, the image is displayed from the top down
;                (default is to display the image from the bottom up).
;                Note that the system variable !ORDER is always ignored.
;
;    USEPOS      If set, the image will be sized to exactly fit a supplied
;                POSITION vector, over-riding ASPECT and MARGIN
;                (default is to honor ASPECT and MARGIN when a POSITION
;                vector is supplied).
;
;    CHANNEL     Display channel (Red, Green, or Blue) to be written.
;                0 => All channels (the default)
;                1 => Red channel
;                2 => Green channel
;                3 => Blue channel
;                This keyword is only recognized by graphics devices which
;                support 24-bit decomposed color (WIN, MAC, X). It is ignored
;                by all other graphics devices. However True color (RGB)
;                images can be displayed on any device supported by IMDISP.
;
;    BACKGROUND  If set to a positive integer, the background will be filled
;                with the color defined by BACKGROUND.
;
;    ERASE       If set, the screen contents will be erased. Note that if
;                !P.MULTI is set to display multiple images, the screen is
;                always erased when the first image is displayed.
;
;    AXIS        If set, plot axes will be drawn on the image. The default
;                x and y axis ranges are determined by the size of the image.
;                When the AXIS keyword is set, IMDISP accepts any keywords
;                supported by PLOT (e.g. TITLE, COLOR, CHARSIZE etc.).
;
;    NEGATIVE    If set, a photographic negative of the image is displayed.
;                The values of BOTTOM and NCOLORS are honored. This keyword
;                allows True color images scanned from color negatives to be
;                displayed. It also allows Pseudo color images to be displayed
;                as negatives without reversing the color table. This keyword
;                is ignored if the NOSCALE keyword is set.
;
; OUTPUTS:
;    None.
;
; OPTIONAL OUTPUTS:
;    None
;
; COMMON BLOCKS:
;    None
;
; SIDE EFFECTS:
;    The image is displayed on the current graphics device.
;
; RESTRICTIONS:
;    Requires IDL 5.0 or higher (square bracket array syntax).
;
; EXAMPLE:
;
;;- Load test data
;
;openr, lun, filepath('ctscan.dat', subdir='examples/data'), /get_lun
;ctscan = bytarr(256, 256)
;readu, lun, ctscan
;free_lun, lun
;openr, lun, filepath('hurric.dat', subdir='examples/data'), /get_lun
;hurric = bytarr(440, 330)
;readu, lun, hurric
;free_lun, lun
;read_jpeg, filepath('rose.jpg', subdir='examples/data'), rose
;help, ctscan, hurric, rose
;
;;- Display single images
;
;!p.multi = 0
;loadct, 0
;imdisp, hurric, /erase
;wait, 3.0
;imdisp, rose, /interp, /erase
;wait, 3.0
;
;;- Display multiple images without color table splitting
;;- (works on 24-bit displays only; top 2 images are garbled on 8-bit displays)
;
;!p.multi = [0, 1, 3, 0, 0]
;loadct, 0
;imdisp, ctscan, margin=0.02
;loadct, 13
;imdisp, hurric, margin=0.02
;imdisp, rose, margin=0.02
;wait, 3.0
;
;;- Display multiple images with color table splitting
;;- (works on 8-bit or 24-bit displays)
;
;!p.multi = [0, 1, 3, 0, 0]
;loadct, 0, ncolors=64, bottom=0
;imdisp, ctscan, margin=0.02, ncolors=64, bottom=0
;loadct, 13, ncolors=64, bottom=64
;imdisp, hurric, margin=0.02, ncolors=64, bottom=64
;imdisp, rose, margin=0.02, ncolors=64, bottom=128
;wait, 3.0
;
;;- Display an image at a specific position, over-riding aspect and margin
;
;!p.multi = 0
;loadct, 0
;imdisp, hurric, position=[0.0, 0.0, 1.0, 0.5], /usepos, /erase
;wait, 3.0
;
;;- Display an image with axis overlay
;
;!p.multi = 0
;loadct, 0
;imdisp, rose, /axis, /erase
;wait, 3.0
;
;;- Display an image with contour plot overlay
;
;!p.multi = 0
;loadct, 0
;imdisp, hurric, out_pos=out_pos, /erase
;contour, smooth(hurric, 10, /edge), /noerase, position=out_pos, $
;  xstyle=1, ystyle=1, levels=findgen(5)*40.0, /follow
;wait, 3.0
;
;;- Display a small image with correct resizing
;
;!p.multi = 0
;loadct, 0
;data = (dist(8))[1:7, 1:7]
;imdisp, data, /erase
;wait, 3.0
;imdisp, data, /interp
;wait, 3.0
;
;;- Display a true color image without and with interpolation
;
;!p.multi = 0
;imdisp, rose, /erase
;wait, 3.0
;imdisp, rose, /interp
;wait, 3.0
;
;;- Display a true color image as a photographic negative
;
;imdisp, rose, /negative, /erase
;wait, 3.0
;
;;- Display a true color image on PostScript output
;;- (note that color table is handled automatically)
;
;current_device = !d.name
;set_plot, 'PS'
;device, /color, bits_per_pixel=8, filename='imdisp_true.ps'
;imdisp, rose, /axis, title='PostScript True Color Output'
;device, /close
;set_plot, current_device
;
;;- Display a pseudo color image on PostScript output
;
;current_device = !d.name
;set_plot, 'PS'
;device, /color, bits_per_pixel=8, filename='imdisp_pseudo.ps'
;loadct, 0
;imdisp, hurric, /axis, title='PostScript Pseudo Color Output'
;device, /close
;set_plot, current_device
;
;;- Display an image where only the offset and size are known
;
;;- Read world elevation data
;file = filepath('worldelv.dat', subdir='examples/data')
;openr, lun, file, /get_lun
;data = bytarr(360, 360)
;readu, lun, data
;free_lun, lun
;;- Reorganize array so it spans 180W to 180E
;world = data
;world[0:179, *] = data[180:*, *]
;world[180:*, *] = data[0:179, *]
;;- Create remapped image
;map_set, /orthographic, /isotropic, /noborder
;remap = map_image(world, x0, y0, xsize, ysize, compress=1)
;;- Convert offset and size to position vector
;pos = fltarr(4)
;pos[0] = x0 / float(!d.x_vsize)
;pos[1] = y0 / float(!d.y_vsize)
;pos[2] = (x0 + xsize) / float(!d.x_vsize)
;pos[3] = (y0 + ysize) / float(!d.y_vsize)
;;- Display the image
;loadct, 0
;imdisp, remap, pos=pos, /usepos
;map_continents
;map_grid
;
; MODIFICATION HISTORY:
; Liam.Gumley@ssec.wisc.edu
; http://cimss.ssec.wisc.edu/~gumley
; $Id: imdisp.pro,v 1.47 2002/06/05 16:31:07 gumley Exp $
;
; Copyright (C) 1999, 2000 Liam E. Gumley
;
; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
;-

rcs_id = '$Id: imdisp.pro,v 1.47 2002/06/05 16:31:07 gumley Exp $'

;-------------------------------------------------------------------------------
;- CHECK INPUT
;-------------------------------------------------------------------------------

;- Check arguments
if (n_params() ne 1) then message, 'Usage: IMDISP, IMAGE'
if (n_elements(image) eq 0) then message, 'Argument IMAGE is undefined'
if (max(!p.multi) eq 0) then begin
  if (n_elements(margin) eq 0) then begin
    if (n_elements(position) eq 4) then margin = 0.0 else margin = 0.1
  endif
endif else begin
  if (n_elements(margin) eq 0) then margin = 0.025
endelse
if (n_elements(order) eq 0) then order = 0
if (n_elements(channel) eq 0) then channel = 0

;- Check position vector
if (n_elements(position) gt 0) then begin
  if (n_elements(position) ne 4) then $
    message, 'POSITION must be a 4 element vector of the form [X0, Y0, X1, Y1]'
  if (position[0] lt 0.0) then message, 'POSITION[0] must be GE 0.0'
  if (position[1] lt 0.0) then message, 'POSITION[1] must be GE 0.0'
  if (position[2] gt 1.0) then message, 'POSITION[2] must be LE 1.0'
  if (position[3] gt 1.0) then message, 'POSITION[3] must be LE 1.0'
  if (position[0] ge position[2]) then $
    message, 'POSITION[0] must be LT POSITION[2]'
  if (position[1] ge position[3]) then $
    message, 'POSITION[1] must be LT POSITION[3]'
endif

;- Check the image dimensions
result = size(image)
ndims = result[0]
if (ndims lt 2) or (ndims gt 3) then $
  message, 'IMAGE must be a Pseudo Color (2D) or True Color (3D) image array'
dims = result[1:ndims]

;- Check that 3D image array is in valid true color format
true = 0
if (ndims eq 3) then begin
  index = where(dims eq 3L, count)
  if (count eq 0) then $
    message, 'True Color dimensions must be [3,NX,NY], [NX,3,NY], or [NX,NY,3]'
  true = 1
  truedim = index[0]
endif

;- Check scaling range for pseudo color images
if (true eq 0) then begin
  if (n_elements(range) eq 0) then begin
    min_value = min(image, max=max_value)
    range = [min_value, max_value]
  endif
  if (n_elements(range) ne 2) then $
    message, 'RANGE keyword must be a 2-element vector'
endif else begin
  if (n_elements(range) gt 0) then $
    message, 'RANGE keyword is not used for True Color images', /continue
endelse

;- Check for supported graphics devices
names = ['WIN', 'MAC', 'X', 'CGM', 'PCL', 'PRINTER', 'PS', 'Z']
result = where((!d.name eq names), count)
if (count eq 0) then message, 'Graphics device is not supported'

;- Get color table information
if ((!d.flags and 256) ne 0) and (!d.window lt 0) then begin
  window, /free, /pixmap
  wdelete, !d.window
endif
if (n_elements(bottom) eq 0) then bottom = 0
if (n_elements(ncolors) eq 0) then ncolors = !d.table_size - bottom

;- Get IDL version number
version = float(!version.release)

;- Check for IDL 5.2 or higher if printer device is selected
if (version lt 5.2) and (!d.name eq 'PRINTER') then $
  message, 'IDL 5.2 or higher is required for PRINTER device support'

;-------------------------------------------------------------------------------
;- GET RED, GREEN, AND BLUE COMPONENTS OF TRUE COLOR IMAGE
;-------------------------------------------------------------------------------

if (true eq 1) then begin
    case truedim of
      0 : begin
            red = image[0, *, *]
            grn = image[1, *, *]
            blu = image[2, *, *]
      end
      1 : begin
            red = image[*, 0, *]
            grn = image[*, 1, *]
            blu = image[*, 2, *]
      end
      2 : begin
            red = image[*, *, 0]
            grn = image[*, *, 1]
            blu = image[*, *, 2]
      end
  endcase
  red = reform(red, /overwrite)
  grn = reform(grn, /overwrite)
  blu = reform(blu, /overwrite)
endif

;-------------------------------------------------------------------------------
;- COMPUTE POSITION FOR IMAGE
;-------------------------------------------------------------------------------

;- Save first element of !p.multi
multi_first = !p.multi[0]

;- Establish image position if not defined
if (n_elements(position) eq 0) then begin
  if (max(!p.multi) eq 0) then begin
    position = [0.0, 0.0, 1.0, 1.0]
  endif else begin
    plot, [0], /nodata, xstyle=4, ystyle=4, xmargin=[0, 0], ymargin=[0, 0]
    position = [!x.window[0], !y.window[0], !x.window[1], !y.window[1]]
  endelse
endif

;- Erase and fill the background if required
if (multi_first eq 0) then begin
  if keyword_set(erase) then erase
  if (n_elements(background) gt 0) then begin
    polyfill, [-0.01,  1.01,  1.01, -0.01, -0.01], $
      [-0.01, -0.01,  1.01,  1.01, -0.01], /normal, color=background[0]
  endif
endif

;- Compute image aspect ratio if not defined
if (n_elements(aspect) eq 0) then begin
  case true of
    0 : result = size(image)
    1 : result = size(red)
  endcase
  dims = result[1:2]
  aspect = float(dims[1]) / float(dims[0])
endif

;- Save image xrange and yrange for axis overlays
xrange = [0, dims[0]]
yrange = [0, dims[1]]
if (order eq 1) then yrange = reverse(yrange)

;- Set the aspect ratio and margin to fill the position window if requested
if keyword_set(usepos) then begin
  xpos_size = float(!d.x_vsize) * (position[2] - position[0])
  ypos_size = float(!d.y_vsize) * (position[3] - position[1])
  aspect_value = ypos_size / xpos_size
  margin_value = 0.0
endif else begin
  aspect_value = aspect
  margin_value = margin
endelse

;- Compute size of displayed image and save output position
pos = position
case true of
  0 : imdisp_imsize, image, x0, y0, xsize, ysize, position=pos, $
        aspect=aspect_value, margin=margin_value
  1 : imdisp_imsize,   red, x0, y0, xsize, ysize, position=pos, $
        aspect=aspect_value, margin=margin_value
endcase
out_pos = pos

;-------------------------------------------------------------------------------
;- BYTE-SCALE THE IMAGE IF REQUIRED
;-------------------------------------------------------------------------------

;- Choose whether to scale the image or not
if (keyword_set(noscale) eq 0) then begin

  ;- Scale the image
  case true of
    0 : scaled = imdisp_imscale(image, bottom=bottom, ncolors=ncolors, $
          range=range, negative=keyword_set(negative))
    1 : begin
          scaled_dims = (size(red))[1:2]
          scaled = bytarr(scaled_dims[0], scaled_dims[1], 3)
          scaled[0, 0, 0] = imdisp_imscale(red, bottom=0, ncolors=256, $
            negative=keyword_set(negative))
          scaled[0, 0, 1] = imdisp_imscale(grn, bottom=0, ncolors=256, $
            negative=keyword_set(negative))
          scaled[0, 0, 2] = imdisp_imscale(blu, bottom=0, ncolors=256, $
            negative=keyword_set(negative))
        end
  endcase

endif else begin

  ;- Don't scale the image
  case true of
    0 : scaled = image
    1 : begin
          scaled_dims = (size(red))[1:2]
          scaled = replicate(red[0], scaled_dims[0], scaled_dims[1], 3)
          scaled[0, 0, 0] = red
          scaled[0, 0, 1] = grn
          scaled[0, 0, 2] = blu
        end
  endcase

endelse

;-------------------------------------------------------------------------------
;- DISPLAY IMAGE ON PRINTER DEVICE
;-------------------------------------------------------------------------------

if (!d.name eq 'PRINTER') then begin

  ;- Display the image
  case true of
    0 : begin
          device, /index_color
          tv, scaled, x0, y0, xsize=xsize, ysize=ysize, order=order
        end
    1 : begin
          device, /true_color
          tv, scaled, x0, y0, xsize=xsize, ysize=ysize, order=order, true=3
        end
  endcase

  ;- Draw axes if required
  if keyword_set(axis) then $
    plot, [0], /nodata, /noerase, position=out_pos, $
      xrange=xrange, xstyle=1, yrange=yrange, ystyle=1, $
      _extra=extra_keywords

  ;- Return to caller
  return

endif

;-------------------------------------------------------------------------------
;- DISPLAY IMAGE ON GRAPHICS DEVICES WHICH HAVE SCALEABLE PIXELS
;-------------------------------------------------------------------------------

if ((!d.flags and 1) ne 0) then begin

  ;- Display the image
  case true of
    0 : tv, scaled, x0, y0, xsize=xsize, ysize=ysize, order=order
    1 : begin
          tvlct, r, g, b, /get
          loadct, 0, /silent
          tv, scaled, x0, y0, xsize=xsize, ysize=ysize, order=order, true=3
          tvlct, r, g, b
        end
  endcase

  ;- Draw axes if required
  if keyword_set(axis) then $
    plot, [0], /nodata, /noerase, position=out_pos, $
      xrange=xrange, xstyle=1, yrange=yrange, ystyle=1, $
      _extra=extra_keywords

  ;- Return to caller
  return

endif

;-------------------------------------------------------------------------------
;- RESIZE THE IMAGE
;-------------------------------------------------------------------------------

;- Resize the image
if (keyword_set(noresize) eq 0) then begin
  if (true eq 0) then begin
    resized = imdisp_imregrid(scaled, xsize, ysize, interp=keyword_set(interp))
  endif else begin
    resized = replicate(scaled[0], xsize, ysize, 3)
    resized[0, 0, 0] = imdisp_imregrid(reform(scaled[*, *, 0]), xsize, ysize, $
      interp=keyword_set(interp))
    resized[0, 0, 1] = imdisp_imregrid(reform(scaled[*, *, 1]), xsize, ysize, $
      interp=keyword_set(interp))
    resized[0, 0, 2] = imdisp_imregrid(reform(scaled[*, *, 2]), xsize, ysize, $
      interp=keyword_set(interp))
  endelse
endif else begin
  resized = temporary(scaled)
  x0 = 0
  y0 = 0
endelse

;-------------------------------------------------------------------------------
;- GET BIT DEPTH FOR THIS DISPLAY
;-------------------------------------------------------------------------------

;- If this device supports windows, make sure a window has been opened
if (!d.flags and 256) ne 0 then begin
  if (!d.window lt 0) then begin
    window, /free, /pixmap
    wdelete, !d.window
  endif
endif

;- Set default display depth
depth = 8

;- Get actual bit depth on supported displays
if (!d.name eq 'WIN') or (!d.name eq 'MAC') or (!d.name eq 'X') then begin
  if (version ge 5.1) then begin
    device, get_visual_depth=depth
  endif else begin
    if (!d.n_colors gt 256) then depth = 24
  endelse
endif

;-------------------------------------------------------------------------------
;- SELECT DECOMPOSED COLOR MODE (ON OR OFF) FOR 24-BIT DISPLAYS
;-------------------------------------------------------------------------------

if (!d.name eq 'WIN') or (!d.name eq 'MAC') or (!d.name eq 'X') then begin
  if (depth gt 8) then begin
    if (version ge 5.2) then device, get_decomposed=entry_decomposed else $
      entry_decomposed = 0
    if (true eq 1) or (channel gt 0) then device, decomposed=1 else $
      device, decomposed=0
  endif
endif

;-------------------------------------------------------------------------------
;- DISPLAY THE IMAGE
;-------------------------------------------------------------------------------

;- If the display is 8-bit and the image is true color,
;- convert image from true color to indexed color
if (depth le 8) and (true eq 1) then begin
  resized = color_quan(temporary(resized), 3, r, g, b, $
    colors=ncolors, dither=keyword_set(dither)) + byte(bottom)
  tvlct, r, g, b, bottom
  true = 0
endif

;- Set channel value for supported devices
if (!d.name eq 'WIN') or (!d.name eq 'MAC') or (!d.name eq 'X') then begin
  channel_value = channel
endif else begin
  channel_value = 0
endelse

;- Display the image
case true of
  0 : tv, resized, x0, y0, order=order, channel=channel_value
  1 : tv, resized, x0, y0, order=order, true=3
endcase

;-------------------------------------------------------------------------------
;- RESTORE THE DECOMPOSED COLOR MODE FOR 24-BIT DISPLAYS
;-------------------------------------------------------------------------------

if ((!d.name eq 'WIN') or (!d.name eq 'MAC') or (!d.name eq 'X')) and $
  (depth gt 8) then begin
  device, decomposed=entry_decomposed
  if (!d.name eq 'MAC') then tv, [0], -1, -1
endif

;-------------------------------------------------------------------------------
;- DRAW AXES IF REQUIRED
;-------------------------------------------------------------------------------

if keyword_set(axis) then $
  plot, [0], /nodata, /noerase, position=out_pos, $
    xrange=xrange, xstyle=1, yrange=yrange, ystyle=1, $
    _extra=extra_keywords

END
