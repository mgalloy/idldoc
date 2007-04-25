; imageprocessor_code1 - a time-saving code snippet.

    ; Make a series of controls for image processing.
    wsmooth = widget_button(wtoolsbase, value='Smooth', uvalue='smooth')
    wusmask = widget_button(wtoolsbase, value='Unsharp Mask', uvalue='umask')
    wsobel = widget_button(wtoolsbase, value='Sobel', uvalue='sobel')
    wroberts = widget_button(wtoolsbase, value='Roberts', uvalue='roberts')
    wmedian = widget_button(wtoolsbase, value='Median', uvalue='median')
    wnegative = widget_button(wtoolsbase, value='Negative', uvalue='negative')
    wahisteq = widget_button(wtoolsbase, value='Adapt Hist Equal', $
        uvalue='ahisteq')
    wthresh = widget_slider(wtoolsbase, title='Threshold', $
        min=0, max=255, value=0, uvalue='thresh')
    wscale = widget_slider(wtoolsbase, title='Scale', $
        min=0, max=255, value=0, uvalue='scale')
    wbscale = widget_button(wtoolsbase, value='Byte Scale', uvalue='bscale')
    wloadct = widget_button(wtoolsbase, value='Load Color Table', $
        uvalue='loadct')
    wrevert = widget_button(wtoolsbase, value='Revert', uvalue='revert')
