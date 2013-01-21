; docformat = 'rst'

;+
; Run a test and compare its output to the given output.
;
; If there are no tests in the input, the test is considered to pass.
;
; :Returns:
;    1 for success, 0 for failure
;
; :Params:
;    input : in, required, type=strarr
;       array of inputs and correct outputs
;-
function mg_doctest::runTest, input
  compile_opt strictarr

  prompt = 'IDL> '
  cmds = strpos(input, prompt) eq 0L
  cmdInds = where(cmds, nCmds)

  if (nCmds eq 0L) then return, 1B

  cmdInds = [cmdInds, n_elements(input)]   ; makes testing easier
  currentLine = 0L
  for c = 0L, nCmds - 1L do begin
    mg_log, 'Executing: "' + input[cmdInds[c]] + '"', $
            name='mg_doctest/runTest', /informational
    self.bridge->execute, strmid(input[cmdInds[c]], strlen(prompt))

    nlines = file_lines(self.filename)
    output = strarr(nlines)
    openr, lun, self.filename, /get_lun
    readf, lun, output
    free_lun, lun

    if (~array_equal(output[currentLine:*], $
                     input[cmdInds[c] + 1L:cmdInds[c + 1L] - 1L])) then return, 0
    currentLine = nlines
  endfor

  return, 1
end


pro mg_doctest::cleanup
  compile_opt strictarr

  file_delete, self.filename
  obj_destroy, self.bridge
end


function mg_doctest::init
  compile_opt strictarr

  self.filename = filepath('bridge.log', /tmp)
  count = 0L
  while (file_test(self.filename)) do begin
    self.filename = filepath('bridge-' + strtrim(count++) + '.log', /tmp)
  endwhile

  self.bridge = obj_new('IDL_IDLBridge', output=self.filename)

  return, 1
end


pro mg_doctest__define
  compile_opt strictarr

  define = { MG_DocTest, $
             bridge: obj_new(), $
             filename: '' $
           }
end


; main-level example program

mg_log, name='mg_doctest/runTest', logger=logger
logger->setProperty, level=[0, 5, 4]

input = ['IDL> print, 5', $
         '       5', $
         'IDL> print, findgen(5)', $
         '      0.00000      1.00000      2.00000      3.00000      4.00000']
doctest = obj_new('MG_DocTest')
result = doctest->runTest(input)
print, result

end
