;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Program:      mop02_v3_1.pro
;
; Version:      3.1
;
; Purpose/Function:
;
;       The purpose of this IDL procedure is to extract data from a
;       MOPITT Level 2 (MOP02) HDF-EOS file and write the data out to
;       an ASCII file. Very basic subsetting is implemented by
;       specifying the minimum and maximum values for latitude and
;       longitude.
;
;       !!! Known limitations:  For three dimensional data fields, only the first
;       !!! index of the first dimension is output.  For the 3-D fields
;       !!!    Ancillary Surface Emissivity
;       !!!    CO Mixing Ratio
;       !!!    Retrieval Error Covariance Matrix
;       !!! the result is that the data values are output, but the error estimates
;       !!! are not.  For the field
;       !!!    Aggregate Bounds
;       !!! the result is that only the values for the first of the four boundary
;       !!! points are output.
;
;
;       The MOPITT Level 2 data are in the swath HDF-EOS data format.
;
;       To read a swath HDF-EOS file the following steps occur:
;          Open the file
;          Attach to the swath
;          Get the field info
;          Read the field
;          Detach the swath
;          Close the file
;
;       More information about HDF-EOS can be found in the online
;       IDL documentation on Scientific Data Formats. Also there
;       is a web site at: http://hdfeos.gsfc.nasa.gov/hdfeos/index.cfm.
;
;       The HDF-EOS file is read and the following variables are used:
;
;       Variable         Type             Description
;       --------         --------------   -----------------------------
;       ntimes           integer          Number of time steps
;       time             array of float   Time at each step
;       theLatitudes     array of float   Latitude in degrees
;       theLongitudes    array of float   Longiutde in degrees
;
;
;       Additional data can be extracted from the MOPITT file.
;       More information about the MOPITT file specification can be
;       found at: http://www.eos.ucar.edu/mopitt/file_spec.html.
;
;       This program takes as input a configuration file that specifies the
;       latitude/longitude range field to be displayed and the list of input files.
;
; Invocation:   idl> mop02_v3_1
;
;       The user can select up to two parameters to be dumped. The
;       field name must match exactly the field in mop02_fields.dat.
;       This includes the case of each letter.
;
;   Output:
;       The output is an ASCII file placed the directory specified by
;       the user.
;
;       The output file name will match the input file name but with the
;       extension ".txt" appended to the end. This way the source file
;       is always known.
;
;       The format of the output file depends on which parameters are selected.
;   For example an input file with "CO Total Column" as the single parameter
;       would give the following results:
;
;       *** MOPITT Example Program ***
;          TAI Time          Time of Day Latitude Longitude      CO TC
;          226209297.0970000 03:54:52.09 20.7296  -77.03265    1.698E+18
;          226209297.0970000 03:54:52.09 20.4999  -77.00012    1.994E+18
;
;       The units are:
;          TAI Time - Seconds since Jan 1, 1993 00Z
;          Time of Day - hh:mm:ss.ss
;          Latitude - degrees
;          Longitude - degrees
;          CO Total Column - molecules cm-2
;
;
; External Routines:  none
;
; Internal Routines:  Uses the HDF-EOS library functions
;
; Language/Compiler Version:  IDL 5.3
;
; Point of Contact:    Comments or questions should be directed to:
;
;                      NASA Langley Atmospheric Sciences Data Center
;                      Science, Users and Data Services Office
;                      NASA Langley Research Center
;                      Mail Stop 157D
;                      2 South Wright Street
;                      Hampton, Virginia 23681-2199
;                      U.S.A.
;
;                      E-mail:   larc@eos.nasa.gov
;                      Phone:    (757)864-8656
;                      FAX:      (757)864-8807
;
; Updates:
; 01/09/2002 - 1.0
;              Initial version.
; 03/27/2002 - 2.1
;              Corrections from Data Provider.
; 04/08/2002 - 2.2
;              Add seconds in day field to compute time field
;              Change output file to have the extension .txt
; 04/09/2002 - 2.3
;              Add ability to select almost any valid field for output.
;              This is a major revision/update.
; 05/31/2002 - 3.0
;              Major rewrite of the read software to use a GUI.
; 08/26/2002 - 3.1
;              Modified to work with any version of IDL. Removed sizing
;              the input buffers which caused a problem with HDF-EOS indices.
;              IDL 5.5 repairs indexing while 5.3 & 5.4 indices are reversed.
;              Added the path_sep function and fixed valid output_filename.
;              Made the output directory default to the input directory.
;              Tested IDL 5.3 on SGI IRIX, IDL 5.4 on Sun Solaris, and IDL 5.5
;              on a PC running Windows.
;
; 04/07/2004 - Fixed bug in output of 2-D parameters to print all values for
;              first dimension (e.g. was printing same value for all pressure
;              levels because statement was to output UserData1(0,itime) rather
;              than UserData1(m,itime).  Fixed for both one and two output
;              parameter cases.
;              Added display of hourglass cursor while the file is being processed.
;              Added /INFORMATION keyword to DIALOG_MESSAGE display of message
;              that processing was complete so it would be an informational message
;              rather than (by default) a warning message.
;              Added known limitations text above for 3-D parameters since only the
;              first index of the first dimension is output as the code is currently
;              written.  Need to consider how to output three-dimensional data.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  read_fields
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function read_fields
   field_table = indgen(28,9,/string)

   openr,field_lun,'mop02_fields.dat',/get_lun

   ; First two lines are comments
   dummy=''
   readf,field_lun,dummy
   readf,field_lun,dummy

   ; Now read in the fields and stuff into field_table
   buffer=''
   for i=0,27 do begin
      readf,field_lun,buffer
      buffer_list= strsplit(buffer, '|', /extract)
      ; print,buffer_list[0],' ',buffer_list[1],' ',buffer_list[2]

      for j=0,n_elements(buffer_list)-1 do begin
          field_table[i,j]=buffer_list[j]
      endfor
   endfor

   close,field_lun
   free_lun,field_lun

   return,field_table
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  elapsed_time
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function elapsed_time,theSeconds
   hours = 0L
   mins = 0L
   secs = 0.0
   t = 0.0
   etime = '00:00:00.00'
   t = theSeconds
   hours = long(t / 3600)
   t = t - (hours * 3600)
   mins = long(t / 60)
   t = t - (mins * 60)
   ; secs = t
   left_secs = 0L
   left_secs = long(t)
   right_secs = long((t - left_secs) * 100)
   etime = strtrim(string(hours,format='(I2.2)'),2) + $
       ':' + strtrim(string(mins,format='(I2.2)'),2) + $
       ':' + strtrim(string(left_secs,format='(I2.2)'),2) + $
       '.' + strtrim(string(right_secs,format='(I2.2)'),2)
   return,etime
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; find_index
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function find_index,thisField,the_fields
   found_index=-1
   for y=0,27 do begin
       if (thisField eq the_fields[y,1]) then begin
       ; Make sure field is selectable
          if (the_fields[y,0] eq '-') or (the_fields[y,0] eq '*') then begin
             print,"*** Error bad parameter selected!"
             print,"    See mop02_fields.dat. Must select a field with a + !"
             stop
          endif else begin
             found_index=y
          endelse
       endif
   endfor
   if (found_index eq -1) then begin
      print,"*** Error bad parameter name in config file!"
      print,"    Does not match any known parameters! See mop02_fields.dat"
      stop
   endif
   return,found_index
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; select_region
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro select_region,selected_coords,output_dir,input_dir

   common region,nlatField,slatField,wlonField,elonField,outdirField
   common coords,nlat,slat,wlon,elon,theOutputPath

   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;; Create a GUI base
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   base=widget_base(/column,title='Select MOPITT Subset Region')

   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;; Create the field widgets for lat/lon
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   fieldBase=widget_base(base,/column)
   nlatField=cw_field(fieldBase,/floating,title="North Latitude:",value=90.0)
   slatField=cw_field(fieldBase,/floating,title="South Latitude:",value=-90.0)
   wlonField=cw_field(fieldBase,/floating,title="West Longitude:",value=-180.0)
   elonField=cw_field(fieldBase,/floating,title="East Longitude:",value=180.0)
   outdirField=cw_field(fieldBase,/string,xsize=40, $
         title="Output Dir:",value=input_dir)

   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;; Create a subBase to put buttons onto bottom
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   subBaseB=widget_base(base,column=3)
   void=widget_button(subBaseB,value='Cancel')
   void=widget_button(subBaseB,value='Ok')
   void=widget_button(subBaseB,value='Help')

   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;; Draw the window
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   widget_control,base,/realize
   xmanager,'select_region',base

   selected_coords[0]=nlat
   selected_coords[1]=slat
   selected_coords[2]=wlon
   selected_coords[3]=elon
   output_dir=theOutputPath

   return
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; select_region_event
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro select_region_event,event

   common region,nlatField,slatField,wlonField,elonField,outdirField
   common coords,nlat,slat,wlon,elon,theOutputPath

   thisType=widget_info(event.id,/name)
   widget_control,event.id,get_value=thisValue
   ; print,"Responding to event:",thisValue

   case thisValue of
   'Cancel':begin
          widget_control,event.top,/destroy
          retall
          end
   'Help':begin
          print,' '
          print,'**** Help ****'
          print,' '
          print,'Enter the values for the latitude and longitude region'
          print,'of interest. Also enter the location of the output'
          print,'directory.'
          print,' '
          result=dialog_message('Enter values for latitude and longitude region.',$
         title='Help Information')
          end
   'Ok'  :begin
          widget_control,nlatField,get_value=nlat
          widget_control,slatField,get_value=slat
          widget_control,wlonField,get_value=wlon
          widget_control,elonField,get_value=elon
          widget_control,outdirField,get_value=theOutputPath

          ;;;;;;;;;;;;;;;;;;;;;;;;;;
          ;; Check the output path
          ;;;;;;;;;;;;;;;;;;;;;;;;;;
          ;; Path must end with a path seperator
          x = strmid(theOutputPath,0,1,/reverse_offset)
          if (x[0] ne path_sep()) then begin
              theOutputPath = theOutputPath + path_sep()
          endif

          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          ;; Check the region values for errors
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          if (nlat le 90.0) and (nlat ge -90.0) and $
             (slat ge -90.0) and (slat le 90.0) and $
             (wlon ge -180.0) and (wlon le 180.0) and $
             (elon le 180.0) and (elon ge -180.0) then begin
              widget_control,event.top,/destroy
          endif else begin
              result=dialog_message('Error: Bad values for latitude and longitude.',$
         title='Error Information')
          endelse

          end
   else: print,'Unknown Event:',thisValue
   endcase

   return
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; select_parameters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro select_parameters,current_parameters,selected_indices

   common parms,theParameters,listID

   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;; Create a GUI base
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   base=widget_base(/column,title='Select One or Two MOPITT Parameters')

   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;; Create the list widget with the parameters
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   subBase=widget_base(base,/row)
   listID=widget_list(subBase,value=current_parameters,ysize=12,/multiple)

   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;; Create a subBase to put buttons onto bottom
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   subBaseB=widget_base(base,column=3)
   void=widget_button(subBaseB,value='Cancel')
   void=widget_button(subBaseB,value='Ok')
   void=widget_button(subBaseB,value='Help')

   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;; Draw the window
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   widget_control,base,/realize
   xmanager,'select_parameters',base

   selected_indices=theParameters

   return
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; select_parameters_event
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro select_parameters_event,event

   common parms,theParameters,listID

   thisType=widget_info(event.id,/name)
   if (thisType eq 'LIST') then thisValue='LIST' else $
      if (thisType eq 'BUTTON') then widget_control,event.id,get_value=thisValue $
      else thisValue=event.value

   ; print,"Responding to event:",thisValue

   case thisValue of
   'Cancel':begin
          widget_control,event.top,/destroy
          retall
          end
   'Help':begin
          print,' '
          print,'**** Help ****'
          print,' '
          print,'Select two parameters to print out.'
          print,' '
          result=dialog_message('Select two parameters to print out.',$
                        title='Help Information')
          end
   'LIST':begin
          ; print,'Found a LIST event'
          end
   'Ok'  :begin
          vars=widget_info(listID,/list_select)
          if (vars[0] eq -1) then begin
             result=dialog_message('Not Done. No parameters were selected.',$
                        title='Parameter Selection Error')
          endif else begin
             if (n_elements(vars) eq 1) or (n_elements(vars) eq 2) then begin
                widget_control,event.top,/destroy
                theParameters=vars
             endif else begin
                result=dialog_message('Only one or two parameters are allowed.',$
                        title='Parameter Selection Error')
             endelse
          endelse
          end
   else: print,'Unknown Event:',thisValue
   endcase

   return
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; mop02_v3_1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro mop02_v3_1

   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;; First get the hdf file to read
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   input_filename=dialog_pickfile(/read,filter= '*hdf', $
                                   title='Select an HDF File')

   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;; Next put up a dialog box that asks for lat/lon info
   ;; along with the output dir.
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   selected_coords=fltarr(4)
   output_dir=''

   ; Default to the input directory
   t=strtrim(input_filename,2)
   x = strpos(t,path_sep(),/reverse_search)
   input_dir = strmid(t,0,x)

   select_region,selected_coords,output_dir,input_dir
   ; print,'Coordinates are: ',selected_coords
   nlat=selected_coords[0]
   slat=selected_coords[1]
   wlon=selected_coords[2]
   elon=selected_coords[3]

   ; print,'Output Directory=',output_dir

   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;; Next put up the list of fields that can be selected
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   the_fields=read_fields()
   ; There are 20 parameters available for printing
   current_parameters=strarr(20)
   count=0
   for n=0,27 do begin
       if (the_fields[n,0] eq '+') then begin
          ; print,'<',the_fields[n,1],'>'
          current_parameters[count]=the_fields[n,1]
          count=count+1
       endif
   endfor
   ; print,current_parameters
   select_parameters,current_parameters,theIndices

   ; print,"The returned indices are : ",theIndices
   number_of_params=n_elements(theIndices)
   ; print,'Number of Parameters=',number_of_params

   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;; Get the field names from the indices
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   param_list=indgen(number_of_params,/string)
   if (number_of_params eq 1) then begin
      param_list[0]=current_parameters[theIndices[0]]
   endif else begin
      if (number_of_params eq 2) then begin
         param_list[0]=current_parameters[theIndices[0]]
         param_list[1]=current_parameters[theIndices[1]]
      endif
   endelse
   ; print,"The list of parameters selected is: ",param_list

   WIDGET_CONTROL,/HOURGLASS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Process the file input_filename
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      input_filename=strtrim(input_filename,2)
      print,'Input Filename:      ',input_filename

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;; Skip comment lines
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      t=strpos(input_filename,"#")
      if (t ne 0) then begin
         ; print,"Processing filename ",input_filename

         ; Make the output filename
         theFileList = strsplit(input_filename, path_sep(), /extract)
         item = size(theFileList,/n_elements)

         ; remove the .hdf from the end of the filename
         x = strpos(theFileList[item-1],".hdf")
         f = strmid(theFileList[item-1],0,x)
         output_filename = output_dir + f + ".txt"
         print,"Output Filename is: ",output_filename

         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         ;; Setup the HDFEOS access
         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         ; Test to make sure a swath is in this file

         result = EOS_SW_INQSWATH(input_filename,swathlist)
         ; Assume only one swath per file
         if (result eq 1) then begin

             fileid = EOS_SW_OPEN(input_filename,/READ)
             if (fileid eq -1) then begin
                print,"ERROR: *** Cannot open the file with EOS_SW_OPEN!"
                result=dialog_message('Cannot open the file with EOS_SW_OPEN!',$
                                      title='Error Notification')
                exit
             endif

             swathid = EOS_SW_ATTACH(fileid, swathlist)
             if (swathid eq -1) then begin
                print,"ERROR: *** Cannot attach to the file with EOS_SW_ATTACH!"
                result=dialog_message('Cannot attach to the file with EOS_SW_ATTACH!',$
                                      title='Error Notification')
                exit
             endif

             ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             ;; Find first parameter in the_fields
             ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             ;for n=0,number_of_params-1 do begin
                  found_index=find_index(param_list[0],the_fields)
             ;endfor

             ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             ;; Get Time
             ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             status = EOS_SW_FIELDINFO(swathid,'Time',rank,dims,numbertype,dimlist)
             if (status eq -1) then begin
                print,"ERROR: *** Cannot get Time field info with EOS_SW_FIELDINFO!"
                result=dialog_message('Cannot get Time field with EOS_SW_FIELDINFO!',$
                                      title='Error Notification')
                exit
             endif
             start = lindgen(rank)
             stride = lindgen(rank)
             edge = lindgen(rank)
             for i=0,rank-1 do begin
                 start(i) = 0
                 stride(i) = 1
                 edge(i) = dims(i)
             endfor
             ntimes = 1L
             ntimes=edge(0)     ; Force ntimes to match the edge
             ; print,"The rank of TAI Time is ",rank
             ; print,"dims=",dims
             ; print,"dimlist=",dimlist
             ; print,"ntimes=",ntimes
             if (ntimes le 0) then begin
                print,"ERROR: *** No Time Steps in this data file!"
                result=dialog_message('No Time steps in this data file!',$
                                      title='Error Notification')
                exit
             endif

             time=dindgen(ntimes)
             status = EOS_SW_READFIELD(swathid,'Time',time,EDGE=edge,START=start,STRIDE=stride)
             if (status eq -1) then begin
                print,"ERROR: *** Cannot read Time field with EOS_SW_READFIELD!"
                result=dialog_message('Cannot read Time field with EOS_SW_READFIELD!',$
                                      title='Error Notification')
                exit
             endif


             ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             ;; Get Seconds in Day
             ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             status = EOS_SW_FIELDINFO(swathid,'Seconds in Day',rank,dims,numbertype,dimlist)
             if (status eq -1) then begin
                print,"ERROR: *** Cannot get Seconds in Day field info with EOS_SW_FIELDINFO!"
                result=dialog_message('Cannot get Seconds in Day field with EOS_SW_FIELDINFO!',$
                                      title='Error Notification')
                exit
             endif
             start = lindgen(rank)
             stride = lindgen(rank)
             edge = lindgen(rank)
             for i=0,rank-1 do begin
                 start(i) = 0
                 stride(i) = 1
                 edge(i) = dims(i)
             endfor
             ntimes = 1L
             ntimes=edge(0)     ; Force ntimes to match the edge

             if (ntimes le 0) then begin
                print,"ERROR: *** No Seconds in Day Steps in this data file!"
                exit
             endif

             seconds_in_day=dindgen(ntimes)
             status = EOS_SW_READFIELD(swathid,'Seconds in Day',seconds_in_day,$
                 EDGE=edge,START=start,STRIDE=stride)
             if (status eq -1) then begin
                print,"ERROR: *** Cannot read Seconds in Day field with EOS_SW_READFIELD!"
                result=dialog_message('Cannot get Seconds in Day field with EOS_SW_READFIELD!',$
                                      title='Error Notification')
                exit
             endif


             ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             ;; Get User Selected Data1
             ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             status = EOS_SW_FIELDINFO(swathid,the_fields[found_index,1],rank_user1, $
                 dims,numbertype,dimlist)
             if (status eq -1) then begin
                print,"ERROR: *** Cannot get ",the_fields[found_index,1], $
                              " field info with EOS_SW_FIELDINFO!"
                result=dialog_message('Cannot get the fields with EOS_SW_FIELDINFO!',$
                                      title='Error Notification')
                exit
             endif
             edge = lindgen(rank_user1)

             status = EOS_SW_READFIELD(swathid,the_fields[found_index,1],userData1)
             if (status eq -1) then begin
                print,"ERROR: *** Cannot read ", the_fields[found_index,1], $
                                " field with EOS_SW_READFIELD!"
                result=dialog_message('Cannot read the fields with EOS_SW_READFIELD!',$
                                      title='Error Notification')
                exit
             endif

             ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             ;; Get User Selected Data2
             ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             if (number_of_params eq 2) then begin
                found_index=find_index(param_list[1],the_fields)
                status = EOS_SW_FIELDINFO(swathid,the_fields[found_index,1],rank_user2, $
                 dims,numbertype,dimlist)
                if (status eq -1) then begin
                   print,"ERROR: *** Cannot get ",the_fields[found_index,1], $
                              " field info with EOS_SW_FIELDINFO!"
                   result=dialog_message('Cannot get the fields with EOS_SW_FIELDINFO!',$
                                      title='Error Notification')
                   exit
                endif
                edge = lindgen(rank_user2)

                status = EOS_SW_READFIELD(swathid,the_fields[found_index,1],userData2)
                if (status eq -1) then begin
                   print,"ERROR: *** Cannot read ", the_fields[found_index,1], $
                                " field with EOS_SW_READFIELD!"
                   result=dialog_message('Cannot read the fields with EOS_SW_READFIELD!',$
                                      title='Error Notification')
                   exit
                endif
             endif

             ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             ;; Create Output File
             ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             if (ntimes gt 0) then begin
                openw,out_lun,output_filename,/get_lun
                printf,out_lun,"*** MOPITT Example Program ***"

                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; Get Latitude
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                status = EOS_SW_FIELDINFO(swathid,'Latitude',rank,dims,numbertype,dimlist)
                if (status eq -1) then begin
                   print,"ERROR: *** Cannot get Latitude field info with EOS_SW_FIELDINFO!"
                   result=dialog_message('Cannot get Latitude field with EOS_SW_FIELDINFO!',$
                                      title='Error Notification')
                   exit
                endif
                start = indgen(rank)
                stride = indgen(rank)
                edge = lindgen(rank)
                for i=0,rank-1 do begin
                       start(i) = 0
                       stride(i) = 1
                       edge(i) = dims(i)
                endfor
                theLatitudes=findgen(dims(0))
                status =EOS_SW_READFIELD(swathid,'Latitude',theLatitudes,EDGE=edge, $
                                          START=start,STRIDE=stride)
                if (status eq -1) then begin
                    print,"ERROR: *** Cannot read Latitude field with EOS_SW_READFIELD!"
                    result=dialog_message('Cannot read Latitude field with EOS_SW_READFIELD!',$
                                      title='Error Notification')
                    exit
                endif

                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; Get Longitude
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                status = EOS_SW_FIELDINFO(swathid,'Longitude',rank,dims,numbertype,dimlist)
                if (status eq -1) then begin
                    print,"ERROR: *** Cannot get Longitude field info with EOS_SW_FIELDINFO!"
                    result=dialog_message('Cannot get Longitude field with EOS_SW_FIELDINFO!',$
                                      title='Error Notification')
                    exit
                endif
                start = indgen(rank)
                stride = indgen(rank)
                edge = lindgen(rank)
                for i=0,rank-1 do begin
                    start(i) = 0
                    stride(i) = 1
                    edge(i) = dims(i)
                endfor
                theLongitudes=findgen(dims(0))
                status = EOS_SW_READFIELD(swathid,'Longitude',theLongitudes,EDGE=edge, $
                                          START=start,STRIDE=stride)
                if (status eq -1) then begin
                   print,"ERROR: *** Cannot read Longitude field with EOS_SW_READFIELD!"
                   result=dialog_message('Cannot read Longitude field with EOS_SW_READFIELD!',$
                                      title='Error Notification')
                   exit
                endif

                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; Write Header out to file
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       header = '   TAI Time          Time of Day  Latitude Longitude      '
                for n=0,number_of_params-1 do begin
                    f=find_index(param_list[n],the_fields)
                    for m=0,the_fields[f,2]-1 do begin
               header = header + the_fields[f,m+3] + '     '
                    endfor
                endfor
       printf,out_lun,header
       ; print,header

                for itime=long64(0),long64(ntimes-1) do begin
                    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                    ;; Subset the data by region
                    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                    if ((theLatitudes(itime) ge slat) AND $
                        (theLatitudes(itime) le nlat) AND $
                       (theLongitudes(itime) ge wlon) AND $
                       (theLongitudes(itime) le elon)) then begin

                    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                    ;; Write Rows of data
                    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                    printf,out_lun, $
         format='(F20.7,1x,A11,1x,F8.4,1x,F10.5,1x,$)', $
         Time(itime),elapsed_time(seconds_in_day(itime)), $
         theLatitudes(itime),theLongitudes(itime)

                    f=find_index(param_list[0],the_fields)
                    for m=0,the_fields[f,2]-1 do begin
                        case rank_user1 of
                        1:begin
                            printf,out_lun, $
                               format='(1x,E12.3,$)',userData1(itime)
                          end
                        2:begin
                            printf,out_lun, $
                               format='(1x,E12.3,$)',userData1(m,itime)
                          end
                        3:begin
                            printf,out_lun, $
                               format='(E12.3,1x,$)',userData1(0,m,itime)
                          end
                        else: print,"Unhandled value for rank!"
                        endcase
                    endfor

                    if (number_of_params eq 2) then begin
                       f=find_index(param_list[1],the_fields)
                       for m=0,the_fields[f,2]-1 do begin
                           case rank_user2 of
                           1:begin
                               printf,out_lun, $
                                  format='(1x,E12.3,$)',userData2(itime)
                             end
                           2:begin
                               printf,out_lun, $
                                  format='(1x,E12.3,$)',userData2(m,itime)
                             end
                           3:begin
                               printf,out_lun, $
                                  format='(E12.3,1x,$)',userData2(0,m,itime)
                             end
                           else: print,"Unhandled value for rank!"
                           endcase
                       endfor
                    endif
                    printf,out_lun," "
                  endif
                endfor

                close,out_lun

                ; device_name = !D.Name
                ; print,"Device name = ",device_name
                ; if (device_name eq 'X') then begin
                ;    command_line = "xterm -e more " + output_filename
                ;    spawn,command_line
                ; endif

             endif

         endif else begin
            print,"ERROR: *** No swath found in file using EOS_SW_INQSWATH!"
            result=dialog_message('No swath found in file with EOS_SW_INQSWATH!',$
                                  title='Error Notification')
            exit
         endelse

      endif else begin
         ; print,"Skipping commented filename ",input_filename
      endelse


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Clean up
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

   status = EOS_SW_DETACH(swathid)
   if (status eq -1) then begin
       print,"ERROR: *** Cannot detach swath with EOS_SW_DETACH!"
       result=dialog_message('Cannot detach swath with EOS_SW_DETACH!',$
                             title='Error Notification')
       exit
   endif

   status = EOS_SW_CLOSE(fileid)
   if (status eq -1) then begin
       print,"ERROR: *** Cannot close swath with EOS_SW_CLOSE!"
       result=dialog_message('Cannot close swath with EOS_SW_CLOSE!',$
                             title='Error Notification')
       exit
   endif

   result=dialog_message('MOPITT Read Software Processing has completed.',$
                        title='Processing Notification',/INFORMATION)


end
