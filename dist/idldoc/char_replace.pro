;+
; Replaces a single character with another character, globally in a string.
;
; @returns string
; @param str {in}{required}{type=string} scalar string to replace characters in
; @param orig_char {in}{required}{type=string} a single character to be replaced
; @param replace_char {in}{required}{type=string} a single character to replace
;        with
;-
function char_replace, str, orig_char, replace_char
    compile_opt idl2

    byte_array = byte(str)
    ind = where(byte_array eq (byte(orig_char))[0], count)

    if (count eq 0) then return, str

    byte_array[ind] = (byte(replace_char))[0]

    return, string(byte_array)
end
