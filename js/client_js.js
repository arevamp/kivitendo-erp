// NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE:

// This file is generated automatically by the script
// "scripts/generate_client_js_actions.pl". See the documentation for
// SL/ClientJS.pm for instructions.

function display_flash(type, message) {
  $('#flash_' + type + '_content').text(message);
  $('#flash_' + type).show();
}

function eval_json_result(data) {
  if (!data)
    return;

  if (data.error)
    return display_flash('error', data.error);

  $(['info', 'warning', 'error']).each(function(idx, category) {
    $('#flash_' + category).hide();
    $('#flash_' + category + '_content').empty();
  });

  if ((data.js || '') != '')
    eval(data.js);

  if (data.eval_actions)
    $(data.eval_actions).each(function(idx, action) {
      // console.log("ACTION " + action[0] + " ON " + action[1]);

      // ## Non-jQuery methods ##
           if (action[0] == 'flash')                display_flash(action[1], action[2]);

      // ## jQuery basics ##

      // Basic effects
      else if (action[0] == 'hide')                 $(action[1]).hide();
      else if (action[0] == 'show')                 $(action[1]).show();
      else if (action[0] == 'toggle')               $(action[1]).toggle();

      // DOM insertion, around
      else if (action[0] == 'unwrap')               $(action[1]).unwrap();
      else if (action[0] == 'wrap')                 $(action[1]).wrap(action[2]);
      else if (action[0] == 'wrapAll')              $(action[1]).wrapAll(action[2]);
      else if (action[0] == 'wrapInner')            $(action[1]).wrapInner(action[2]);

      // DOM insertion, inside
      else if (action[0] == 'append')               $(action[1]).append(action[2]);
      else if (action[0] == 'appendTo')             $(action[1]).appendTo(action[2]);
      else if (action[0] == 'html')                 $(action[1]).html(action[2]);
      else if (action[0] == 'prepend')              $(action[1]).prepend(action[2]);
      else if (action[0] == 'prependTo')            $(action[1]).prependTo(action[2]);
      else if (action[0] == 'text')                 $(action[1]).text(action[2]);

      // DOM insertion, outside
      else if (action[0] == 'after')                $(action[1]).after(action[2]);
      else if (action[0] == 'before')               $(action[1]).before(action[2]);
      else if (action[0] == 'insertAfter')          $(action[1]).insertAfter(action[2]);
      else if (action[0] == 'insertBefore')         $(action[1]).insertBefore(action[2]);

      // DOM removal
      else if (action[0] == 'empty')                $(action[1]).empty();
      else if (action[0] == 'remove')               $(action[1]).remove();

      // DOM replacement
      else if (action[0] == 'replaceAll')           $(action[1]).replaceAll(action[2]);
      else if (action[0] == 'replaceWith')          $(action[1]).replaceWith(action[2]);

      // General attributes
      else if (action[0] == 'attr')                 $(action[1]).attr(action[2], action[3]);
      else if (action[0] == 'prop')                 $(action[1]).prop(action[2], action[3]);
      else if (action[0] == 'removeAttr')           $(action[1]).removeAttr(action[2]);
      else if (action[0] == 'removeProp')           $(action[1]).removeProp(action[2]);
      else if (action[0] == 'val')                  $(action[1]).val(action[2]);

      // Class attribute
      else if (action[0] == 'addClass')             $(action[1]).addClass(action[2]);
      else if (action[0] == 'removeClass')          $(action[1]).removeClass(action[2]);
      else if (action[0] == 'toggleClass')          $(action[1]).toggleClass(action[2]);

      // Data storage
      else if (action[0] == 'data')                 $(action[1]).data(action[2], action[3]);
      else if (action[0] == 'removeData')           $(action[1]).removeData(action[2]);

      // Form Events
      else if (action[0] == 'focus')                $(action[1]).focus();

      // ## jstree plugin ##

      // Operations on the whole tree
      else if (action[0] == 'jstree:lock')          $.jstree._reference($(action[1])).lock();
      else if (action[0] == 'jstree:unlock')        $.jstree._reference($(action[1])).unlock();

      // Opening and closing nodes
      else if (action[0] == 'jstree:open_node')     $.jstree._reference($(action[1])).open_node(action[2]);
      else if (action[0] == 'jstree:open_all')      $.jstree._reference($(action[1])).open_all(action[2]);
      else if (action[0] == 'jstree:close_node')    $.jstree._reference($(action[1])).close_node(action[2]);
      else if (action[0] == 'jstree:close_all')     $.jstree._reference($(action[1])).close_all(action[2]);
      else if (action[0] == 'jstree:toggle_node')   $.jstree._reference($(action[1])).toggle_node(action[2]);
      else if (action[0] == 'jstree:save_opened')   $.jstree._reference($(action[1])).save_opened();
      else if (action[0] == 'jstree:reopen')        $.jstree._reference($(action[1])).reopen();

      // Modifying nodes
      else if (action[0] == 'jstree:create_node')   $.jstree._reference($(action[1])).create_node(action[2], action[3], action[4]);
      else if (action[0] == 'jstree:rename_node')   $.jstree._reference($(action[1])).rename_node(action[2], action[3]);
      else if (action[0] == 'jstree:delete_node')   $.jstree._reference($(action[1])).delete_node(action[2]);
      else if (action[0] == 'jstree:move_node')     $.jstree._reference($(action[1])).move_node(action[2], action[3], action[4], action[5]);

      // Selecting nodes (from the 'ui' plugin to jstree)
      else if (action[0] == 'jstree:select_node')   $.jstree._reference($(action[1])).select_node(action[2], true);
      else if (action[0] == 'jstree:deselect_node') $.jstree._reference($(action[1])).deselect_node(action[2]);
      else if (action[0] == 'jstree:deselect_all')  $.jstree._reference($(action[1])).deselect_all();

      // ## other stuff ##
      else if (action[0] == 'redirect_to')          window.location.href = action[1];

      else                                          console.log('Unknown action: ' + action[0]);

    });

  // console.log("current_content_type " + $('#current_content_type').val() + ' ID ' + $('#current_content_id').val());
}

function submit_ajax_form(url, form_selector, additional_data) {
  var separator = /\?/.test(url) ? '&' : '?';
  $.post(url + separator + $(form_selector).serialize(), additional_data, eval_json_result);
  return true;
}

// Local Variables:
// mode: js
// End:
