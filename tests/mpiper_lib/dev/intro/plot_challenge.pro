pro plot_challenge
    compile_opt idl2

    ; Generate data in the form of an arctan curve.
    depth = findgen(30)/3 - 5
    data = atan(depth)

    plot, data, depth

end
