;+
; GREP2.PRO
;
; Search .PRO files for a search string
;
; Syntax
;   GREP, search_string [, /INSENSITIVE] [, /PATH]
;
;   search_string		The text string to match in .pro files
;   /INSENSITIVE		Optional. Do a case-insensitive search for the search_string
;   /PATH				=1 Search current directory (not recursively), and then the IDL !PATH
;						=0 Default is to search the current directory only including subdirectories
;
; Example 1
;   grep, 'map_proj_forward', /i
;
;   Not case sensitive search.
;   Searches the current directory and all subdirectories for .pro files containing the string 'map_proj_forward'
;
; Example 2
;   Not case sensitive.
;   Searches in the current directory and then !PATH
;   Does not search subdirectories of the current dir.
;
; IDL> grep, 'map_image', /i, /path
; Searching for String: map_image
; Search String Found In: C:\RSI\IDL62\lib\map_image.pro
; Search String Found In: C:\RSI\IDL62\lib\map_patch.pro
; Search String Found In: C:\RSI\IDL62\examples\demo\demosrc\d_map.pro
; Search String Found In: C:\RSI\IDL62\examples\widgets\wexmast\worlddemo.pro
; Search String Found In: C:\RSI\IDL62\examples\widgets\wexmast\worldrot.pro
;-

pro grep2, keyword, path=path, insensitive=insensitive
  compile_opt idl2,hidden

  search_str=byte(keyword)

  ; If we have specified a case-insensitive search then convert the search string to uppercase.
  ; Note we can't use strupcase() function as it is expensive and type casts from a byte array to a string

  IF keyword_set(insensitive) then search_str=search_str and 223B
  print, 'Searching for String: ',string(search_str)
  num_search_char=n_elements(search_str)  ; the number of characters in the search string

  ;
  ; Create a text display widget to indicate search status

  b=widget_base(xoff=300,yoff=300)
  text=widget_text(b,xs=100,ys=1)
  widget_control,b,/realize

 ;
 ; Setup an array of subdirectories in !PATH to search if we specified /PATH
 ;

  dirs='.'
  ; IF /PATH is set then parse and add the IDL !PATH string into a list of individual subdirectories to be searched
  IF keyword_set(path) then begin
    IF (!version.os_family eq 'Windows') $
     THEN dirs=[dirs,strsplit(!path,';',/extract,COUNT=num_subdirs)] $
     ELSE dirs=[dirs,strsplit(!path,':',/extract,COUNT=num_subdirs)]
  ENDIF

  num_dirs=n_elements(dirs)
  FOR cur_dir=0,num_dirs-1 DO BEGIN

    ; For each subdirectory get a list of all .pro files
    ; IF /PATH was specified, then search all subdirectories in !PATH
    ; otherwise only search the '.' current directory

    IF keyword_set(path) THEN BEGIN
      files=file_search(dirs[cur_dir]+'/*.pro')   ; /PATH search !PATH Dirs[*]
    ENDIF ELSE BEGIN
      files=file_search('.','*.pro')			  ; Just search current dir
    ENDELSE

    ; If any .pro files were found then open each file and look for the search keyword

    num_files =  n_elements(files)
    IF (files[0] ne '') THEN FOR Cur_file=0,num_files-1 DO BEGIN

    ; Display the .pro filename being opened and searched
      widget_control, text, set_value='Searching:  ' + files[Cur_file]
      wait,0.0001

      IF file_test(files[Cur_file], /zero_length) then continue   ; Skip loop iteration if file is empty

      ; Read the next .pro file as a BYTE array stream and do byte operations
      bytestream=read_binary(files[Cur_file])

      ; If case insensitive search is set, convert the bytestream to all uppercase. (the search word has already been converted to uppercase)
      ; Since we are using byte array operations we can't use the strupcase() function as it is expensive and would type
      ; cast the byte array to a string array. Instead we will use a logical AND to shift lowercase bytes to uppercase.

      IF keyword_set(insensitive) then bytestream=bytestream AND 223B

      nbytes=n_elements(bytestream)

      ; Some explanation is useful here. Remember we are doing BYTE operations to obtain speed rather than using
      ; string and substring operations. The entire file is contained in the bytestream BYTE Array and using IDL's
      ; powerful Array operations we will check the bytestream for the search string - one character at a time.
      ;
      ; char_found will contain an array of offsets to the first and subsequent characters of the search string
      ; For example, let's say our search string is 'TEST'. The first char_found array contains the
      ; locations of each occurance of 'T' in the bytestream. The next iteration will check the bytestream at each
      ; occurance of 'T' for the occurance of 'TE', then 'TES' and finally 'TEST'.

      search_found=where(bytestream eq search_str[0])   ; Check for the first char of the search string

      IF (search_found[0] ne -1) THEN FOR next_char=0,num_search_char-1 do begin  ; Check for each char in search_str
        ;
        ; test bytestream for the next character in the search string
        ; str_loc is an array of the locations the next char of the search string (search_str[search_char])
        ; We make sure that the byte offset (char_found+next_char) is not past the end of file (nbytes)

        char_loc=where(bytestream[search_found+next_char<nbytes] eq search_str[next_char])

        ; If the next char of the search string is not found,
        ; set str_found=-1, exit this loop iteration and go to the next file

        IF (char_loc[0] eq -1) then begin
          search_found=-1
          break								     ; exit this file and check next file
        ENDIF ELSE BEGIN
          search_found=search_found[char_loc]    ; else, update the char_found[*] array and procedd to the next char
          								         ; in the search string
        ENDELSE

      END

      IF (search_found[0] ne -1) then print, 'Search String Found In: ',files[Cur_file]

    ENDFOR ; CUR_FILE

  ENDFOR  ; CUR_DIR


  widget_control,b,/destroy

end
