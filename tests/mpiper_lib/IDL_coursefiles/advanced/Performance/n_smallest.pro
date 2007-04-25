;2345678901234567890123456789012345678901234567890123456789012345678901234567890

;+
; Finds the n smallest data elements of an array.
;
; @file_comments Find the n smallest data elements of an array.
; @returns indices of the data array of the n smallest elements in the array
; @param data {in}{required}{type=numeric array} data array
; @param n {in}{required}{type=integral} the number of elements to return
; @keyword largest {in}{optional}{type=boolean} set to return the indices of the
;          n largest elements; largest element's index is returned first
; @history Motivated by an article on comp.lang.idl-pvwave by JD Smith on
;          10/18/02, "Re: Find minimums in an array...".
;-
function n_smallest, data, n, largest=largest
    compile_opt idl2
    on_error, 2

    if (n_elements(data) lt n) then $
        message, 'n must be less than or equal to the number of data elements'

    hist = histogram(data, nbins=n_elements(data)/n, reverse_indices=ri)

    if (keyword_set(largest)) then begin
        start = n_elements(hist) - 1
        finish = 0
        inc = -1
    endif else begin
        start = 0
        finish = n_elements(hist) - 1
        inc = +1
    endelse

    sum = 0L
    for i = start, finish, inc do begin
        sum = sum + hist[i]
        if (sum ge n) then break
    endfor

    ; i now is set to the bin that contains the n-th element

    if (keyword_set(largest)) then begin
        big_indices = ri[ri[i]:ri[n_elements(hist)-1]]
        mult = -1
    endif else begin
        big_indices = ri[ri[0]:ri[i+1]-1]
        mult = +1
    endelse

    vals = data[big_indices]
    indices = (sort(mult * vals))[0:n-1]
    return, big_indices[indices]
end
