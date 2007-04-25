; Batch file - IDL object lifecycle.

; Make a surface object. The class name is a string, case-insensitive.
; Mixed case is commonly used convention.
s = obj_new('IDLgrSurface')

; See that s is an object reference linked to a heap variable.
help, s
help, /heap

; Is s valid? To what class does it belong?
print, obj_valid(s)
print, obj_class(s)

; What color is the surface? Access the object's data with the getProperty
; method.
s->getProperty, color=s_color
print, s_color

; Change the color of the surface from black to red. Change the object's
; data with the setProperty method.
s->setProperty, color=[255,0,0]

; Clean up the object referenced by s.
obj_destroy, s

; Does the object reference s still exist? Is it valid?
help, s
print, obj_valid(s)
