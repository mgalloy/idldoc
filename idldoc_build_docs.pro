orig_quiet = !quiet
!quiet = 1
@idldoc_compile_all
!quiet = orig_quiet

profiler
profiler, /system

idldoc, root='src', output='api-docs', $
  title='API documentation for IDLdoc ' + idldoc_version(), $
  subtitle='IDLdoc ' + idldoc_version(/full), /statistics, index_level=1, $
  overview='overview', footer='footer', /embed, $
  format_style='rst', markup_style='rst'

profiler, /report, data=data

openw, lun, 'api-docs/profiler.csv', /get_lun
printf, lun, data, format='(%"%s, %d, %f, %f, %d")'
free_lun, lun

exit