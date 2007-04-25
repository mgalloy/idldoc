;+
;-
pro widget_output::draw_display
    compile_opt idl2

    wset, self.draw_window
    tv, *self.last_display
end


;+
; Override to do an action when a test suite begins testing.
;
; @param testname {in}{type=string} name of the test
; @param ntests {in}{type=integral} number of tests
;-
pro widget_output::start_testing, testname, ntests
    compile_opt idl2

    self.current_test = testname
    widget_control, self.status, set_value='Testing ' + testname

    self.ntests = ntests
    *self.last_results = bytarr(ntests) + 2B
    *self.last_display = bytarr(self.draw_xsize, self.draw_ysize) + 2B

    self->draw_display
end


;+
; Override to do an action when a all testing is done.
;
;-
pro widget_output::done_testing
    compile_opt idl2

    widget_control, self.status, set_value='Done testing'
end


;+
; Override to do an action when a test suite finishes testing.
;
; @param passed {in}{type=integral} number of passed tests
; @param failed {in}{type=integral} number of failed tests
; @param failed_tests {in}{type=object ref} vector of string test names
;-
pro widget_output::end_testing, passed, failed, failed_tests
    compile_opt idl2

    if (failed ne 0) then begin
        ftests_arr = failed_tests->to_array()
        log_output = [ 'Failed tests for ' + self.current_test + ':', '  ' + ftests_arr ]
        widget_control, self.log, set_value=log_output, /append
    endif
end


;+
; Override to do an action when a test case passes or fails.
;
; @param pass {in}{type=boolean} 0 (fail) or 1 (pass)
; @param test_name {in}{type=string} name of the test case
;-
pro widget_output::test_case, pass, test_name
    compile_opt idl2

    widget_control, self.status, set_value='Testing ' + self.current_test + ': ' + test_name
    inc = float(self.draw_xsize) / self.ntests
    start = inc * self.cur_test_number
    stop = inc * (self.cur_test_number + 1) - 1
    (*self.last_results)[self.cur_test_number] = pass
    (*self.last_display)[start:stop, 0:self.draw_ysize-1] = pass
    self.cur_test_number = self.cur_test_number + 1
    self->draw_display
end


pro widget_output::cleanup
    compile_opt idl2

    device, decomposed=self.dc
    tvlct, self.ct
    ptr_free, self.last_results, self.last_display
end


pro widget_output::create_widgets
    compile_opt idl2

    self.tlb = widget_base(title='IDLunit', /column, /base_align_left)
    self.status = widget_label(self.tlb, /dynamic_resize, value=' ')
    self.draw = widget_draw(self.tlb, xsize=self.draw_xsize, ysize=self.draw_ysize)
    self.log = widget_text(self.tlb, xsize=60, ysize=15, units=0)
    widget_control, self.log, scr_xsize=400

    widget_control, self.tlb, /realize
    widget_control, self.draw, get_value=draw_window
    self.draw_window = draw_window

    colors = widget_info(self.tlb, /system_colors)
    background = colors.scrollbar
    wset, draw_window
    bcolor = background[0] + 2L ^ 8 * background[1] + 2L ^ 16 * background[2]
    erase, bcolor
    tvlct, [255, 0, background[0]], [0, 255, background[1]], [0, 0, background[2]]

    ;xmanager, 'widget_output', self.tlb, /no_block
end


function widget_output::init
    compile_opt idl2

    device, get_decomposed=dc
    self.dc = dc

    tvlct, r, g, b, /get
    self.ct = [[r], [g], [b]]

    device, decomposed=0

    self.last_results = ptr_new(/allocate_heap)
    self.last_display = ptr_new(/allocate_heap)

    self.draw_xsize = 400
    self.draw_ysize = 10
    self->create_widgets
    return, 1
end


pro widget_output__define
    compile_opt idl2

    define = { widget_output, $
        dc:0, $
        ct:bytarr(256, 3), $
        current_test:'', $
        tlb:0, $
        status:0L, $
        log:0L, $
        draw:0L, $
        draw_window:0L, $
        draw_xsize:0L, $
        draw_ysize:0L, $
        ntests:0L, $
        cur_test_number:0L, $
        last_results:ptr_new(), $
        last_display:ptr_new() $
        }
end
