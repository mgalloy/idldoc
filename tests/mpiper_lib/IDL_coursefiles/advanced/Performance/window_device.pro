function window_device
    compile_opt idl2

    case strlowcase(!version.os_family) of
        'windows' : return, 'win'
        'unix' : return, 'x'
        'vms' : message, 'unsure of graphics device'
        'macos' : return, 'mac'
        else : message, 'unknown windows device'
    endcase
end
