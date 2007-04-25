;+
; This function represents the model of wind speed as a function
; of height given by the expression<br>
;
; <center><i>U(z) = a0 + a1*alog(z) + a2*alog(z)^2</i></center><br>
;
; where <i>U</i> is wind speed, <i>z</i> is height and <i>a0</i>,
; <i>a1</i> and <i>a2</i> are coefficients to be determined.
; This function is called by SVDFIT, not directly by the user.
;
; @param x {in}{type=float} A value at which the model function
;   is evaluated.
; @param m {in} The value of the derivative of the model at <i>x</i>.
;   This parameter is not currently used.
; @returns A three-element array, corresponding to the three terms
;   of the logsquare model.
; @author Mark Piper, RSI, 2003
;-
function wind_profile_model, x, m

    return, [1.0, alog(x), alog(x)^2]
end
