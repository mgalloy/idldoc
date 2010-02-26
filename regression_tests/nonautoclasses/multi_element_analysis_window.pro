;+
;  Description: Handles user window selection and starts up the
;  multi_element_image_canvas window
;
;  @author: Chris Widdis
;  @field image_parent_widget An object containing the main base
;   widget
;  @field button_panel_id The widget id of the button panel
;  @field data_model_obj The data model object
;  @field data_nav_handle Handle of the data navigation settings.
;   Data navigation is not implemented, but would be simple to do so
;  @field multi_element_image_canvas Object reference to the
;   multi_element_image_canvas
;  @field analysis_cache_handle Handle of the cache where the requests
;   are stored when suspend analysis is pressed
;  @field display_output_handle Handle to the file output structure
;  @field caller_handle Handle of the one responsible for cleaning up
;   the analysis window
;  @field notify_procedure string of the function used to notify the
;   caller_handle it has closed.  It has the form:
;   pro notify_procedure, caller_handle
;-
PRO multi_element_analysis_window_settings__define
  struct = { multi_element_analysis_window_settings, $
             image_parent_widget:obj_new(), $
             button_panel_id:0L, $
             data_model_obj:obj_new(), $ 
             data_nav_handle:0L, $
             multi_element_image_canvas:obj_new(), $
             analysis_cache_handle:0L, $
             display_output_handle:0L, $
             caller_handle:0L, $
             notify_procedure: "" }
END