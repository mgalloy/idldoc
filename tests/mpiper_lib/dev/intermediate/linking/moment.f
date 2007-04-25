c======================================================================
c
c	moment
c
c	This subroutine returns the mean, average deviation, standard
c	deviation, variance, skewness and kurtosis of an input array.
c
c	This routine is from Numerical Recipes in Fortran, p607-608.
c
c======================================================================

	subroutine moment(data, n, ave, adev, sdev, var, skew, curt)
	
	integer n
	real adev, ave, curt, sdev, skew, var, data(n)
	integer j
	real p, s, ep
	
	s = 0.
	do 11 j = 1, n
		s = s + data(j)
11	continue
	
	ave = s / n
	adev = 0.
	var = 0.
	skew = 0.
	curt = 0.
	ep = 0.
	do 12 j = 1, n
		s = data(j) - ave
		ep = ep + s
		adev = adev + abs(s)
		p = s * s
		var = var + p
		p = p * s
		skew = skew + p
		p = p * s
		curt = curt + p
12	continue
	
	adev = adev / n
	var = (var - ep**2/n) / (n-1)
	sdev = sqrt(var)
	
	if (var.ne.0) then 
		skew = skew / (n*sdev**3)
		curt = curt / (n*var**2) - 3.0
	endif
	
	return	
	end

	