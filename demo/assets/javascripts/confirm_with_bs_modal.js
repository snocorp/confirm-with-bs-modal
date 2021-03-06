var $;

$ = this.jQuery;

$.fn.extend({
  confirmWithModal: function(options) {
    var defaults, do_confirm, handler, settings;
    if (options == null) {
      options = {};
    }
    defaults = {
      modal_class: '',
      title: 'Are you sure?',
      title_class: '',
      body: 'This action cannot be undone.',
      body_class: '',
      password: false,
      prompt: 'Type <strong>%s</strong> to continue:',
      footer_class: '',
      ok: 'Confirm',
      ok_class: 'btn btn-danger',
      cancel: 'Cancel',
      cancel_class: 'btn btn-default'
    };
    settings = $.extend({}, defaults, options);
    do_confirm = function($el) {
      var confirm_button, confirm_html, confirm_label, el_options, modal, option, password, _ref;
      el_options = $el.data('confirm');
      if (!el_options) {
        return true;
      }
      if ((typeof el_options === 'string') && (el_options.length > 0)) {
        return (((_ref = $.rails) != null ? _ref.confirm : void 0) || window.confirm).call(window, el_options);
      }
      option = function(name) {
        return el_options[name] || settings[name];
      };
      modal = $("<div class='modal fade'>\n  <div class='modal-dialog " + (option('modal_class')) + "'>\n    <div class='modal-content'>\n      <div class='modal-header'>\n        <button type='button' class='close' data-dismiss='modal' aria-label='Close'><span aria-hidden='true'>&times;</span></button>\n        <h4 data-confirm-title class=\"modal-title " + (option('title_class')) + "\"></h4>\n      </div>\n      <div class=\"modal-body " + (option('body_class')) + "\">\n        <p data-confirm-body></p>\n      </div>\n      <div data-confirm-footer class=\"modal-footer " + (option('footer_class')) + "\">\n        <a data-confirm-cancel class='" + (option('cancel_class')) + "'></a>\n      </div>\n    </div>\n  </div>\n</div>");
      confirm_button = $el.is('a') ? $el.clone() : $('<a/>');
      confirm_button.removeAttr('data-confirm').attr('class', option('ok_class')).html(option('ok')).on('click', function(e) {
        if ($(this).prop('disabled')) {
          return false;
        }
        $el.trigger('confirm.modal', e);
        if ($el.is('form, :input')) {
          return $el.closest('form').removeAttr('data-confirm').submit();
        }
      });
      modal.find('[data-confirm-title]').html(option('title'));
      modal.find('[data-confirm-body]').html(option('body'));
      modal.find('[data-confirm-cancel]').html(option('cancel')).on('click', function(e) {
        modal.modal('hide');
        return $el.trigger('cancel.modal', e);
      });
      modal.find('[data-confirm-footer]').append(confirm_button);
      if ((password = option('password'))) {
        confirm_label = (option('prompt')).replace('%s', password);
        confirm_html = "<div class='form-group'>\n  <label>\n    " + confirm_label + "\n    <input data-confirm-password class='form-control' type='text'/>\n  </label>\n</div>";
        modal.find('[data-confirm-body]').after($(confirm_html));
        modal.find('[data-confirm-password]').on('keyup', function(e) {
          var disabled;
          disabled = $(this).val() !== password;
          return confirm_button.toggleClass('disabled', disabled).prop('disabled', disabled);
        }).trigger('keyup');
      }
      modal.appendTo($('body')).modal().on('hidden.bs.modal', function(e) {
        return modal.remove();
      });
      return false;
    };
    if ($.rails) {
      $.rails.allowAction = function(link) {
        return do_confirm($(link));
      };
      return $(this);
    } else {
      handler = function(e) {
        if (!(do_confirm($(this)))) {
          e.preventDefault();
          return e.stopImmediatePropagation();
        }
      };
      return this.each(function() {
        var $el;
        $el = $(this);
        $el.on('click', 'a[data-confirm], :input[data-confirm]', handler);
        $el.on('submit', 'form[data-confirm]', handler);
        return $el;
      });
    }
  }
});
