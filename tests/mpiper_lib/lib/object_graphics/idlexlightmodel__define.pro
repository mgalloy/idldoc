;============================================================================
;+
; Init method. Uses keyword inheritance to pass information to the model.
;
; @returns 1=instantiate object, 0=do not instantiate object.
;-
function idlexlightmodel::init, $
    default_lights=default_lights, $
    _extra=e

    compile_opt idl2

    ; Call the superclass' init method.
    if 0 eq self->idlgrmodel::init(_extra=e) then return, 0

    ; Make two lights.
    self.light0 = obj_new('idlgrlight', name='light0')
    self.light1 = obj_new('idlgrlight', name='light1')

    ; Set default light properties, if the keyword is set.
    if keyword_set(default_lights) then begin
        self.light0->setproperty, type=0, intensity=0.3
        self.light1->setproperty, type=1, location=[1,1,1]
    endif

    ; Add the lights to the object tree.
    self->add, [self.light0, self.light1]

    ; Return success.
    return, 1
end


;============================================================================
;+
; The cleanup method.
;-
pro idlexlightmodel::cleanup
    compile_opt idl2

    ; Destroy the objs in the tree.
    obj_destroy, [self.light0, self.light1]

    ; Call the superclass' cleanup method.
    self->idlgrmodel::cleanup
end


;============================================================================
;+
; The setproperty method.
;
; @keyword object_name {in}{type=string} Set to the name of one of the
; light objects.
;-
pro idlexlightmodel::setproperty, $
    object_name=obj, $
    _extra=e

    compile_opt idl2

    ; Set the properties of the model or light objects.
    if n_elements(obj) eq 0 then begin
        self->idlgrmodel::setproperty, _extra=e
    endif else begin
        case obj of
            'light0' : self.light0->setproperty, _extra=e
            'light1' : self.light1->setproperty, _extra=e
            else: begin
                message, "Object name '" + obj + "' not defined.", /info
                return
            end
        endcase
    endelse
end


;============================================================================
;+
; The getproperty method. The _ref_extra keyword is needed to return
; information from the light & model getproperty methods.
;
; @keyword object_name {in}{type=string} Set to the name of
; one of the light objects.
; @keyword child_names {out}{type=string array} Set to a named variable
; to receive a string array containing the names of the light objects.
;-
pro idlexlightmodel::getproperty, $
    object_name=obj, $
    child_names=children, $
    _ref_extra=e

    compile_opt idl2

    ; Get the names of the light objects.
    if arg_present(children) then begin
        self.light0->getproperty, name=name0
        self.light1->getproperty, name=name1
        children = [name0, name1]
    endif

    ; Get any other properties of the lights or their model.
    if n_elements(obj) eq 0 then begin
        self->idlgrmodel::getproperty, _extra=e
    endif else begin
        case obj of
            'light0' : self.light0->getproperty, _extra=e
            'light1' : self.light1->getproperty, _extra=e
            else: begin
                message, "Object name '" + obj + "' not defined.", /info
                return
            end
        endcase
    endelse
end


;============================================================================
;+
; The data definition procedure for the class IDLexLightmodel.
;
; @author Mark Piper, 2002
; @copyright RSI
;-
pro idlexlightmodel__define

    define = { idlexlightmodel, $
               inherits idlgrmodel, $
               light0 : obj_new(), $
               light1 : obj_new() $
             }
end
