;+
; Returns the string name of the given type code.  This gives a more human
; readable name than <code>size(/tname)</code>.
;
; <center><table>
; <tr><td><b>Number</b></td><td><b>Name</b></td><td><b>Size</b></td></tr>
; <tr><td>0</td><td>unknown</td><td>0</td></tr>
; <tr><td>1</td><td>byte</td><td>1</td></tr>
; <tr><td>2</td><td>integer</td><td>2</td></tr>
; <tr><td>3</td><td>longword integer</td><td>4</td></tr>
; <tr><td>4</td><td>floating point</td><td>4</td></tr>
; <tr><td>5</td><td>double-precision</td><td>8</td></tr>
; <tr><td>6</td><td>complex</td><td>8</td></tr>
; <tr><td>7</td><td>string</td><td>0</td></tr>
; <tr><td>8</td><td>structure</td><td>0</td></tr>
; <tr><td>9</td><td>double-precision complex</td><td>16</td></tr>
; <tr><td>10</td><td>pointer</td><td>0</td></tr>
; <tr><td>11</td><td>object reference</td><td>0</td></tr>
; <tr><td>12</td><td>unsigned integer</td><td>2</td></tr>
; <tr><td>13</td><td>unsigned longword integer</td><td>4</td></tr>
; <tr><td>14</td><td>64-bit integer</td><td>8</td></tr>
; <tr><td>15</td><td>unsigned 64-bit integer</td><td>8</td></tr>
; </table></center>
;
; @returns string representing the type name or long indicating the size in
;          bytes of the data type
; @param code {in}{required}{type=integer type} type code as returned from
;        <code>size(/type)</code>
; @keyword size {in}{optional}{type=boolean} set to return size of data type in
;          bytes
; @author Michael D. Galloy
;-
function type_name, code, size=size
    compile_opt idl2
    on_error, 2

    if (n_params() ne 1) then message, 'argument required'

    names = [ $
        'unknown', $
        'byte', $
        'integer', $
        'longword integer', $
        'floating point', $
        'double-precision', $
        'complex', $
        'string', $
        'structure', $
        'double-precision complex', $
        'pointer', $
        'object reference', $
        'unsigned integer', $
        'unsigned longword integer', $
        '64-bit integer', $
        'unsigned 64-bit integer' $
        ]

    sizes = [ $
        0B, $
        1B, $
        2B, $
        4B, $
        4B, $
        8B, $
        8B, $
        0B, $
        0B, $
        16B, $
        0B, $
        0B, $
        2B, $
        4B, $
        8B, $
        8B $
        ]

    return, keyword_set(size) ? sizes[code] : names[code]
end