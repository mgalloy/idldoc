pro increment_it, x
    x = temporary(x) + 1
end

pro double_it, x
    x = 2 * x
    increment_it, x
end

pro sqrt_it, x
    x = sqrt(x)
    double_it, x
end

pro main
    x = findgen(10)
    sqrt_it, x
    double_it, x
end
