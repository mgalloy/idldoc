;+
; This program accepts a byte value & returns its base-16 value as a
; string.
;
; @param bvalue {in}{type=byte} A byte value. If not of type byte, it
;    is converted.
; @returns A string containing the hexadecimal value of the input.
;
; @requires IDL 5.3
;
; @author Mark Piper
; @copyright RSI, 2001
;-
function byte_to_hex, bvalue
    compile_opt idl2

    ;; Convert bvalue to type byte.
    bvalue = byte(bvalue)

    ;; Decompose bvalue into base 16.
    value16 = bytarr(2)
    value16[1] = bvalue / 16B
    value16[0] = bvalue - value16[1]*16B

    ;; Checksum, ha!
    checkval = value16[1]*16B + value16[0]
    if checkval ne bvalue then begin
        print, 'Whoops!', checkval, ' NE ', bvalue
        return, "'00'xb"
    endif

    ;; Convert base 16 components into a hex number.
    hexval = strarr(2)
    for i = 0, 1 do begin
        case value16[i] of
            15: hexval[i] = 'F'
            14: hexval[i] = 'E'
            13: hexval[i] = 'D'
            12: hexval[i] = 'C'
            11: hexval[i] = 'B'
            10: hexval[i] = 'A'
            else: hexval[i] = strtrim(fix(value16[i]),2)
        endcase
    endfor

    ;; Return a string containing the hex value of bvalue.
    return, hexval[1] + hexval[0]

end
