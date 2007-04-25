;
; NAME:
;       NETCDF
;
; FILENAME:
;       netcdf__define.pro
;
; PURPOSE:
;       This class retrieves data from a reasonably generic netCDF file
;
; SUPERCLASSES:
;       none
;
; AUTHOR:
;       Darran Edmundson
;       Canadian NSERC Visiting Fellow
;       Optical Sciences Centre, RSPhysSE
;       Australian National University
;       email: dEdmundson@bigfoot.com
;
; COPYRIGHT:
;       While this code is copyright, Darran Edmundson, 1998-1999, it is
;       free for use in a non-commercial environment subject to two
;       restrictions (i) derivations of this code acknowledge their
;       origin and (ii) derivations of this code use a different name 
;       to avoid namespace conflicts.  Commercial use requires permission 
;       from the author.
;
; CATEGORY:
;       IDL 5.1 (object oriented)
;
; CALLING SEQUENCE:
;       myfile = Obj_New('netcdf',filename)
;
; REQUIRED INPUTS:
;       Filename:  string
;
; INIT METHOD KEYWORD PARAMETERS:
;       none.
;
; PUBLIC METHODS:
;
;       Stats (Procedure)
;             Display dimension and variable information
;
;       Dim_Exists, 'name' (Function)
;             Returns true if the dimension 'name' exists.
;
;       Dim_GetSize, 'name' (Function)
;             Returns the length of dimension 'name'
;
;       Var_Exists, 'name' (Function)
;             Returns true if the variable 'name' exists.
;
;       Var_Get, 'name' (Function)
;             Returns data for variable 'name'.  Beware of calling
;             this function for a variable containing large amounts
;             of data.  Consider Var_GetSlab instead.
;
;       Var_Get1, 'name', index  (Function)
;             Returns single element of the 1-vector variable 'name'.
;
;       Var_GetSlab, 'name', index_name=index (Function)
;             Return a hyperslab of variable 'name' at index.
;
;       Var_GetType, 'name' (Function)
;            Return a lowercase string showing the data-type of
;            variable 'name'.
;
;       Var_GetNDims, 'name' (Function)
;            Return the number of dimensions in variable 'name'.
;
;       Var_GetDims, 'name' (Function)
;            Return a string array containing the dimension names
;            of variable 'name'.
;
; SIDE EFFECTS:
;       A netcdf structure is created
;
; RESTRICTIONS:
;       None.
;
; EXAMPLE USAGE:
;       f = obj_new('netcdf','test.nc')
;       f->stats  ; display file structure
;       if f->var_exists('x') then x = f->var_get('x') else stop
;       if f->var_exists('time') then t = f->var_get('time') else stop
;       if f->dim_exists('time_index') then $
;          maxtime = f->dim_getsize('time_index') else stop
;       if not f->var_exists('intensity') then stop
;       i = f->var_get('intensity') ; get the entire (x,t) surface
;       i = f->var_getslab('intensity',z_index=maxtime-1) ;
;       obj_destroy, f  ; close the file
;
; INSTALLATION:
;       Place this file in a directory contained in your IDL_PATH
;       environment variable.
;
; MODIFICATION HISTORY:
;       Written by Darran Edmundson, Tue Jul 28 1998
;         - added self-documenting help method, Aug. 5, 1998.  DEE.

; object constructor
function  netcdf::init, filename

   ; quit if netCDF not supported on current platform
   if ncdf_exists() eq 0 then begin 
      print, 'netcdf::init error - netCDF not supported on this platform'
      return, 0
   endif

   ; test for existence of 'filename'
   result = findfile(filename,count=filecount)
   if filecount eq 0 then begin 
      print, 'netcdf::init error - file ', filename, ' not found'
      return, 0
   endif

   ; open netCDF file and store the file identifier
   self.ncid = ncdf_open(filename)
   self.filename = filename

   ; obtain number of dimensions and variables
   result = ncdf_inquire(self.ncid)
   self.numdims = result.ndims
   self.numvars = result.nvars

   ; information about unlimited dimension
   self.ulid = result.recdim

   ; create and fill data structure to hold dimension info
   self.diminfo = ptr_new( ptrarr(self.numdims) )
   for i=0,self.numdims-1 do begin
      ncdf_diminq, self.ncid, i, name, size
      (*self.diminfo)[i] = ptr_new({name:'', size:0L})
      (*(*self.diminfo)[i]).name = name
      (*(*self.diminfo)[i]).size = size
      if i eq self.ulid then self.ulmax=size
   endfor

   ; create and fill data structure to hold variable info
   self.varinfo = ptr_new( ptrarr(self.numvars) )
   for i=0,self.numvars-1 do begin
      result = ncdf_varinq(self.ncid, i)

      ; if variable is a scalar ...
      if result.ndims eq 0 then begin
         (*self.varinfo)[i] = ptr_new({name:'', type:'', ndims:0L})
      endif else begin
         (*self.varinfo)[i] = ptr_new({name:'', type:'', ndims:0L, $
                                       dim:intarr(result.ndims)})
         (*(*self.varinfo)[i]).dim = result.dim
      endelse

      ; set records common to both of above structures
      (*(*self.varinfo)[i]).ndims = result.ndims
      (*(*self.varinfo)[i]).name = result.name
      (*(*self.varinfo)[i]).type = strlowcase(result.datatype)
   endfor

   ; return success
   return, 1

end 


;-----------------------------------------------------------------

; routines that access netcdf dimension/variable info

function netcdf::get_filename
   return, self.filename
end

function netcdf::get_numdims
   return, self.numdims
end

function netcdf::dim_getname,index
   return, (*(*self.diminfo)[index]).name
end

function netcdf::dim_getsize,index
   if size(index,/tname) eq 'STRING' then begin
      ; ensure the variable exists
      if not self->dim_exists(index) then begin
         print, 'netcdf::dim_getsize error - dimension "', index, $
          '" does not exist'
         return, 0
      endif
      index = self->dim_getindex(index)
   endif
   return, (*(*self.diminfo)[index]).size
end

function netcdf::dim_getindex,name
   for i = 0, self->get_numdims() - 1 do begin
      if name eq self->dim_getname(i) then return, i
   endfor
end

function netcdf::get_numvars
   return, self.numvars
end

function netcdf::var_getname,index
   return, (*(*self.varinfo)[index]).name
end

function netcdf::var_gettype,index
   if size(index,/tname) eq 'STRING' then begin 
      ; ensure the variable exists
      if not self->var_exists(index) then begin
         print, 'netcdf::var_gettype error - variable "', index, $
          '" does not exist'
         return, 0
      endif
      index = self->var_getindex(index)
   endif
   return, (*(*self.varinfo)[index]).type
end

function netcdf::var_getndims,index
   if size(index,/tname) eq 'STRING' then begin 
      ; ensure the variable exists
      if not self->var_exists(index) then begin
         print, 'netcdf::var_getndims error - variable "', index, $
          '" does not exist'
         return, 0
      endif
      index = self->var_getindex(index)
   endif
   return, (*(*self.varinfo)[index]).ndims
end


function netcdf::var_getdims,index

   ; if called with index being a var name
   if size(index,/tname) eq 'STRING' then begin 

      ; ensure the variable exists
      if not self->var_exists(index) then begin
         print, 'netcdf::var_getdims error - variable "', index, $
          '" does not exist'
         return, 0
      endif

      ; quit if variable is a scalar
      index = self->var_getindex(index)
      ndims = self->var_getndims(index)
      if ndims eq 0  then begin
         print, 'netcdf::var_getdims error - variable "', index, $
          '" is a scalar'
         return, 0
      endif

      ; build a string array containing dimension names
      dims = self->var_getdims(index)
      s = strarr(ndims)
      for i = 0, ndims-1 do begin
         s[i] = self->dim_getname(dims[i])
      endfor
      return, s
   endif else $
    return, (*(*self.varinfo)[index]).dim
end

function netcdf::var_getindex,name
   for i = 0, self->get_numvars() - 1 do begin
      if name eq self->var_getname(i) then return, i
   endfor
end


;-----------------------------------------------------------------

; boolean routines testing existence of dimensions and variables

function netcdf::dim_exists,name
   ; return true if name matches a dimension name
   for i = 0, self->get_numdims() - 1 do begin
      if name eq self->dim_getname(i) then return, 1
   endfor
   return, 0  ; otherwise return false
end

function netcdf::var_exists,name
   ; return true if name matches a variable name
   for i = 0, self->get_numvars() - 1 do begin
      if name eq self->var_getname(i) then return, 1
   endfor   
   return, 0  ; otherwise return false
end



;-----------------------------------------------------------------

; routines that retrieve data

; retrieve all data for named variable
function netcdf::var_get, name
   if self->var_exists(name) then begin
      varid = self->var_getindex(name) 
      ncdf_varget, self.ncid, varid, vardata
      return, vardata
   endif
   print, 'netcdf::var_get error - no such variable name ', name
   return, 0
end

; retrieve single element from 1-vector variable
function netcdf::var_get1, name, index

   ; ensure the variable exists
   if not self->var_exists(name) then begin
      print, 'netcdf::var_get1 error - variable "', name, $
       '" does not exist'
      return, 0
   endif

   ; retrieve variable index
   varid = self->var_getindex(name) 

   ; quit if variable is a scalar
   ndims = self->var_getndims(varid)
   if ndims eq 0  then begin
      print, 'netcdf::var_get1 error - variable "', name, $
       '" is a scalar'
      return, 0
   endif

   ; ensure that variable is a 1-vector
   dims = self->var_getdims(varid)
   s = size(dims,/dimensions)
   if s[0] ne 1 then begin
      print, 'netcdf::var_get1 error - variable "', name, $
       '" is not a 1-vector '
      return, 0
   endif

   ; ensure that index is within bounds
   size = self->dim_getsize(dims[0])
   if index lt 0 or index gt size-1 then begin
      print, 'netcdf::var_get1 error - index out of range (0-', $
          strtrim(size-1,2),')'
      return, 0
   endif

   ; retrieve data
   ncdf_varget1, self.ncid, varid, vardata, offset=index
   return, vardata

end


function netcdf::var_getslab, name, unique=unique, _extra=ex

   if self->var_exists(name) then begin

      ; get info for named variable
      varid = self->var_getindex(name) 

      ; quit if variable is a scalar
      ndims = self->var_getndims(varid)
      if ndims eq 0 then begin
         print, 'netcdf::var_getslab error - variable "', name, $
          '" is a scalar'
         return, 0
      endif
      dims = self->var_getdims(varid)

      ; ensure that _extra is non-null
      if not keyword_set(ex) then begin
         print, 'netcdf::var_getslab error - missing index specifier'
         return, 0
      endif

      ; construct vectors of slab dimensions and starting point
      count = intarr(ndims)
      offset = intarr(ndims)
      tags = tag_names(ex)
      tagmatch=1
      for i = 0,ndims-1 do begin
         curdim = strupcase(self->dim_getname(dims[i]))
         match = where (strpos( tags,curdim ) eq 0, index )
         if index ne 0 then begin
             count[i] = 1
             offset[i] = ex.(match[0])
             tagmatch=0
              
         endif else begin
            count[i] = self->dim_getsize( dims[i] )
            offset[i] = 0
         endelse
      endfor

      if tagmatch ne 0 then begin
         print, 'netcdf::var_getslab error - unmatched index specifier'
         return, 0
      endif

      ncdf_varget, self.ncid, varid, vardata, count=count, offset=offset
     return, vardata

   endif
   print, 'netcdf::var_getslab error - no such variable name ', name
   return, 0


end


;-----------------------------------------------------------------

; display information about file structure
pro netcdf::stats

   print, 'Name:  ', self->get_filename()

   print, 'Dimensions:  ', strtrim(self->get_numdims(),2)
   for i=0,self->get_numdims() - 1 do begin
      s = '       '+strtrim(i,2)+'  '+self->dim_getname(i)+$
       ' ['+strtrim(self->dim_getsize(i),2)+']'
      if (i eq self.ulid) then s = s + '  (unlimited)'
      print, s
   endfor

   print, 'Variables:   ', strtrim(self->get_numvars(),2)
   for i=0,self->get_numvars() - 1 do begin
      s = self->var_getname(i)+' ['
      for n=0,self->var_getndims(i)-1 do begin
         s = s+self->dim_getname( (self->var_getdims(i))[n] )+','
      endfor
      strput, s, ']', strlen(s)-1
      print, '       ', strtrim(i,2), '  ', s
   endfor

end


;-----------------------------------------------------------------

; print online help on object usage
pro netcdf::help, extra=_ex
   r = routine_info('NETCDF__DEFINE', /source)
   openr, source, r.path, /get_lun
   s = ''
   repeat begin
      print, strmid(s,1)
      readf, source, s
   endrep until strmid(s,0,1) ne ';' or eof(source)
   free_lun, source
end

;-----------------------------------------------------------------

; object destruction - close the netCDF file
pro netcdf::cleanup

   ; free pointers from dimension info array
   for i=0,self->get_numdims() - 1 do begin
      ptr_free, (*self.diminfo)[i]
   endfor
   ptr_free, self.diminfo

   ; free pointers from variable info array
   for i=0,self->get_numvars() - 1 do begin
      ptr_free, (*self.varinfo)[i]
   endfor
   ptr_free, self.varinfo

   ; close the file
   ncdf_close, self.ncid
end


;-----------------------------------------------------------------

; structure definition
pro netcdf__define
   struct = {netcdf, $             ; structure name
             filename:'', $        ; netCDF filename
             numdims:0L, $         ; number of dimensions in file
             numvars:0L, $         ; number of variables in file
             diminfo:ptr_new(), $  ; array containing dimension info
             varinfo:ptr_new(), $  ; array containing variable info
             ulid:0L, $            ; ID of unlimited dimension
             ulmax:0L, $           ; size of unlimited dimension
             ncid:0L }             ; netCDF file ID
end

;-----------------------------------------------------------------

