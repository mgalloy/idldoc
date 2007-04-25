; FUNCTION read_L12_swath_file
;
; Created by Stephen Licata on 12-27-2004.
;
; DESCRIPTION:
; This function reads a Level 1 or 2 granule data file in the HDF-EOS format
; and extracts one of the following information types into a data buffer:
;
; INPUT ARGUMENTS (REQUIRED)
;
; filename  - The fuilly qualified path to a Level 1B/2 EOS-HDF format granule file.
;
; content_flag - An integer (0-3) that specifies the type of data to be extracted, as follows:
;                0: A text string showing the name of the swath(s) in that file.
;                1: The name and values of the swath's dimension parameters.
;                2: The name and values of the swath's attribute parameters.
;                3: The name and values of the swath's data field parameters.
;
; INPUT ARGUMENTS [OPTIONAL]:
;
; content_list - An array of names for the content items to be returned. If left unspecified,
;                the function will return ALL the parameters in that content category.
; swathname    - A text expression for the data swath within the granule file that is to be
;                examined. This function will only process one data swath at a time. In the
;                (typical) case that there is only ONE data swath in the granule file, this
;                argument can be left unspecified.
;
; RETURN VALUES:
;
; buffer       - IDL data structure with fields of parameter name/parameter value.
;                Type "help,buffer,/struct" at the IDL command line for details.
; status       - "0" for success and "-1" for failure.
;
   function read_L12_swath_file,filename,content_flag,buffer,content_list=content_list,swathname=swathname

   prog_name = 'read_L12_swath_file'

   type_list = ['swath','dimension','attribute','field']

; Abort the program if no data file has been provided.
   if (n_elements(filename) eq 0) then begin
      print,prog_name,': ERROR - No input filename was specified.'
      return,-1
   endif

; Abort the program if no data type has been specified.
   if (n_elements(content_flag) eq 0) then begin
      print,prog_name,': ERROR - No content code (type) was provided.'
      return,-1
   endif

; Get a file id value.
   fid      = EOS_SW_OPEN(filename,/READ)

; Abort the program if the file does not exist or cannot be read.
   if (fid le 0) then begin
      print,prog_name,': ERROR - ',filename,' could not be opened.'
      status = EOS_SW_CLOSE(fid)
      return,-1
   endif

; Get the number of data swaths in the file (normally just 1)
   nswath = EOS_SW_INQSWATH(filename,swathlist)

; Abort the program if no data swath(s) is/are found.
   if (nswath le 0) then begin
      print,prog_name,': ERROR - ',filename,' has no data swath.'
      status = EOS_SW_CLOSE(fid)
      return,-1
   endif

; If only the swath list is requested, return that text string and end the program.
   if (content_flag eq 0) then begin
      buffer = swathlist
      status = EOS_SW_CLOSE(fid)
      return,0
   endif

; Only continue processing if the data set is confined to a single swath.
   if (n_elements(swathname) eq 1) then begin
      swathname = swathname
   endif else if (nswath eq 1) then begin
      swathname = swathlist
   endif else begin
      print,prog_name,': ERROR - only one data swath can be read at a time.'
      status = EOS_SW_CLOSE(fid)
      return,-1
   endelse

; Attach an ID to this swath.
   swath_id = EOS_SW_ATTACH(fid,swathname)

; Abort the program if this data swath cannot be accessed.
   if (swath_id le 0) then begin
      print,prog_name,': ERROR - Could not attach to swath ',swathname  
      status = EOS_SW_DETACH(swath_id)
      status = EOS_SW_CLOSE(fid)
      return,-1
   endif

; ###################################################################
; Assemble the content list (e.g., parameter names) to be extracted
; if this information has not already been provided as an input argument.
   if n_elements(content_list) eq 0 then begin

; Each data type has its own extraction routine.
      case content_flag of
         1: begin
               status       = EOS_SW_INQDIMS(swath_id,dimname,dims)
               content_list = strsplit(dimname,',', /extract)
            end
         2: begin
               nattrib      = EOS_SW_INQATTRS(swath_id,attrlist)
               content_list = strsplit(attrlist,',',/extract)
            end
         3: begin
               ngeo         = EOS_SW_INQGEOFIELDS(swath_id,geolist,rank,numbertype)
               geonames     = strsplit(geolist,',', /extract)
               nflds        = EOS_SW_INQDATAFIELDS(swath_id,fieldlist,rank,numtype) + ngeo
               content_list = [geonames,strsplit(fieldlist,',',/extract)]
            end
      else: begin
               print,prog_name,': ERROR - No content list (based on content flag) was generated.'  
               status = EOS_SW_DETACH(swath_id)
               status = EOS_SW_CLOSE(fid)
               return,-1
            end
      endcase
   endif

; Abort the program if the content list is just a single blank string entry.
   if (n_elements(content_list) eq 1) and (strlen(content_list(0)) eq 0) then begin
      print,prog_name,': ERROR - No set of ',type_list(content_flag),' parameter names was specified.'
      status = EOS_SW_DETACH(swath_id)
      status = EOS_SW_CLOSE(fid)
      return,-1
   endif

; Abort the program if the content list is still undefined.
   if (n_elements(content_list) eq 0) then begin
      print,prog_name,': ERROR - No set of ',type_list(content_flag),' parameter names was specified.'
      status = EOS_SW_DETACH(swath_id)
      status = EOS_SW_CLOSE(fid)
      return,-1
   endif

; Now get the content (values) for each item in the content list.
   num_items = n_elements(content_list)
   j         = 0
   for i=0,num_items-1 do begin
      item_name = content_list(i)

; Discard any parameter names that have a '=' sign in the name.
; NOTE: This is an optional feature based on experience with these data files.
      bad_pos = strpos(item_name,'=')
      if (bad_pos[0] ne -1) then continue

; Initially assume there is no value to go with this parameter name.
      fail = -1

; Extract the data value based on the parameter name and data type.
      case content_flag of
; ------------------------------------------------------------------
         1: begin
               item_val = EOS_SW_DIMINFO(swath_id,item_name)
               if (item_val ne -1) then begin
                  fail = 0
               endif
            end
; ------------------------------------------------------------------
         2: begin
               fail     = EOS_SW_READATTR(swath_id,item_name,item_val)
            end
; ------------------------------------------------------------------
         3: begin
               fail     = EOS_SW_READFIELD(swath_id,item_name,item_val)
            end
; ------------------------------------------------------------------
      else: begin
               print,prog_name,': ERROR - Content flag must be a dimension(1), attribute(2) or field(3).'
               status = EOS_SW_DETACH(swath_id)
               status = EOS_SW_CLOSE(fid)
               return,-1
            end  
      endcase

; NOTE: If a parameter name has one or more '.' in its name, replace the dots
; with '_' for now so that the name will not be confused with a lower level
; structure within the 'name' part of the output 'buffer' structure.
      dot_pos = strpos(item_name,'.')
      if (dot_pos[0] ne -1) then begin
         new_name = repstr(item_name,'.','_')
         print,prog_name,': CAUTION - The ',type_list(content_flag),' parameter ',$
                  item_name,' will be saved as ',new_name 
         item_name = new_name
      endif

; Build a name/value pair for the output buffer structure.
; Be sure to skip this item if the 'name' part is already part of the structure.
      if (not fail) then begin
         if (j eq 0) then begin
            buffer = create_struct(item_name,item_val)
         endif else begin
            tag_list = Tag_Names(buffer)
            tag_loc  = where(tag_list eq STRUPCASE(item_name))
            if (tag_loc[0] eq -1) then begin
               buffer = create_struct(buffer,item_name,item_val)
            endif
         endelse
         j = j + 1
      endif else begin
         print,prog_name,': ERROR - Failed reading ',type_list(content_flag),' ',item_name
      endelse

   endfor

; Detach from the data swath.
   status = EOS_SW_DETACH(swath_id)

; Close the file.
   status = EOS_SW_CLOSE(fid)

   return,0

end

