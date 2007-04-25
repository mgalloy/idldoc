;
;  Solve Sudoku puzzles
;  IDL version of Javascript code below.
;  RTK, 28-Dec-2005
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;-------------------------------------------------
;  print_sudoku
;+
;  Print a sudoku puzzle stored as a 4-dimensional array
;  (ie, 3x3 array of boxes, each of which is a 3x3 array)
;-
pro print_sudoku, s
  compile_opt idl2

  for a=0,2 do begin
    for b=0,2 do begin
      for c=0,2 do begin
        for d=0,2 do begin
          print, s[d,b,c,a], FORMAT='(1X,I1,$)'
        endfor
        if (c lt 2) then print, FORMAT="(' |',$)"
      endfor
      print
    endfor
    if (a lt 2) then print, "-------+-------+-------"
  endfor
end


;-------------------------------------------------
;  solve
;+
;  Actual routine which solves the sudoku and 
;  returns true (1) or false (0) if a solution can be
;  found.
;-
function solve, a,b,c,d, s
  compile_opt idl2

  if (d eq 3) then return, solve(a, b, c+1, 0, s)
  if (c eq 3) then return, solve(a, b+1, 0, d, s)
  if (b eq 3) then return, solve(a+1, 0, c, d, s)
  if (a eq 3) then return, 1
  if (s[d,c,b,a] ne 0) then return, solve(a,b,c,d+1, s)

  for j=1,9 do begin
    for x=0,2 do begin
      for y=0,2 do begin
        if ((s[y,x,b,a] eq j) || (s[y,c,x,a] eq j) || (s[d,y,b,x] eq j)) then   $
          goto, here
      endfor
    endfor
    s[d,c,b,a] = j
    if solve(a,b,c,d+1, s) then return, 1
    s[d,c,b,a] = 0
  here:
    continue  ; literal translation from the javascript
  endfor
  return, 0
end


;-------------------------------------------------
;  sudoku
;+
;  Solve a sudoku puzzle printing the solution.
;-
pro sudoku, SOLUTION=s
  compile_opt idl2

  ;
  ;  Place the puzzles here for convenience.  Think of them as a 3x3 array
  ;  of 3x3 arrays in each element, hence, 4D.  IDL doesn't like you entering
  ;  a 4D array as a single assignment so break it up by rows.
  ;
  s = bytarr(3,3,3,3)

  ;  Puzzle included with javascript code.  Solved instantly:
  s[*,*,*,0] = [[[0,0,0],[0,7,1],[0,0,5]], [[5,0,0],[0,6,9],[0,7,1]], [[0,7,1],[8,5,3],[4,2,0]]]
  s[*,*,*,1] = [[[0,1,0],[0,0,2],[0,0,0]], [[7,8,0],[1,5,4],[0,9,2]], [[0,4,0],[3,6,0],[1,8,0]]]
  s[*,*,*,2] = [[[0,6,4],[0,2,3],[0,5,0]], [[9,0,5],[0,1,0],[0,0,0]], [[7,0,0],[5,9,0],[0,0,0]]]

  ;  Wikipedia says this is the most minimal sudoku known.  Takes 216s to solve on my machine:
  ;1 - -  - - -  - - -
  ;- - 2  7 4 -  - - -
  ;- - -  5 - -  - - 4
  ;
  ;- 3 -  - - -  - - -
  ;7 5 -  - - -  - - -
  ;- - -  - - 9  6 - - 
  ;
  ;- 4 -  - - 6  - - -
  ;- - -  - - -  - 7 1
  ;- - -  - - 1  - 3 -

;  s[*,*,*,0] = [[[1,0,0],[0,0,2],[0,0,0]], [[0,0,0],[7,4,0],[5,0,0]], [[0,0,0],[0,0,0],[0,0,4]]]
;  s[*,*,*,1] = [[[0,3,0],[7,5,0],[0,0,0]], [[0,0,0],[0,0,0],[0,0,9]], [[0,0,0],[0,0,0],[6,0,0]]]
;  s[*,*,*,2] = [[[0,4,0],[0,0,0],[0,0,0]], [[0,0,6],[0,0,0],[0,0,1]], [[0,0,0],[0,7,1],[0,3,0]]]

  print_sudoku, s  

  print
  print, "Solving..."
  print

  if solve(0,0,0,0,s) then begin
    print_sudoku, s  
  endif else begin
    print, "No solution found."
  endelse
end


;
;  Original javascript code:
;

;// Author: Kevin Greer,   Date: Dec 25, 2005  --  Copyright 2005, All Rights Reserved
;
;s = [[[[0,0,0],[0,7,1],[0,0,5]], [[5,0,0],[0,6,9],[0,7,1]], [[0,7,1],[8,5,3],[4,2,0]]], 
;    [[[0,1,0],[0,0,2],[0,0,0]],  [[7,8,0],[1,5,4],[0,9,2]], [[0,4,0],[3,6,0],[1,8,0]]], 
;    [[[0,6,4],[0,2,3],[0,5,0]], [[9,0,5],[0,1,0],[0,0,0]], [[7,0,0],[5,9,0],[0,0,0]]]]
;
;function display() { 
;  for ( a = 0 ; a < 3 ; a++ ) { 
;    for ( b = 0 ; b < 3 ; b++ ) { 
;      for ( c = 0 ; c < 3 ; c++ ) { 
;        for ( d = 0 ; d < 3 ; d++ ) 
;            document.write(" " + s[a][c][b][d]) 
;        if ( c < 2 ) document.write(" |") 
;      } 
;      document.write("<br/>") 
;    } 
;    if ( a < 2 ) document.write("-------+-------+-------<br/>") 
;  } 
;}
;
;function solve(a, b, c, d) { 
;  if ( d == 3 ) return solve(a, b, c+1, 0) 
;  if ( c == 3 ) return solve(a, b+1, 0, d) 
;  if ( b == 3 ) return solve(a+1, 0, c, d) 
;  if ( a == 3 ) return true 
;  if ( s[a][b][c][d] != 0 ) return solve(a, b, c, d+1) 
;    outer: for ( var j = 1 ; j <= 9 ; j++ ) { 
;             for ( var x = 0 ; x < 3 ; x++ ) 
;               for ( var y = 0 ; y < 3 ; y++ ) 
;                 if ( s[a][b][x][y] == j || s[a][x][c][y] == j || s[x][b][y][d] == j ) continue outer 
;               s[a][b][c][d] = j 
;               if ( solve(a, b, c, d+1) ) return true 
;               s[a][b][c][d] = 0 
;           } 
;  return false 
;}
;
;display() document.write("<br/>solving...<br/><br/>") if ( solve(0,0,0,0) ) display()

