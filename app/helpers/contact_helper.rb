# Contains contact specific helper methods.
module ContactHelper

  # Returns select box options with all possible contact fields.
  def contact_field_options
    options_for_select Contact.select_box_friendly_fields
  end

  # Returns the contact value. If field is :emails or :websites, the value
  # is wrapped with <a> tag.
  def contact_value(val, field, html_options = {})
    case field
    when :emails
      mail_to val
    when :websites
      link_to val, (URI.parse(val).scheme.blank? ? "http://#{val}" : val)
    else
      val
    end
  end

  # Returns a delete contact button.
  #
  #   delete_contact_button('x', contact_url(contact), :emails, 'alf@aol.com')
  def contact_delete_button(txt, url, field, contact, html_options = {})
    form_tag url, method: :delete, class: 'button_to' do
      html = hidden_field_tag('contact[field]', field)
      html << hidden_field_tag('contact[contact]', contact)
      html << submit_tag(txt, html_options)
      html.html_safe
    end
  end
end
