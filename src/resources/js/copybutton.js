$(document).ready(function() {
  /* Add a "hide prompts" button on the top-right corner of code samples to
   * hide the IDL> prompts and comment out the output and thus make the code
   * copyable to the IDL command line. */
  var code = $('.listing')

  // get the styles from the current theme
  code.parent().parent().css('position', 'relative');
  var hide_text = 'Hide the prompts and output';
  var show_text = 'Show the prompts and output';
  var border_width = code.css('border-top-width');
  var border_style = code.css('border-top-style');
  var border_color = code.css('border-top-color');
  var button_styles = {
    'cursor':'pointer',
    'position': 'absolute',
    'top': '0',
    'right': '0',
    'border-color': '#5070ff',
    'border-style': 'solid',
    'border-width': border_width,
    'color': '#5070ff',
    'font-size': '8pt',
    'font-weight': 'bold',
    'font-family': 'Verdana',
    'padding-left': '0.2em',
    'padding-right': '0.2em'
  }

  // create and add the button to all the code blocks that contain IDL>
  code.each(function(index) {
    var jthis = $(this);
    if (jthis.find('.code-prompt').length > 0) {
      var button = $('<span class="copybutton">hide prompts</span>');
      button.css(button_styles)
      button.attr('title', hide_text);
      jthis.prepend(button);
    }
    // tracebacks (.code-traceback) contain bare text elements that need to
    // be wrapped in a span to work with .nextUntil() (see later)
    jthis.find('code:has(.code-traceback)').contents().filter(function() {
      return ((this.nodeType == 3) && (this.data.trim().length > 0));
    }).wrap('<span>');
  });

  // define the behavior of the button when it's clicked
  $('.copybutton').toggle(
    function() {
      var button = $(this);
      button.parent().find('.code-output, .code-prompt, .code-traceback').hide();
      button.next('code').find('.code-traceback').nextUntil('.code-prompt, .code-output').css('visibility', 'hidden');
      button.text('show prompts');
      button.attr('title', show_text);
    },
    function() {
      var button = $(this);
      button.parent().find('.code-output, .code-prompt, .code-traceback').show();
      button.next('code').find('.code-traceback').nextUntil('.code-prompt, .code-output').css('visibility', 'visible');
      button.text('hide prompts');
      button.attr('title', hide_text);
    });
});

