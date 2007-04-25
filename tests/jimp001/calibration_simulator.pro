;+
; A simple utility for reading raw LWIR and MWIR
; data files and constructing fake calibration images
; from them.  This routine is obsolete and has been
; replaced with Culex_Calibration.
;
; @Obsolete
;
; @Keyword
;   File_Type {in}{optional}{type=string}{default="2PTL"}
;       Set this keyword to  2PTL, or 2PTH.
;
; @Author
;   JLP, RSI Global Services
;
; @History
;   October 25, 2005
;-
Pro Calibration_Simulator, file_type=file_type
Compile_Opt StrictArr
On_Error, 2
F = Dialog_Pickfile(/Must_Exist, Filter = '*_data', $
    Path = SourcePath(), /Fix_Filter, $
    Title = 'Input _data file')
If (F eq '') then Begin
    Return
EndIf
Base = File_BaseName(F)
Components = StrTok(Base, '_DATA', /Extract, Count = Count)
Base = Components[0]
if n_elements(file_type) then begin
  if size(file_type, /tname) ne 'STRING' then Return
  if strlen(file_type) ne 4 then Return
  if ~(file_type eq '2PTL' or file_type eq '2PTH') then Return
endif else begin
  file_type='2PTL'
endelse
F2 = Dialog_Pickfile(Filter = '*.' + file_type, $
    Path = File_DirName(F), Title = 'Output "calibration" data', $
    File = Base + '.' + file_type, /overwrite_prompt)
If (F2 eq '') then Begin
    Return
EndIf
Frame = {TBirdFrame, $
    Header : BytArr(22), $
    Image : UIntArr(640, 512) $
    }
BufferSize = N_Tags(Frame, /Length)
Count = (File_Info(F)).Size/BufferSize
ImageMaxes = UIntArr(Count)
ImageMins = UIntArr(Count)
ImageMeans = UIntArr(Count)
ImageRanges = UIntArr(Count)
NDifferencePixels = LonArr(Count)
OpenR, LUN, F, /Get_LUN, /Swap_if_Little_Endian
OpenW, LUN2, F2, /Get_LUN
Buffer = Assoc(LUN, Frame)
window, xsize = 640, ysize = 512
  ; Write out the header stuff first.
  bandpass = strmatch(F, 'LWIR', /fold_case) ? byte('LWIR') : byte('MWIR')
  writeu, LUN2, bandpass
  version = fix(1)
  writeu, LUN2, version
  ; file_type set up above
  writeu, LUN2, file_type
  flight_name = byte('2005.03.17.14.32.41.of_bumblebee  ')
  writeu, LUN2, flight_name
  collection_number = 42b
  writeu, LUN2, collection_number
  cal_collection_number = 0b
  writeu, LUN2, cal_collection_number
  julian_day = systime(/julian)
  writeu, LUN2, julian_day
  frame_count = long(count)
  writeu, LUN2, frame_count
  data_type = fix(12)
  writeu, LUN2, data_type
  column_count = fix(640)
  writeu, LUN2, column_count
  row_count = fix(512)
  writeu, LUN2, row_count
For I = 0L, Count - 1 Do Begin
    Data = Buffer[I]
    NewImage = Data.Image
    SubImage = NewImage[50:149, 350:449]
;    MinSubImage = Min(SubImage)
;    M = Moment(SubImage, Sdev = SDEV)
;    Bad = Where(Abs(subImage - M[0]) gt .5*SDev, NBad)
;    If (NBad ne 0) then Begin
;        SubImage[Bad] = MinSubImage
;    EndIf
    For Y = 0, 511, 100 Do Begin
        DY = Y + 100 gt 511 ? 512 - Y : 100
        For X = 0, 639, 100 Do Begin
            DX = X + 100 gt 639 ? 640 - x : 100
            NewImage[X:X + DX - 1, Y:Y + DY - 1] = $
                SubImage[0:DX - 1, 0:DY - 1]
        EndFor
    EndFor
    Print, I
    wait, .01
    WriteU, LUN2, NewImage
    tvscl, newimage
EndFor
  ; Write out the trailer info.
  frame_numbers = (lindgen(count)+1)*2
  writeu, LUN2, frame_numbers
  frame_time_stamps = (dindgen(count) + 1) / 24.0D
  writeu, LUN2, frame_time_stamps
  frame_starting_columns = intarr(count)
  writeu, LUN2, frame_starting_columns
  frame_starting_rows = intarr(count)
  writeu, LUN2, frame_starting_rows
Free_LUN, LUN
Free_LUN, LUN2
End