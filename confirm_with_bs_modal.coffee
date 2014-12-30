# Examples using Rails’ link_to helper
#
# Basic usage:
#   = link_to 'Delete', foo_path(foo), method: :delete, data: { confirm: true }
#
# Customization of individual links/buttons via JSON in data-confirm:
#   = link_to 'Delete', foo_path(foo), method: :delete, data: {
#       confirm: {
#         title: 'You might want to think twice about this!',
#         body: 'If you click “Simon Says Delete” there will be no takebacks!',
#         ok: 'Simon Says Delete'
#       }
#     }
#
# Fall back to window.confirm() when confirm is a plain string:
#   = link_to 'Delete', foo_path(foo), method: :delete, confirm: 'Are you sure?'

$ = this.jQuery

$.fn.extend
  confirmWithModal: (options = {}) ->

    defaults =
      modal_class: ''
      title: 'Are you sure?'
      title_class: ''
      body: 'This action cannot be undone.'
      body_class: ''
      password: false
      prompt: 'Type <strong>%s</strong> to continue:'
      footer_class: ''
      ok: 'Confirm'
      ok_class: 'btn btn-danger'
      cancel: 'Cancel'
      cancel_class: 'btn btn-default'

    settings = $.extend {}, defaults, options

    do_confirm = ($el) ->

      el_options = $el.data('confirm')

      # The confirmation is actually triggered again when hitting "OK"
      # (or whatever) in the modal (since we clone the original link in),
      # but since we strip off the 'confirm' data attribute, we can tell
      # whether this is the first confirmation or a subsequent one.
      return true if !el_options

      if (typeof el_options == 'string') and (el_options.length > 0)
        return ($.rails?.confirm || window.confirm).call(window, el_options)

      option = (name) ->
        el_options[name] || settings[name]

      # TODO: allow caller to pass in a template (DOM element to clone?)
      modal = $("""
        <div class='modal fade'>
          <div class='modal-dialog #{option 'modal_class'}'>
            <div class='modal-content'>
              <div class='modal-header'>
                <button type='button' class='close' data-dismiss='modal' aria-label='Close'><span aria-hidden='true'>&times;</span></button>
                <h4 data-confirm-title class="modal-title #{option 'title_class'}"></h4>
              </div>
              <div class="modal-body #{option 'body_class'}">
                <p data-confirm-body></p>
              </div>
              <div data-confirm-footer class="modal-footer #{option 'footer_class'}">
                <a data-confirm-cancel class='#{option 'cancel_class'}'></a>
              </div>
            </div>
          </div>
        </div>
        """)

      confirm_button = if $el.is('a') then $el.clone() else $('<a/>')
      confirm_button
        .removeAttr('data-confirm')
        .attr('class', option 'ok_class')
        .html(option 'ok')
        .on 'click', (e) ->
          return false if $(this).prop('disabled')
          # TODO: Handlers of this event cannot stop the confirmation from
          # going through (e.g. chaining additional validation). Fix TBD.
          $el.trigger('confirm.modal', e)
          if $el.is('form, :input')
            $el
              .closest('form')
              .removeAttr('data-confirm')
              .submit()

      modal
        .find('[data-confirm-title]')
        .html(option 'title')
      modal
        .find('[data-confirm-body]')
        .html(option 'body')
      modal
        .find('[data-confirm-cancel]')
        .html(option 'cancel')
        .on 'click', (e) ->
          modal.modal('hide')
          $el.trigger('cancel.modal', e)
      modal
        .find('[data-confirm-footer]')
        .append(confirm_button)

      if (password = option 'password')
        confirm_label =
          (option 'prompt')
            .replace '%s', password
        confirm_html = """
          <div class='form-group'>
            <label>
              #{confirm_label}
              <input data-confirm-password class='form-control' type='text'/>
            </label>
          </div>
          """
        modal
          .find('[data-confirm-body]')
          .after($(confirm_html))
        modal
          .find('[data-confirm-password]')
          .on 'keyup', (e) ->
            disabled = $(this).val() != password
            confirm_button
              .toggleClass('disabled', disabled)
              .prop('disabled', disabled)
          .trigger('keyup')

      modal
        .appendTo($('body'))
        .modal()
        .on 'hidden.bs.modal', (e) ->
          modal.remove()

      return false

    if $.rails

      # We do NOT do the event binding if $.rails exists, because jquery_ujs
      # has already done it for us

      $.rails.allowAction = (link) -> do_confirm $(link)
      return $(this)

    else

      handler = (e) ->
        unless (do_confirm $(this))
          e.preventDefault()
          e.stopImmediatePropagation()

      return @each () ->
        $el = $(this)
        $el.on 'click', 'a[data-confirm], :input[data-confirm]', handler
        $el.on 'submit', 'form[data-confirm]', handler
        $el
