;+
; Finds an element of a sparse array.
;
; @param sparse_array {in}{type=structure} sparse array
; @param col {in}{type=integer} column of desired element
; @param row {in}{type=integer} row of desired element
;-
function sprsel, sparse_array, col, row
    compile_opt idl2

    zero = size(sparse_array.sa, /type) eq 4 ? 0.0 : 0.0D
    n_cols = sparse_array.ija[0] - 2
    if ((col ge n_cols) or (row ge n_cols)) then $
        message, 'array index out of bounds: ' + strtrim(col, 2) + ', ' $
            + strtrim(row, 2) + ' when only ' + strtrim(n_cols, 2) $
            + ' rows and columns'

    ; Diagonal elements are stored in sparse_array first
    if (col eq row) then return, sparse_array.sa[col]

    range = sparse_array.ija[row:(row+1)] - 1
    range[1] = range[1] - 1

    index = where(sparse_array.ija[range[0]:range[1]] eq col + 1, found)

    if (not found) then $
        return, zero $
    else $
        return, sparse_array.sa[index[0] + range[0]]
end