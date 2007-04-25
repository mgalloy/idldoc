;+

; Reads information from an AIRS L2-RetStd file in HDF-EOS format.
; Two datafields, PRESSSTD (the 28 standard pressure levels for the
; satellite, ordered from the ground up) and TAIRSTD (the retrieved
; atmospheric temperature profile at the pressure levels) are read
; from the file. A temperature profile at one location is displayed.
;
; <p>Links:
; <ol>
; <li> AIRS home page: http://www-airs.jpl.nasa.gov/
; <li> NASA-GSFC DAAC for AIRS: http://disc.gsfc.nasa.gov/AIRS/index.shtml/
; </ol>
;
; @param file {in}{optional}{type=string} A filepath to an HDF-EOS file
; downloaded from the NASA-GSFC DAAC.
; @keyword debug {in}{optional}{type=boolean} Set this keyword to
; display debugging information when running this program.
; @examples
; <pre>
; IDL> print, hdfeos_read_ex()
;            1
; </pre>
; @uses An AIRS L2-RetStd file downloaded from the NASA-GSFC DAAC. 
; @returns 1 on success, 0 on failure
; @requires IDL 6.0
; @author Mark Piper, RSI, 2006
;-
function hdfeos_read_ex, file, debug=debug
    compile_opt idl2
    on_error, 2

    switch 0 of
        n_params() :
        file_test(file) : begin
            file = dialog_pickfile( $
                title='Please select an HDF-EOS file...', $
                filter='*.hdf')
            if file eq '' then return, 0
        end 
    endswitch 

    ;; Is the file HDF-EOS?
    ok = eos_query(file, info)
    if ~ok then return, 0
    if keyword_set(debug) then begin
        help, info, /structures, output=help_info
        xdisplayfile, null, text=help_info, /block
    endif  
    ;; We now know the sample file contains one swath.

    ;; Open the file, returning a file identifier (fid). Note that 0 =
    ;; success, -1 = failure, unlike most IDL routines, where 0 =
    ;; failure, 1 = success.
    fid = eos_sw_open(file, /read)
    if fid eq -1 then return, 0

    ;; Get the swath name. If the file contains more than one swath, a
    ;; string array of names is returned.
    n_swath = eos_sw_inqswath(file, swath_name)
    if (n_swath gt 0) && keyword_set(debug) then begin
        txt = [ $
            'Number of swaths:' + string(n_swath), $
            'Swath name: ' + swath_name ]
        xdisplayfile, null, text=txt, /block
    endif 

    ;; Attach a swath object, returning a swath identifier.
    sid = eos_sw_attach(fid, swath_name)
    if sid eq -1 then return, 0

    ;; Inquire: attributes. The variable attr_list is a comma-delimted
    ;; scalar string with the attribute names.
    n_attr = eos_sw_inqattrs(sid, attr_list)
    if (n_attr gt 0) && keyword_set(debug) then begin
        txt = [ $
            '* Attributes *', $
            'Count: ' + string(n_attr), $
            strsplit(attr_list, ',', /extract)]
        xdisplayfile, null, text=txt, /block
    endif  

    ;; Inquire: dimensions.
    n_dims = eos_sw_inqdims(sid, dim_name, dims)
    if (n_dims gt 0) && keyword_set(debug) then begin
        help, dim_name
        print, dims
    endif  

    ;; Inquire: geofields. Rank is the dimensionality of the field,
    ;; type is the category of data: float, int, string, etc.
    n_geofields = eos_sw_inqgeofields(sid, geofield_list, rank, type) 
    if (n_geofields gt 0) && keyword_set(debug) then begin
        txt = [ $
            '* Geofields *', $
            'Count: ' + string(n_geofields), $
            strsplit(geofield_list, ',', /extract)]
        xdisplayfile, null, text=txt, /block
    endif  

    ;; Inquire: datafields.
    n_datafields = eos_sw_inqdatafields(sid, datafield_list, rank, type)
    if (n_datafields gt 0) && keyword_set(debug) then begin
        txt = [ $
            '* Datafields *', $
            'Count: ' + string(n_datafields), $
            strsplit(datafield_list, ',', /extract)]
        xdisplayfile, null, text=txt, /block
    endif  

    ;; Read the PRESSSTD and TAIRSTD datafields. The field name is
    ;; case-sensitive; it must entered as it is listed in the
    ;; geofield_list or datafield_list.
    p_ok = eos_sw_readfield(sid, 'pressStd', pressstd)
    t_ok = eos_sw_readfield(sid, 'TAirStd', tairstd)
    if (p_ok eq 0) && (t_ok eq 0) then begin
        if keyword_set(debug) then begin
            help, pressstd, tairstd, output=help_out
            xdisplayfile, null, text=help_out, /block
        endif 
    endif else return, 0

    ;; Detach the swath object.
    ok = eos_sw_detach(sid)
    if ok eq -1 then return, 0

    ;; Close the file.
    ok = eos_sw_close(fid) 
    if ok eq -1 then return, 0

    ;; Display a temperature profile at one location, with a
    ;; logarithmic vertical axis.
    plot, tairstd[*,0,0], pressstd, $
        xrange=[1e2,3e2], $
        yrange=[1e3,1e-1], $
        /ylog, $
        xtitle='Temperature (K)', $
        ytitle='Pressure (mb)'

    return, 1
end
