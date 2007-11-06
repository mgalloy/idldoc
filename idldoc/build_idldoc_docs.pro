@compile_all

idldoc, root='src', output='api-docs', $
  title='API documenation for IDLdoc ' + idldoc_version(), $
  subtitle='IDLdoc ' + idldoc_version(/full), /statistics, $
  overview='overview', footer='footer', /embed, $
  format_style='rst'

exit