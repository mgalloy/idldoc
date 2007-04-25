;+
; Looks up a classname in the hierarchy.
;
; @returns IDLdocClass object or -1L if not found
; @param classname {in}{required}{type=string} classname of class to look up
; @keyword found {out}{optional}{type=boolean} returns if class is found
;-
function IDLdocClassHierarchy::getClass, classname, found=found
    compile_opt strictarr

    return, self.hash->get(strupcase(classname), found=found)
end



;+
; Finds the fields of a class.
;
; @returns class structure or -1L if definition not found
; @param classname {in}{required}{type=string} classname of the class
; @keyword error {out}{optional}{type=boolean} returns if there was an error
;          finding the class definition
;-
function IDLdocClassHierarchy::createClassStructure, classname, error=error
    compile_opt strictarr

    error = 0L
    catch, error
    if (error ne 0) then begin
        catch, /cancel
        !quiet = oldQuiet
        error = 1L
        return, -1L
    endif

    oldQuiet = !quiet
    !quiet = 1
    statement = 's = {' + classname + '}'
    @idldoc_execute
    ;result = execute('s = {' + classname + '}', 1, 1)
    if ((result eq 0) || (n_elements(s) eq 0)) then begin
        error = 1L
        s = -1L
    endif
    !quiet = oldQuiet

    return, s
end


;+
; Add a class object to the hierarchy.
;
; @param classname {in}{required}{type=string} classname of the class
; @keyword class {out}{optional}{type=object} IDLdocClass object created
; @keyword superclass_fields {out}{optional}{type=strarr} names of fields
;          of the class; all uppercase
;-
pro IDLdocClassHierarchy::addClass, classname, class=oclass, superclass_fields=scf
    compile_opt strictarr

    oclass = self->getClass(classname, found=found)
    if (found) then begin
        oclass->getProperty, nfields=nfields, fields=fields
        if (nfields gt 0) then begin
            fieldnames = strarr(nfields)
            for i = 0L, nfields - 1L do begin
                fields[i]->getProperty, name=name
                fieldnames[i] = strupcase(name)
            endfor
            scf = size(scf, /type) eq 7 ? [scf, fieldnames] : fieldnames
        endif
        return
    endif

    oclass = obj_new('IDLdocClass', classname)

    ; store the new class
    self.hash->put, strupcase(classname), oclass

    s = self->createClassStructure(classname, error=error)
    if (error) then oclass->setProperty, /unknown

    sc = obj_class(classname, count=nsc, /superclass)

    ; add superclasses first
    for i = 0L, nsc - 1L do begin
        self->addClass, sc[i], class=osuper, superclass_fields=scf
        oclass->addSuperclass, osuper
        osuper->addSubclass, oclass
    endfor

    ; get fields
    found = idldoc_class_fields(classname, names=names, types=types)
    if (found) then begin
        for f = 0L, n_elements(names) - 1L do begin
            if (size(scf, /type) eq 7) then begin
                ind = where(strupcase(names[f]) eq scf, count)
            endif else begin
                count = 0L
            endelse

            if (count eq 0L) then begin
                ofield = obj_new('IDLdocField', names[f])
                ofield->setProperty, type=types[f]
                oclass->addField, ofield
                if (size(scf, /type) eq 7) then begin
                    scf = [scf, strupcase(names[f])]
                endif else scf = strupcase(names[f])
            endif
        endfor
    endif
end


;+
; Get properties of the class hierarchy.
;
; @keyword nclasses {out}{optional}{type=long} number of classes in the library
;          (superclasses of those found in the library, but which themselves are
;          not in the library don't count)
;-
pro IDLdocClassHierarchy::getProperty, nclasses=nclasses
    compile_opt strictarr

    if (arg_present(nclasses)) then begin
        nclasses = 0L
        classes = self.hash->values(ntotalclasses)
        for i = 0L, ntotalclasses - 1L do begin
            classes[i]->getProperty, url=url
            if (url ne '') then nclasses++
        endfor
    endif
end


;+
; Destroy a class hierarchy object.
;-
pro IDLdocClassHierarchy::cleanup
    compile_opt strictarr

    classes = self.hash->values()
    if (size(classes, /type) eq 11) then obj_destroy, classes
    obj_destroy, self.hash
end


;+
; Create a class hierary object.
;
; @returns 1 for succes, 0 o/w
;-
function IDLdocClassHierarchy::init
    compile_opt strictarr

    self.hash = obj_new('hash_table', key_type=7, value_type=11)

    return, 1
end


;+
; Define member variables.
;
; @file_comments A class hierarchy is responsible for connections between
;                classes. There should be only one class hierarchy object.
; @field hash hash_table object with keys = classname and
;        values = IDLdocClass objects
;-
pro IDLdocClassHierarchy__define
    compile_opt strictarr

    define = { IDLdocClassHierarchy, $
        hash : obj_new() $
        }
end
