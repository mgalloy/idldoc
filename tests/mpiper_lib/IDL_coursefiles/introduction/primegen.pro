;+
; This function determines a vector of N prime numbers, starting
; at 2, where N > 0 is the number of primes a user desires.
; A direct search factorization algorithm is used. This method is
; inefficient, but it's useful for small primes.
; The implementation of this algorithm in IDL should be
; vectorized further.<p>
;
; Note that the built-in IDL routine PRIMES has the same functionality.
; PRIMEGEN is slower than PRIMES for small sets of primes, but
; faster for large (>10000) sets.<p>
;
; @param n_desired {in}{type=integer} An integer > 0; the
;  number of primes desired.
; @returns An unsigned long integer vector of <i>n_desired</i>
;  prime numbers.
; @examples
;   <code>
;   IDL> a = primegen(10)<br>
;   IDL> print, a<br>
;       2   3   5   7   11  13  17  19  23  29<br>
;   </code>
; @requires IDL 6.0
; @author Mark Piper, RSI, 2003
; @version 1.0
;-
function primegen, n_desired
    compile_opt idl2
    on_error, 2

    ;; Weed out bad requests.
    case 1 of
        n_desired eq 0: return, 0
        n_desired eq 1: return, 2
        n_desired gt 1: primes = ulonarr(n_desired)
        else: message, 'A positive integer is required for input.'
    endcase

    ;; Give the first two primes.
    primes[0:1] = [2,3]
    n_found = 2UL

    ;; Iterate to find the rest.
    i = primes[n_found-1]
    while n_found lt n_desired do begin
        i++
        if min(i mod [2,3]) eq 0 then continue ;; skip evens & triples
        limit = floor(sqrt(i))
        factors = ulindgen(limit)+2
        remainders = i mod factors
        n_zeros = where(remainders eq 0, hits)
        if hits eq 0 then begin
            primes[n_found] = i
            n_found++
        endif
    endwhile

    return, primes
end