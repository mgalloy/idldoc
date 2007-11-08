; $Id: //depot/idl/trunk/idldir/lib/adapt_hist_equal.pro#4 $
;
; Copyright (c) 1999-2007, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;+
; NAME:
;	ADAPT_HIST_EQUAL
;
; PURPOSE:
;	Perform Adaptive Histogram Equalization (AHE), a form of
;	automatic image contrast enhancement, using a method described
;	by Pizer, et. al. Adaptive Histogram Equalization involves
;	applying contrast enhancement based on the local region
;	surrounding each pixel.  That is, each pixel is mapped to an
;	intensity proportional to its rank in its surrounding
;	neighborhood.  This routine implements what Pizer calls
;	"Contrast Limited Adaptive Histogram Equalization", or CLAHE.
;
; CATEGORY:
;	Image processing.
;
; CALLING SEQUENCE:
;	Result = ADAPT_HIST_EQUAL(Image [, NREGIONS=nregions] [, CLIP=clip])
;
; INPUTS:
;	Image:  A 2-dimensional array of byte type.  Other types of
;		images may be used, but they are converted to byte type before
;		use.  For proper operation, be sure that the range of pixels
;		lies between 0 and 255.
;
; KEYWORD PARAMETERS:
;	CLIP:	If non-zero, clip the histogram to limit its slope to "CLIP",
;		thereby limiting contrast.  For example, if CLIP is 3, the
;		slope of the histogram is limited to 3. By default, the slope
;		and/or contrast is not limited.  Noise overenhancement in
;		nearly homogeneous regions is reduced by setting this
;		parameter to values larger than 1.0.
;	NREGIONS: Set this keyword to the size of the overlapped tiles, as a
;		fraction of the largest	dimension of the image size.  The
;		default is 12, which makes each tile 1/12 the size of the
;		largest image dimension.
;   TOP: 	Set this keyword to the maximum value to scale the output
;		array. The default is 255.
;   FCN:	The desired cumulative probability distribution
;   		function in the form of a 256 element vector.  If
;   		omitted, a linear ramp, which yields equal probability
;   		bins results.  This function is later normalized, so
;   		its magnitude doesn't matter.  It should be
;   		monotonically increasing. 
;
; OUTPUTS:
;	The result of the function is a byte image with the same
;	dimensions as the input parameter.
;
; RESTRICTIONS:
;	Works only on byte images.
;
; PROCEDURE:
;	The procedure described by Pizer, et.al., "Adaptive Histogram
;	Equalization and Its Variations", Computer Vision, Graphics,
;	and Image Processing, 39:355-368, is followed.  This method has
;	the advantages of being automatic, reproducible, locally
;	adaptive, and usually produces superior images when compared
;	with interactive contrast enhancement.
;
;	The image is split into overlapping regions, each of size
;	MaxDimension / NREGIONS.  The distribution histogram for each
;	region is computed.  Then, for each pixel, its histogram
;	equalized value is computed from the four overlapping regions
;	that cover the pixel, normalized for the pixel's distance from
;	each region's center.
;
; EXAMPLE:
;	A = Read_Tiff('xyz.tif') ; Read an image
;	TVSCL, Adapt_Hist_Equal(A)   ;Contrast enhance and display.
;
;  To perform adaptive histogram "equalization", with a logarithmic
;  cumulative distribution (i.e. more pixels with lower values):
;       y = alog(findgen(256)+1)   ;a log shaped curve
;       TVSCL, Adapt_Hist_Equal(A, FCN = y)
;
;  The following example does adaptive histogram "equalization", with
;  a gaussian probability (not cumulative) distribution.  This results
;  in most of the pixels having an intensity near the midrange:
;	x = findgen(256)/255.	   ;Ramp from 0 to 1.
;	y=exp(-((x-.5)/.2)^2)      ;Gaussian centered at middle, full
;				   ;width at 1/2 max ~ 0.4
;		;Form cumulative distribution, transform and display:
;       TVSCL, Adapt_Hist_Equal(A, FCN = TOTAL(y, /CUMULATIVE))
;
; MODIFICATION HISTORY:
;	DMS, RSI	July, 1999.
;-
;
Function AHMHistogram, Im, ix0, iy0, sx, sy, CLIP=fclip, TOP=otop
; Make a histogram from the image Im, LL = ix0, iy0, size = sx, sy.
; CLIP = if set clip histogram according to Pizer.
;
COMPILE_OPT hidden, idl2

ON_ERROR, 2
s = size(im)
nx = s[1]
ny = s[2]
h = histogram(byte(Im[ix0 > 0: ix0+sx-1 < (nx-1), $
                      iy0 > 0: iy0+sy-1 < (ny-1)]), /NAN)
nh = n_elements(h)
z = where(h)                    ;Get non-zero population
hmin = z[0]                     ;Minimum histogram bin
hmax = z[n_elements(z)-1]       ;Maximum histogram bin
nbins = hmax-hmin+1

if keyword_set(fclip) then begin
    clip = abs(float(fclip)) * sx * sy / nbins > 1 ;Clipping level
    if fclip lt 0 then begin    ;Simple clip?
        h = h < clip
    endif else begin            ;Clip with redistribution
        top = clip
        bottom = 0
        s = 0.0
        while (top - bottom gt 1) do begin
            mid = (top + bottom)/2
            s = total(h-mid > 0)
            if s gt (clip-mid)*nbins then top = mid else bottom = mid
        endwhile
        p = fix(s/nbins) + bottom
        l = clip - p > 0
        over = where(h ge p, count)
        h = h + l
        if count gt 0 then h[over] = clip
        hmin = 0
        hmax = nh-1
    endelse
endif

;Make a cumulative histogram
h = total(h, /CUMULATIVE)
return, bytscl(h, min=0, max=h[nh-1], $
               TOP=n_elements(otop) ? otop : 255) ;Scale it
end


;  *****************************************************************

Function Adapt_Hist_Equal, Im, NREGIONS=NregionsIn, CLIP=clip, TOP = top, $
                           Fcn=fcn_in

COMPILE_OPT idl2
ON_ERROR, 2

if n_elements(fcn_in) ge 256 then $
  y2 = bytscl(total(histogram(Bytscl(Fcn_in)),/cum))

s = size(im)
if s[0] ne 2 then message, 'Image parameter Must be 2D'
nx = s[1]
ny = s[2]
if s[s[0]+1] ne 1 then begin    ;Not byte?  Check scaling...
    imax = max(im, min=imin, /NAN)
    if imin lt 0 or imax ge 256 then $
      message, 'Warning, range truncated to bytes.', /INFO
endif

Nregions = (N_ELEMENTS(NregionsIn) GT 0) ? NregionsIn[0] : 12
IF ((Nregions LT 1) OR (Nregions GT (nx > ny))) THEN MESSAGE, $
	'Value for NREGIONS is out of allowed range.'

TileSize = Fix((nx > ny) / Nregions)
Ts2 = (TileSize/2) > 1
NTy = (ny-1) / Ts2              ;# of tiles in Y
NTx = (nx-1) / Ts2              ;# of Tiles in X

ptr = ptrarr(Ntx, 2)            ;Pointers to 2 rows of tile histograms

r = bytarr(nx, ny, /NOZERO)     ;Result

tx = findgen(ts2) # replicate(1./ts2,ts2) ;Interpolation matrices
ty = transpose(tx)

if nx mod ts2 ne 0 then begin   ;Last row of Partial tiles on right
    tx1 = tx[0 : nx mod ts2, *]
    ty1 = ty[0 : nx mod ts2, *]
endif


for irow = 0, nty do begin      ;Each row of tiles
    ptr[0,0] = ptr[*,1]         ;Move down a row of histograms
    if irow lt nty then $       ;Compute next row
      for icol=0, Ntx-1 do begin
        h1 = AHMHistogram(im, icol*ts2, irow*ts2, TileSize, TileSize, $
                          CLIP=clip, TOP=top)
        ptr[icol,1] = ptr_new(fix(keyword_set(y2) ? y2[h1] : h1))
    endfor
    if irow eq 0 then ptr[0,0] = ptr[*,1] ;Duplicate first row.

    for icol = 0, ntx do begin  ;Each column of tiles
        x0 = icol * ts2         ;Left edge of cell
        y0 = irow * ts2         ;Bottom edge of cell
        x1 = x0 + ts2 -1        ;Opposite corner
        y1 = y0 + ts2 -1
        a = im[x0:x1 < (nx-1), y0:y1 < (ny-1)] ;The cell
        a0 = (*ptr[icol-1 > 0, 0])[a] ;Get the 4 surrounding histograms (LL)
        a1 = (*ptr[icol < (ntx-1), 0])[a] ;LR
        a2 = (*ptr[icol-1 > 0, 1])[a] ;UL
        a3 = (*ptr[icol < (ntx-1), 1])[a] ;UR

        a0 = a0 + (a1-a0) * (x1 lt nx ? tx : tx1) ;Horizontal interpolate
        a2 = a2 + (a3-a2) * (x1 lt nx ? tx : tx1)

; (we don't have to take into account the last partial columns,
; because they just drop off)

        r[x0,y0] = a0 + (a2-a0) * (x1 lt nx ? ty : ty1) ;Vertical interpolate
    endfor                      ;icol
    if irow ne 0 then ptr_free, ptr[*,0]
endfor                          ;irow

ptr_free, ptr
return, r
end

