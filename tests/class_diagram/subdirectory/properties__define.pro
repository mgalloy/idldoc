;2345678901234567890123456789012345678901234567890123456789012345678901234567890

;+
; Process the opening of a tag during XML parsing.
;
; @private
; @param URI
; @param local
; @param str_name {in}{required}{type=string} name of the tag
; @param attr {in}{required}{type=string array} the names of the attributes of
;        the tag
; @param value {in}{required}{type=string array} the values of the attributes
;        of the tag
;-
pro properties::startElement, URI, local, str_name, attr, value
    compile_opt idl2
    on_error, 2

    case str_name of
    'properties_list' : self.state = 2
    'property' : begin
            self.state = 1
            name_indices = where(strlowcase(attr) eq 'name', count)
            if (count ne 1) then begin
                message, 'invalid properties file format', /continue
                return
            endif

            value_indices = where(strlowcase(attr) eq 'value', count)
            if (count ne 1) then begin
                message, 'invalid properties file format', /continue
                return
            endif

            self->put, value[name_indices[0]], value[value_indices[0]]
        end
    else : message, 'Illegal properties file: ' + str_name + ' tag', /continue
    endcase
end


;+
; Parse the closing of a tag during XML parsing.
;
; @private
; @param URI
; @param local
; @param str_name {in}{required}{type=string} name of the tag
;-
pro properties::endElement, URI, local, str_name
    compile_opt idl2
    on_error, 2

    case self.state of
    0 : ; illegal
    1 : ; illegal
    2 : self.state = 0
    3 : self.state = 2
    endcase
end


;+
; Change state to start XML parsing.
;
; @private
;-
pro properties::startDocument
    compile_opt idl2
    on_error, 2

    self.state = 1
end


;+
; Change state to finished/not started during XML parsing.
;
; @private
;-
pro properties::endDocument
    compile_opt idl2
    on_error, 2

    self.state = 0
end


;+
; Set properties of the object.
;
; @keyword filename {in}{optional}{type=string}{default=last filename} filename
;          associated with properties; this file will be used for subsequent
;          reading and writing until a new FILENAME is provided
;-
pro properties::set, filename=filename
    compile_opt idl2

    if (n_elements(filename) ne 0) then self.properties_filename = filename
end


;+
; Reads properties from a file.
;
; @keyword filename {in}{optional}{type=string}{default=last filename} filename
;          associated with properties; this file will be used for subsequent
;          reading and writing until a new FILENAME is provided
;-
pro properties::read, filename=filename
    compile_opt idl2
    on_error, 2

    if (n_elements(filename) ne 0) then $
        self.properties_filename = file_expand_path(filename)

    self->parseFile, self.properties_filename
end


;+
; Save the current properties to a file.
;
; @keyword filename {in}{optional}{type=string}{default=last filename} filename
;          associated with properties; this file will be used for subsequent
;          reading and writing until a new FILENAME is provided
;-
pro properties::save, filename=filename
    compile_opt idl2
    on_error, 2

    if (n_elements(filename) ne 0) then $
        self.properties_filename = file_expand_path(filename)

    if (self.properties_filename eq '') then $
        message, 'FILENAME must be given to save'

    h = obj_new('html_output')
    h->add, '<properties_list>'

    if (not self->is_empty()) then begin
        keys = self->keys(count)
        values = self->values()

        for i = 0, count - 1 do begin
            h->add, '  <property name="' + keys[i] + '" value="' $
                + values[i] + '" />'
        endfor
    endif

    h->add, '</properties_list>'

    openw, lun, self.properties_filename, /get_lun
    h->print, lun=lun
    free_lun, lun

    obj_destroy, h
end


;+
; Frees resources of the properties object.
;-
pro properties::cleanup
    compile_opt idl2
    on_error, 2

    self->hash_table::cleanup
    self->IDLffXMLSAX::cleanup
end


;+
; Initialize the properties.
;
; @returns 1 if successful; 0 otherwise
; @keyword filename {in}{optional}{type=string}{default=''} filename
;          associated with properties; this file will be used for subsequent
;          reading and writing until a new FILENAME is provided
; @keyword array_size {in}{optional}{type=integral}{default=101} size of
;          hash table
;-
function properties::init, array_size=array_size, filename=filename
    compile_opt idl2
    on_error, 2

    if (n_elements(array_size) eq 0) then array_size = 101

    ; type 7 = string
    ok = self->hash_table::init(array_size=array_size, key_type=7, value_type=7)
    ok = ok and self->IDLffXMLSAX::init()

    if (n_elements(filename) ne 0) then $
        self.properties_filename = file_expand_path(filename)

    ; state
    ; 0 = finished, not started
    ; 1 = start
    ; 2 = inside properties_list
    ; 3 = inside property
    self.state = 0

    return, ok
end


;+
; Persistent set of string properties.
;
; @file_comments A set of string properties that can be read from and written
;                to an XML file.
; @requires IDL 5.6
; @uses hash_table__define, html_output__define
; @inherits <a href="hash_table__define.html">hash_table</a>, IDLffXMLSAX
; @field state the current level in the XML structure being read: <br>
;        0 = finished, not started <br>
;        1 = start <br>
;        2 = inside properties_list <br>
;        3 = inside property <br>
; @field properties_filename filename currently associated with the properties;
;        this filename will be used for reading and writing until another
;        filename is provided by the READ or SAVE method
; @author Michael D. Galloy
; @copyright Research Systems, Inc. 2002
;-
pro properties__define
    compile_opt idl2

    define = { properties, inherits hash_table, inherits IDLffXMLSAX, $
        state:0, $
        properties_filename:'' $
        }
end