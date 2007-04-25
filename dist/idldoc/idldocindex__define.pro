;+
; Returns an array of start indices into the return value of get_first_letters.
; Use the keyword num_letters for convenience to determine the length of each
; division.
;
; @returns long array or -1L if index is empty
; @keyword max_per_page {in}{optional}{type=integer}{default=infinity} Set to
;          max number of items per page. Divisions will be created so that
;          fewer items than this value will be placed on each page (unless a
;          single letter has more than this value).
; @keyword num_letters {out}{optional}{type=lonarr} An array of division sizes,
;          the same length as the return value.
;-
function idldocindex::get_divisions, max_per_page=mpp, num_letters=num_letters
    compile_opt strictarr

    found_ind = where(self.found gt 0, nfound)
    if (nfound le 0) then begin
        num_letters = 0L
        return, -1L
    endif

    if (n_elements(mpp) eq 0) then begin
        num_letters = [nfound]
        return, [0L]
    endif

    odiv = obj_new('array_list', block_size=30, type=3)
    onum = obj_new('array_list', block_size=30, type=3)

    cumulative_found = long(total(self.found, /cumulative));, /preserve_type,)
    cumulative_found = cumulative_found[found_ind]

    start = 0
    limit = mpp
    while (start lt nfound) do begin
        ind = where(cumulative_found gt limit, count)
        if (count eq 0) then begin
            num = nfound - start
        endif else begin
            num = ind[0] eq start ? 1 : (ind[0] - start)
        endelse

        odiv->add, start
        onum->add, num

        start += num
        limit = cumulative_found[(start - 1L) < (nfound - 1L)] + mpp
    endwhile

    divisions = odiv->to_array()
    num_letters = onum->to_array()
    ;nbin = obin->to_array()

    obj_destroy, [odiv, onum]

    return, divisions
end


;+
; Returns the items whose first letter match the given letter (in alphabetical
; order).
;
; @returns an array of structures with definition:
;          { name:'', url:'', description:'', first_letter:0B }
;          or -1L if index is empty
; @param letter {in}{required}{type=string} a single letter to match
; @keyword empty {out}{optional}{type=boolean} set to a named variable to
;          determine if the index is empty.
;-
function idldocindex::get_items, letter, empty=empty
    compile_opt strictarr

    items = self.items->to_array(empty=empty)
    if (empty) then return, -1L

    matching_items_ind = where(items.first_letter eq (byte(strupcase(letter)))[0], count)
    empty = count eq 0
    if (empty) then return, -1L

    matching_items = items[matching_items_ind]
    return, matching_items[sort(matching_items.name)]
end


;+
; Find the letters included in the index.
;
; @returns string array of characters
; @keyword empty {out}{type=boolean} set if no entries in index
;-
function idldocindex::get_first_letters, empty=empty
    compile_opt strictarr

    ind = where(self.found gt 0, count)
    empty = count eq 0

    if (~empty) then begin
        letters = strarr(count)
        for i = 0L, count - 1L do letters[i] = string(byte(ind[i]))
    endif else letters = -1L

    return, letters
end


;+
; Add an item to the index.
;
; @keyword name Name of the item to be added to the index
; @keyword url Url of item to be added
; @keyword description Description of the item to be added
;-
pro idldocindex::add_item, name=name, url=url, description=description
    compile_opt strictarr

    ; mark off first letter of name as used
    first_letter = (byte(strupcase(strmid(name, 0, 1))))[0]
    ++self.found[first_letter]

    ; add item to list
    self.items->add, $
        { name : name, $
          url : url, $
          description : description, $
          first_letter : first_letter }
end


;+
; Free resources.
;-
pro idldocindex::cleanup
    compile_opt strictarr

    obj_destroy, self.items
end


;+
; Create index.
;
; @returns 1 for success, 0 for failure
;-
function idldocindex::init
    compile_opt strictarr

    self.items = obj_new('array_list', block_size=100, $
        example={ name:'', url:'', description:'', first_letter:0B })

    return, 1
end


;+
; Define index member variables.
;
; @file_comments Represents the index entries in IDLdoc.
; @field items names in index; array list of structures of type
;        {name:'', url:'', description:'', first_letter:0B }
; @field found How many items in the index start with the corresponding ASCII
;        value
;-
pro idldocindex__define
    compile_opt strictarr

    define = { IDLdocIndex, $
        items : obj_new(), $
        found : lonarr(256) $
        }
end